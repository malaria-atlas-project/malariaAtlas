#' List administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' \code{listShp} lists all administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @return \code{listShp} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#' @examples
#' available_admin_units <- listShp()
#' @export listData
#'
#'
#' \code{\link{autoplot.MAPraster}}:
#'

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
