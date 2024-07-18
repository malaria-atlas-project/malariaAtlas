#' Quickly visualise Rasters downloaded from MAP
#'
#' \code{autoplot.SpatRasterCollection} creates a map of all rasters in a autoplot.SpatRasterCollection object and
#'   displays these in a grid.
#'
#' @param object SpatRasterCollection object to be visualised.
#' @param shp_df Shapefile(s) (data.frame) to plot with downloaded raster.
#' @param legend_title String used as title for all colour scale legends.
#' @param plot_titles Plot name of raster object as header for each individual raster plot?
#' @param printed Logical vector indicating whether to print maps of supplied rasters.
#' @param fill_colour_palette String referring to a colorbrewer palette to be used for raster colour scale.
#' @param fill_scale_transform String givning a transformation for the fill aesthetic.
#'   See the trans argument in \code{\link[ggplot2]{continuous_scale}} for possible values.
#' @param ... Other arguments passed to specific methods
#'
#' @return \code{autoplot.SpatRasterCollection} returns a list of plots (gg objects) for each
#'   supplied raster.
#'
#' @return gg object
#' @export
#'
autoplot.SpatRasterCollection <- function(
    object,
    ...,
    shp_df = NULL,
    legend_title = "",
    plot_titles = TRUE,
    fill_scale_transform = "identity",
    fill_colour_palette = "RdYlBu",
    printed = TRUE
) {
  collection_list <- as.list(object)
  names(collection_list) <- lapply(collection_list, function(o) ifelse(length(o) == 1, names(o), names(o[[1]])))
  
  raster_names <- unique(names(collection_list))
  plot_list <- lapply(X = raster_names, function(name) {
    makeSpatRasterAutoplot(spatraster = collection_list[[name]], name, shp_df, legend_title, fill_scale_transform, fill_colour_palette, plot_titles)
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