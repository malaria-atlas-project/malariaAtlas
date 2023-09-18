#' Download Rasters produced by the Malaria Atlas Project
#'
#' \code{getRaster} downloads publicly available MAP rasters for a specific surface & year, clipped to a provided bounding box or shapefile.
#'
#' @param dataset_id A character string specifying the dataset ID(s) of one or more rasters. These dataset ids can be found in the data.frame returned by listRaster, in the dataset_id column e.g. c('Malaria__202206_Global_Pf_Mortality_Count', 'Malaria__202206_Global_Pf_Parasite_Rate')
#' @param surface deprecated argument. Please remove it from your code.
#' @param shp SpatialPolygon(s) object of a shapefile to use when clipping downloaded rasters. (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param extent  2x2 matrix specifying the spatial extent within which raster data is desired, as returned by sf::st_bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))) (use either \code{shp} OR \code{extent}; if neither is specified global raster is returned).
#' @param file_path string specifying the directory to which raster files will be downloaded, if you want to download them. If none given, rasters will not be saved to files. 
#' @param year deprecated argument. Please remove it from your code.
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
                      year = NULL, 
                      vector_year= NULL) {
  
  if (!is.null(surface)) {
    lifecycle::deprecate_warn("1.5.0", "getRaster(surface)", details = "The argument 'surface' has been deprecated. It will be removed in the next version. Please use dataset_id to specify the raster instead.")
  }
  
  if (!is.null(year)) {
    lifecycle::deprecate_warn("1.5.0", "getRaster(year)", details = "The argument 'year' has been deprecated. It will be removed in the next version. Please use dataset_id to specify the raster instead.")
  }
  
  if (!is.null(vector_year)) {
    lifecycle::deprecate_warn("1.5.0", "getRaster(vector_year)", details = "The argument 'vector_year' has been deprecated. It will be removed in the next version. Please use dataset_id to specify the raster instead.")
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
  
  
  if (!is.null(shp)) {
    shp <- terra::vect(shp)
  }
  
  
  ## if extent is not defined by user, use sf::st_bbox to define this from provided shapefile
  if (is.null(extent) & !is.null(shp)) {
    extent <- matrix(unlist(sf::st_bbox(shp)), ncol = 2)
  }
  
  if(!is.null(extent)) {
    bbox_filter <- build_bbox_filter(extent)
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
  
  
  spat_rasters <- future.apply::future_lapply(dataset_id, function(individual_dataset_id){
    
    if(!is.null(file_path)) {
      file_name <- gsub("-", ".", paste0(individual_dataset_id, file_tag))
      
      if (any(grepl(file_name, dir(rstdir)))) {
        message(
          "Pre-downloaded raster with identical query parameters loaded ('",
          grep(file_name, dir(rstdir), value = T),
          "')"
        )
      } else {
        rst_path <- file.path(rstdir, paste0(file_name, ".tiff"))
        spat_rasters <- fetchRaster(individual_dataset_id, bbox_filter)
        terra::writeRaster(spat_rasters, rst_path,  filetype = "GTiff", overwrite=FALSE)
        return(spat_rasters)
      }
    } else {
      spat_rasters <- fetchRaster(individual_dataset_id, bbox_filter)
      return(spat_rasters)
    }
  })
  
  if(length(spat_rasters) == 0) {
    stop("Raster download error: check dataset_id and/or extent are specified correctly")
  }
  
  names(spat_rasters) <- dataset_id
  
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


fetchRaster <- function(dataset_id, bbox_filter) {
  wcs_client <- get_wcs_client_from_raster_id(dataset_id)
  
  if(!is.null(extent)) {
    spat_raster <- wcs_client$getCoverage(identifier = dataset_id, bbox = bbox_filter)
  } else {
    spat_raster <- wcs_client$getCoverage(identifier = dataset_id)
  }
  return(spat_raster)
}



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


