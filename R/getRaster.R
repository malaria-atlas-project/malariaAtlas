#' Download Rasters produced by the Malaria Atlas Project
#'
#' \code{getRaster} downloads publicly available MAP rasters for a specific surface & year, clipped to a provided bounding box or shapefile.
#'
#' @param surface string containing 'title' of desired raster(s), e.g. \code{c("raster1", "raster2")}. Defaults to "PfPR2-10" - the most recent global raster of PfPR 2-10.
#' Check \code{\link{listRaster}} to find titles of available rasters.
#' @param shp SpatialPolygon(s) object of a shapefile to use when clipping downloaded rasters. (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param extent  2x2 matrix specifying the spatial extent within which raster data is desired, as returned by sp::bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))) (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param file_path string specifying the directory to which working files will be downloaded. Defaults to tempdir().
#' @param year default = \code{rep(NA, length(surface))} (use \code{NA} for static rasters); for time-varying rasters: if downloading a single surface for one or more years, \code{year} should be a string specifying the desired year(s). if downloading more than one surface, use a list the same length as \code{surface}, providing the desired year-range for each time-varying surface in \code{surface} or \code{NA} for static rasters.
#' @param vector_year default = \code{NULL} for vector occurence rasters, the desired version as prefixed in raster_code returned using available_rasters. By default (\code{NULL}) returns the most recent raster version )
#'
#' @return \code{getRaster} returns a RasterLayer (if only a single raster is queried) or RasterStack (for multiple rasters) for the specified extent.
#'
#' @examples
#' # Download PfPR2-10 Raster for Madagascar in 2015 and visualise this immediately.
#' \donttest{
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#' MDG_PfPR2_10 <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2015)
#' autoplot_MAPraster(MDG_PfPR2_10)
#'
#' # Download global raster of G6PD deficiency from Howes et al 2012.
#' G6PDd_global <- getRaster(surface = "G6PD Deficiency Allele Frequency")
#' autoplot_MAPraster(G6PDd_global)
#'
#' # Download a temporal raster by range
#' MDG_PfPR2_10_range <- getRaster(surface = "Plasmodium falciparum PR2-10", 
#'                                 shp = MDG_shp, year = 2012:2015)
#'
#' # Download a mix of rasters
#' MDG_rasters <- getRaster(surface = c("Plasmodium falciparum PR2-10", 
#'                                      'Plasmodium falciparum Incidence', 
#'                                      'Plasmodium falciparum Support'),
#'                          shp = MDG_shp, year = list(2009:2012, 2005:2007, NA))
#' p <- autoplot_MAPraster(MDG_rasters)
#'
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

getRaster <- function(surface = "Plasmodium falciparum PR2-10",
                      shp = NULL,
                      extent = NULL,
                      file_path = tempdir(),
                      year = as.list(rep(NA, length(surface))), 
                      vector_year= NULL) {
  ## if extent is not defined by user, use sp::bbox to define this from provided shapefile
  if (is.null(extent) & !is.null(shp)) {
    extent <- sp::bbox(shp)
  }
  
  if (length(surface) > 1) {
    if (length(year) != length(surface)) {
      stop(
        "If downloading multiple different surfaces, 'year' must be a list of the same length as 'surface'."
      )
    }
    
  } else if (length(surface) == 1) {
    if (!inherits(year, "list")) {
      year <- list(year)
    }
  }
  
  ## download list of all available rasters and use this df to define raster codes for specifed 'surface's
  available_rasters <- listRaster(printed = FALSE)
  
  raster_code_list <- character()
  for(s in surface){
    raster_code_list <- c(raster_code_list, as.character(available_rasters$raster_code[available_rasters$title%in%s]))
  }
  
  
  if(length(raster_code_list)!=length(surface)&any(grepl("anoph", raster_code_list, ignore.case = T))){
    
  for(i in surface){
    if(length(as.character(available_rasters$raster_code[available_rasters$title%in%i]))>1){
      raster_code_list_i <- as.character(available_rasters$raster_code[available_rasters$title%in%i])
      
      idx <- raster_code_list %in% raster_code_list_i
      
      if(is.null(vector_year)){
      vector_year <- max(as.numeric(substr(raster_code_list_i, 1, 4)))
      }
      
       raster_code_list <- c(raster_code_list[!idx], grep(vector_year, raster_code_list, value = TRUE))
      
    }
    
  }
    
  }

  if (anyNA(raster_code_list)) {
    stop(
      "The following surfaces have been incorrectly specified, use listRaster to confirm spelling of raster 'title':\n",
      paste("  -", surface[is.na(raster_code_list)], collapse = "\n")
    )  
  } else if( length(raster_code_list) == 0 ) {
    stop(
      "The following surfaces have been incorrectly specified, use listRaster to confirm spelling of raster 'title':\n",
      paste("  -", surface, collapse = "\n")
    )  
    
  } else {
    message("All specified surfaces are available to download.")
  }

  message("Checking if the following Surface-Year combinations are available to download:")
  message(paste0("\n    ", "RASTER CODE  ", "YEAR "))
  query_def <- data.frame()
  for (i in raster_code_list) {
    df_i <-
      data.frame("raster_code" = i, "year" = year[[which(raster_code_list == i)]])
    code_y <- i
    
    for (y in 1:length(df_i$year)) {
      if (is.na(df_i$year[y])) {
        df_i$file_prefix[y] <- paste0(code_y, "_latest_")
        df_i$raster_title[y] <-
          paste(available_rasters$title[available_rasters$raster_code == code_y])
      } else if (!is.na(y)) {
        df_i$file_prefix[y] <-
          paste0(df_i$raster_code[y], "-", df_i$year[y])
        df_i$raster_title[y] <-
          paste0(available_rasters$title[available_rasters$raster_code == code_y], "-", df_i$year[y])
      }
    }
    query_def <- rbind(query_def, df_i)
    current_title <-
      available_rasters$title[available_rasters$raster_code == i]
    current_year <- year[[which(raster_code_list == i)]]
    
    if (all(is.na(current_year))) {
      message(paste0("  - ", current_title, ":  DEFAULT "))
    } else{
      message(paste0(
        "  - ",
        current_title,
        ":  ",
        paste0(current_year, collapse = ", ")
      ))
    }
  }
  message("")
  

    
  
  # check whether specified years are available for specified rasters
  year_warnings <- 0
  for (r in raster_code_list) {
    for (y in unique(query_def$year[query_def$raster_code == r])) {
      if (!is.na(y)) {
        if (!y %in% seq(
          available_rasters$min_raster_year[available_rasters$raster_code == r &
                                            !is.na(available_rasters$min_raster_year)],
          available_rasters$max_raster_year[available_rasters$raster_code ==
                                            r & !is.na(available_rasters$max_raster_year)],
          by = 1
        )) {
          warning(
            paste0(
              "Raster: \"",
              available_rasters$title[available_rasters$raster_code == r],
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
    stop(
      "Specified surfaces are not available for all requested years,. \n Try downloading surfaces separately or double-check availability of 'surface'-'year' combinations using listRaster()\n see warnings() for more info."
    )
  }
  
  ## create directory to which rasters will be downloaded
  rstdir <- file.path(file_path, "getRaster")
  file_tag <-
    paste(paste(substr(extent, 1, 5), collapse = "_"),
          "_",
          gsub("-", "_", Sys.Date()),
          sep = "")
  dir.create(rstdir, showWarnings = FALSE)
  
  query_def$file_name <-
    gsub("-", ".", paste0(query_def$file_prefix, file_tag))
  
  #download rasters to designated file_path (tempdir as default)
  invisible(sapply(
    X = 1:nrow(query_def),
    FUN = function(x) {
      download_rst(
        raster_code = query_def$raster_code[x],
        extent = extent,
        target_path = rstdir,
        year = query_def$year[x],
        file_name = query_def$file_name[x]
      )
    }
  ))
  
  #create vector of filenames for rasters downloaded in the current query
  newrst <-
    unname(sapply(query_def$file_name, function(p)
      grep(
        pattern = p,
        x = dir(rstdir),
        value = TRUE
      )))
  
  # Return error if new rasters are not found
  if (length(newrst) == 0) {
    stop("Raster download error: check surface and/or extent are specified correctly")
    # If only one new raster is found, read this in
  } else if (length(newrst) == 1) {
    rst_dl <- raster::raster(file.path(rstdir, newrst))
    raster::NAvalue(rst_dl) <- -9999
    names(rst_dl) <- query_def$raster_title
    if (!is.null(shp)) {
      rst_dl <- raster::mask(rst_dl, shp)
    }
    return(rst_dl)
    
    #if more than one raster is found we want a raster stack - but only for rasters with the same resolution
  } else if (length(newrst) > 1) {
    #read in multiple rasters into a list
    rst_list <- lapply(file.path(rstdir, newrst), raster::raster)
    # create a dataframe with information on the resolution of each raster
    rst_list_index <-
      data.frame(cbind(
        "resolution" = lapply(rst_list, raster::res),
        "raster_name" = lapply(rst_list, names),
        "res_id" = as.numeric(factor(as.character(
          lapply(rst_list, function(x) round(raster::res(x), 6))
        )))
      ))
    
    #check whether more than one resolution is present in downloaded rasters
    #if only one resolution is present, create a raster stack of all downloaded rasters
    if (length(unique(rst_list_index$res_id)) == 1) {
      rst_stk <- raster::stack(rst_list)
      
      raster::NAvalue(rst_stk) <- -9999
      
      if (!is.null(shp)) {
        rst_stk <- raster::mask(rst_stk, shp)
      }
      
      names(rst_stk) <- query_def$raster_title
      return(rst_stk)
      #if not then we want to return a list of raster stacks - one for each resolution present in the index dataframe above.
    } else if (length(unique(rst_list_index$res_id)) != 1) {
      #for each unique raster resolution create a raster stack and store this in stk_list
      
      stack_rst <- function(res_id) {
        return(raster::stack(rst_list[rst_list_index$res_id == res_id]))
      }
      
      stk_list <-
        lapply(X = unique(rst_list_index$res_id), FUN = stack_rst)
      
      for (i in 1:length(stk_list)) {
        for (r in 1:length(names(stk_list[[i]]))) {
          raster::NAvalue(stk_list[[i]][[r]]) <- -9999
        }
      }
      
      # mask each stack by shapefile if this is provided
      if (!is.null(shp)) {
        stk_list <- lapply(X = stk_list,
                           FUN = raster::mask,
                           mask = shp)
      }
      
      # tidy names of rasters within the stacks within this list.
      for (i in 1:length(stk_list)) {
        for (ii in 1:length(stk_list[i])) {
          names(stk_list[i][[ii]]) <-
            query_def$raster_title[paste0('X', query_def$file_name) %in% names(stk_list[i][[ii]])]
        }
      }
      
      return(stk_list)
    }
  }
}

#Define a small function that downloads rasters from the MAP geoserver to a specifed location
download_rst <-
  function(raster_code,
           extent,
           target_path,
           year,
           file_name) {
    available_rasters <- listRaster(printed = FALSE)
    download_warnings <- 0
    
    if (is.na(available_rasters$min_raster_year[available_rasters$raster_code ==
                                                raster_code]) |
        is.na(available_rasters$max_raster_year[available_rasters$raster_code ==
                                                raster_code])) {
      year <- NA
    }
    
    if (is.na(year)) {
      year <-
        available_rasters$max_raster_year[available_rasters$raster_code == raster_code]
    }
    
    if (any(grepl(file_name, dir(target_path)))) {
      message(
        "Pre-downloaded raster with identical query parameters loaded ('",
        grep(file_name, dir(target_path), value = T),
        "')"
      )
    } else {
      rst_path <- file.path(target_path, paste0(file_name, ".tiff"))
      
      if (!is.null(extent)) {
        bbox_filter <-
          paste(
            "&SUBSET=Long(",
            paste(extent[1, ], collapse = ","),
            ")&SUBSET=Lat(",
            paste(extent[2, ], collapse = ","),
            ")",
            sep = ""
          )
      } else{
        bbox_filter <- ""
      }
      
      
      raster_code_URL <- curl::curl_escape(raster_code)
      rst_URL <-
        paste(
          "https://map.ox.ac.uk/geoserver/Explorer/ows?service=WCS&version=2.0.1&request=GetCoverage&format=image/geotiff&coverageid=",
          raster_code_URL,
          bbox_filter,
          sep = ""
        )
      
      if (!is.na(year)) {
        rst_URL <-
          paste(rst_URL,
                "&SUBSET=time(\"",
                year,
                "-01-01T00:00:00.000Z\")",
                sep = "")
      }
      
      r <-
        httr::GET(utils::URLencode(rst_URL), httr::write_disk(rst_path, overwrite = TRUE))
      
      if (!"image/geotiff" %in% r$headers$`content-type`) {
        file.remove(rst_path)
        warning(
          "Raster download error - check ",
          raster_code,
          " surface is available for specified extent at map.ox.ac.uk/explorer."
        )
        message(rst_URL)
        download_warnings <- download_warnings + 1
      } else{
        if (!is.na(year)) {
          message("Downloaded ", raster_code, " for ", year, ".")
        } else if (is.na(year)) {
          message("Downloaded ", raster_code, ".")
        }
      }
      
    }
    
    if (download_warnings > 0) {
      stop(download_warnings,
           " Raster download error(s) check warnings() for details.")
    }
    
  }


# TEST_SHP <- getShp(ISO = "MDG", admin_level = "admin0")
# TEST_single_raster <- getRaster(shp = TEST_SHP)
# TEST_same_res <- getRaster(shp = TEST_SHP, surface = c("Pv Endemicity", "PfPR2-10"))
# TEST_different_res <- getRaster(shp = TEST_SHP, surface = c("Pv Endemicity","Pv Support"))
