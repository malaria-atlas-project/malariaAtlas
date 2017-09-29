autoplot.MAPraster <- function(object, boundaries = NULL, shp_df = NULL, legend_title = "", plot_title = "", log_scale = FALSE){

  make_plot <- function(object, rastername, boundaries, shp_df, legend_title){

  if(log_scale == TRUE){
    trans <- "log10"
  }else{
    trans <- "identity"
  }

  plot <- ggplot()+
    geom_tile(data = object[object$raster_name == rastername,], aes(x=x, y=y, fill = z))+
    coord_equal()+
    scale_fill_distiller(name = paste(legend_title),
                         palette = "RdYlBu",
                         trans = trans,
                         na.value = grey(0.9))+
  theme(plot.title = element_text(vjust=-1),
        panel.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        panel.border = element_rect(colour = "grey50", fill=NA, size = 0.5))+
    ggtitle(paste(rastername))

  if(!is.null(shp_df)){
    plot$layers <- c(geom_polygon(data = shp_df, aes(x=long, y=lat, group = group), fill = "grey65"),
                     plot$layers)
    plot <- plot + geom_polygon(data = shp_df, aes(x=long, y=lat, group = group), alpha = 0, colour = "black")
  } else if(!is.null(boundaries)){
    plot_shp <- getShp(country = boundaries, admin_level = "admin0", format = "df")
    plot$layers <- c(geom_polygon(data = plot_shp, aes(x=long, y=lat, group = group), fill = "grey65"),
                     plot$layers)
    plot <- plot + geom_polygon(data = plot_shp, aes(x=long, y=lat, group = group), alpha = 0, colour = "black")
  }

  return(plot)
  }

plot_list <- lapply(X = unique(object$raster_name), FUN = make_plot, object = object, boundaries = boundaries, shp_df = shp_df, legend_title = legend_title)

if(length(plot_list)<=3){
  ncol = length(plot_list)
}else {
  ncol = 2
}

gridExtra::grid.arrange(grobs = plot_list, ncol = ncol, top = grid::textGrob(paste("\n",plot_title),
                                                                          gp = grid::gpar(fontsize = 15, font = 2)))




  return(plot)
}


# CHN_pvpr_2010 <- getRaster(surface = "PvPR2010", shp = getShp(lat = CHN$latitude, long = CHN$longitude))
# autoplot(as.MAPraster(CHN_pvpr_2010), boundaries = "China")


