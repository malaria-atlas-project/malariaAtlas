#' Quickly visualise Rasters downloaded from MAP
#'
#' \code{autoplot.MAPraster} creates a map of all rasters in a MAPraster object and
#'   displays these in a grid.
#'
#' @param object MAPraster object to be visualised.
#' @param shp_df Shapefile(s) (data.frame) to plot with downloaded raster.
#' @param legend_title String used as title for all colour scale legends.
#' @param plot_titles Plot name of raster object as header for each individual raster plot?
#' @param printed Logical vector indicating whether to print maps of supplied rasters.
#' @param fill_colour_palette String referring to a colorbrewer palette to be used for raster colour scale.
#' @param fill_scale_transform String givning a transformation for the fill aesthetic.
#'   See the trans argument in \code{\link[ggplot2]{continuous_scale}} for possible values.
#' @param ... Other arguments passed to specific methods
#'
#' @return \code{autoplot.MAPraster} returns a list of plots (gg objects) for each
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
#' \code{\link{as.MAPraster}}:
#'
#' to convert RasterLayer/RasterStack objects into a 'MAPraster' object
#' (data.frame) for easy plotting with ggplot.
#'
#' \code{\link{autoplot.MAPraster}}:
#'
#' to quickly visualise MAPraster objects created using \code{as.MAPraster}.
#'
#' @importFrom ggplot2 autoplot
#' @method autoplot MAPraster
#' @export

autoplot.MAPraster <- function(object,
                               ...,
                               shp_df = NULL,
                               legend_title = "",
                               plot_titles = TRUE,
                               fill_scale_transform = "identity",
                               fill_colour_palette = "RdYlBu",
                               printed = TRUE) {
  
  lifecycle::deprecate_stop("1.6.0", "autoplot.MAPraster()", details = "This function will is deprecated. getRaster should return an object of type SpatRaster")
  

  make_plot <- function(object, rastername, shp_df, legend_title){

  plot <- ggplot2::ggplot()+
    ggplot2::geom_raster(data = object[object$raster_name == rastername,], ggplot2::aes(.data$x, .data$y, fill = .data$z))+
    ggplot2::coord_equal()+
    ggplot2::scale_fill_distiller(name = paste(legend_title),
                         palette = fill_colour_palette,
                         trans = fill_scale_transform,
                         na.value = grDevices::grey(0.9))+
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
        panel.background = ggplot2::element_rect(fill = "white"),
        panel.grid = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))

  if(plot_titles == TRUE){
  plot <- plot +  ggplot2::ggtitle(paste(rastername))
  }

  if(!is.null(shp_df)){
    plot$layers <- c(ggplot2::geom_polygon(data = shp_df, ggplot2::aes(.data$long, .data$lat, group = .data$group), fill = "grey65"),
                     plot$layers)
    plot <- plot + ggplot2::geom_polygon(data = shp_df, ggplot2::aes(.data$long, .data$lat, group = .data$group), alpha = 0, colour = "grey40")
  }

  return(plot)
  }

plot_list <- lapply(X = unique(object$raster_name), FUN = make_plot, object = object, shp_df = shp_df, legend_title = legend_title)
names(plot_list) <- unique(object$raster_name)

if(printed == TRUE){
if(length(plot_list)==1){
  message("Plotting:\n", paste("  -",names(plot_list), collapse = "\n"))
gridExtra::grid.arrange(plot_list[[1]])
  }else if(length(plot_list)>1) {
    split_list <- base::split(plot_list, (seq_along(plot_list)-1) %/% 4)

    if(length(plot_list)==2){
      nrow = 1
    }else{
      nrow = 2
    }

    message("Plotting (over ",length(split_list)," page(s)):\n", paste("  -",names(plot_list), collapse = "\n"))

    for(p in 1:length(split_list)){
   do.call(gridExtra::grid.arrange, args = list(grobs = split_list[[p]], nrow = nrow, ncol = 2, top = paste("Page", p, "of", length(split_list))))
      }
    }
}

  return(invisible(plot_list))

}



