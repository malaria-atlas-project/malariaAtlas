getRaster <- function(surface = "PfPR2-10", shp = NULL, view_bbox = NULL, file_path = tempdir(), format = "raster", year = NULL){

  ## if bbox is not defined by user, use sp::bbox to define this from provided shapefile
  if(is.null(view_bbox)&!is.null(shp)){
  view_bbox <- sp::bbox(shp)
  }

  ## return all available rasters and use this df to define raster codes for specifed 'Surfaces'
  available_rasters <- listAllRaster(printed = FALSE)
  raster_code_list <- available_rasters$raster_code[match(surface, available_rasters$title)]

  ## create directory to which rasters will be downloaded
  rstdir <- file.path(file_path,"getRaster")
  dir.create(rstdir, showWarnings = FALSE)

  message("Downloading the following rasters: \n", paste(available_rasters$title[match(raster_code_list, available_rasters$raster_code)], collapse = "\n"))

  download_rst <- function(raster_code, view_bbox, target_path, year){

    if(raster_code %in% SPECIFY_LIST_HERE){
      year = NULL
    }

    rst_path <- file.path(target_path, paste(available_rasters$title[match(raster_code,available_rasters$raster_code)],"_",paste(substr(view_bbox,1,5),collapse = "_"),"_",Sys.Date(),".tiff",sep = ""))
    rst_URL <- paste("http://map-prod3.ndph.ox.ac.uk:8080/geoserver/Explorer/ows?service=WCS&version=2.0.1&request=GetCoverage&format=image/geotiff&coverageid=",raster_code,"&SUBSET=Long(",paste(view_bbox[1,],collapse = ","),")&SUBSET=Lat(",paste(view_bbox[2,],collapse = ","),")", sep = "")

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
  newrst <- grep(paste(surface,"_",paste(substr(view_bbox,1,5),collapse = "_"),"_",Sys.Date(),collapse = "|", sep = ""),dir(rstdir), value = TRUE)

  # Return error if new rasters are not found
  if(length(newrst)==0){
    stop("Raster download error: check surface and/or view_bbox are specified correctly")
  # If only one new raster is found, read this in
  }else if(length(newrst)==1){
    rst_dl <- raster::raster(file.path(rstdir, newrst))
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
      rst_stk <- stack(rst_list)
      if(!is.null(shp)){
        rst_stk <- raster::mask(rst_stk, shp)
        names(rst_stk) <- lapply(X = sub("_.*","",names(rst_stk)), FUN = agrep, x = surface, value = TRUE, ignore.case = TRUE)
      }
      return(rst_stk)
      #if not then we want to return a list of raster stacks - one for each resolution present in the index dataframe above.
    }else if (length(unique(rst_list_index$res_id))!=1){
      #create empty list
      stk_list <- list()

      #for each unique raster resolution create a raster stack and store this in stk_list
      for(i in 1:length(unique(rst_list_index$res_id))){
        stk_list[i] <- stack(rst_list[rst_list_index$res_id == i])
      }
        if(!is.null(shp)){
          stk_list<- lapply(X =stk_list, FUN = raster::mask, mask = shp)
        }

      raster_name <- function(stack){
        names(stack) <- lapply(X = sub("_.*","",names(stack)), FUN = agrep, x = surface, value = TRUE, ignore.case = TRUE)
        return(stack)
      }

      stk_list <- lapply(stk_list, FUN = raster_name)

        return(stk_list)
        }
    }
  }


## TEST_SHP <- getShp(ISO = "MDG")
## TEST <- getRaster(shp = TEST_SHP)
## TEST2 <- getRaster(shp = TEST_SHP, surface = c("Pv Endemicity","Pf Spatial Limits"))
