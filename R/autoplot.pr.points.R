#' Create a basic plot showing locations of downloaded PR points
#'
#' \code{text} more text
#' @examples
#' \dontrun{object <- getPR(country = c("Nigeria"), species = "Pf")}
#' \dontrun{autoplot(object)}
#' @importFrom ggplot2 autoplot
#' @export

autoplot.pr.points <- function(object, col_both = "orchid3", col_confidential = "grey", col_pf = "royalblue3", col_pv = "coral", map_title = NULL, extent = "national_only", facet =FALSE, hide_confidential = FALSE, ...){

  if(is.null(map_title)){
    map_title <- paste("PR Survey Locations in", paste(unique(object$country), collapse = ", "))
  }

  if(hide_confidential==TRUE){
    object <- object[object$permissions_info=="",]
  }

  if(all(c("pv_pr", "pf_pr") %in% colnames(object))){
  object$species[is.na(object$pv_pos)&is.na(object$pf_pos)] <- "Confidential"
  object$species[is.na(object$pv_pos)&!is.na(object$pf_pos)] <- "P. falciparum only"
  object$species[!is.na(object$pv_pos)&is.na(object$pf_pos)] <- "P. vivax only"
  object$species[!is.na(object$pv_pos)&!is.na(object$pf_pos)] <- "Both Species"
  }else if("pv_pr" %in% colnames(object) & !("pf_pr" %in% colnames(object))){
    object$species[is.na(object$pv_pos)] <- "Confidential"
    object$species[!is.na(object$pv_pos)] <- "P. vivax only"
  }else if(!("pv_pr" %in% colnames(object)) & "pf_pr" %in% colnames(object)){
    object$species[is.na(object$pf_pos)] <- "Confidential"
    object$species[!is.na(object$pf_pos)] <- "P. falciparum only"
  }


  pr_shp <- getShp(ISO = unique(object$country_id), format = "df")

pr_plot <-   ggplot2::ggplot()+
  ggplot2::geom_polygon(data = pr_shp[pr_shp$ADMN_LEVEL == 1,], aes_string(x="long", y = "lat", group = "group"), colour = "grey80", fill = "grey95")+
  ggplot2::geom_polygon(data = pr_shp[pr_shp$ADMN_LEVEL == 0,], aes_string(x="long", y = "lat", group = "group"), colour = "grey50", alpha = 0)+
  ggplot2::geom_point(data = object, aes_string(x = "longitude", y = "latitude", colour = "species"), alpha = 0.7)+
  ggplot2::coord_equal()+
  ggplot2::ggtitle(paste(map_title))+
  ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
        panel.background = ggplot2::element_rect(fill = "white"),
        panel.grid = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
  ggplot2::scale_color_manual(name = "Species tested:", values = c("Both Species" = col_both, "Confidential" = col_confidential, "P. falciparum only" = col_pf, "P. vivax only" = col_pv))

if(facet==TRUE){
  pr_plot <- pr_plot + ggplot2::facet_wrap(~species)
}

print(pr_plot)
return(invisible(pr_plot))
}


# MDG_both <- getPR(country = "Madagascar", species = "BOTH")
# autoplot(MDG_both)
# autoplot(MDG_both, map_title = "CUSTOM TITLE!")
#

# asia_ex <- getPR(country = c("Myanmar","Thailand","China"), species = "both")
# autoplot(asia_ex)




#object <- asia_ex













