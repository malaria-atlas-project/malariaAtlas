#' Create a basic plot showing locations of downloaded PR points
#'
#' \code{autoplot.pr.points} creates a map of PR points downloaded from MAP.
#'
#' @param object a pr.points object downloaded using /code{/link{getPR}}
#' @param point_colours a vector of colours to use for plotted points
#' @param admin_level the administrative level used for plotting administrative boundaries; either /code{"admin0"}; /code{"admin1"} OR /code{"both"}
#' @param map_title custom title used for the plot
#' @param facet if TRUE, splits map into a separate facet for each malaria species
#' @param hide_confidential if TRUE, removes confidential points from the map
#'
#' @return \code{autoplot.pr.points} returns a plots (gg object) for the supplied pr.points dataframe.
#'
#' @examples
#' \dontrun{PfPR_surveys_NGA <- getPR(country = c("Nigeria"), species = "Pf")}
#' \dontrun{autoplot(PfPR_surveys_NGA)}
#'
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
#' @importFrom ggplot2 autoplot
#' @export

autoplot.pr.points <- function(object,
                               point_colours = c("orchid3", "grey", "royalblue3", "coral"),
                               admin_level = "both",
                               map_title = NULL,
                               facet =FALSE,
                               hide_confidential = FALSE,
                               ...){

  if(is.null(map_title)){
    map_title <- paste("PR Survey Locations in", paste(unique(object$country), collapse = ", "))
  }

  if(hide_confidential==TRUE){
    object <- object[object$permissions_info=="",]
  }

  if(all(c("pv_pr", "pf_pr") %in% colnames(object))){
    object$species[is.na(object$pv_pos)&is.na(object$pf_pos)] <- "conf"
    object$species[is.na(object$pv_pos)&!is.na(object$pf_pos)] <- "pf"
    object$species[!is.na(object$pv_pos)&is.na(object$pf_pos)] <- "pv"
    object$species[!is.na(object$pv_pos)&!is.na(object$pf_pos)] <- "both"
  }else if("pv_pr" %in% colnames(object) & !("pf_pr" %in% colnames(object))){
    object$species[is.na(object$pv_pos)] <- "conf"
    object$species[!is.na(object$pv_pos)] <- "pv"
  }else if(!("pv_pr" %in% colnames(object)) & "pf_pr" %in% colnames(object)){
    object$species[is.na(object$pf_pos)] <- "conf"
    object$species[!is.na(object$pf_pos)] <- "pf"
  }

  pr_shp <- getShp(ISO = unique(object$country_id), format = "df", admin_level = admin_level)

  if(admin_level == "admin0"){
    pr_plot <-  ggplot2::ggplot()+ggplot2::geom_polygon(data = pr_shp[pr_shp$ADMN_LEVEL == 0,], aes_string(x="long", y = "lat", group = "group"), colour = "grey50", fill = "grey95")
  }

  if(admin_level == "admin1"){
    pr_plot <-  ggplot2::ggplot()+ggplot2::geom_polygon(data = pr_shp[pr_shp$ADMN_LEVEL == 1,], aes_string(x="long", y = "lat", group = "group"), colour = "grey80", fill = "grey95")
  }

  if(admin_level == "both"){
    pr_plot <-  ggplot2::ggplot()+ggplot2::geom_polygon(data = pr_shp[pr_shp$ADMN_LEVEL == 1,], aes_string(x="long", y = "lat", group = "group"), colour = "grey80", fill = "grey95")+
      ggplot2::geom_polygon(data = pr_shp[pr_shp$ADMN_LEVEL == 0,], aes_string(x="long", y = "lat", group = "group"), colour = "grey50", alpha = 0)
  }

  pr_plot <-   pr_plot +
    ggplot2::geom_point(data = object, aes_string(x = "longitude", y = "latitude", colour = "species"), alpha = 0.7)+
    ggplot2::coord_equal()+
    ggplot2::ggtitle(paste(map_title))+
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
                   panel.background = ggplot2::element_rect(fill = "white"),
                   panel.grid = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
    ggplot2::scale_color_manual(name = "Species tested:",
                                values = c("both" = point_colours[1], "conf" = point_colours[2], "pf" = point_colours[3], "pv" = point_colours[4]),
                                labels = c("both" = "Both Species", "conf" = "Confidential", "pf" = "P. falciparum only", "pv" = "P. vivax only"))

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
# autoplot(asia_ex, facet = TRUE)


