#' Quickly visualise Rasters downloaded from MAP
#'
#' \code{autoplot.SpatRaster} creates a map of all rasters in a SpatRaster object and
#'   displays these in a grid.
#'
#' @param object SpatRaster object to be visualised.
#' @param shp_df Shapefile(s) (data.frame) to plot with downloaded raster.
#' @param legend_title String used as title for all colour scale legends.
#' @param plot_titles Plot name of raster object as header for each individual raster plot?
#' @param printed Logical vector indicating whether to print maps of supplied rasters.
#' @param fill_colour_palette String referring to a colorbrewer palette to be used for raster colour scale.
#' @param fill_scale_transform String givning a transformation for the fill aesthetic.
#'   See the trans argument in \code{\link{continuous_scale}} for possible values.
#' @param ... Other arguments passed to specific methods
#'
#' @return \code{autoplot.SpatRaster} returns a list of plots (gg objects) for each
#'   supplied raster.
#'
#' @examples
#' \dontrun{
#' # Download PfPR2-10 Raster (Bhatt et al 2015) and raw survey points
#' #   for Madagascar in 2013 and visualise these together on a map.
#'
#' # Download madagascar shapefile to use for raster download.
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#'
#' # Download PfPR2-10 Raster for 2013 & plot this
#' MDG_PfPR2_10 <- getRaster(surface = "Plasmodium falciparum PR2-10", 
#'                           shp = MDG_shp, year = 2013)
#' p <- autoplot(MDG_PfPR2_10, shp_df = MDG_shp)
#'
#' # Download raw PfPR survey points & plot these over the top of the raster
#' pr <- getPR(country = c("Madagascar"), species = "Pf")
#' # p[[1]] + geom_point(data = pr[pr$year_start==2013,],
#' #            aes(longitude, latitude, fill = positive / examined,
#' #                size = examined), shape = 21) +
#' #   scale_size_continuous(name = "Survey Size") +
#' #    scale_fill_distiller(name = "PfPR", palette = "RdYlBu") +
#' #    ggtitle("Raw PfPR Survey points\n +
#' #          Modelled PfPR 2-10 in Madagascar in 2013")
#'
#'
#' # Download global raster of G6PD deficiency (Howes et al 2012) and visualise this on a map.
#' G6PDd_global <- getRaster(surface = "G6PD Deficiency Allele Frequency")
#' autoplot(G6PDd_global)
#' }
#'
#' @seealso
#' \code{\link{getRaster}}:
#'
#' to download rasters directly from MAP.
#'
#'
#' @importFrom ggplot2 autoplot
#' @method autoplot SpatRaster
#' @export

autoplot.SpatRaster <- function(
    object,
    ...,
    shp_df = NULL,
    legend_title = "",
    plot_titles = TRUE,
    fill_scale_transform = "identity",
    fill_colour_palette = "RdYlBu",
    printed = TRUE
) {
  raster_names <- unique(names(object))
  plot_list <- lapply(X = raster_names, function(name) {
    makeSpatRasterAutoplot(spatraster = object[[name]], name, shp_df, legend_title, fill_scale_transform, fill_colour_palette, plot_titles)
  })
                     
  names(plot_list) <- raster_names
  
  if (printed == TRUE) {
    if (length(plot_list) == 1) {
      message("Plotting:\n", paste("  -",names(plot_list), collapse = "\n"))
      gridExtra::grid.arrange(plot_list[[1]])
    } else if (length(plot_list) > 1) {
      split_list <- base::split(plot_list, (seq_along(plot_list)-1) %/% 4)
  
      nrow = if(length(plot_list)==2) 1 else 2
      message("Plotting (over ",length(split_list)," page(s)):\n", paste("  -",names(plot_list), collapse = "\n"))
  
      for (p in 1:length(split_list)) {
        do.call(gridExtra::grid.arrange, args = list(grobs = split_list[[p]], nrow = nrow, ncol = 2, top = paste("Page", p, "of", length(split_list))))
      }
    }
  }

  return(invisible(plot_list))
}



