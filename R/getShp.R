#' Download MAPadmin2013 Administrative Boundary Shapefiles from the MAP geoserver
#'
#' \code{getShp} downloads a shapefile for a specified country (or countries) and returns this as either a spatialPolygon or data.frame object.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param admin_level string specifying the administrative level for which shapefile are desired (only "admin0","admin1","admin2","admin3", or "all" accepted). N.B. Not all administrative levels are available for all countries. Use listShp to check which shapefiles are available. If an administrative level is requested that is not available, the closest available administrative level shapefiles will be returned.
#' @param extent 2x2 matrix specifying the spatial extent within which polygons are desired, as returned by sp::bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))).
#' Note: getShp downloads the entire polygon for any polygons falling within the extent.
#' @param format string specifying the desired format for the downloaded shapefile: either "spatialpolygon" or "df"
#' @param long longitude of a point location falling within the desired shapefile.
#' @param lat latitude of a point location falling within the desired shapefile.
#'
#' @return \code{getShp} returns either a dataframe or spatialPolygon object for requested administrative unit polygons. The following attribute fields are included:
#'
#' \enumerate{
#' \item \code{id} unique identifier for any given polygon/administrative unit. 
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
                   admin_level = c("admin0"),
                   format = "spatialpolygon",
                   long = NULL,
                   lat = NULL) {
  # Specifcy country_input (ISO3 code) for db query

  available_admin <- listShp(printed = FALSE, admin_level= "admin0")

  if(all(!admin_level%in%c("admin0", "admin1", "admin2", "admin3", "all"))){
    stop('admin_level must be one or more of: c("admin0", "admin1", "admin2", "admin3", "all")')
  }  
  
  if (!is.null(ISO)) {
    country_input <- toupper(ISO)
  } else if (!is.null(country)) {
    country_input <-
      as.character(available_admin$iso[available_admin$name_0 %in% country])
  } else{
    country_input <-  NULL
  }

  # return error if ISO or country are not correctly specified and extent is unspecified
  if (length(country_input) == 0 & is.null(c(extent, lat, long))) {
    stop(
      "Invalid country/ISO definition, use isAvailable() OR listShp() to confirm country spelling and/or ISO code."
    )
  }

  if ("all"%in% tolower(admin_level)){
    admin_num <- c(0, 1, 2, 3)
  } else {
    admin_num <- as.numeric(gsub("admin","", admin_level))
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
    "https://map.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&srsName=EPSG:4326"
  
  
  if ("all" %in% tolower(admin_level) ) {
    URL_input <-
      list(
        "admin0" = paste(
          base_URL,
          "&TypeName=Explorer:mapadmin_0_2018",
          paste(URL_filter),
          sep = ""
        ),
        "admin1" = paste(
          base_URL,
          "&TypeName=Explorer:mapadmin_1_2018",
          paste(URL_filter),
          sep = ""
        ),
        "admin2" = paste(
          base_URL,
          "&TypeName=Explorer:mapadmin_2_2018",
          paste(URL_filter),
          sep = ""
        ),
        "admin3" = paste(
          base_URL,
          "&TypeName=Explorer:mapadmin_3_2018",
          paste(URL_filter),
          sep = ""
        )
      )
  } else {
  
  URL_input <- list()
  
  if ("admin0" %in% tolower(admin_level) ) {
    URL_input <- c(URL_input, 
      list("admin0" = paste(
        base_URL,
        "&TypeName=Explorer:mapadmin_0_2018",
        paste(URL_filter),
        sep = ""
      )))
  }
  
  if ("admin1" %in% tolower(admin_level)) {
    URL_input <- c(URL_input,
      list("admin1" = paste(
        base_URL,
        "&TypeName=Explorer:mapadmin_1_2018",
        paste(URL_filter),
        sep = ""
      )))
  }
  
  if ("admin2" %in% tolower(admin_level)) {
    URL_input <- c(URL_input,
      list("admin2" = paste(
        base_URL,
        "&TypeName=Explorer:mapadmin_2_2018",
        paste(URL_filter),
        sep = ""
      )))
  }
  
  if ("admin3" %in% tolower(admin_level)) {
    URL_input <- c(URL_input,
      list("admin3" = paste(
        base_URL,
        "&TypeName=Explorer:mapadmin_3_2018",
        paste(URL_filter),
        sep = ""
      )))
  } 
  
}

  Shp_polygon <- lapply(URL_input, downloadShp)
  if (length(admin_level) == 1 & !("all" %in% admin_level)){
    Shp_polygon <- Shp_polygon[[paste(admin_level)]]
  } else {
    Shp_polygon <- do.call(what = sp::rbind.SpatialPolygonsDataFrame, args = Shp_polygon)
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
        sp::rbind.SpatialPolygonsDataFrame(.malariaAtlasHidden$stored_polygons, new_shps)
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
  dir.create(shpdir, showWarnings = FALSE)
  temp <- tempfile(pattern = "shp", tmpdir = shpdir, fileext = ".zip")
  uzipdir <- file.path(shpdir, sub("^([^.]*).*", "\\1", basename(temp)))
  dir.create(uzipdir)
  # download shapefile to temp directory & extract shapefilepath & layername
  
  r <- httr::GET(utils::URLencode(URL), httr::write_disk(temp, overwrite = TRUE))
  
  utils::unzip(temp, exdir = uzipdir)
  shp <- dir(uzipdir, "*.shp$")
  shp.path <- file.path(uzipdir, shp)
  lyr <- sub(".shp$", "", shp)

  ## read shapefile into R
  shapefile_dl <- rgdal::readOGR(dsn = shp.path, layer = lyr)

  extra_cols <- list("id_0"=NA,"name_1"=NA,"id_1"=NA,"code_1"=NA,"type_1"=NA,"name_2"=NA,"id_2"=NA,"code_2"=NA,"type_2"=NA,"name_3"=NA,"id_3"=NA,"code_3"=NA,"type_3"=NA)
  if(any(!names(extra_cols)%in%names(shapefile_dl))){
  shapefile_dl@data <- cbind(shapefile_dl@data, extra_cols[!names(extra_cols)%in%names(shapefile_dl)])
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



