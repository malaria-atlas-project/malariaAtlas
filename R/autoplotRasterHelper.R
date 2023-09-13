#' Create a single (sub) plot for a SpatRaster
#'
#' @param spatraster SpatRaster object containing a single layer
#' @param rastername raster name, to include in title
#' @param shp_df 
#' @param legend_title 
#' @param fill_scale_transform 
#' @param fill_colour_palette 
#' @param plot_titles bool, whether to include title
#'
#' @return ggplot object
#'
#' @examples
makeSpatRasterAutoplot <- function(
    spatraster, 
    rastername, 
    shp_df, 
    legend_title, 
    fill_scale_transform, 
    fill_colour_palette,
    plot_titles
) {
  plot <- ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = spatraster, aes()) +
    ggplot2::coord_sf() +
    ggplot2::scale_fill_distiller(name = paste(legend_title),
                                  palette = fill_colour_palette,
                                  trans = fill_scale_transform,
                                  na.value = grDevices::grey(0.9)) +
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
                   panel.background = ggplot2::element_rect(fill = "white"),
                   panel.grid = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))
  
  if (plot_titles == TRUE) {
    plot <- plot +  ggplot2::ggtitle(paste(rastername))
  }
  
  if (!is.null(shp_df)) {
    plot$layers <- c(ggplot2::geom_sf(data = shp_df, ggplot2::aes(group = "group"), fill = "grey65"),
                     plot$layers)
    plot <- plot + ggplot2::geom_sf(data = shp_df, ggplot2::aes(group = "group"), alpha = 0, colour = "grey40")
  }
  
  return(plot)
}