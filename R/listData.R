#' List data available to download from the MAP geoserver.
#'
#' \code{listData} is a wrapper for listPoints; listRaster and listShp, listing data (PR survey point data; raster data; shapefiles) available to download from the MAP geoserver.
#'
#' @return \code{listData} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @param datatype One of 'pr points', 'vector points', 'raster' or 'shape'
#' @param printed Should the list be printed to the console?
#' @param ... Other arguments to be passed to \code{list*} functions. (e.g. \code{admin_level} for \code{listShp})
#' @examples
#' \donttest{
#' available_admin_units <- listShp()
#' available_pr_points <- listPoints(sourcedata = "pr points")
#' available_vector_points <- listPoints(sourcedata = "vector points")
#' available_rasters <- listRaster()
#' }
#' @seealso
#' \code{link{listPoints}}
#' \code{\link{listRaster}}
#' \code{\link{listShp}}
#'
#' @export listData

listData <- function(datatype, printed = TRUE, ...){

  if(!datatype %in% c('pr points', 'vector points', 'raster', 'shape')){
    stop("Please choose one of: \n datatype = \"pr points\"  \n datatype = \"vector points\" \n datatype = \"raster\" \n datatype = \"shape\"")
  }

  if(datatype == "pr points"){
    listPoints(printed = printed, sourcedata = "pr points")      
  }else if(datatype == "vector points"){
   listPoints(printed = printed, sourcedata = "vector points")
  }else if(datatype == "raster"){
    listRaster(printed = printed)
  }else if(datatype == "shape"){
    listShp(printed = printed, ...)
  }

}
