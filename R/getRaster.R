#' Download Rasters produced by the Malaria Atlas Project
#'
#' \code{getRaster} downloads publicly available MAP rasters for a specified bounding box or shapefile.
#'
#' @param surface string containing code for desired raster(s), e.g. \code{c("rasterCode1", "rasterCode2")}. Defaults to "PfPR2-10" - the most recent global raster of PfPR 2-10.
#' @param shp SpatialPolygon(s) object of a shapefile to use when clipping downloaded rasters. (use either \code{shp} OR \code{view_bbox}; if neither is specified global raster is returned).
#' @param view_bbox  matrix containing bounding box for which rasters will be downloaded (as returned by sp::bbox()) (use either \code{shp} OR \code{view_bbox}; if neither is specified global raster is returned).
#' @param file_path string specifying the directory to which working files will be downloaded. Defaults to tempdir().
#' @param year string specifying the desired year to be downloded for multi-year/dynamic rasters.
#'
#' @return \code{getRaster} returns a RasterLayer (if only a single raster is queried) or RasterStack (for multiple rasters) for the specified extent.
#'
#' @examples
#' #Download PfPR2-10 Raster for Madagascar in 2016 and visualise this immediately.
#' \dontrun{
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#' MDG_PfPR2_10 <- getRaster(surface = "PfPR2-10", shp = MDG_shp, year = 2016)
#' autoplot_MAPraster(MDG_PfPR2_10)}
#'
#' #Download global raster of G6PD deficiency from Howes et al 2012.
#' \dontrun{G6PDd_global <- getRaster(surface = "G6PDd_allele_freq")
#' autoplot_MAPraster(G6PDd_global)}
#'
#' @seealso
#' \code{autoplot_MAPraster} custom function for quick mapping of rasters downloaded directly from MAP (\code{\link{autoplot_MAPraster}}).
#'
#' \code{as.MAPraster} method to turn RasterLayer/RasterStack objects into a 'MAPraster' object (data.frame) for easy plotting with ggplot and use with autoplot method below. (\code{\link{as.MAPraster}}).
#'
#' \code{autoplot} method for quick mapping of rasters downloaded from MAP and converted to MAPraster objects (\code{\link{autoplot.MAPraster}}).
#'
#'
#' @export getRaster
#'

getRaster <- function(surface = "PfPR2-10",
                      shp = NULL,
                      view_bbox = NULL,
                      file_path = tempdir(),
                      year = NULL){

  ## if bbox is not defined by user, use sp::bbox to define this from provided shapefile
  if(is.null(view_bbox)&!is.null(shp)){
  view_bbox <- sp::bbox(shp)
  }

  ## return all available rasters and use this df to define raster codes for specifed 'Surfaces'
  available_rasters <- listAllRaster(printed = FALSE)
  raster_code_list <- available_rasters$raster_code[match(surface, available_rasters$title)]

  ## create directory to which rasters will be downloaded
  rstdir <- file.path(file_path,"getRaster")
  file_tag <- paste(paste(substr(view_bbox,1,5),collapse = "_"),"_",Sys.Date(),sep="")
  dir.create(rstdir, showWarnings = FALSE)

  message("Downloading the following rasters: \n", paste(available_rasters$title[match(raster_code_list, available_rasters$raster_code)], collapse = "\n"))

  download_rst <- function(raster_code, view_bbox, target_path, year){

    if(!raster_code %in% c("africa-act-2000-2015","africa-inc-2000-2015","africa-irs-2000-2015","africa-itn-2000-2015","africa-pr-2000-2015")){
      year = NULL
    }

    rst_path <- file.path(target_path, paste(raster_code,"_",file_tag,".tiff",sep = ""))

    if(!is.null(view_bbox)){
      bbox_filter <- paste("&SUBSET=Long(",paste(view_bbox[1,],collapse = ","),")&SUBSET=Lat(",paste(view_bbox[2,],collapse = ","),")", sep = "")
    }else{
      bbox_filter <- ""
    }

    rst_URL <- paste("http://map-prod3.ndph.ox.ac.uk:8080/geoserver/Explorer/ows?service=WCS&version=2.0.1&request=GetCoverage&format=image/geotiff&coverageid=",raster_code,bbox_filter, sep = "")

    if(!is.null(year)){
      rst_URL <- paste(rst_URL, "&SUBSET=time(\"", year, "-01-01T00:00:00.000Z\")", sep = "")
    }

    r <- httr::GET(rst_URL, httr::write_disk(paste(rst_path), overwrite = TRUE))

    if(!"image/geotiff" %in% r$headers$`content-type`){
      file.remove(rst_path)
      stop("Raster download error - check ",raster_code, " surface is available for specified extent at map.ox.ac.uk/explorer.")
   message(rst_URL)
    }
  }

 #download rasters to designated file_path (tempdir as default)
  invisible(sapply(X = raster_code_list, FUN = download_rst, view_bbox = view_bbox, target_path = rstdir, year = year))

  #create vector of filenames for rasters downloaded in the current query
  newrst <- grep(paste(raster_code_list,"_",file_tag,collapse = "|", sep = ""),dir(rstdir), value = TRUE)

  name_rst <- function(rst){

    raster_codes <- lapply(X = gsub(paste("_",gsub("-","\\.",file_tag), sep = ""),"",names(rst)),
                           FUN = agrep,
                           x = unique(available_rasters$raster_code),
                           max.distance = 3, value = TRUE)

    names(rst) <- available_rasters$title[available_rasters$raster_code %in% raster_codes]
    return(rst)
  }

  # Return error if new rasters are not found
  if(length(newrst)==0){
    stop("Raster download error: check surface and/or view_bbox are specified correctly")
  # If only one new raster is found, read this in
  }else if(length(newrst)==1){
    rst_dl <- raster::raster(file.path(rstdir, newrst))
    rst_dl <- name_rst(rst_dl)
    if(!is.null(shp)){
      rst_dl <- raster::mask(rst_dl, shp)
    }
    return(rst_dl)

  #if more than one raster is found we want a raster stack - but only for rasters with the same resolution
  }else if(length(newrst)>1){
    #read in multiple rasters into a list
    rst_list <- lapply(file.path(rstdir, newrst), raster::raster)
    # create a dataframe with information on the resolution of each raster
    rst_list_index <- data.frame(cbind("resolution" = lapply(rst_list, raster::res),
                                       "raster_name" = lapply(rst_list, names),
                                       "res_id" = as.numeric(factor(as.character(lapply(rst_list, raster::res))))))

    #check whether more than one resolution is present in downloaded rasters
    #if only one resolution is present, create a raster stack of all downloaded rasters
    if(length(unique(rst_list_index$res_id))==1){
      rst_stk <- raster::stack(rst_list)
      if(!is.null(shp)){
        rst_stk <- raster::mask(rst_stk, shp)
        rst_stk <- name_rst(rst_stk)
      }
      return(rst_stk)
      #if not then we want to return a list of raster stacks - one for each resolution present in the index dataframe above.
    }else if (length(unique(rst_list_index$res_id))!=1){
      #create empty list

      #for each unique raster resolution create a raster stack and store this in stk_list

      stack_rst <- function(res_id){
        return(raster::stack(rst_list[rst_list_index$res_id==res_id]))
      }

      stk_list <- lapply(X = unique(rst_list_index$res_id), FUN = stack_rst)

      # mask each stack by shapefile if this is provided
      if(!is.null(shp)){
          stk_list<- lapply(X =stk_list, FUN = raster::mask, mask = shp)
        }

      # tidy names of rasters within the stacks within this list.

      stk_list <- lapply(X = stk_list, FUN = name_rst)

        return(stk_list)
        }
    }
  }


## TEST_SHP <- getShp(ISO = "MDG")
## TEST <- getRaster(shp = TEST_SHP)
## TEST2 <- getRaster(shp = TEST_SHP, surface = c("Pv Endemicity","Pf Spatial Limits"))
