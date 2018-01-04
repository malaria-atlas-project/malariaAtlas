#' Download Rasters produced by the Malaria Atlas Project
#'
#' \code{getRaster} downloads publicly available MAP rasters for a specific surface & year, clipped to a provided bounding box or shapefile.
#'
#' @param surface string containing code for desired raster(s), e.g. \code{c("rasterCode1", "rasterCode2")}. Defaults to "PfPR2-10" - the most recent global raster of PfPR 2-10.
#' @param shp SpatialPolygon(s) object of a shapefile to use when clipping downloaded rasters. (use either \code{shp} OR \code{view_bbox}; if neither is specified global raster is returned).
#' @param view_bbox  matrix containing bounding box for which rasters will be downloaded (as returned by sp::bbox()) (use either \code{shp} OR \code{view_bbox}; if neither is specified global raster is returned).
#' @param file_path string specifying the directory to which working files will be downloaded. Defaults to tempdir().
#' @param year default = \code{NULL} (use \code{NULL} for static rasters); for time-varying rasters: if downloading a single surface for one or more years, \code{year} should be a string specifying the desired year(s). if downloading more than one surface, use a list the same length as \code{surface}, providing the desired year-range for each time-varying surface in \code{surface} or \code{NULL} for static rasters.
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
#' \dontrun{G6PDd_global <- getRaster(surface = "G6PD Deficiency")
#' autoplot_MAPraster(G6PDd_global)}
#'
#' @seealso
#' (\code{\link{autoplot_MAPraster}}:
#'
#' to quickly visualise rasters downloded using /code{getRaster}.
#'
#' \code{\link{as.MAPraster}}:
#'
#' to convert RasterLayer/RasterStack objects into a 'MAPraster' object (data.frame) for easy plotting with ggplot.
#'
#' \code{\link{autoplot.MAPraster}}:
#'
#' to quickly visualise MAPraster objects created using /code{as.MAPraster}.
#'
#' @export getRaster

getRaster <- function(surface = "PfPR2-10",
                      shp = NULL,
                      view_bbox = NULL,
                      file_path = tempdir(),
                      year = NULL){

  ## if bbox is not defined by user, use sp::bbox to define this from provided shapefile
  if(is.null(view_bbox)&!is.null(shp)){
  view_bbox <- sp::bbox(shp)
  }

if(length(surface)>1){
  if(length(year) != length(surface)){
    stop("If downloading multiple different surfaces, 'year' must be a list of the same length as 'surface'.")
  }
}else if(length(surface) == 1){
  if(!inherits(year, "list")){
    year <- list(year)
  }
}
  ## download list of all available rasters and use this df to define raster codes for specifed 'surface's
  available_rasters <- listAllRaster(printed = FALSE)
  raster_code_list <- as.character(available_rasters$raster_code[match(surface, available_rasters$title)])

  message("Attempting to download the following rasters:")
  query_def <- data.frame()
  for(i in raster_code_list){
    df_i <- data.frame("raster_code" = i, "year" = year[[which(raster_code_list==i)]])
    code_y <- i

    for(y in 1:length(df_i$year)){
      if(is.na(df_i$year[y])){
        df_i$file_prefix[y] <- paste(code_y)
        df_i$raster_title[y] <- paste(available_rasters$title[available_rasters$raster_code==code_y])
      }else if(!is.na(y)){
        df_i$file_prefix[y] <- paste0(df_i$raster_code[y], "-", df_i$year[y])
        df_i$raster_title[y] <- paste0(available_rasters$title[available_rasters$raster_code==code_y],"-", df_i$year[y])
      }
    }
    query_def <- rbind(query_def, df_i)
    message(paste0("  - ",available_rasters$title[available_rasters$raster_code==i], ": ", paste0(year[[which(raster_code_list==i)]], collapse = ", ")))
  }

  # check whether specified years are available for specified rasters
 year_warnings = 0
  for(r in raster_code_list){
    for(y in unique(query_def$year[query_def$raster_code==r])){
      if(!is.na(y)){
      if(!y %in% seq(available_rasters$min_raster_year[available_rasters$raster_code==r&!is.na(available_rasters$min_raster_year)],
                     available_rasters$max_raster_year[available_rasters$raster_code==r&!is.na(available_rasters$max_raster_year)],
                     by = 1)){
        warning(paste0("Raster: \"",available_rasters$title[available_rasters$raster_code==r],"\" not available for specified year: ", y, "\n  - check available raster years using listAllRaster()."))
      year_warnings = year_warnings+1
      }
        }
    }
  }

 if(year_warnings>0){
   stop(year_warnings, " error(s) regarding surface-year combination, see warnings() and either try downloading surfaces separately or check 'year' specification matches specified 'surface' using listAllRaster().")
 }


  ## create directory to which rasters will be downloaded
  rstdir <- file.path(file_path,"getRaster")
  file_tag <- paste(paste(substr(view_bbox,1,5),collapse = "_"),"_",Sys.Date(),sep="")
  dir.create(rstdir, showWarnings = FALSE)


 #download rasters to designated file_path (tempdir as default)
  invisible(sapply(X = raster_code_list,
                   FUN = function(x){
                     year_i <- year[[which(raster_code_list==x)]]
                     download_rst(raster_code = x,
                                  view_bbox = view_bbox,
                                  target_path = rstdir,
                                  year = year_i,
                                  file_tag = file_tag)}))

  #create vector of filenames for rasters downloaded in the current query
  newrst <- sapply(1:length(query_def$raster_code), function(z) grep(pattern = paste(query_def$file_prefix[z]), x = dir(rstdir), value = TRUE))

  # Return error if new rasters are not found
  if(length(newrst)==0){
    stop("Raster download error: check surface and/or view_bbox are specified correctly")
  # If only one new raster is found, read this in
  }else if(length(newrst)==1){
    rst_dl <- raster::raster(file.path(rstdir, newrst))
    raster::NAvalue(rst_dl) <- -9999
    rst_dl <- name_rst(rst_dl, query_def=query_def)
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

      raster::NAvalue(rst_stk) <- -9999

      if(!is.null(shp)){
        rst_stk <- raster::mask(rst_stk, shp)
        rst_stk <- name_rst(rst_stk,query_def=query_def)
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

      for(i in 1:length(stk_list)){
          for(r in 1:length(names(stk_list[[i]]))){
            raster::NAvalue(stk_list[[i]][[r]]) <- -9999
          }
        }

      # mask each stack by shapefile if this is provided
      if(!is.null(shp)){
          stk_list<- lapply(X =stk_list, FUN = raster::mask, mask = shp)
        }

      # tidy names of rasters within the stacks within this list.

      stk_list <- lapply(X = stk_list, FUN = name_rst,query_def=query_def)

        return(stk_list)
        }
    }
  }

#Define a small function that downloads rasters from the MAP geoserver to a specifed location
download_rst <- function(raster_code, view_bbox, target_path, year, file_tag){
  available_rasters <- listAllRaster(printed = FALSE)
  download_warnings <- 0
  for(yy in year){
  year_current <- yy

   if(is.na(available_rasters$min_raster_year[available_rasters$raster_code==raster_code])|is.na(available_rasters$max_raster_year[available_rasters$raster_code==raster_code])){
     year_current <- NULL
   }

  if(!is.null(year_current)){
  year_tag <- paste0(year_current,"_")
  }else{
    year_tag <- ""
  }
    rst_path <- file.path(target_path, paste(raster_code,"-",year_tag,file_tag,".tiff",sep = ""))

    if(!is.null(view_bbox)){
      bbox_filter <- paste("&SUBSET=Long(",paste(view_bbox[1,],collapse = ","),")&SUBSET=Lat(",paste(view_bbox[2,],collapse = ","),")", sep = "")
    }else{
      bbox_filter <- ""
    }

    rst_URL <- paste("https://map-dev1.ndph.ox.ac.uk/geoserver/Explorer/ows?service=WCS&version=2.0.1&request=GetCoverage&format=image/geotiff&coverageid=",raster_code,bbox_filter, sep = "")

    if(!is.null(year_current)){
      rst_URL <- paste(rst_URL, "&SUBSET=time(\"", year_current, "-01-01T00:00:00.000Z\")", sep = "")
    }

    r <- httr::GET(rst_URL, httr::write_disk(paste(rst_path), overwrite = TRUE))

    if(!"image/geotiff" %in% r$headers$`content-type`){
      file.remove(rst_path)
      warning("Raster download error - check ",raster_code, " surface is available for specified extent at map.ox.ac.uk/explorer.")
      message(rst_URL)
      download_warnings <- download_warnings+1
    }else{
      if(!is.null(year_current)){
      message("Downloaded ", raster_code, " for ", year_current,".")
      }else if (is.null(year_current)){
        message("Downloaded ", raster_code,".")
      }
    }

  }

  if(download_warnings>0){
    stop(download_warnings, " Raster download error(s) check warnings() for details.")
  }

}

#Define a small function that renames a raster object with a more useful name
name_rst <- function(rst, query_def){

  names(rst) <- query_def$raster_title
  return(rst)
}

# TEST_SHP <- getShp(ISO = "MDG")
# TEST <- getRaster(shp = TEST_SHP)
# TEST2 <- getRaster(shp = TEST_SHP, surface = c("Pv Endemicity","Pf Spatial Limits"))
