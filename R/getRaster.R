#' Download Rasters produced by the Malaria Atlas Project
#'
#' \code{getRaster} downloads publicly available MAP rasters for a specific surface & year, clipped to a provided bounding box or shapefile.
#'
#' @param dataset_id A character string specifying the dataset ID(s) of one or more rasters. These dataset ids can be found in the data.frame returned by listRaster, in the dataset_id column e.g. c('Malaria__202206_Global_Pf_Mortality_Count', 'Malaria__202206_Global_Pf_Parasite_Rate')
#' @param surface deprecated argument. Please remove it from your code.
#' @param shp SpatialPolygon(s) object of a shapefile to use when clipping downloaded rasters. (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param extent  2x2 matrix specifying the spatial extent within which raster data is desired, as returned by sf::st_bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))) (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param file_path string specifying the directory to which raster files will be downloaded, if you want to download them. If none given, rasters will not be saved to files. 
#' @param year default = \code{rep(NA, length(dataset_id))} (use \code{NA} for static rasters); for time-varying rasters: if downloading a single surface for one or more years, \code{year} should be a string specifying the desired year(s). if downloading more than one surface, use a list the same length as \code{dataset_id}, providing the desired year-range for each time-varying surface in \code{dataset_id} or \code{NA} for static rasters.
#' @param vector_year deprecated argument. Please remove it from your code.
#'

#' @return \code{getRaster} returns a SpatRaster for the specified extent. Or a SpatRasterCollection if the two rasters are incompatible in terms of projection/extent/resolution
#'
#' @examples
#' # Download PfPR2-10 Raster for Madagascar and visualise this immediately.
#' \dontrun{
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#' MDG_PfPR2_10 <- getRaster(dataset_id = "Malaria__202206_Global_Pf_Parasite_Rate", shp = MDG_shp)
#' autoplot(MDG_PfPR2_10)
#' }
#'
#' @seealso
#' \code{\link{autoplot_MAPraster}}
#'
#' to quickly visualise rasters downloded using \code{\link{getRaster}}.
#'
#' \code{\link{as.MAPraster}}
#'
#' to convert RasterLayer/RasterStack objects into a 'MAPraster' object (data.frame) for
#'   easy plotting with ggplot.
#'
#' \code{\link{autoplot.MAPraster}}
#'
#' to quickly visualise MAPraster objects created using /code{as.MAPraster}.
#'
#' @export getRaster

getRaster <- function(dataset_id = NULL,
                      surface = NULL,
                      shp = NULL,
                      extent = NULL,
                      file_path = NULL,
                      year = NULL, 
                      vector_year= NULL) {
  
  #Parameter checking
  
  availableRasters <- suppressMessages(listRaster(printed = FALSE))
  
  if (!is.null(surface)) {
    lifecycle::deprecate_warn("1.6.0", "getRaster(surface)", details = "The argument 'surface' has been deprecated. It will be removed in the next version. Please use dataset_id to specify the raster instead.")
  }
  
  if (!is.null(vector_year)) {
    lifecycle::deprecate_warn("1.6.0", "getRaster(vector_year)", details = "The argument 'vector_year' has been deprecated. It will be removed in the next version. You can now just use the year parameter instead to specify the years for any type of raster.")
  }
  
  if(is.null(dataset_id)) {
    if(!is.null(surface)) {
      dataset_id = lapply(surface, function(individual_surface){
        id <- getRasterDatasetIdFromSurface(availableRasters, individual_surface)
        return(id)
      })
    } else {
      stop('Please provide a value for dataset_id. Options for this variable can be found by running listRaster() and looking in the dataset_id column.')
    }
  } else {
    diff <- setdiff(dataset_id, availableRasters$dataset_id)
    intersect <- intersect(dataset_id, availableRasters$dataset_id)
    if(length(diff) > 0) {
      if(length(intersect) == 0) {
        stop(paste0('All value(s) provided for dataset_id are not valid. All values must be from dataset_id column of listRaster()'))
      } else {
        warning(paste0('Following value(s) provided for dataset_id are not valid and so will be ignored: ', diff, ' . All values must be from dataset_id column of listRaster()'))
        dataset_id <- intersect
      }
    }
  }
  
  ## if extent is not defined by user, use sf::st_bbox to define this from provided shapefile
  if (is.null(extent) & !is.null(shp)) {
    extent <- matrix(unlist(sf::st_bbox(shp)), ncol = 2)
  }
  
  if(is.null(year)) {
    year <- as.list(rep(NA, length(dataset_id)))
  }
  
  if (length(dataset_id) > 1) {
    if (length(year) != length(dataset_id)) {
      stop(
        "If downloading multiple different rasters, 'year' must be a list of the same length as 'dataset_id'."
      )
    }
    
  } else if (length(dataset_id) == 1) {
    if (!inherits(year, "list")) {
      year <- list(year)
    }
  }
  
  if (!is.null(shp)) {
    shp <- terra::vect(shp)
  }
  
  message("Checking if the following Surface-Year combinations are available to download:")
  message(paste0("\n    ", "DATASET ID  ", "YEAR "))
  query_def <- data.frame()
  for (id in dataset_id) {
    df_i <-
      data.frame("dataset_id" = id, "year" = year[[which(dataset_id == id)]])
    
    for (y in 1:length(df_i$year)) {
      if (is.na(df_i$year[y])) {
        df_i$file_prefix[y] <- paste0(id, "_latest_")
        df_i$raster_title[y] <-
          paste(availableRasters$title[availableRasters$dataset_id == id])
      } else if (!is.na(y)) {
        df_i$file_prefix[y] <-
          paste0(df_i$dataset_id[y], "-", df_i$year[y])
        df_i$raster_title[y] <-
          paste0(availableRasters$title[availableRasters$dataset_id == id], "-", df_i$year[y])
      }
    }
    query_def <- rbind(query_def, df_i)
    current_year <- year[[which(dataset_id == id)]]
    
    if (all(is.na(current_year))) {
      message(paste0("  - ", id, ":  DEFAULT "))
    } else{
      message(paste0(
        "  - ",
        id,
        ":  ",
        paste0(current_year, collapse = ", ")
      ))
    }
  }
  message("")
  
  
  
  
  # check whether specified years are available for specified rasters
  year_warnings <- 0
  for (r in dataset_id) {
    for (y in unique(query_def$year[query_def$dataset_id == r])) {
      if (!is.na(y)) {
        if (!y %in% seq(
          availableRasters$min_raster_year[availableRasters$dataset_id == r &
                                           !is.na(availableRasters$min_raster_year)],
          availableRasters$max_raster_year[availableRasters$dataset_id ==
                                           r & !is.na(availableRasters$max_raster_year)],
          by = 1
        )) {
          warning(
            paste0(
              "Raster: \"",
              availableRasters$title[availableRasters$dataset_id == r],
              "\" not available for specified year: ",
              y,
              "\n  - check available raster years using listRaster()."
            )
          )
          year_warnings = year_warnings + 1
        }
      }
    }
  }
  
  if (year_warnings > 0) {
    message <- "Specified surfaces are not available for all requested years. \n Try downloading surfaces separately or double-check availability of 'dataset_id'-'year' combinations using listRaster()\n see warnings() for more info."
    
    message(message)
    return(message)
  }
  
  if(!is.null(file_path)) {
    ## create directory to which rasters will be downloaded
    rstdir <- file.path(file_path, "getRaster")
    dir.create(rstdir, showWarnings = FALSE)
  }

  file_tag <-
    paste(paste(substr(extent, 1, 5), collapse = "_"),
          "_",
          gsub("-", "_", Sys.Date()),
          sep = "")
  
  query_def$file_name <-
    gsub("-", ".", paste0(query_def$file_prefix, file_tag))
  
  #download rasters to designated file_path (tempdir as default)
  rasters <- sapply(
    X = 1:nrow(query_def),
    FUN = function(x) {
      download_rst(
        dataset_id = query_def$dataset_id[x],
        extent = extent,
        year = query_def$year[x],
        file_name = query_def$file_name[x],
        file_path = file_path
      )
    }
  )
  
  # Return error if new rasters are not found
  if (length(rasters) == 0) {
    message <- "Raster download error: check dataset_id and/or extent are specified correctly"
    message(message)
    return(message)
    # If only one new raster is found, read this in
  } else if (length(rasters) == 1) {
    raster <- rasters[[1]]
    terra::NAflag(raster) <- -9999
    names(raster) <- query_def$raster_title
    if (!is.null(shp)) {
      raster <- terra::mask(raster, shp)
    }
    return(raster)
    
    #if more than one raster is found we want a raster stack - but only for rasters with the same resolution
  } else if (length(rasters) > 1) {
    # create a dataframe with information on the resolution of each raster
    rasters_index <-
      data.frame(cbind(
        "resolution" = lapply(rasters, terra::res),
        "raster_name" = lapply(rasters, names),
        "res_id" = as.numeric(factor(as.character(
          lapply(rasters, function(x) round(terra::res(x), 6))
        )))
      ))
    
    #check whether more than one resolution is present in downloaded rasters
    #if only one resolution is present, create a raster stack of all downloaded rasters
    if (length(unique(rasters_index$res_id)) == 1) {
      rst_stk <- terra::rast(rasters)
      
      terra::NAflag(rst_stk) <- -9999
      
      if (!is.null(shp)) {
        rst_stk <- terra::mask(rst_stk, shp)
      }
      
      names(rst_stk) <- query_def$raster_title
      return(rst_stk)
      #if not then we want to return a list of raster stacks - one for each resolution present in the index dataframe above.
    } else if (length(unique(rasters_index$res_id)) != 1) {
      #for each unique raster resolution create a raster stack and store this in stk_list
      
      stack_rst <- function(res_id) {
        return(terra::rast(rasters[rasters_index$res_id == res_id]))
      }
      
      stk_list <-
        lapply(X = unique(rasters_index$res_id), FUN = stack_rst)
      
      for (i in 1:length(stk_list)) {
        for (r in 1:length(names(stk_list[[i]]))) {
          terra::NAflag(stk_list[[i]][[r]]) <- -9999
        }
      }
      
      # mask each stack by shapefile if this is provided
      if (!is.null(shp)) {
        stk_list <- lapply(X = stk_list,
                           FUN = terra::mask,
                           mask = shp)
      }
      
      # tidy names of rasters within the stacks within this list.
      for (i in 1:length(stk_list)) {
        for (ii in 1:length(stk_list[i])) {
          names(stk_list[i][[ii]]) <-
            query_def$raster_title[query_def$file_name %in% names(stk_list[i][[ii]])]
        }
      }
      return(terra::sprc(stk_list))
    }
  }
}

#Define a small function that downloads rasters from the MAP geoserver to a specifed location
download_rst <-
  function(dataset_id,
           extent,
           year,
           file_name, 
           file_path) {
    
    wcs_client <- get_wcs_client_from_raster_id(dataset_id)
    
    if (!is.na(year) & !is.null(year)) {
      time <- lapply(year, lubridate::make_date)
      time <- lapply(time, format, format = '%Y-%m-%dT%H:%M:%S')
      time_filter <- paste0('time=', time)
      raster_name <- paste0(dataset_id, '_', year)
    } else {
      time_filter <- NULL
      raster_name <- dataset_id
    }
    
    if (!is.null(time_filter)) {
      workspace <- get_workspace_and_version_from_coverage_id(dataset_id)[[1]]
      if (workspace == "Explorer") { # datetime is set up different between the old Explorer workspace and the new ones.
        spat_raster <- wcs_client$getCoverage(identifier = dataset_id, bbox = extent, cql_filter = time_filter)
      } else {
        spat_raster <- wcs_client$getCoverage(identifier = dataset_id, bbox = extent, time = time)
      }
      
    } else {
      spat_raster <- wcs_client$getCoverage(identifier = dataset_id, bbox = extent)
    }
    
    
    if(!is.null(file_path)) {
      rst_path <- file.path(file_path, paste0(file_name, ".tiff"))
      terra::writeRaster(spat_raster, rst_path,  filetype = "GTiff", overwrite=FALSE)
    }
    
    names(spat_raster) <- file_name
    
    return(spat_raster)
  }

