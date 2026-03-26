#' Convert Raster objects into MAPraster objects
#'
#' \code{as.MAPraster} converts a RasterLayer or RasterStack object into a 'MAPraster' object (data.frame) for easy plotting with ggplot.
#'
#' @param raster_object RasterLayer or Rasterstack object to convert into a MAPraster.
#'
#' @return \code{as.MAPraster} returns a MAPraster object (data.frame) containing the below columns.
#'
#' \enumerate{
#' \item \code{x} - x coordinates of raster pixels
#' \item \code{y} - y coordinates of raster pixels
#' \item \code{z} - value of raster pixels
#' \item \code{raster_name} - name of raster for which values are stored in z
#' }
#'
#' @examples
#' # Download PfPR2-10 Raster for Madagascar in 2015 and visualise this on a map.
#' \dontrun{
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#' MDG_PfPR2_10 <- getRaster(
#'   dataset_id = "Explorer__2015_Nature_Africa_PR", 
#'   shp = MDG_shp, year = 2015
#' )
#' autoplot(MDG_PfPR2_10)}
#'
#' #Download global raster of G6PD deficiency from Howes et al 2012 and visualise this on a map.
#' \dontrun{
#' G6PDd_global <- getRaster(
#'   dataset_id = "Explorer__2012_G6PDd_Allele_Frequency_Global_5k_Decompressed"
#' )
#' G6PDd_global <- as.MAPraster(G6PDd_global)
#' autoplot(G6PDd_global)}
#'
#' @seealso
#' \code{\link{getRaster}}:
#'
#' to download rasters directly from MAP.
#'
#' \code{\link{as.MAPraster}}:
#'
#' to convert RasterLayer/RasterStack objects into a 'MAPraster' object (data.frame) for easy plotting with ggplot.
#'
#' \code{\link{autoplot.MAPraster}}:
#'
#' to quickly visualise MAPraster objects
#'
#'
#' @export as.MAPraster

as.MAPraster <- function(raster_object){
  lifecycle::deprecate_stop("1.6.0", "as.MAPraster()", details = "This function has become unnecessary for usage with autoplot.")
  return(raster_object)
  
  x <- y <- NULL

  rasterobj2df <- function(object){
    raster_df <- methods::as(object, "SpatialPixelsDataFrame")
    raster_df <- as.data.frame(raster_df)
    raster_df <- tidyr::gather(raster_df, key = "raster_name", value = "z", -x,-y)
    return(raster_df)
  }

  if(inherits(raster_object, c("RasterLayer", "RasterBrick", "RasterStack"))){
    raster_df <- rasterobj2df(raster_object)
    class(raster_df) <- c(class(raster_df), "MAPraster")
    return(raster_df)

  } else if(inherits(raster_object, "list")){
      raster_df <- do.call(rbind, lapply(raster_object, rasterobj2df))
      class(raster_df) <- c(class(raster_df), "MAPraster")
      return(raster_df)
  }
}





