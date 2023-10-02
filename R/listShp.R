#' List administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' \code{listShp} lists all administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @param printed Should the list be printed to the console?
#' @param admin_level Specifies which administrative unit level for which to return available polygon shapefiles. A string vector including one or more of\code{"admin0"}, \code{"admin1"}, \code{"admin2"} OR \code{"admin3"}. Default: \code{c("admin0", "admin1")}
#' @param version The admin unit dataset version to return. Is NULL by default, and if left NULL will just use the most recent version of admin unit data.
#' @return \code{listShp} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#' @examples
#' \dontrun{
#' available_admin_units <- listShp()
#' available_admin_units <- listShp(admin_level = c('admin2','admin3'), version = '202206')
#' }
#' @export listShp


listShp <- function(printed = TRUE,
                    admin_level = c("admin0", "admin1"),
                    version = NULL) {
  
  if (is.null(version)) {
    version <- getLatestVersionForAdminData()
    message('Please Note: Because you did not provide a version, by default the version being used is ', version, 
            ' (This is the most recent version of admin unit shape data. To see other version options use function listShpVersions)')
  } else {
    df_available_versions <- listShpVersions(printed = FALSE)
    if (!version %in% df_available_versions$version) {
      stop(
        paste0(
          'Version provided is not valid. Valid versions for admin unit shape data can be found using listShpVersions() and are ["',
          paste(df_available_versions$version, collapse = '", "'),
          '"]. Otherwise, you can choose to not specify a version, and the most recent version will be automatically selected'
        )
      )
    }
  }
  
    wfs_client <- get_wfs_clients()$Admin_Units
  wfs_cap <- wfs_client$getCapabilities()
  
  features_list <-
    future.apply::future_lapply(admin_level, function(individual_admin_level) {
      cached <- .malariaAtlasHidden$list_shp[[individual_admin_level]][[version]]
      if(!is.null(cached)) {
        return(cached)
      }
      
      dataset_id_admin_level <-
        getDatasetIdForAdminDataGivenAdminLevelAndVersion(individual_admin_level, version)

      wfs_ft_type <-
        wfs_cap$findFeatureTypeByName(dataset_id_admin_level)
      features_admin_level <-
        wfs_ft_type$getFeatures(outputFormat = "json",
                                propertyName = getPropertiesForAdminLevel(individual_admin_level))
      
      .malariaAtlasHidden$list_shp[[individual_admin_level]][[version]] <- features_admin_level # add to cache
      return(features_admin_level)
    })
  
  features <- dplyr::bind_rows(features_list)
  
  if (printed == TRUE) {
    message("Shapefiles Available to Download for: \n ",
            paste(sort(unique(
              features$name_0[features$admn_level == 0]
            )), collapse = " \n "))
  }
  
  df_available_admin <- data.frame(features)
  
  df_available_admin <- df_available_admin[,!names(df_available_admin)%in%c("id","geometry")]
  
  return(invisible(df_available_admin))
}


#' Gets the property string to provide to getFeatures input propertyName, given an admin level.
#'
#' @param admin_level The admin level as a character - either 'admin0', 'admin1', 'admin2' or 'admin3'
#' @return The properrty string to pass to getFeartures as propertyName
#' @keywords internal
#'
getPropertiesForAdminLevel <- function(admin_level) {
  if (admin_level == 'admin0') {
    return('iso,admn_level,name_0,id_0,type_0,source')
  } else if (admin_level == 'admin1') {
    return('iso,admn_level,name_0,id_0,type_0,name_1,id_1,type_1,source')
  } else if (admin_level == 'admin2') {
    return('iso,admn_level,name_0,id_0,type_0,name_1,id_1,type_1,name_2,id_2,type_2,source')
  } else if (admin_level == 'admin3') {
    return('iso,admn_level,name_0,id_0,type_0,name_1,id_1,type_1,name_2,id_2,type_2,name_3,id_3,type_3,source')
  }
}
