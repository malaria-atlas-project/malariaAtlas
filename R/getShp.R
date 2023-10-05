#' Download MAPadmin2013 Administrative Boundary Shapefiles from the MAP geoserver
#'
#' \code{getShp} downloads a shapefile for a specified country (or countries) and returns this as either a spatialPolygon or data.frame object.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{ISO} OR \code{country})
#' @param admin_level string specifying the administrative level for which shapefile are desired (only "admin0","admin1","admin2","admin3", or "all" accepted). N.B. Not all administrative levels are available for all countries. Use listShp to check which shapefiles are available. If an administrative level is requested that is not available, the closest available administrative level shapefiles will be returned.
#' @param extent 2x2 matrix specifying the spatial extent within which polygons are desired, as returned by sp::bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))).
#' @param format deprecated argument. Please remove it from your code.
#' @param long longitude of a point location falling within the desired shapefile.
#' @param lat latitude of a point location falling within the desired shapefile.
#' @param version The admin unit dataset version to return. Is NULL by default, and if left NULL will just use the most recent version of admin unit data.
#'
#' @return \code{getShp} returns a sf object for requested administrative unit polygons. The following attribute fields are included:
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
#' \dontrun{
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
                   format = NULL,
                   long = NULL,
                   lat = NULL, 
                   version = NULL) {
  if (!is.null(format)) {
    lifecycle::deprecate_warn("1.6.0", "getShp(format)", details = "The argument 'format' has been deprecated. It will be removed in the next version. Admin boundaries will be correctly plotted using autoplot without the argument.")
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
  
  if (!is.null(extent) & !is.null(lat) & !is.null(lat)) {
    stop("Can only specify one of: 'extent' or 'lat' and 'long'. Please choose one.")
  }
  
  if(is.null(version)) {
    version <- getLatestVersionForAdminData()
  }
  
  wfs_client <- get_wfs_clients()$Admin_Units
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
    latlong_extent <- matrix(unlist(sf::st_bbox(array(data.frame(long, lat)))), ncol = 2)
    bbox_filter <- build_bbox_filter(latlong_extent)
  } else if (!is.null(extent)) {
    bbox_filter <- build_bbox_filter(extent)
  } 
  
  location_filter <- build_cql_filter('iso', iso_list)
  
  if (length(iso_list) == 0 & is.null(c(extent, lat, long))) {
    stop(
      "Invalid country/ISO definition, use isAvailable() OR listShp() to confirm country spelling and/or ISO code."
    )
  }


  #Getting features

  features_list <- future.apply::future_sapply(
    admin_level, function(al) {download_shp(wfs_cap, al, version, location_filter, bbox_filter)}, simplify = FALSE, USE.NAMES = TRUE
  )

  if (length(admin_level) == 1 & !("all" %in% admin_level)){
    features <- features_list[[paste(admin_level)]]
  } else {
    features <- do.call(what = rbind, args = features_list)
  }
  
  return(invisible(features))
}


download_shp <- function(wfs_cap, individual_admin_level, version, location_filter, bbox_filter) {
  dataset_id_admin_level <-
    getDatasetIdForAdminDataGivenAdminLevelAndVersion(individual_admin_level, version)
  wfs_ft_type <-
    wfs_cap$findFeatureTypeByName(dataset_id_admin_level)
  features_admin_level <- callGetFeaturesWithFilters(wfs_ft_type, location_filter, bbox_filter, propertyName = getPropertiesForAdminLevel(individual_admin_level))
  
  extra_cols <- c("id_0", "name_1", "id_1", "code_1", "type_1", "name_2", "id_2", "code_2", "type_2", "name_3", "id_3", "code_3", "type_3")
  for (col_name in setdiff(extra_cols, names(features_admin_level))) {
    features_admin_level[[col_name]] <- NA
  }
  
  features_admin_level <-  features_admin_level[,c("iso","admn_level",
                                   "name_0","id_0","type_0","name_1",
                                   "id_1","type_1","name_2","id_2",
                                   "type_2","name_3","id_3",
                                   "type_3","source")]
  features_admin_level$country_level <-
    paste(features_admin_level$iso, "_", features_admin_level$admn_level, sep = "")
  
  
  return(features_admin_level)
}
