# getRaster <- function(object, bbox = NULL){
#
# if(is.null(bbox)){
#
# bbox_0.02 <- function(x){
#     bbox <-  c(min(x$latitude[!is.na(x$latitude)]),
#                min(x$longitude[!is.na(x$longitude)]),
#                max(x$latitude[!is.na(x$latitude)]),
#                max(x$longitude[!is.na(x$longitude)]))
#
#     bbox[1:2] <- bbox[1:2]-(0.02*abs(bbox[1:2]))
#     bbox[3:4] <- bbox[3:4]+(0.02*abs(bbox[3:4]))
#
#     return(bbox)
#   }
#
# bbox <- bbox_0.02(object)
# }
#
#
# }
#
#
#
# x <- raster::raster("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=WCS&version=2.0.1&request=GetCoverage&format=geotiff&coverageid=africa-pr-2000-2015&BBOX(the_geom,-26.06751,42.68112,-11.89176,51.27320)")
