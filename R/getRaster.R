#' Download Rasters produced by the Malaria Atlas Project
#'
#' \code{getRaster} downloads publicly available MAP rasters for a specific surface & year, clipped to a provided bounding box or shapefile.
#'
#' @param dataset_id A character string specifying the dataset ID(s) of one or more rasters. These dataset ids can be found in the data.frame returned by listRaster, in the dataset_id column e.g. c('Malaria__202206_Global_Pf_Mortality_Count', 'Malaria__202206_Global_Pf_Parasite_Rate')
#' @param surface deprecated argument. Please remove it from your code.
#' @param shp SpatialPolygon(s) object of a shapefile to use when clipping downloaded rasters. (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param extent  2x2 matrix specifying the spatial extent within which raster data is desired, as returned by sf::st_bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))) (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param file_path string specifying the directory to which raster files will be downloaded, if you want to download them. If none given, rasters will not be saved to files. 
#' @param year default = \code{rep(NA, length(dataset_id))} (use \code{NA} for static rasters); for time-varying rasters: if downloading a single surface for one or more years, \code{year} should be a string specifying the desired year(s). if downloading more than one surface, use a list the same length as \code{surface}, providing the desired year-range for each time-varying surface in \code{surface} or \code{NA} for static rasters.
#' @param vector_year deprecated argument. Please remove it from your code.
#'

#' @return \code{getRaster} returns a SpatRaster for the specified extent. Or a SpatRasterCollection if the two rasters are incompatible in terms of projection/extent/resolution
#'
#' @examples
#' # Download PfPR2-10 Raster for Madagascar and visualise this immediately.
#' \donttest{
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
                      year = as.list(rep(NA, length(dataset_id))), 
                      vector_year= NULL) {
  
  if (!is.null(surface)) {
    lifecycle::deprecate_warn("1.5.0", "getRaster(surface)", details = "The argument 'surface' has been deprecated. It will be removed in the next version. Please use dataset_id to specify the raster instead.")
  }
  
  if (!is.null(surface)) {
    lifecycle::deprecate_warn("1.5.0", "getRaster(vector_year)", details = "The argument 'vector_year' has been deprecated. It will be removed in the next version. You can now just use the year parameter instead to specify the years for any type of raster.")
  }
  
  if(is.null(dataset_id)) {
    if(!is.null(surface)) {
      raster_list <- listRaster(printed = FALSE)
      dataset_id = future.apply::future_lapply(surface, function(individual_surface){
        id <- getRasterDatasetIdFromSurface(raster_list, individual_surface)
        return(id)
      })
    } else {
      stop('Please provide a value for dataset_id. Options for this variable can be found by running listRaster() and looking in the dataset_id column.')
    }
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
  
  ## if extent is not defined by user, use sf::st_bbox to define this from provided shapefile
  if (is.null(extent) & !is.null(shp)) {
    extent <- matrix(unlist(sf::st_bbox(shp)), ncol = 2)
  }
  
  if(!is.null(file_path)) {
    rstdir <- file.path(file_path, "getRaster")
    
    dir.create(rstdir, showWarnings = FALSE)
    
    file_tag <-
      paste(paste(substr(extent, 1, 5), collapse = "_"),
            "_",
            gsub("-", "_", Sys.Date()),
            sep = "")
  }
  
  spat_rasters_by_dataset_id <- mapply(function(individual_dataset_id, year_range){
    
    coverageSummary <- get_wcs_coverage_summary_from_raster_id(individual_dataset_id)
    
    spat_rasters_by_year <- future.apply::future_lapply(year_range, function(individual_year){ 

      if(!is.null(file_path)) {
        
        if(!is.na(individual_year)) {
          file_name <- gsub("-", ".", paste0(individual_dataset_id, '_', individual_year, '_', file_tag))
        } else {
          file_name <- gsub("-", ".", paste0(individual_dataset_id, file_tag))
        }
        
        if (any(grepl(file_name, dir(rstdir)))) {
          message(
            "Pre-downloaded raster with identical query parameters loaded ('",
            grep(file_name, dir(rstdir), value = T),
            "')"
          )
        } else {
          rst_path <- file.path(rstdir, paste0(file_name, ".tiff"))
          spat_raster <- fetchRaster(individual_dataset_id, extent, individual_year)
          terra::writeRaster(spat_raster, rst_path,  filetype = "GTiff", overwrite=FALSE)
          name(spat_raster)
          return(spat_raster)
        }
      } else {
        spat_raster <- fetchRaster(individual_dataset_id, extent, individual_year)
        return(spat_raster)
      }
      
    })
    
    return(spat_rasters_by_year)
    
  }, dataset_id, year)
  
  #Unnest list

  spat_rasters <- lapply(rapply(spat_rasters_by_dataset_id, enquote, how="unlist"), eval)

  if(length(spat_rasters) == 0) {
    stop("Raster download error: check dataset_id and/or extent are specified correctly")
  }
  
  # mask each stack by shapefile if this is provided
  if (!is.null(shp)) {
    spat_rasters <- lapply(X = spat_rasters,
                       FUN = terra::mask,
                       mask = shp)
  }
  
  for (i in 1:length(spat_rasters)) {
    terra::NAflag(spat_rasters[[i]]) <- -9999
  }
  
  if (length(spat_rasters) == 1) {
    return(spat_rasters[[1]])
  } else if (length(spat_rasters) > 1) {
    #if more than one raster is found we want a SpatRasterCollection - but only for rasters with the same resolution
    spat_raster_collection <- collectRastersOfSameResolution(spat_rasters)
    return(spat_raster_collection)
  }
}

#' Will group rasters that have the same resolution into a SpatRasterCollection. Ones that do not have the same
#' resolution as any other raster are left as a single SpatRaster.
#'
#' @param rst_list list of SpatRasters.
#' @return either a list of SpatRasters/SpatRasterCollections, or a single SpatRaster or SpatRasterCollection
#' @keywords internal
#'
collectRastersOfSameResolution <- function(rst_list) {
  # create a dataframe with information on the resolution of each raster
  rst_list_index <-
    data.frame(cbind(
      "resolution" = lapply(rst_list, terra::res),
      "raster_name" = lapply(rst_list, names),
      "res_id" = as.numeric(factor(as.character(
        lapply(rst_list, function(x) round(terra::res(x), 6))
      )))
    ))
  
  #check whether more than one resolution is present in downloaded rasters
  #if only one resolution is present, create a raster stack of all downloaded rasters
  if (length(unique(rst_list_index$res_id)) == 1) {
    return(rst_list)
    #if not then we want to return a list of raster stacks - one for each resolution present in the index dataframe above.
  } else if (length(unique(rst_list_index$res_id)) != 1) {
    #for each unique raster resolution create a raster stack and store this in stk_list
    
    stack_rst <- function(res_id) {
      return(rst_list[rst_list_index$res_id == res_id])
    }
    
    stk_list <-
      lapply(X = unique(rst_list_index$res_id), FUN = stack_rst)
    
    return(terra::sprc(stk_list))
  }
}


#' Fetches the raster from geoserver, given the dataset id of the raster, and filter value for bbox and year.
#'
#' @param dataset_id character that is the dataset id of a raster.
#' @param extent 2x2 matrix specifying the spatial extent within which raster data is desired, as returned by sf::st_bbox(), or NULL.
#' @param year numeric that is a single year, or NA.
#' @return the SpatRaster that matches the dataset_id with filters applied for extent and year if not NULL/NA.
#' @keywords internal
#'
fetchRaster <- function(dataset_id, extent, year) {

  wcs_client <- get_wcs_client_from_raster_id(dataset_id)
  
  if (!is.na(year) & !is.null(year)) {
    time <- lapply(year, lubridate::make_date)
    time <- lapply(time, format, format = '%Y-%m-%dT%H:%M:%S')
    time_filter <- do.call('c', time)
    raster_name <- paste0(dataset_id, '_', year)
  } else {
    time_filter <- NULL
    raster_name <- dataset_id
  }
  
  spat_raster <- wcs_client$getCoverage(identifier = dataset_id, bbox = extent, time = time_filter)
  
  names(spat_raster) <- raster_name
  
  return(spat_raster)
}


#' Gets the rasters dataset id, given a surface (title). If more than one rasters have that surface/title, then the one with
#' the most recent version is selected. If there are no matches, the program will stop with a relevant message. 
#'
#' @param rasterList data.frame containing available raster information, as returned by listRaster().
#' @param surface character that is the surface/title of the raster.
#' @return character that is the dataset id of the raster that matches the given surface.
#' @keywords internal
#'
getRasterDatasetIdFromSurface <- function(rasterList, surface) {
  rasterList_filtered_by_title <- subset(rasterList, title == surface)
  if(length(rasterList_filtered_by_title) == 0) {
    stop(paste("Surface with title ", surface, " not found. Please use the dataset_id parameter instead anyway. As thes surface parameter will be removed in next version. "))
  } else if(length(rasterList_filtered_by_title) == 1) {
    return(rasterList_filtered_by_title$dataset_id[1])
  } else {
    maxVersion <- max(rasterList_filtered_by_title$version)
    rasterList_filtered_by_title_and_version <- subset(rasterList_filtered_by_title, version == maxVersion)
    return(rasterList_filtered_by_title_and_version$dataset_id[1])
  }
}


