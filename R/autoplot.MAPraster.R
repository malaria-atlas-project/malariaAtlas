#' Quickly visualise Rasters downloaded from MAP
#'
#' \code{autoplot.MAPraster} creates a map of all rasters in a MAPraster object and displays these in a grid.
#'
#' @param object MAPraster object to be visualised.
#' @param shp_df Shapefile(s) (data.frame) to plot with downloaded raster.
#' @param legend_title String used as title for all colour scale legends.
#' @param page_title String used as header for all plot pages.
#' @param log_scale Logical vector indicating whether to use a log scale for legend colour scales.
#' @param printed Logical vector indicating whether to print maps of supplied rasters.
#'
#' @return \code{autoplot.MAPraster} returns a list of plots (gg objects) for each supplied raster.
#'
#' #' @examples
#' \dontrun{#Download PfPR2-10 Raster (Bhatt et al 2015) and raw survey points for Madagascar in 2013 and visualise these together on a map.
#'
#' Download madagascar shapefile to use for raster download.
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#'
#' Download PfPR2-10 Raster for 2013 & plot this
#' MDG_PfPR2_10 <- getRaster(surface = "PfPR2-10", shp = MDG_shp, year = 2013)
#' p <- autoplot_MAPraster(MDG_PfPR2_10)
#'
#' Download raw PfPR survey points & plot these over the top of the raster
#' pr <- getPR(country = c("Madagascar"), species = "Pf")
#' p[[1]] +
#' geom_point(data = pr[pr$year_start==2013,], aes(longitude, latitude, fill = pf_pos / examined, size = examined), shape = 21)+
#' scale_size_continuous(name = "Survey Size")+
#' scale_fill_distiller(name = "PfPR", palette = "RdYlBu")+
#' ggtitle("Raw PfPR Survey points\n + Modelled PfPR 2-10 in Madagascar in 2013")}
#'
#'
#' #Download global raster of G6PD deficiency (Howes et al 2012) and visualise this on a map.
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
#' @importFrom ggplot2 autoplot
#' @export autoplot.MAPraster

autoplot.MAPraster <- function(object,
                               shp_df = NULL,
                               legend_title = "",
                               plot_title = "",
                               log_scale = FALSE,
                               printed = TRUE){

  make_plot <- function(object, rastername, boundaries, shp_df, legend_title){

  if(log_scale == TRUE){
    trans <- "log10"
  }else{
    trans <- "identity"
  }

  plot <- ggplot2::ggplot()+
    ggplot2::geom_tile(data = object[object$raster_name == rastername,], ggplot2::aes_string(x="x", y="y", fill = "z"))+
    ggplot2::coord_equal()+
    ggplot2::scale_fill_distiller(name = paste(legend_title),
                         palette = "RdYlBu",
                         trans = trans,
                         na.value = grDevices::grey(0.9))+
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
        panel.background = ggplot2::element_rect(fill = "white"),
        panel.grid = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
    ggplot2::ggtitle(paste(rastername))

  if(!is.null(shp_df)){
    plot$layers <- c(ggplot2::geom_polygon(data = shp_df, ggplot2::aes_string(x="long", y="lat", group = "group"), fill = "grey65"),
                     plot$layers)
    plot <- plot + ggplot2::geom_polygon(data = shp_df, ggplot2::aes_string(x="long", y="lat", group = "group"), alpha = 0, colour = "black")
  }

  return(plot)
  }

plot_list <- lapply(X = unique(object$raster_name), FUN = make_plot, object = object, boundaries = boundaries, shp_df = shp_df, legend_title = legend_title)
names(plot_list) <- unique(object$raster_name)

if(length(plot_list)>=4){
  layout = matrix(c(1,2,3,4), nrow = 2, ncol = 2, byrow = TRUE)
}else if(length(plot_list)>=2) {
  layout = matrix(c(1,2), nrow = 1, ncol = 2, byrow = TRUE)
}else{
  layout = matrix(c(1), nrow = 1, ncol = 1, byrow = TRUE)
  }

split_list <- split(plot_list, (seq_along(plot_list)-1) %/% 4)

if(printed == TRUE){
  print(lapply(split_list, function(x) gridExtra::marrangeGrob(grobs = x,
                                                               layout_matrix = layout,
                                                               top = grid::textGrob(paste("\n",plot_title),
                                                                                    gp = grid::gpar(fontsize = 15, font = 2)))))
}
  return(invisible(plot_list))
}


# CHN_pvpr_2010 <- getRaster(surface = "PvPR2010", shp = getShp(lat = CHN$latitude, long = CHN$longitude))
# autoplot(as.MAPraster(CHN_pvpr_2010), boundaries = "China")


