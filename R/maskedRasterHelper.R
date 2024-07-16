# ' Helpers relating to masked rasters. Masking generally relates to low values, or low population areas

#' Returns true if second band of raster is a mask
#' @param raster SpatRaster object containing a single layer
#' 
isMaskedRaster <- function(raster) {
  return(terra::nlyr(raster) == 2 && startsWith(names(raster[[2]]), "Mask:"))
}

#' @param raster SpatRaster object containing a single layer
getMaskBand <- function(raster) {
  if (!isMaskedRaster(raster)) {
    stop("Given raster is not a masked raster.")
  }
  
  return(raster[[2]])
}

getMaskBandName <- function(maskBand) {
  return(gsub("Mask:", "", names(maskBand)))
}