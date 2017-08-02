#' Create a basic plot showing locations of downloaded PR points
#'
#' \code{text} more text
#' @examples
#' \dontrun{object <- getPR(country = c("Nigeria"), species = "Pf")}
#' \dontrun{autoplot(object)}
#' @importFrom ggplot2 autoplot
#' @export

autoplot.pr.points <- function(object, col_both = "orchid3", col_confidential = "grey", col_pf = "royalblue3", col_pv = "coral", map_title = NULL, extent = "national_only", facet =FALSE, ...){

  if(is.null(map_title)){
    map_title <- paste("PR Points Downloaded for", paste(unique(object$country), collapse = ", "))
  }

  bbox_0.05 <- function(x){
    bbox <-  c(min(x$latitude[!is.na(x$latitude)]),
               min(x$longitude[!is.na(x$longitude)]),
               max(x$latitude[!is.na(x$latitude)]),
             max(x$longitude[!is.na(x$longitude)]))

    bbox[1:2] <- bbox[1:2]-(0.02*abs(bbox[1:2]))
    bbox[3:4] <- bbox[3:4]+(0.02*abs(bbox[3:4]))

    return(bbox)
  }

  bbox <- bbox_0.05(object)

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

  if(extent == "bbox"){
    URL_list <- list("admin0" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin0_map_2013&srsName=EPSG:4326&bbox=",paste(bbox,collapse = ","), sep = ""), "admin1" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin1_map_2013&srsName=EPSG:4326&bbox=",paste(bbox,collapse = ","), sep = ""))
  }else if(extent == "national_only"){
  URL_list <- list("admin0" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin0_map_2013&srsName=EPSG:4326&cql_filter=COUNTRY_ID%20IN%20(",paste("%27",unique(object$country_id),"%27",collapse = ",", sep = ""),")", sep = ""),
                   "admin1" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin1_map_2013&srsName=EPSG:4326&cql_filter=COUNTRY_ID%20IN%20(",paste("%27",unique(object$country_id),"%27",collapse = ",", sep = ""),")", sep = ""))
  }

  download_shp <- function(URL) {
    td <- tempdir()
    shpdir <- file.path(td,"shp")
    dir.create(shpdir)
    temp <- tempfile(tmpdir = shpdir, fileext = ".zip")
    download.file(URL, temp, mode = "wb")
    unzip(temp, exdir = shpdir)

    shp <- dir(shpdir, "*.shp$")
    shp.path <- file.path(shpdir,shp)
    lyr <- sub(".shp$", "", shp)

    shapefile_dl <- rgdal::readOGR(dsn = shp.path, layer = lyr)
    on.exit(unlink(shpdir, recursive = TRUE))
    return(shapefile_dl)}

  pr_polygon <- lapply(URL_list, download_shp)

  polygon_to_df <- function(polygon){
    polygon@data$id <- rownames(polygon@data)
    polygon_df <- ggplot2::fortify(polygon)
    polygon_df <- merge(polygon_df, polygon@data, by = "id")

    return(polygon_df)
  }

pr_polygon_df <- lapply(pr_polygon, polygon_to_df)

pr_plot <-   ggplot()+
  geom_polygon(data = pr_polygon_df$admin1, aes(x=long, y = lat, group = group), colour = "grey80", fill = "grey95")+
  geom_polygon(data = pr_polygon_df$admin0, aes(x=long, y = lat, group = group), colour = "grey50", alpha = 0)+
  geom_point(data = object, aes(x = longitude, y = latitude, colour = species), alpha = 0.7)+
  coord_equal()+
  ggtitle(paste(map_title))+
  theme(plot.title = element_text(vjust=-1),
        panel.background = element_rect(fill = "lightblue1"),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        panel.border = element_rect(colour = "grey50", fill=NA, size = 0.5))+
  scale_color_manual(name = "Species tested:", values = c("Both Species" = col_both, "Confidential" = col_confidential, "P. falciparum only" = col_pf, "P. vivax only" = col_pv))

if(facet==TRUE){
  pr_plot <- pr_plot + facet_wrap(~species)
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













