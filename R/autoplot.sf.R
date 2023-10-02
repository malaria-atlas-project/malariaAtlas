#' Create a basic plot to visualise downloaded shapefiles
#'
#' \code{autoplot.sf} creates a map of shapefiles downloaded using getShp.
#'
#' @param object A sf object downloaded using /code{/link{getShp}}.
#' @param map_title Custom title used for the plot.
#' @param facet If TRUE, splits map into a separate facet for each administrative level.
#' @param printed Should the plot print to graphics device.
#' @param ... Other arguments passed to specific methods
#'
#' @return \code{autoplot.sf} returns a map of the supplied sf object
#'
#'
#' @examples
#' \dontrun{
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#' autoplot(MDG_shp)
#' }
#'
#' @importFrom ggplot2 autoplot
#' @method autoplot sf
#' @export


autoplot.sf <- function(object,
                            ...,
                            map_title = NULL,
                            facet = FALSE,
                            printed = TRUE){

  if(is.null(map_title)){
    map_title <- paste0(paste0(unique(object$name_0), collapse = ", "),": ",paste0("admin", unique(object$admn_level), collapse = ", "))
  }

  plot <- ggplot2::ggplot(object) +
    ggplot2::geom_sf(aes(group = "group"), colour = "grey50", fill = "grey95") +
    ggplot2::coord_sf() +
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
                   strip.text = ggplot2::element_text(face = "bold"),
                   strip.background = element_blank(),
                   panel.background = ggplot2::element_rect(fill = "white"),
                   panel.grid = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
    ggtitle(paste(map_title))

  if(all(c(0,1) %in% unique(object$admn_level))){
    if(facet == TRUE){
     plot <- plot + ggplot2::facet_wrap(~country_level)
    }
  }

  if(printed ==TRUE){
    print(plot)
  }

  return(invisible(plot))
}
