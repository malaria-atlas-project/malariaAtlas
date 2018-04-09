#' List data available to download from the MAP geoserver.
#'
#' \code{listData} is a wrapper for listPoints; listRaster and listShp, listing data (PR survey point data; raster data; shapefiles) available to download from the MAP geoserver.
#'
#' @return \code{listData} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @param datatype One of 'points', 'raster' or 'shape'
#' @param printed Should the list be printed to the console?
#' @examples
#' \donttest{
#' available_admin_units <- listShp()
#' available_pr_points<- listPoints()
#' available_rasters <- listRaster()
#' }
#' @seealso
#' \code{link{listPoints}}
#' \code{\link{listRaster}}
#' \code{\link{listShp}}
#'
#' @export listData

listData <- function(datatype = NULL, printed = TRUE){

  if(is.null(datatype)){
    message("Choose a type of data using one of: \n datatype = \"points\" \n datatype = \"raster\" \n datatype = \"shape\"")
  }

  if(datatype == "points"){
    listPoints(printed = printed)
  }else if(datatype == "raster"){
    listRaster(printed = printed)
  }else if(datatype == "shape"){
    listShp(printed = printed)
  }

}
