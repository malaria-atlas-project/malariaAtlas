#' Create a basic plot to visualise downloaded shapefiles
#'
#' \code{autoplot.MAPshp} creates a map of shapefiles downloaded using getShp.
#'
#' @param object a MAPShp object downloaded using /code{/link{getShp}} with format = "df" specified.
#' @param map_title custom title used for the plot
#' @param facet if TRUE, splits map into a separate facet for each malaria species
#'
#' @return \code{autoplot.MAPshp} returns a map (gg object) of the supplied MAPShp dataframe.
#'
#'
#' @examples
#' \dontrun{MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")}
#' \dontrun{autoplot(MDG_shp)}
#'
#' @importFrom ggplot2 autoplot
#' @export


autoplot.MAPshp <- function(object,
                            map_title = NULL,
                            facet = FALSE,
                            printed = TRUE){

  if(is.null(map_title)){
    map_title <- paste0(unique(object$COUNTRY_ID),": ",paste0("admin", unique(object$ADMN_LEVEL), collapse = ", "))
  }

  plot <- ggplot2::ggplot()+
    ggplot2::geom_polygon(data = object, aes_string(x="long", y = "lat", group = "group"), colour = "grey50", fill = "grey95")+
    ggplot2::coord_equal()+
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
                   strip.text = ggplot2::element_text(face = "bold"),
                   strip.background = element_blank(),
                   panel.background = ggplot2::element_rect(fill = "white"),
                   panel.grid = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
    ggtitle(paste(map_title))


  if(all(c(0,1) %in% unique(object$ADMN_LEVEL))){
    if(facet == TRUE){
     plot <- plot + ggplot2::facet_wrap(~country_level)
    }
  }

  if(printed ==TRUE){
  print(plot)
  }

  return(invisible(plot))
}
