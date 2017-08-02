#' Download MAPadmin2013 Administrative Boundary Shapefiles from the MAP geoserver
#'
#' \code{getShp} downloads shapefiles for a specified country (or countries) and returns this as a spatial
#'
#'
#' @param object string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param species string specifying the Plasmodium species for which to find PR points, options include: \code{"Pf"} OR \code{"Pv"} OR \code{"BOTH"}
#'
#'
#' @return \code{getShp} returns a dataframe containing the below columns, in which each row represents a distinct data point/ study site.
#'
#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' #Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
#' NGA_CMR_PR <- getShp(country = c("Nigeria", "Cameroon"), species = "Pf")
#' \dontrun{autoplot(NGA_CMR_PR)}
#'
#' #Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
#' Madagascar_pr <- getShp(ISO = "MDG", species = "Pv")
#' \dontrun{autoplot(Madagascar_pr)}
#'
#' \dontrun{getShp(country = "ALL", species = "BOTH")}
#'
#'
#' @seealso \code{autoplot} method for quick mapping of PR point locations (\code{\link{autoplot.pr.points}}).
#'
#'
#' @export getShp

getShp <- function(object = NULL,country = NULL, ISO = NULL,admin_level = "both", extent = "national_only") {

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

polygon2df <- function(polygon){
    polygon@data$id <- rownames(polygon@data)
    polygon_df <- ggplot2::fortify(polygon)
    polygon_df <- merge(polygon_df, polygon@data, by = "id")
    return(polygon_df)
  }

  Shp_df <- lapply(Shp_polygon, polygon2df)

  return(Shp_df)
 }


## x <- getShp(object = object, admin_level = "both")
## zz <- getShp(ISO = "CHN")
## zz <- getShp(country = "Chad")
## i <- getShp (object = a)

# a <- ggplot()+geom_polygon(data = x$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
# a <- ggplot()+geom_polygon(data = zz$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
#a
