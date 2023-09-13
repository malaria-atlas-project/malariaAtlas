#' Quickly visualise Rasters downloaded from MAP
#'
#' \code{autoplot_MAPraster} is a wrapper for /code{/link{autoplot.MAPraster}} that calls
#'   \code{\link{as.MAPraster}} to allow automatic map creation for RasterLayer/RasterStack
#'   objects downloaded from MAP.
#'
#' @param object RasterLayer/RasterStack object to be visualised.
#' @param ... other optional arguments to autoplot.MAPraster (e.g. shp_df, legend_title, page_title...)
#'
#' @return \code{autoplot_MAPraster} returns a list of plots (gg objects) for each supplied raster.
#'
#' @examples
#' \donttest{
#' #Download PfPR2-10 Raster (Bhatt et al 2015) and raw survey points for Madagascar in
#' #  2013 and visualise these together on a map.
#'
#' # Download madagascar shapefile to use for raster download.
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#'
#' # Download PfPR2-10 Raster for 2013 & plot this
#' MDG_PfPR2_10 <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2013)
#' # p <- autoplot_MAPraster(MDG_PfPR2_10)
#'
#' # Download raw PfPR survey points & plot these over the top of the raster
#' pr <- getPR(country = c("Madagascar"), species = "Pf")
#' # p[[1]] +
#' # geom_point(data = pr[pr$year_start==2013,],
#' #            aes(longitude, latitude, fill = positive / examined, size = examined), shape = 21) +
#' #   scale_size_continuous(name = "Survey Size") +
#' #   scale_fill_distiller(name = "PfPR", palette = "RdYlBu") +
#' #   ggtitle("Raw PfPR Survey points\n + Modelled PfPR 2-10 in Madagascar in 2013")}
#'
#'
#' # Download global raster of G6PD deficiency (Howes et al 2012) and visualise this on a map.
#' \donttest{
#' G6PDd_global <- getRaster(surface = "G6PD Deficiency Allele Frequency")
#' #autoplot_MAPraster(G6PDd_global)
#' }
#'
#' @seealso
#' \code{\link{getRaster}}:
#'
#' to download rasters directly from MAP.
#'
#' \code{\link{as.MAPraster}}:
#'
#' to convert RasterLayer/RasterStack objects into a 'MAPraster' object (data.frame) for
#'   easy plotting with ggplot.
#'
#' \code{\link{autoplot.MAPraster}}:
#'
#' to quickly visualise MAPraster objects created using /code{as.MAPraster}.
#'
#'
#' @export autoplot_MAPraster

autoplot_MAPraster <- function(object, ...){
  lifecycle::deprecate_warn("1.5.0", "autoplot_MAPraster()", details = "This function has become unnecessary, just call autoplot directly with the SpatRaster object. It will be removed in the next version.")
  plot <- autoplot(object, ...)
  return(invisible(plot))
}
