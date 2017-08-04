autoplot.MAPraster <- function(object, country = NULL, shp_df = NULL, legend = ""){

  if(!"data.frame" %in% class(object)){
    object <- as(object, "SpatialPixelsDataFrame")
    object <- as.data.frame(object)
  }

  plot <- ggplot()+
    geom_tile(data = object, aes(x=x, y=y, fill = object[,1]))+
    coord_equal()+
    scale_fill_distiller(name = paste(legend), palette = "RdYlBu")+
  theme(plot.title = element_text(vjust=-1),
        panel.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        panel.border = element_rect(colour = "grey50", fill=NA, size = 0.5))

  if(!is.null(shp_df)){
    plot$layers <- c(geom_polygon(data = shp_df, aes(x=long, y=lat, group = group), fill = "grey65"),
                     plot$layers)
    plot <- plot + geom_polygon(data = shp_df, aes(x=long, y=lat, group = group), alpha = 0, colour = "black")
  } else if(!is.null(country)){
    plot_shp <- getShp(country = country, admin_level = "admin0", format = "df")[[1]]
    plot$layers <- c(geom_polygon(data = plot_shp, aes(x=long, y=lat, group = group), fill = "grey65"),
                     plot$layers)
    plot <- plot + geom_polygon(data = plot_shp, aes(x=long, y=lat, group = group), alpha = 0, colour = "black")
}
  return(plot)
}

