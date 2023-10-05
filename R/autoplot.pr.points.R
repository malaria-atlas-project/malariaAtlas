#' Create a basic plot showing locations of downloaded PR points
#'
#' \code{autoplot.pr.points} creates a map of PR points downloaded from MAP.
#'
#' @param object a pr.points object downloaded using /code{/link{getPR}}
#' @param shp_df Shapefile(s) (data.frame) to plot with downloaded points. (If not specified automatically uses getShp() for all countries included in pr.points object).
#' @param admin_level the administrative level used for plotting administrative boundaries; either /code{"admin0"}; /code{"admin1"} OR /code{"both"}
#' @param map_title custom title used for the plot
#' @param facet if TRUE, splits map into a separate facet for each malaria species; by default FALSE if only one species is present in object, TRUE if both P. falciparum and P. vivax data are present in object.
#' @param hide_confidential if TRUE, removes confidential points from the map
#' @param fill_legend_title Add a title to the legend.
#' @param fill_scale_transform String givning a transformation for the fill aesthetic.
#'   See the trans argument in \code{\link{continuous_scale}} for possible values.
#' @param printed Should the plot be printed to the graphics device.
#' @param ... Other arguments passed to specific methods
#'
#' @return \code{autoplot.pr.points} returns a plots (gg object) for the supplied pr.points dataframe.
#'
#' @examples
#' \dontrun{
#' PfPR_surveys_NGA <- getPR(country = c("Nigeria"), species = "Pf")
#' autoplot(PfPR_surveys_NGA)
#'
#' # Download PfPR2-10 Raster (Bhatt et al. 2015) and raw survey points for Madagascar in
#' #   2013 and visualise these together on a map.
#'
#' # Download madagascar shapefile to use for raster download.
#' MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
#'
#' # Download PfPR2-10 Raster for 2013 & plot this
#' MDG_PfPR2_10 <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2013)
#' p <- autoplot(MDG_PfPR2_10)
#'
#' # Download raw PfPR survey points & plot these over the top of the raster
#' pr <- getPR(country = c("Madagascar"), species = "Pf")
#' # p[[1]] +
#' # geom_point(data = pr[pr$year_start==2013,],
#' #            aes(longitude, latitude, fill = positive / examined,
#' #                size = examined), shape = 21) +
#' #   scale_size_continuous(name = "Survey Size") +
#' #   scale_fill_distiller(name = "PfPR", palette = "RdYlBu") +
#' #   ggtitle("Raw PfPR Survey points\n + Modelled PfPR 2-10 in Madagascar in 2013")
#' }
#'
#' @method autoplot pr.points
#' @export

# @importFrom ggplot2 autoplot


autoplot.pr.points <- function(object,
                               ...,
                               shp_df = NULL,
                               admin_level = "admin0",
                               map_title = "PR Survey Locations",
                               fill_legend_title = "Raw PR",
                               fill_scale_transform = "identity",
                               facet = NULL,
                               hide_confidential = FALSE,
                               printed = TRUE){

  if(map_title=="PR Survey Locations" & is.null(shp_df)){
    if(length(unique(as.character(object$country)))>4){
      title_loc <- unique(as.character(object$continent_id))
    } else {
    title_loc <- unique(object$country)
    }
    map_title <- paste("PR Survey Locations in", paste(title_loc, collapse = ", "))
  }

  if(hide_confidential==TRUE){
    object <- object[!is.na(object$pr),]
  }

if(is.null(shp_df)){
  if(!(admin_level %in% c('admin0', 'admin1', 'both'))){ 
    stop('admin level must be one of admin0, admin1 or both')
  }
  if(admin_level == 'both'){
    admin_level_request <- c('admin0', 'admin1')
  } else {
    admin_level_request <- admin_level
  }
  
  unique_iso <- unique(object$country_id)
  unique_iso <- unique_iso[unique_iso != '']
  pr_shp <- getShp(ISO = unique_iso, format = "df", admin_level = admin_level_request)

  if(admin_level == "admin0"){
    pr_plot <-  ggplot2::ggplot() +
      ggplot2::geom_sf(data = pr_shp[pr_shp$admn_level == 0,], aes(group = "group"), colour = "grey50", fill = "grey95")
  }

  if(admin_level == "admin1"){
    pr_plot <-  ggplot2::ggplot() +
      ggplot2::geom_sf(data = pr_shp[pr_shp$admn_level == 1,], aes(group = "group"), colour = "grey80", fill = "grey95")
  }

  if(admin_level == "both"){
    pr_plot <-  ggplot2::ggplot() +
      ggplot2::geom_sf(data = pr_shp[pr_shp$admn_level == 1,], aes(group = "group"), colour = "grey80", fill = "grey95") +
      ggplot2::geom_sf(data = pr_shp[pr_shp$admn_level == 0,], aes(group = "group"), colour = "grey50", fill = "grey95")
  }
} else {
  pr_plot <-  ggplot2::ggplot() +
    ggplot2::geom_sf(data = shp_df, aes(group = "group"), colour = "grey80", fill = "grey95")
  }


  if(all(c("P. vivax", "P. falciparum") %in% unique(object$species))){
    plot_species_n <- 2
  } else {
    plot_species_n <- 1
  }

if(plot_species_n == 1){
  pr_plot <- pr_plot +
    ggplot2::coord_sf() +
    ggplot2::ggtitle(paste(map_title))+
    ggplot2::geom_point(data = object[!object$species %in% "Confidential",], aes_string(x = "longitude", y = "latitude", fill = "pr", size = "examined"), alpha = 0.8, shape = 21, na.rm = TRUE)+
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
                   strip.text = ggplot2::element_text(face = "bold"),
                   strip.background = element_blank(),
                   panel.background = ggplot2::element_rect(fill = "white"),
                   panel.grid = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
    ggplot2::scale_fill_distiller(name = paste(fill_legend_title), palette = "RdYlBu", trans = fill_scale_transform)+
    ggplot2::scale_size(name = "Survey Size")
  if(is.null(facet)){
    facet <- FALSE
    }
} else if(plot_species_n == 2){
  pr_plot <- pr_plot +
    ggplot2::coord_sf() +
    ggplot2::ggtitle(paste(map_title))+
    ggplot2::geom_point(data = object[!object$species %in% "Confidential",], aes_string(x = "longitude", y = "latitude", fill = "pr", size = "examined"), alpha = 0.8, shape = 21, na.rm = TRUE)+
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
                   strip.text = ggplot2::element_text(face = "bold"),
                   strip.background = element_blank(),
                   panel.background = ggplot2::element_rect(fill = "white"),
                   panel.grid = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
    ggplot2::scale_fill_distiller(name = paste(fill_legend_title), palette = "RdYlBu", trans = fill_scale_transform)+
    ggplot2::scale_size(name = "Survey Size")
  if(is.null(facet)){
    facet <- TRUE
  }
}

  if(facet==TRUE){
    pr_plot <- pr_plot + ggplot2::facet_wrap(~species)
  }

  if("Confidential" %in% unique(object$species)){
    pr_plot$layers <- c(pr_plot$layers[[1]], geom_point(data = object[object$species == "Confidential",],
                 aes_string(x = 'longitude', y = 'latitude'),
                 fill = "grey40", colour = "grey40", size = 1, shape = 21, alpha = 0.8), pr_plot$layers[[2]])
    pr_plot <- pr_plot +
      ggtitle(label = paste(map_title), subtitle = "(confidential data shown in grey)")
  }

  if(printed == TRUE){
    print(pr_plot)
  }

  return(invisible(pr_plot))
}








# MDG_both <- getPR(country = "Madagascar", species = "BOTH")
# autoplot(MDG_both)
# autoplot(MDG_both, map_title = "CUSTOM TITLE!")
#

# asia_ex <- getPR(country = c("Myanmar","Thailand","China"), species = "both")
# autoplot(asia_ex, facet = TRUE)


