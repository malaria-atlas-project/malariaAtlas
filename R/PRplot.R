#' Create a basic plot showing locations of downloaded PR points
#'
#' \code{text} more text
#' @examples
#' \dontrun{object <- getPR(country = c("Nigeria"), species = "Pf")
#' autoplot(object)}
#' @export


autoplot.pr.points <- function(object, col_both = "orchid3", col_confidential = "grey", col_pf = "royalblue3", col_pv = "coral", map_title = NULL, ...){

  if(is.null(map_title)){
    map_title <- paste("PR Points Downloaded for", paste(unique(object$country), collapse = ", "))
  }

  bbox_0.05 <- function(x){
    bbox <-  c(min(x$longitude[!is.na(x$longitude)]),
             min(x$latitude[!is.na(x$latitude)]),
             max(x$longitude[!is.na(x$longitude)]),
             max(x$latitude[!is.na(x$latitude)]))

    bbox[1:2] <- bbox[1:2]-(0.05*abs(bbox[1:2]))
    bbox[3:4] <- bbox[3:4]+(0.05*abs(bbox[3:4]))

    return(bbox)
  }

  bbox <- bbox_0.05(object)

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

   ggmap(ggmap = get_stamenmap(bbox = bbox, zoom = 6, maptype = "toner-background", colour = "color"), extent = "device", legend = "bottom")+
     geom_point(data = object, aes(x = longitude, y = latitude, colour = species), alpha = 0.7)+
     ggtitle(paste(map_title))+
     theme(plot.title = element_text(vjust=-1))+
     scale_color_manual(name = "Species tested:", values = c("both" = col_both, "conf" = col_confidential, "pf" = col_pf, "pv" = col_pv),
                        labels = c("pf" = "P. falciparum only", "pv" = "P. vivax only","both" = "Both Species", "conf" = "Confidential"))
 }


# MDG_both <- getPR(country = "Madagascar", species = "BOTH")
# autoplot(MDG_both)
# autoplot(MDG_both, map_title = "CUSTOM TITLE!")
#

# asia_ex <- getPR(country = c("Myanmar","Thailand","China"), species = "both")
# autoplot(asia_ex)



