#' Deprecated function. Please instead use listPRPointCountries for pr points, listVecOccPointCountries for vector points, listRaster for raster and listShp for shape.
#'
#' \code{listData}  deprecated function Please remove it from your code.
#' 
#' @param datatype "pr points", "vector points" "raster", or "shape"
#' @param printed whether to pretty print the output in console
#' @param ... passed on to listPRPointCountries, listVecOccPointCountries, listShp
#'
#' @export listData

listData <- function(datatype, printed = TRUE, ...){
  
  lifecycle::deprecate_warn("1.6.0", "listData()", details = "The function 'listData' has been deprecated. It will be removed in the next version. Please switch to using listPRPointCountries for pr points, listVecOccPointCountries for vector points, listRaster for raster and listShp for shape.")

  if(!datatype %in% c('pr points', 'vector points', 'raster', 'shape')){
    stop("Please choose one of: \n datatype = \"pr points\"  \n datatype = \"vector points\" \n datatype = \"raster\" \n datatype = \"shape\"")
  }

  if(datatype == "pr points"){
    listPRPointCountries(printed = printed, ...)      
  }else if(datatype == "vector points"){
   listVecOccPointCountries(printed = printed, ...)
  }else if(datatype == "raster"){
    listRaster(printed = printed)
  }else if(datatype == "shape"){
    listShp(printed = printed, ...)
  }

}
