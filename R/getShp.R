#' Download MAPadmin2013 Administrative Boundary Shapefiles from the MAP geoserver
#'
#' \code{getShp} downloads a shapefile for a specified country (or countries) and returns this as either a spatialPolygon or data.frame object.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param admin_level string specifying the administrative level for which shapefile are desired (only "admin1", "admin0", or "both" accepted)
#' @param extent 2x2 matrix specifying the spatial extent within which polygons are desired, as returned by sp::bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))).
#' Note: getShp downloads the entire polygon for any polygons falling within the extent.
#' @param format string specifying the desired format for the downloaded shapefile: either "spatialpolygon" or "df"
#' @param long longitude of a point location falling within the desired shapefile.
#' @param lat latitude of a point location falling within the desired shapefile.
#'
#' @return \code{getShp} returns either a dataframe or spatialPolygon object for requested administrative unit polygons. The following attribute fields are included:
#'
#' \enumerate{
#' \item \code{COUNTRY_ID} ISO-3 code of given administrative unit (or the ISO code of parent unit for administrative-level 1 units).
#' \item \code{GAUL_CODE} GAUL code of given administrative unit.
#' \item \code{ADMN_LEVEL} administrative level of the given administrative unit - either 0 (national) or 1 (first-level division)
#' \item \code{PARENT_ID} GAUL code of parent administrative unit of a given polygon (for admin0 polygons, PARENT_ID = 0).
#' \item \code{country_level} composite \code{ISO3}_\code{ADMN_LEVEL} field.
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
                   admin_level = "both",
                   format = "spatialpolygon",
                   long = NULL,
                   lat = NULL) {
  # Specifcy country_input (ISO3 code) for db query

  available_admin <- listShp(printed = FALSE)

  if (!is.null(ISO)) {
    country_input <- toupper(ISO)
  } else if (!is.null(country)) {
    country_input <-
      as.character(available_admin$country_id[available_admin$name %in% country])
  } else{
    country_input <-  NULL
  }

  # return error if ISO or country are not correctly specified and extent is unspecified
  if (length(country_input) == 0 & is.null(c(extent, lat, long))) {
    stop(
      "Invalid country/ISO definition, use is_available() OR listShp() to confirm country spelling and/or ISO code."
    )
  }

  if (admin_level == "both") {
    admin_num <- c(0, 1)
  } else if (admin_level == "admin1") {
    admin_num <- 1
  } else if (admin_level == "admin0") {
    admin_num <- 0
  }

  # if lat and long are provided, define extent from lat-longs

  if (!is.null(lat) & !is.null(long)) {
    extent <- sp::bbox(array(data.frame(long, lat)))
  }

  #treat ISO = "ALL" separately - return stored polygon OR define big bounding box.
  if ("all" %in% tolower(ISO)) {
    if (exists("all_polygons", envir = .malariaAtlasHidden)) {
      Shp_polygon <- .malariaAtlasHidden$all_polygons

      if (tolower(format) == "spatialpolygon") {
        return(Shp_polygon)
      } else if (tolower(format) == "df") {
        Shp_df <- as.MAPshp(Shp_polygon)
        return(Shp_df)
      }

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

        if (tolower(format) == "spatialpolygon") {
          return(Shp_polygon)
        } else if (tolower(format) == "df") {
          Shp_df <- as.MAPshp(Shp_polygon)
          return(Shp_df)
        }
      }
    }
  }

  # if extent is specified, use this for geoserver query URL
  if (!is.null(extent)) {
    URL_filter <-
      paste("&bbox=", paste(c(extent[2, 1], extent[1, 1], extent[2, 2], extent[1, 2]), collapse = ","), sep = "")
    #otherwise by default use object country names to download shapefiles for these countries only via cql_filter.
  } else{
    URL_filter <-
      paste(
        "&cql_filter=country_id%20IN%20(",
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
    "https://map.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&srsName=EPSG:4326"
  if (tolower(admin_level) == "admin0") {
    URL_input <-
      list("admin0" = paste(
        base_URL,
        "&TypeName=mapadmin_0_2013",
        paste(URL_filter),
        sep = ""
      ))
  } else if (tolower(admin_level) == "admin1") {
    URL_input <-
      list("admin1" = paste(
        base_URL,
        "&TypeName=mapadmin_1_2013",
        paste(URL_filter),
        sep = ""
      ))
  } else if (tolower(admin_level) == "both") {
    URL_input <-
      list(
        "admin0" = paste(
          base_URL,
          "&TypeName=mapadmin_0_2013",
          paste(URL_filter),
          sep = ""
        ),
        "admin1" = paste(
          base_URL,
          "&TypeName=mapadmin_1_2013",
          paste(URL_filter),
          sep = ""
        )
      )
  }

  Shp_polygon <- lapply(URL_input, downloadShp)

  if (admin_level != "both") {
    Shp_polygon <- Shp_polygon[[paste(admin_level)]]
    if ("sum" %in% names(Shp_polygon) |
        "mean" %in% names(Shp_polygon) | "lsms.agri" %in% names(Shp_polygon)) {
      Shp_polygon <-
        Shp_polygon[, !names(Shp_polygon) %in% c("sum", "mean", "lsms.agri")]
    }
  } else if (admin_level == "both") {
    Shp_polygon <-
      sp::rbind.SpatialPolygonsDataFrame(Shp_polygon$admin0[names(Shp_polygon$admin1)], Shp_polygon$admin1)
  }

  Shp_polygon$country_level <-
    paste(Shp_polygon$country_id, "_", Shp_polygon$admn_level, sep = "")

  if ("all" %in% tolower(ISO)) {
    .malariaAtlasHidden$all_polygons <- Shp_polygon
  } else if (is.null(extent)) {
    if (!exists("stored_polygons", envir = .malariaAtlasHidden)) {
      .malariaAtlasHidden$stored_polygons <- Shp_polygon
    } else if (exists("stored_polygons", envir = .malariaAtlasHidden)) {
      new_shps <-
        Shp_polygon[!Shp_polygon$country_level %in% unique(.malariaAtlasHidden$stored_polygons$country_level), ]
      new_shps@data[, names(.malariaAtlasHidden$stored_polygons)[!names(.malariaAtlasHidden$stored_polygons) %in% names(new_shps)]] <- NA
      .malariaAtlasHidden$stored_polygons <-
        sp::rbind.SpatialPolygonsDataFrame(.malariaAtlasHidden$stored_polygons, new_shps[names(new_shps)[names(new_shps) %in% names(.malariaAtlasHidden$stored_polygons)]])
    }
  }

  if (tolower(format) == "spatialpolygon") {
    return(Shp_polygon)
  } else if (tolower(format) == "df") {
    Shp_df <- as.MAPshp(Shp_polygon)
    return(Shp_df)
  }
}

#Define a few utility funcitons:

#define function that downloads a shapefiles from map geoserver to tempdir and loads this into R
downloadShp <- function(URL) {
  # create a temporary filepath & directory to download shapefiles from MAP geoserver
  td <- tempdir()
  shpdir <- file.path(td, "shp")
  dir.create(shpdir)
  temp <- tempfile(tmpdir = shpdir, fileext = ".zip")
  # download shapefile to temp directory & extract shapefilepath & layername
  utils::download.file(URL, temp, mode = "wb")
  utils::unzip(temp, exdir = shpdir)
  shp <- dir(shpdir, "*.shp$")
  shp.path <- file.path(shpdir, shp)
  lyr <- sub(".shp$", "", shp)

  ## read shapefile into R
  shapefile_dl <- rgdal::readOGR(dsn = shp.path, layer = lyr)

  ## delete temporary directory and return shapefile object
  on.exit(unlink(shpdir, recursive = TRUE))
  return(shapefile_dl)
}
