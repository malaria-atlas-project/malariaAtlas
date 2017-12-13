#' Quickly visualise Rasters downloaded from MAP
#'
#' \code{autoplot_MAPraster} is a wrapper for /code{/link{autoplot.MAPraster}} that calls /code{/link{as.MAPraster}} to allow automatic map creation for RasterLayer/RasterStack objects downloaded from MAP.
#'
#' @param object RasterLayer/RasterStack object to be visualised.
#' @param ... other optional arguments to autoplot.MAPraster (e.g. shp_df, legend_title, page_title...)
#'
#' @return \code{autoplot_MAPraster} returns a list of plots (gg objects) for each supplied raster.
#'
#' @examples
#' #Download PfPR2-10 Raster for Madagascar in 2016 and visualise this on a map.
#' \dontrun{MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#' MDG_PfPR2_10 <- getRaster(surface = "PfPR2-10", shp = MDG_shp, year = 2016)
#' autoplot_MAPraster(MDG_PfPR2_10)}
#'
#' #Download global raster of G6PD deficiency from Howes et al 2012 and visualise this on a map.
#' \dontrun{G6PDd_global <- getRaster(surface = "G6PD Deficiency")
#' autoplot_MAPraster(G6PDd_global)}
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
#' to quickly visualise MAPraster objects created using /code{as.MAPraster}.
#'
#'
#' @export as.MAPraster

autoplot_MAPraster <- function(object,...){
  object <- as.MAPraster(object)

  plot <- autoplot.MAPraster(object, ...)
return(plot)
}
