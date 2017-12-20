#' Download MAPadmin2013 Administrative Boundary Shapefiles from the MAP geoserver
#'
#' \code{getShp} downloads shapefiles for a specified country (or countries) and returns this as a spatial
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param admin_level string specifying the administrative level for which shapefile are desired (only "admin1", "admin0", or "both" accepted)
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
#'
#'
#' @seealso \code{autoplot} method for quick mapping of PR point locations (\code{\link{autoplot.pr.points}}).
#'
#' @export getShp
#'



getShp <- function(country = NULL,
                   ISO = NULL,
                   bbox = NULL,
                   admin_level = "both",
                   format = "spatialpolygon",
                   long = NULL,
                   lat = NULL) {

# Specifcy country_input (ISO3 code) for db query

 if(!is.null(ISO)){
    country_input <- toupper(ISO)
  }else if (!is.null(country)){
      country_input <- as.character(suppressMessages(listAll())$country_id[suppressMessages(listAll())$country %in% country])
  }else{
    country_input <-  NULL
  }

  # return error if ISO or country are not correctly specified and bbox is unspecified
  if(length(country_input)==0 & is.null(c(bbox, lat, long))){
    stop("Invalid country/ISO definition, use is_available() OR listAll() to confirm country spelling and/or ISO code.")
  }

  if(admin_level=="both"){
  admin_num <- c(0,1)
  }else if (admin_level=="admin1"){
  admin_num <- 1
  }else if (admin_level=="admin0"){
  admin_num <- 0
  }

  # if lat and long are provided, define bbox from lat-longs

  if(!is.null(lat)&!is.null(long)){
    bbox <- sp::bbox(array(data.frame(long, lat)))
  }

  #treat ISO = "ALL" separately - return stored polygon OR define big bounding box.
  if("ALL" %in% ISO){
    if(exists("all_polygons", envir = .malariaAtlasHidden)){
      Shp_polygon <- .malariaAtlasHidden$all_polygons

      if(tolower(format)=="spatialpolygon"){
        return(Shp_polygon)
      }else if(tolower(format)=="df"){
        Shp_df <- polygon2df(Shp_polygon)
        return(Shp_df)
      }

    } else {
    bbox <- matrix(c(-180,-60, 180,85), nrow = 2)
    }
  }

##if not using bbox - check to see if we have a previosuly stored version of the shapefile we can use.
  if(is.null(bbox)){
    if(exists("stored_polygons", envir = .malariaAtlasHidden)){

      if(all(unlist(lapply(X = country_input, FUN = function(x) paste(x, admin_num, sep = "_"))) %in% unique(.malariaAtlasHidden$stored_polygons$country_level))){
        Shp_polygon <- .malariaAtlasHidden$stored_polygons[.malariaAtlasHidden$stored_polygons$country_level %in% unlist(lapply(X = country_input, FUN = function(x) paste(x, admin_num, sep = "_"))),]

      if(tolower(format)=="spatialpolygon"){
        return(Shp_polygon)
        }else if(tolower(format)=="df"){
          Shp_df <- polygon2df(Shp_polygon)
          return(Shp_df)
        }
      }
    }
  }

  # if bbox is specified, use this for geoserver query URL
 if(!is.null(bbox)){
  URL_filter <- paste("&bbox=",paste(c(bbox[2,1],bbox[1,1],bbox[2,2],bbox[1,2]),collapse = ","), sep = "")
  #otherwise by default use object country names to download shapefiles for these countries only via cql_filter.
  }else{
  URL_filter <- paste("&cql_filter=COUNTRY_ID%20IN%20(",paste("%27",country_input,"%27",collapse = ",", sep = ""),")", sep = "")
  }

  #define which admin levels are queried and return as a list full geoserver query URL
  base_URL <- "https://map-dev1.ndph.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&srsName=EPSG:4326"
  if(tolower(admin_level) == "admin0"){
    URL_input <- list("admin0" = paste(base_URL,"&TypeName=admin0_map_2013",paste(URL_filter), sep = ""))
  } else if(tolower(admin_level) == "admin1"){
    URL_input <- list("admin1" = paste(base_URL,"&TypeName=admin1_map_2013",paste(URL_filter), sep = ""))
  } else if(tolower(admin_level) == "both"){
    URL_input <- list("admin0" = paste(base_URL,"&TypeName=admin0_map_2013",paste(URL_filter), sep = ""),
                      "admin1" = paste(base_URL,"&TypeName=admin1_map_2013",paste(URL_filter), sep = ""))
  }

Shp_polygon <- lapply(URL_input, downloadShp)

if(admin_level!="both"){
  Shp_polygon <- Shp_polygon[[paste(admin_level)]]
  if("sum" %in% names(Shp_polygon)|"mean" %in% names(Shp_polygon)){
    Shp_polygon <- Shp_polygon[,!names(Shp_polygon)%in% c("sum", "mean")]
  }
}else if (admin_level == "both"){
  Shp_polygon <- sp::rbind.SpatialPolygonsDataFrame(Shp_polygon$admin0[names(Shp_polygon$admin1)], Shp_polygon$admin1)
}

Shp_polygon$country_level <- paste(Shp_polygon$COUNTRY_ID,"_",Shp_polygon$ADMN_LEVEL,sep = "")

if("ALL" %in% ISO){
  .malariaAtlasHidden$all_polygons <- Shp_polygon
  } else if(is.null(bbox)){
    if(!exists("stored_polygons", envir = .malariaAtlasHidden)){
    .malariaAtlasHidden$stored_polygons <- Shp_polygon
    }else if(exists("stored_polygons", envir = .malariaAtlasHidden)){
      new_shps <- Shp_polygon[!Shp_polygon$country_level %in% unique(.malariaAtlasHidden$stored_polygons$country_level),]
      .malariaAtlasHidden$stored_polygons <- sp::rbind.SpatialPolygonsDataFrame(.malariaAtlasHidden$stored_polygons, new_shps[names(new_shps)[names(new_shps)%in% names(.malariaAtlasHidden$stored_polygons)]])
    }
}

  if(tolower(format)=="spatialpolygon"){
    return(Shp_polygon)
    }else if(tolower(format)=="df"){
      Shp_df <- polygon2df(Shp_polygon)
    return(Shp_df)
    }
}

#Define a few utility funcitons:

#define function that downloads a shapefiles from map geoserver to tempdir and loads this into R
downloadShp <- function(URL){
  # create a temporary filepath & directory to download shapefiles from MAP geoserver
  td <- tempdir()
  shpdir <- file.path(td,"shp")
  dir.create(shpdir)
  temp <- tempfile(tmpdir = shpdir, fileext = ".zip")
  # download shapefile to temp directory & extract shapefilepath & layername
  utils::download.file(URL, temp, mode = "wb")
  utils::unzip(temp, exdir = shpdir)
  shp <- dir(shpdir, "*.shp$")
  shp.path <- file.path(shpdir,shp)
  lyr <- sub(".shp$", "", shp)

  ## read shapefile into R
  shapefile_dl <- rgdal::readOGR(dsn = shp.path, layer = lyr)

  ## delete temporary directory and return shapefile object
  on.exit(unlink(shpdir, recursive = TRUE))
  return(shapefile_dl)
}

#define function to convert 'SpatialPolygon' to data.frame if needed later
polygon2df <- function(polygon){
  polygon@data$id <- rownames(polygon@data)
  polygon_df <- ggplot2::fortify(polygon)
  polygon_df <- merge(polygon_df, polygon@data, by = "id")
  return(polygon_df)}


# currently only uses stored polygons if ALL of the requested country/admin_levels are present - add version that uses some from stored polygons and adds some new ones?


## zz <- getShp(ISO = "CHN")
## zz <- getShp(country = "Chad")

# a <- ggplot()+geom_polygon(data = x$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
# a <- ggplot()+geom_polygon(data = zz$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
# a <- ggplot()+geom_polygon(data = MDG_shp$admin0, aes(x = long, y = lat, group = group), fill = "white", colour = "black")+coord_equal()
#a



#ggplot()+geom_polygon(data = polygon2df(test), aes(x= long, y = lat, group = group, fill = COUNTRY_ID), colour = "white")+coord_equal()
#ggplot()+geom_polygon(data = polygon2df(MDG_shp), aes(x= long, y = lat, group = group, fill = COUNTRY_ID), colour = "white")+coord_equal()
