#' Convert SpatialPolygon objects into MAPshp objects
#'
#' \code{as.MAPshp} converts a SpatialPolygon or SpatialPolygonsDataframe object downloaded using getShp into a 'MAPshp object (data.frame) for easy plotting with ggplot.
#'
#' @param object SpatialPolygon or SpatialPolygonsDataframe object to convert into a 'MAPshp'.
#'
#' @return \code{as.MAPshp} returns a MAPshp object (data.frame) containing the below columns.
#'
#' \enumerate{
#' \item \code{country_id} ISO-3 code of given administrative unit (or the ISO code of parent unit for administrative-level 1 units).
#' \item \code{gaul_code} GAUL code of given administrative unit.
#' \item \code{admn_level} administrative level of the given administrative unit - either 0 (national) or 1 (first-level division)
#' \item \code{parent_id} GAUL code of parent administrative unit of a given polygon (for admin0 polygons, PARENT_ID = 0).
#' \item \code{country_level} composite \code{country_id}_\code{admn_level} field.
#' }
#'
#' @examples
#' #Download shapefiles for Madagascar and visualise these on a map.
#'
#' \donttest{
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#' MDG_shp <- as.MAPshp(MDG_shp)
#' autoplot(MDG_shp)
#' }
#'
#' @seealso
#' \code{\link{autoplot.MAPshp}}
#'
#' to download rasters directly from MAP.
#'
#' @export

as.MAPshp <- function(object){
  lifecycle::deprecate_warn("1.5.0", "as.MAPshp()", details = "This function has become unnecessary for usage with autoplot. It will be removed in the next version.")
  return(object)
}




