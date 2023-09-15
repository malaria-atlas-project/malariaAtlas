
#' Return sp style bbox
#'
#' @param sfBboxOrShp sf shapefile or result of sf::st_bbox(sf_shp)
#'
#' @return bbox in sp style. A 2x2 matrix - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max"))))
#'
getSpBbox <- function(sfBboxOrShp) {
  if (inherits(sfBboxOrShp, "matrix") && all(dim(sfBboxOrShp) == c(2,2))) {
    # already in correct format
    return(sfBboxOrShp)
  }
  
  if (inherits(sfBboxOrShp, "sf")) {
    sfBbox <- sf::st_bbox(sfBboxOrShp)
  } else if (inherits(sfBboxOrShp, "bbox")) {
    sfBbox <- sfBboxOrShp
  } else {
    stop(paste0("Unhandled class '", class(sfBboxOrShp),"' for getSpBbox"))
  }
  matrix(unlist(sfBbox), ncol = 2)
}