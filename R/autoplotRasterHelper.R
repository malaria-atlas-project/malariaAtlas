#' Create a single (sub) plot for a SpatRaster
#'
#' @param spatraster SpatRaster object containing a single layer
#' @param rastername raster name, to include in title
#' @param shp_df sf shapefile 
#' @param legend_title title for legend
#' @param fill_scale_transform scale
#' @param fill_colour_palette palette
#' @param plot_titles bool, whether to include title
#'
#' @return ggplot object
#'
makeSpatRasterAutoplot <- function(
    spatraster, 
    rastername, 
    shp_df, 
    legend_title, 
    fill_scale_transform, 
    fill_colour_palette,
    plot_titles
) {
  plot <- ggplot2::ggplot()
  
  if (!is.null(shp_df)) {
    plot <- plot + ggplot2::geom_sf(data = shp_df, ggplot2::aes(group = "group"), fill = "grey65")
  }
  
  plot <- plot +
    tidyterra::geom_spatraster(data = spatraster[[1]], aes()) +
    ggplot2::coord_sf() +
    ggplot2::scale_fill_distiller(name = paste(legend_title),
                                  palette = fill_colour_palette,
                                  trans = fill_scale_transform,
                                  na.value = grDevices::grey(0.9)) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(vjust=-1),
      panel.background = ggplot2::element_rect(fill = "white"),
      panel.grid = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5),
      legend.key = element_rect(colour = "black")
    )
  
  if (isMaskedRaster(spatraster)) {
    # skip if all pixels are NA
    if (terra::global(getMaskBand(spatraster), fun="notNA")[[1]] != 0) {
      maskBand <- terra::as.factor(getMaskBand(spatraster))
      plot <- plot + 
        ggnewscale::new_scale_fill() +
        tidyterra::geom_spatraster(data = maskBand, aes()) +
        scale_fill_manual(
          name="",
          values = c("white"), 
          limits = c("1"), 
          labels = getMaskBandName(maskBand),
          na.value = NA, na.translate = FALSE
        )
    }
  }
  
  if (plot_titles == TRUE) {
    name <- if (isMaskedRaster(spatraster)) {rastername[[1]]} else {paste(rastername)}
    plot <- plot +  ggplot2::ggtitle(name)
  }
  
  if (!is.null(shp_df)) {
    plot <- plot + ggplot2::geom_sf(data = shp_df, ggplot2::aes(group = "group"), alpha = 0, colour = "grey40")
  }
  
  return(plot)
}