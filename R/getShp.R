#' Download MAPadmin2013 Administrative Boundary Shapefiles from the MAP geoserver
#'
#' \code{getShp} downloads shapefiles for a specified country (or countries) and returns this as a spatial
#'
#'
#' @param object object of class pr.points (e.g. data downloaded uisng getPR()) for which corresponding shapefiles are desired (use either \code{object} OR \code{ISO} OR \code{country}, not in combination)
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{object} OR \code{ISO} OR \code{country}, not in combination)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{object} OR \code{ISO} OR \code{country}, not in combination)
#' @param admin_level string specifying the administrative level for which shapefile are desired (only "admin1", "admin0", or "both" accepted)
#' @param extent string specifying method of defining shapefile extent - accepts either \code{bbox} (for use with pr.points object only - defines 2% bounding box around data and downloads shapefiles intersecting this box) or "national_only" (the default - downloads all shapefiles associated with specified country name or names of countries within 'object')
#'
#' @return \code{getShp} returns a list containing separate shapefile dataframes for each administrative level. The following attribute fields are included:
#'
#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' #Download PfPR data & associated shapefiles for Nigeria and Cameroon
#' \dontrun{NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")}
#' \dontrun{NGA_CMR_shp <- getShp(country = c("Nigeria", "Cameroon"))}
#'
#'#' #Download PfPR data & associated shapefiles for Chad
#' \dontrun{Chad_PR <- getPR(ISO = "TCD", species = "both")}
#' \dontrun{Chad_shp <- getShp(ISO = "TCD")}
#'
#' #' #Download PfPR data & associated shapefiles defined by bbox for Madagascar
#' \dontrun{MDG_PR <- getPR(country = "Madagascar", species = "Pv")}
#' \dontrun{MDG_shp <- getShp(object = MDG_PR, extent = "bbox")}
#'
#'
#' @seealso \code{autoplot} method for quick mapping of PR point locations (\code{\link{autoplot.pr.points}}).
#'
#' @export getShp

getShp <- function(object = NULL,country = NULL, ISO = NULL,admin_level = "both", extent = "national_only", format = "spatialpolygon") {

  if(!is.null(object)){
    if(!"pr.points" %in% class(object)){
      stop("Supplying 'object' argument only valid for objects of class \'pr.points\' (e.g. data downloaded using getPR()), in all other cases use country or ISO instead.")
    }
  country_input <- unique(object$country_id)
  }else if(!is.null(ISO)){
    country_input <- ISO
  }else if (!is.null(country)){
      country_input <- as.character(suppressMessages(listAll())$country_id[suppressMessages(listAll())$country %in% country])
  }

  if(length(country_input)==0){
    stop("Invalid country/ISO definition, use is_available() OR listAll() to confirm country spelling and/or ISO code.")
  }

  # if bbox is wanted for shapefile extent definition, create a 2% bounding box around data and pass this into URL query
  if(tolower(extent) == "bbox"){
    bbox_0.02 <- function(x){
      bbox <-  c(min(x$latitude[!is.na(x$latitude)]),
                 min(x$longitude[!is.na(x$longitude)]),
                 max(x$latitude[!is.na(x$latitude)]),
                 max(x$longitude[!is.na(x$longitude)]))

      bbox[1:2] <- bbox[1:2]-(0.02*abs(bbox[1:2]))
      bbox[3:4] <- bbox[3:4]+(0.02*abs(bbox[3:4]))

      return(bbox)
    }

  bbox <- bbox_0.02(object)

  URL_filter <- paste("&bbox=",paste(bbox,collapse = ","), sep = "")

  #otherwise by default use object country names to download shapefiles for these countries only via cql_filter.
  }else if(tolower(extent) == "national_only"){
  URL_filter <- paste("&cql_filter=COUNTRY_ID%20IN%20(",paste("%27",country_input,"%27",collapse = ",", sep = ""),")", sep = "")
  }

  #define which admin levels are queried and return as a list correct query URL
  if(tolower(admin_level) == "admin0"){
    URL_input <- list("admin0" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin0_map_2013&srsName=EPSG:4326",paste(URL_filter), sep = ""))
  } else if(tolower(admin_level) == "admin1"){
    URL_input <- list("admin1" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin1_map_2013&srsName=EPSG:4326",paste(URL_filter), sep = ""))
  } else if(tolower(admin_level) == "both"){
    URL_input <- list("admin0" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin0_map_2013&srsName=EPSG:4326",paste(URL_filter), sep = ""),
                      "admin1" = paste("http://map-prod3.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&TypeName=admin1_map_2013&srsName=EPSG:4326",paste(URL_filter), sep = ""))
  }

downloadShp <- function(URL){
  # create a temporary filepath & directory to download shapefiles from MAP geoserver
  td <- tempdir()
  shpdir <- file.path(td,"shp")
  dir.create(shpdir)
  temp <- tempfile(tmpdir = shpdir, fileext = ".zip")
  # download shapefile to temp directory & extract shapefilepath & layername
  download.file(URL, temp, mode = "wb")
  unzip(temp, exdir = shpdir)
  shp <- dir(shpdir, "*.shp$")
  shp.path <- file.path(shpdir,shp)
  lyr <- sub(".shp$", "", shp)

  ## read shapefile into R
  shapefile_dl <- rgdal::readOGR(dsn = shp.path, layer = lyr)

  ## delete temporary directory and return shapefile object
  on.exit(unlink(shpdir, recursive = TRUE))
  return(shapefile_dl)
}

Shp_polygon <- lapply(URL_input, downloadShp)

if(tolower(format)=="spatialpolygon"){
  return(Shp_polygon)
  }else if(tolower(format)=="df"){
    polygon2df <- function(polygon){
      polygon@data$id <- rownames(polygon@data)
      polygon_df <- ggplot2::fortify(polygon)
      polygon_df <- merge(polygon_df, polygon@data, by = "id")
      return(polygon_df) }

      Shp_df <- lapply(Shp_polygon, polygon2df)
      return(Shp_df)
  }
}


## x <- getShp(object = object, admin_level = "both")
## zz <- getShp(ISO = "CHN")
## zz <- getShp(country = "Chad")
## i <- getShp (object = a)

# a <- ggplot()+geom_polygon(data = x$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
# a <- ggplot()+geom_polygon(data = zz$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
# a <- ggplot()+geom_polygon(data = MDG_shp$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
#a



#ggplot()+geom_polygon(data = x_shp$admin0, aes(x= long, y = lat, group = group))+coord_equal()
