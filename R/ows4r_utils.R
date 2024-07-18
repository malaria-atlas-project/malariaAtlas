#' WFS clients lazily created or from cache
#'
#' @return A list with of WFSClients by workspace
#' @keywords internal
#'
get_wfs_clients <- function(logger=NULL) {
  if(exists('malariaatlas.wfs_clients', envir = .malariaAtlasHidden)){
    wfs_clients_by_workspace <- .malariaAtlasHidden$malariaatlas.wfs_clients
    return(invisible(wfs_clients_by_workspace))
  }

  wfs_clients_by_workspace <- list()
  for (workspace in get_workspaces()) {
    wfs_clients_by_workspace[[workspace]] <- tryCatch({
      ows4R::WFSClient$new(paste0(.malariaAtlasHidden$geoserver, workspace, "/ows"), "2.0.0", logger = logger)
    }, error=connectionErrFn)
  }
  .malariaAtlasHidden$malariaatlas.wfs_clients <- wfs_clients_by_workspace
  return(wfs_clients_by_workspace)
}

#' WCS clients lazily created or from cache
#'
#' @return A list with of WCSClients by workspace
#' @keywords internal
#' 
get_wcs_clients <- function(logger=NULL) {
  if(exists('malariaatlas.wcs_clients', envir = .malariaAtlasHidden)){
    wcs_clients_by_workspace <- .malariaAtlasHidden$malariaatlas.wcs_clients
    return(invisible(wcs_clients_by_workspace))
  }

  wcs_clients_by_workspace <- list()
  for (workspace in get_workspaces()) {
    wcs_clients_by_workspace[[workspace]] <- tryCatch({
      ows4R::WCSClient$new(paste0(.malariaAtlasHidden$geoserver, workspace, "/ows"), "2.0.1", logger = logger)
    }, error=connectionErrFn)
  }
  .malariaAtlasHidden$malariaatlas.wcs_clients <- wcs_clients_by_workspace
  return(wcs_clients_by_workspace)
}

#' WMS clients lazily created or from cache
#'
#' @return A list with of WMSClients by workspace
#' @keywords internal
#'
get_wms_clients <- function(logger=NULL) {
  if(exists('malariaatlas.wms_clients', envir = .malariaAtlasHidden)){
    wms_clients_by_workspace <- .malariaAtlasHidden$malariaatlas.wms_clients
    return(invisible(wms_clients_by_workspace))
  }

  wms_clients_by_workspace <- list()
  for (workspace in get_workspaces()) {
    wms_clients_by_workspace[[workspace]] <- tryCatch({
      ows4R::WMSClient$new(paste0(.malariaAtlasHidden$geoserver, workspace, "/ows"), "1.3.0", logger = logger)
    }, error=connectionErrFn)
  }
  .malariaAtlasHidden$malariaatlas.wms_clients <- wms_clients_by_workspace
  return(wms_clients_by_workspace)
}

#' @keywords internal
#'
get_workspaces <- function() {
  return(.malariaAtlasHidden$workspaces)
}

#' Get the workspace and version from a raster id.
#'
#' @param id The ID to parse.
#' @return A list with the workspace and version.
#' @keywords internal
#'
get_workspace_and_version_from_coverage_id <- function(id) {
  parts <- unlist(strsplit(id, "__"))
  workspace <- parts[1]
  version <- unlist(strsplit(parts[2], "_"))[1]
  return(list(workspace = workspace, version = version))
}

#' Get the workspace and version from a wfs feature type id.
#'
#' @param id The ID to parse.
#' @return A list with the workspace and version.
#' @keywords internal
#'
get_workspace_and_version_from_wfs_feature_type_id <- function(id) {
  parts <- unlist(strsplit(id, ":"))
  workspace <- parts[1]
  version <- unlist(strsplit(parts[2], "_"))[1]
  return(list(workspace = workspace, version = version))
}


#' Get the name from a wfs feature type id.
#'
#' @param id The ID to parse.
#' @return A name of the dataset
#' @keywords internal
#'
get_name_from_wfs_feature_type_id <- function(id) {
  parts <- unlist(strsplit(id, ":"))
  name <- substring(parts[2], 8)
  return(name)
}

#' List all datasets from the Web Feature Services provided by the Malaria Atlas Project within the given workspace.
#'
#' This function lists minimal information of all the feature datasets from the Web Feature Services provided by the Malaria Atlas Project, in the given workspace.
#'
#' @param workspace Character vector representing the name of the workspace.
#' @return A data.frame with columns 'id', 'version', and 'workspace' representing the unique identifier, version, and domain of the datasets
#'
#' @keywords internal
#'
listFeatureTypeDatasetsFromWorkspace <- function(workspace) {
  wfs_client <- get_wfs_clients()[[workspace]]
  wfs_cap <- wfs_client$getCapabilities()
  wfs_ft_types <- wfs_cap$getFeatureTypes()
  
  wfs_ft_types_dataframes <- future.apply::future_lapply(wfs_ft_types, function(wfs_ft_type){
    id <- wfs_ft_type$getName()
    workspace_and_version <- get_workspace_and_version_from_wfs_feature_type_id(id)
    
    return(data.frame(
      dataset_id = id,
      version = workspace_and_version$version,
      workspace = workspace_and_version$workspace
    ))
  })
  
  df_datasets <- do.call(rbind, wfs_ft_types_dataframes)
  return(df_datasets)
}


#' @keywords internal
#'
getDatasetIdForAdminDataGivenAdminLevelAndVersion <- function(admin_level, version) {
  admin_level_numeric <- gsub('admin', '', admin_level) 
  return(paste0('Admin_Units:', version, '_Global_Admin_', admin_level_numeric))
}

#' Builds a CQL filter to be used with getFeatures, that will filter based on the given bounding box.
#'
#' @param bbox A matrix representing a bounding box.
#' @return The character string of the CQL filter.
#' @keywords internal
#'
build_cql_bbox_filter <- function(bbox) {
  minY <- bbox[2, 1]
  minX <- bbox[1, 1]
  maxY <- bbox[2, 2]
  maxX <- bbox[1, 2]
  bbox_filter <-
    paste("BBOX(geom,", minX,",",minY,",",maxX,",",maxY,",'EPSG:4326')",sep = '')
  return(bbox_filter)
}

#' Builds a filter to be used with getFeatures, that will filter based on the given bounding box.
#'
#' @param bbox A matrix representing a bounding box.
#' @return The character string of the filter.
#' @keywords internal
#'
build_bbox_filter <- function(bbox) {
  minY <- bbox[2, 1]
  minX <- bbox[1, 1]
  maxY <- bbox[2, 2]
  maxX <- bbox[1, 2]
  bbox_filter <-
    paste(minX,",",minY,",",maxX,",",maxY,",EPSG:4326",sep = '')
  return(bbox_filter)
}


#' Builds a cql filter to be used with getFeatures, that will filter based on the given list of values.
#'
#'@param attribute A string representing the attribute to filter by
#' @param values A character, or character list, representing one or more values
#' @return The character string of the cql filter.
#' @keywords internal
#'
build_cql_filter <- function(attribute, values) {
  values_string <- paste(gsub("'", "''", values), collapse = "', '")
  filter <-
    paste0(attribute, " IN ('", values_string, "')")
  return(filter)
}

#' Calls getFeatures on the given type with the given filters, where they are not NULL.
#'
#' @param feature_type Object of WFSFeatureType.
#' @param cql_filter A character string that reflects cql filter e.g. "time_start AFTER 2020-00-00T00:00:00Z AND country IN ('Nigeria')"
#' @return The features returned from the getFeatures called on the feature_type with the filter where not NULL.
#' @keywords internal
#'
callGetFeaturesWithFilters <- function(feature_type, cql_filter, ...) {
    if (!is.null(cql_filter)) {
      features <- feature_type$getFeatures(outputFormat = "json", cql_filter = cql_filter, ...)
    } else {
      features <- feature_type$getFeatures(outputFormat = "json", ...)
    }
    return(features)
  }


#' Tries to convert character into a Date object. If this fails, the program will be stopped and an error message
#' shown to the user
#'
#' @param input A character of length 1, to convert into a Date object.
#' @param input_name A character string that reflects the name of the input (to inform the user).
#' @return Will return input as a Date is it can be converted into one. Else will stop the program and issue the user with an error message.
#' @keywords internal
#'
convert_to_date_with_trycatch <- function(input, input_name) {
  if (is.null(input)) {
    return(NULL)
  }
  tryCatch({
    return(as.Date(input))
  },
  error = function(e) {
    message(
      paste0(
        'Input Error: The value you provided for ',
        input_name,
        ' is not in a format that can be converted in a Date'
      )
    )
    stop(e)
  })
}


#' Builds a cql filter to be used with getFeatures, that will filter based on the time range
#' provided by start_date and end_date.
#'
#' @param start_date A Date Object that is the lower bound on the time range (inclusive).
#' @param end_date A Date Object that is the upper bound on the time range (exclusive).
#' @return The character string of the cql filter.
#' @keywords internal
#'
build_cql_time_filter <- function(start_date, end_date) {
  filters <- list()
  if (!is.null(start_date)) {
    start_date_formatted <- format(start_date - 1, '%Y-%m-%dT%H:%M:%SZ')
    filters$start_date <-
      paste("time_start AFTER ", start_date_formatted, sep = "")
  }
  
  if (!is.null(end_date)) {
    end_date_formatted <- format(end_date, '%Y-%m-%dT%H:%M:%SZ')
    filters$end_date <-
      paste("time_end BEFORE ", end_date_formatted, sep = "")
  }
  all_filters <- paste(filters, collapse = ' AND ')
  return(all_filters)
}


#' Builds a cql filter from a list of cql sub filters
#'
#' @param filter_list List of characters and NULL objects that represent individual cql filters e.g. list("time_start AFTER 2020-00-00T00:00:00Z", NULL, "country IN ('Nigeria')")
#' @return If all values in filter_list are null, will return NULL, else will return character of combined filters. e.g. "time_start AFTER 2020-00-00T00:00:00Z AND country IN ('Nigeria')"
#' @keywords internal
#'
combine_cql_filters <- function(filter_list) {
  cql_filters_not_null <- filter_list[lengths(filter_list) != 0]
  if(is_empty(cql_filters_not_null)) {
    return(NULL)
  }
  
  cql_filter <- paste(cql_filters_not_null, collapse = ' AND ')
  return(cql_filter)
}

#' Get the WCS coverage summary for a raster ID.
#'
#' @param raster The raster ID.
#' @return A \link[ows4R]{WCSCoverageSummary} object.
#' @keywords internal
#'
get_wcs_coverage_summary_from_raster_id <- function(raster) {
  id_parts <- get_workspace_and_version_from_coverage_id(raster)
  wcs_client <- get_wcs_clients()[[id_parts$workspace]]
  if (is.null(wcs_client)) {
    stop(paste("Can't find WCS client for workspace ", id_parts$workspace))
  }
  coverageSummary <- wcs_client$getCapabilities()$findCoverageSummaryById(raster, exact = TRUE)
  coverageSummary
}

#' Get the WCS client for a raster ID.
#'
#' @param raster The raster ID.
#' @return A \link[ows4R]{WCSClient} object.
#' @keywords internal
#'
get_wcs_client_from_raster_id <- function(raster) {
  id_parts <- get_workspace_and_version_from_coverage_id(raster)
  wcs_client <- get_wcs_clients()[[id_parts$workspace]]
  wcs_client
}

#' Gets the rasters dataset id, given a surface (title). If more than one rasters have that surface/title, then the one with
#' the most recent version is selected. If there are no matches, the program will stop with a relevant message. 
#'
#' @param rasterList data.frame containing available raster information, as returned by listRaster().
#' @param surface character that is the surface/title of the raster.
#' @return character that is the dataset id of the raster that matches the given surface.
#' @keywords internal
#'
getRasterDatasetIdFromSurface <- function(rasterList, surface) {
  rasterList_filtered_by_title <- subset(rasterList, title == surface)
  if (nrow(rasterList_filtered_by_title) == 0) {
    stop(
      paste(
        "Surface with title ",
        surface,
        " not found. Please use the dataset_id parameter instead anyway. As thes surface parameter will be removed in next version. "
      )
    )
  } else if (nrow(rasterList_filtered_by_title) == 1) {
    return(rasterList_filtered_by_title$dataset_id[1])
  } else {
    maxVersion <- max(unlist(rasterList_filtered_by_title$version))
    rasterList_filtered_by_title_and_version <-
      subset(rasterList_filtered_by_title, version == maxVersion)
    return(rasterList_filtered_by_title_and_version$dataset_id[1])
  }
}

#' @keywords internal
#'
getLatestPRPointVersion <- function() {
  df_versions <- listPRPointVersions(printed = FALSE)
  return(max(unlist(df_versions$version)))
}

#' @keywords internal
#'
getLatestVecOccPointVersion <- function() {
  df_versions <- listVecOccPointVersions(printed = FALSE)
  return(max(unlist(df_versions$version)))
}


#' Get the latest version of admin boundary data
#'
#' @return The latest version of admin boundary data
#' @keywords internal
#'
getLatestVersionForAdminData <- function() {
  df_versions <- listShpVersions(printed = FALSE)
  return(max(unlist(df_versions$version)))
}

#' @keywords internal
#'
getPfPRPointDatasetIdFromVersion <- function(version) {
  return(paste0('Malaria:', version, '_Global_Pf_Parasite_Rate_Surveys'))
}

#' @keywords internal
#'
getPvPRPointDatasetIdFromVersion <- function(version) {
  return(paste0('Malaria:', version, '_Global_Pv_Parasite_Rate_Surveys'))
}

#' @keywords internal
#'
getVecOccPointDatasetIdFromVersion <- function(version) {
  return(paste0('Vector_Occurrence:', version, '_Global_Dominant_Vector_Surveys'))
}

#' Get the list of available countries for a given dataset_id in the Explorer workspace,
#'
#' @param dataset_id The dataset id from which to get the list of available countries from.
#' @return A dataframe with columns for country, country_id and continent_id
#' @keywords internal
#'
fetchCountriesGivenDatasetId <- function(wfs_client, dataset_id) {
  cached <- .malariaAtlasHidden$list_points[[dataset_id]]
  if(!is.null(cached)) {
    return(cached)
  }
  
  wfs_cap <- wfs_client$getCapabilities()
  wfs_feature_type <- wfs_cap$findFeatureTypeByName(dataset_id)
  suppressWarnings({
    features <- wfs_feature_type$getFeatures(outputFormat="json", propertyName='country,country_id,continent_id')
  })
  available_countries <- unique(data.frame(country = features$country, country_id = features$country_id, continent_id = features$continent_id))
  available_countries <- available_countries[available_countries$continent_id!= "",]
  available_countries <- stats::na.omit(available_countries)
  names(available_countries) <- c("country", "country_id", "continent")
  
  .malariaAtlasHidden$list_points[[dataset_id]] <- available_countries # add to cache
  return(available_countries)
}

connectionErrFn <- function(err) {
  err$message <- "Failed to connect to MAP geoserver. Please try again later. If this error keeps occurring please send us an email at data.malariaatlas.org@telethonkids.org.au"
  stop(err)
}
