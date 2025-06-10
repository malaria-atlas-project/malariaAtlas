#' Create a basic plot showing locations of downloaded Vector points
#'
#' \code{autoplot.vector.points} creates a map of Vector points downloaded from MAP.
#'
#' @param object a vector.points object downloaded using \code{\link{getVecOcc}}
#' @param shp_df Shapefile(s) (data.frame) to plot with downloaded points. (If not specified automatically uses getShp() for all countries included in vector.points object).
#' @param admin_level the administrative level used for plotting administrative boundaries; either \code{"admin0"}; \code{"admin1"} OR \code{"both"}
#' @param map_title custom title used for the plot
#' @param facet if TRUE, splits map into a separate facet for each malaria species; by default FALSE.
#' @param fill_legend_title Add a title to the legend.
#' @param fill_scale_transform String givning a transformation for the fill aesthetic.
#'   See the trans argument in \code{\link[ggplot2]{continuous_scale}} for possible values.
#' @param printed Should the plot be printed to the graphics device.
#' @param ... Other arguments passed to specific methods
#'
#' @return \code{autoplot.vector.points} returns a plots (gg object) for the supplied vector.points dataframe.
#'
#' @examples
#' \dontrun{
#' Vector_surveys_NGA_NG <- getVecOcc(country = c("Nigeria", "Niger"))
#' autoplot(Vector_surveys_NGA_NG)
#' 
#' # Download the predicted distribution of An. dirus species complex Raster and  
#' #  vector points for Myanmar and visualise these together on a map.
#'
#' # Download Myanmar shapefile to use for raster download.
#' MMR_shp <- getShp(ISO = "MMR", admin_level = "admin0")
#'
#' # Download An. dirus predicted distribution Raster & plot this
#' MMR_An_dirus <- getRaster(surface = "Anopheles dirus species complex", shp = MMR_shp)
#' p <- autoplot(MMR_An_dirus, shp_df = MMR_shp, printed = FALSE)
#'
#' # Download raw occurrence points & plot these over the top of the raster   
#' species <- getVecOcc(country = "Myanmar", species = "Anopheles dirus")
#' # p[[1]] +
#' # geom_point(data = species,
#' #  aes(longitude,
#' #   latitude,
#' #   colour = species))+
#' #   scale_colour_manual(values = "black", name = "Vector suvery locations")+
#' # scale_fill_distiller(name = "Predicted distribution of An. dirus complex",
#' #  palette = "PuBuGn",
#' #   direction = 1)+
#' #   ggtitle("Vector Survey points\n + The predicted distribution of An. dirus complex")
#' }
#'
#' @method autoplot vector.points
#' @export

# @importFrom ggplot2 autoplot


autoplot.vector.points <- function(object,
                        ...,
                        shp_df = NULL,
                        admin_level = "admin0",
                        map_title = "Vector Survey Locations",
                        fill_legend_title = "Raw Vetor Occurrences",
                        fill_scale_transform = "identity",
                        facet = NULL,
                        printed = TRUE){
  
  if(map_title=="Vector Survey Locations" & is.null(shp_df)){
    if(length(unique(as.character(object$country)))>4){
      title_loc <- unique(as.character(object$continent_id))
    } else {
      title_loc <- unique(object$country)
    }
    map_title <- paste("Vector Survey Locations in", paste(title_loc, collapse = ", "))
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
    vector_shp <- getShp(ISO = unique(object$country_id), format = "df", admin_level = admin_level_request)
    
    if(admin_level == "admin0"){
      vector_plot <-  ggplot2::ggplot()+
        ggplot2::geom_sf(data = vector_shp[vector_shp$admn_level == 0,], aes(group = "group"), colour = "grey50", fill = "grey95")
    }
    
    if(admin_level == "admin1"){
      vector_plot <-  ggplot2::ggplot() +
        ggplot2::geom_sf(data = vector_shp[vector_shp$admn_level == 1,], aes(group = "group"), colour = "grey80", fill = "grey95")
    }
    
    if(admin_level == "both"){
      vector_plot <-  ggplot2::ggplot() +
        ggplot2::geom_sf(data = vector_shp[vector_shp$admn_level == 1,], aes(group = "group"), colour = "grey80", fill = "grey95") + 
        ggplot2::geom_sf(data = vector_shp[vector_shp$admn_level == 0,], aes(group = "group"), colour = "grey50", fill = "grey95")
    }
  } else {
    vector_plot <- ggplot2::ggplot() +
      ggplot2::geom_sf(data = shp_df, aes(group = "group"), colour = "grey80", fill = "grey95")
  }
  
  vector_plot <- vector_plot +
    ggplot2::coord_sf() +
    ggplot2::ggtitle(paste(map_title))+
    ggplot2::geom_point(data = object[!object$species %in% "Confidential",], aes(.data$longitude, .data$latitude, fill = .data$species), alpha = 0.8, shape = 21, na.rm = TRUE)+
    ggplot2::theme(plot.title = ggplot2::element_text(vjust=-1),
                   strip.text = ggplot2::element_text(face = "bold"),
                   strip.background = element_blank(),
                   panel.background = ggplot2::element_rect(fill = "white"),
                   panel.grid = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(colour = "grey50", fill=NA, size = 0.5))+
    #ggplot2::scale_fill_distiller(name = paste(fill_legend_title), palette = "RdYlBu", trans = fill_scale_transform)+
    ggplot2::scale_size(name = "Survey Size")
  if(is.null(facet)){
    facet <- FALSE
  }
    
  if(facet==TRUE){
      vector_plot <- vector_plot + ggplot2::facet_wrap(~species)
  }
  
  if(printed == TRUE){
    print(vector_plot)
  }
  
  return(invisible(vector_plot))  
    
}

