#' Download MAPadmin2013 Administrative Boundary Shapefiles from the MAP geoserver
#'
#' \code{getShp} downloads a shapefile for a specified country (or countries) and returns this as either a spatialPolygon or data.frame object.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param admin_level string specifying the administrative level for which shapefile are desired (only "admin0","admin1","admin2","admin3", or "all" accepted). N.B. Not all administrative levels are available for all countries. Use listShp to check which shapefiles are available. If an administrative level is requested that is not available, the closest available administrative level shapefiles will be returned.
#' @param extent 2x2 matrix specifying the spatial extent within which polygons are desired. The first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))).
#' Note: getShp downloads the entire polygon for any polygons falling within the extent.
<<<<<<< HEAD
#' @param sf an sf (simple feature) object specifying the spatial extent within which polygons are desired
#' @param format string specifying the desired format for the downloaded shapefile: either "spatialpolygon" or "df" (currently meaningless, soon to be deprecated)
=======
#' @param format deprecated argument. Please remove it from your code.
>>>>>>> e790317eafd0ae3164ff98a3d5dc73cdd48c2de5
#' @param long longitude of a point location falling within the desired shapefile.
#' @param lat latitude of a point location falling within the desired shapefile.
#' @param version The admin unit dataset version to return. Is NULL by default, and if left NULL will just use the most recent version of admin unit data.
#'
#' @return \code{getShp} returns either a dataframe or spatialPolygon object for requested administrative unit polygons. The following attribute fields are included:
#'
#' \enumerate{
#' \item \code{iso} ISO-3 code of given administrative unit (or the ISO code of parent unit for administrative-level 1 units).
#' \item \code{admn_level} administrative level of the given administrative unit - either 0 (national), 1 (first-level division), 2 (second-level division), 3 (third-level division). 
#' \item \code{name_0} name of admin0 parent of a given administrative unit (or just shapefile name for admin0 units)
#' \item \code{id_0} id code of admin0 parent of the current shapefile (or just shapefile id for admin0 units)
#' \item \code{type_0} if applicable, type of administrative unit or admin0 parent
#' \item \code{name_1} name of admin1 parent of a given administrative unit (or just shapefile name for admin1 units); NA for admin0 units
#' \item \code{id_1} id code of admin1 parent of the current shapefile (or just shapefile id for admin1 units); NA for admin0 units
#' \item \code{type_1} if applicable, type of administrative unit or admin1 parent
#' \item \code{name_2} name of admin2 parent of a given administrative unit (or just shapefile name for admin2 units); NA for admin0, admin1 units
#' \item \code{id_2} id code of admin2 parent of the current shapefile (or just shapefile id for admin2 units); NA for admin0, admin1 units
#' \item \code{type_2} if applicable, type of administrative unit or admin2 parent
#' \item \code{name_3} name of admin3 parent of a given administrative unit (or just shapefile name for admin3 units); NA for admin0, admin1, admin2 units
#' \item \code{id_3} id code of admin3 parent of the current shapefile (or just shapefile id for admin3 units); NA for admin0, admin1, admin2 units
#' \item \code{type_3} if applicable, type of administrative unit
#' \item \code{source} source of administrative boundaries
#' \item \code{geometry} geometry of administrative boundaries
#' \item \code{country_level} composite \code{iso}_\code{admn_level} field.
#' }
#'
#' @examples
#' #Download PfPR data & associated shapefiles for Nigeria and Cameroon
#' \donttest{
#' NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
#' NGA_CMR_shp <- getShp(country = c("Nigeria", "Cameroon"))
#'
#' #Download PfPR data & associated shapefiles for Chad
#' Chad_PR <- getPR(ISO = "TCD", species = "both")
#' Chad_shp <- getShp(ISO = "TCD")
#'
#' #' #Download PfPR data & associated shapefiles defined by extent for Madagascar
#' MDG_PR <- getPR(country = "Madagascar", species = "Pv")
#' }
#'
#'
#' @seealso \code{autoplot} method for quick mapping of PR point locations (\code{\link{autoplot.pr.points}}).
#'
#' @export getShp
#'


getShp <- function(country = NULL,
                   ISO = NULL,
                   extent = NULL,
                   sf = NULL,
                   admin_level = c("admin0"),
                   format = NULL,
                   long = NULL,
<<<<<<< HEAD
                   lat = NULL, 
                   version = NULL) {
=======
                   lat = NULL) {
  if (!is.null(format)) {
    lifecycle::deprecate_warn("1.5.0", "getShp(format)", details = "The argument 'format' has been deprecated. It will be removed in the next version. Admin boundaries will be correctly plotted using autoplot without the argument.")
  }
  
  # Specify country_input (ISO3 code) for db query
    available_admin <- listShp(printed = FALSE, admin_level= "admin0")
  if(inherits(available_admin, 'try-error')){
    message(available_admin)
    return(available_admin)
  }
>>>>>>> e790317eafd0ae3164ff98a3d5dc73cdd48c2de5
  
  if(!is.null(format)) {
    message('Please Note: The format parameter will soon be deprecated. Currently, the option for spatialPolygon has already been removed, and the data
            is always returned as a data.frame. Therefore, the format parameter currently is not used, and will soon be removed, so please stop using it.')
  }

  available_admin <- listShp(printed = FALSE, admin_level= "admin0", version = version)

  if(all(!admin_level %in% c("admin0", "admin1", "admin2", "admin3", "all"))){
    stop('admin_level must be one or more of: c("admin0", "admin1", "admin2", "admin3", "all")')
  }  

  if(any(!ISO %in% available_admin$iso) & !is.null(ISO)){
    stop('One or more ISO codes are wrong')
  }  

  if(any(!country %in% available_admin$name_0) & !is.null(country)){
    stop('One or more country names are wrong')
  }  
  
  if ((!is.null(lat) & is.null(lat)) | (is.null(lat) & !is.null(lat))) {
    stop("If you specify one of 'lat' or 'long', you must also specify the other.")
  }
  
  if (sum(c(!is.null(extent), !is.null(sf), !is.null(lat) | !is.null(lat)), na.rm = TRUE)) {
    stop("Can only specify one of: 'extent', 'sf' or 'lat' and 'long'. Please choose one.")
  }
  
  if(is.null(version)) {
    version <- getLatestVersionForAdminData()
  }
  
  wfs_client <- getOption("malariaatlas.wfs_clients")$Admin_Units
  wfs_cap <- wfs_client$getCapabilities()
  
  if ("all" %in% tolower(admin_level)){
    admin_level <- c("admin0", "admin1", "admin2", "admin3")
  } 
  
  location_filter <- NULL
  bbox_filter <- NULL
  
  #Building location filter or bbox filter
  
  if (!is.null(ISO)) {
    iso_list <- toupper(ISO)
  } else if (!is.null(country)) {
    iso_list <-
      as.character(available_admin$iso[available_admin$name_0 %in% country])
  } else if (!is.null(lat) & !is.null(long)) {
    latlong_extent <- sp::bbox(array(data.frame(long, lat)))
    bbox_filter <- build_bbox_filter(latlong_extent)
  } else if (!is.null(extent)) {
    bbox_filter <- build_bbox_filter(extent)
  } else if (!is.null(sf)) {
    bbox_filter <- build_bbox_filter(sf::st_bbox(sf))
  }
  
  location_filter <- build_cql_filter('iso', iso_list)
  
  if (length(iso_list) == 0 & is.null(c(extent, sf, lat, long))) {
    stop(
      "Invalid country/ISO definition, use isAvailable() OR listShp() to confirm country spelling and/or ISO code."
    )
  }

<<<<<<< HEAD
  #Getting features
=======
  if ("all"%in% tolower(admin_level)){
    admin_num <- c(0, 1, 2, 3)
  } else {
    admin_num <- as.numeric(gsub("admin","", admin_level))
  } 

  # if lat and long are provided, define extent from lat-longs

  if (!is.null(lat) & !is.null(long)) {
    extent <- extent <- matrix(unlist(sf::st_bbox(array(data.frame(long, lat)))), ncol = 2)
  }

  #treat ISO = "ALL" separately - return stored polygon OR define big bounding box.
  if ("all" %in% tolower(ISO)) {
    if (exists("all_polygons", envir = .malariaAtlasHidden)) {
      Shp_polygon <- .malariaAtlasHidden$all_polygons
      return(Shp_polygon)
    } else {
      extent <- matrix(c(-180, -60, 180, 85), nrow = 2)
    }
  }

  ##if not using extent - check to see if we have a previosuly stored version of the shapefile we can use.
  if (is.null(extent)) {
    if (exists("stored_polygons", envir = .malariaAtlasHidden)) {
      if (all(
        unlist(lapply(
          X = country_input,
          FUN = function(x)
            paste(x, admin_num, sep = "_")
        )) %in% unique(.malariaAtlasHidden$stored_polygons$country_level)
      )) {
        Shp_polygon <-
          .malariaAtlasHidden$stored_polygons[.malariaAtlasHidden$stored_polygons$country_level %in% unlist(lapply(
            X = country_input,
            FUN = function(x)
              paste(x, admin_num, sep = "_")
          )), ]

        return(Shp_polygon)
      }
    }
  }

  # if extent is specified, use this for geoserver query URL
  if (!is.null(extent)) {
    URL_filter <-
      paste("&bbox=", paste(c(extent[2, 1], extent[1, 1], extent[2, 2], extent[1, 2]), collapse = ","), sep = "")
    #otherwise by default use object country names to download shapefiles for these countries only via cql_filter.
  } else {
    URL_filter <-
      paste(
        "&cql_filter=iso%20IN%20(",
        paste(
          "%27",
          country_input,
          "%27",
          collapse = ",",
          sep = ""
        ),
        ")",
        sep = ""
      )
  }

  #define which admin levels are queried and return as a list full geoserver query URL
  base_URL <-
    "https://malariaatlas.org/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&srsName=EPSG:4326"
>>>>>>> e790317eafd0ae3164ff98a3d5dc73cdd48c2de5
  
  features_list <-
    future.apply::future_lapply(admin_level, function(individual_admin_level) {
      dataset_id_admin_level <-
        getDatasetIdForAdminDataGivenAdminLevelAndVersion(individual_admin_level, version)
      dataset_id_admin_level <-
        getDatasetIdForAdminDataGivenAdminLevelAndVersion(individual_admin_level, version)
      wfs_ft_type <-
        wfs_cap$findFeatureTypeByName(dataset_id_admin_level)
      features_admin_level <- callGetFeaturesWithFilters(wfs_ft_type, location_filter, bbox_filter, propertyName = getPropertiesForAdminLevel(individual_admin_level))
      return(features_admin_level)
    })
  
  features <- dplyr::bind_rows(features_list)
  
  df_features <- data.frame(features)
  
  df_features <- df_features[,!names(df_features)%in%c("gid", "id")]
  
  df_features$country_level <- paste0(df_features$iso, "_", df_features$admn_level)
  
  return(invisible(df_features))



}

<<<<<<< HEAD
=======
  Shp_polygon <- lapply(URL_input, downloadShp)
  if (length(admin_level) == 1 & !("all" %in% admin_level)){
    Shp_polygon <- Shp_polygon[[paste(admin_level)]]
  } else {
    Shp_polygon <- do.call(what = rbind, args = Shp_polygon)
  }

  Shp_polygon$country_level <-
    paste(Shp_polygon$iso, "_", Shp_polygon$admn_level, sep = "")
  

  if ("all" %in% tolower(ISO)) {
    .malariaAtlasHidden$all_polygons <- Shp_polygon
  } else if (is.null(extent)) {
    if (!exists("stored_polygons", envir = .malariaAtlasHidden)) {
      .malariaAtlasHidden$stored_polygons <- Shp_polygon
    } else if (exists("stored_polygons", envir = .malariaAtlasHidden)) {
      new_shps <-
        Shp_polygon[!Shp_polygon$country_level %in% unique(.malariaAtlasHidden$stored_polygons$country_level), ]
      .malariaAtlasHidden$stored_polygons <-
        rbind(.malariaAtlasHidden$stored_polygons, new_shps)
    }
  }
  
  return(Shp_polygon)
}

#Define a few utility funcitons:

#define function that downloads a shapefiles from map geoserver to tempdir and loads this into R
downloadShp <- function(URL) {
  # create a temporary filepath & directory to download shapefiles from MAP geoserver
  td <- tempdir()
  shpdir <- file.path(td, "shp")
  dir.create(shpdir, showWarnings = FALSE)
  temp <- tempfile(pattern = "shp", tmpdir = shpdir, fileext = ".zip")
  uzipdir <- file.path(shpdir, sub("^([^.]*).*", "\\1", basename(temp)))
  dir.create(uzipdir)
  # download shapefile to temp directory & extract shapefilepath & layername
  
  r <- try(httr::GET(utils::URLencode(URL), httr::write_disk(temp, overwrite = TRUE)))
  if(inherits(r, 'try-error')){
    message(r[1])
    return(r)
  }
  
  utils::unzip(temp, exdir = uzipdir)
  shp <- dir(uzipdir, "*.shp$")
  shp.path <- file.path(uzipdir, shp)
  lyr <- sub(".shp$", "", shp)

  ## read shapefile into R
  shapefile_dl <- sf::st_read(dsn = shp.path, layer = lyr)
  
  extra_cols <- c("id_0", "name_1", "id_1", "code_1", "type_1", "name_2", "id_2", "code_2", "type_2", "name_3", "id_3", "code_3", "type_3")
  for (col_name in setdiff(extra_cols, names(shapefile_dl))) {
    shapefile_dl[[col_name]] <- col_name
  }
  
  shapefile_dl <-  shapefile_dl[,c("iso","admn_level",
                                 "name_0","id_0","type_0","name_1",
                                 "id_1","type_1","name_2","id_2",
                                 "type_2","name_3","id_3",
                                 "type_3","source")]
  
  ## delete temporary directory and return shapefile object
  on.exit(unlink(shpdir, recursive = TRUE))
  return(shapefile_dl)
}



>>>>>>> e790317eafd0ae3164ff98a3d5dc73cdd48c2de5
