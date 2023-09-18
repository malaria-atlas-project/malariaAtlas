#' Get the workspace and version from a raster id.
#'
#' @param id The ID to parse.
#' @return A list with the workspace and version.
#' @keywords internal
#'
get_workspace_and_version_from_coverage_id <- function(id) {
  parts <- unlist(strsplit(id, "__"))
  workspace <- parts[1]
  wcs_client <- getOption("malariaatlas.wcs_clients")[[workspace]]
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



#' Get the dataset id of the latest version of a given dataset name within a dataset
#'
#' @param datasets The datasets in a data.frame with columns for dataset_id, version and workspace.
#' @param dataset_name The dataset name e.g. 'Global_Pf_Parasite_Rate_Surveys'.
#' @return A dataset id within the datasets that matches the dataset name and has the most recent version
#' @keywords internal
#'
getLatestDatasetId <- function(datasets, dataset_name) {
  datasetNames <-
    future.apply::future_lapply(datasets$dataset_id, get_name_from_wfs_feature_type_id)
  datasetNames <- do.call(rbind, datasetNames)
  datasets$name <- datasetNames
  datasets_filtered_by_name <- subset(datasets, name == dataset_name)
  maxVersion <- max(datasets_filtered_by_name$version)
  datasets_filtered_by_name_and_version <-
    subset(datasets_filtered_by_name, version == maxVersion)
  datasetId <- datasets_filtered_by_name_and_version$dataset_id[1]
  return(datasetId)
}

#' Get the dataset id of the latest version of pf PR data
#'
#' @return The dataset id of the latest version of pf PR Data
#' @keywords internal
#'
getLatestDatasetIdForPfPrData <- function() {
  prDatasets <- listParasiteRateDatasets()
  return(getLatestDatasetId(prDatasets, 'Global_Pf_Parasite_Rate_Surveys'))
}

#' Get the dataset id of the latest version of pv PR data
#'
#' @return The dataset id of the latest version of pv PR Data
#' @keywords internal
#'
getLatestDatasetIdForPvPrData <- function() {
  prDatasets <- listParasiteRateDatasets()
  return(getLatestDatasetId(prDatasets, 'Global_Pv_Parasite_Rate_Surveys'))
}

#' Get the dataset id of the latest version of vector occurrence data
#'
#' @return The dataset id of the latest version of vector occurrence Data
#' @keywords internal
#'
getLatestDatasetIdForVecOccData <- function() {
  vecOccDatasets <- listVectorOccurrenceDatasets()
  return(getLatestDatasetId(vecOccDatasets, 'Global_Dominant_Vector_Surveys'))
}


#' Get the latest version of admin boundary data
#'
#' @return The latest version of admin boundary data
#' @keywords internal
#'
getLatestVersionForAdminData <- function() {
  adminDatasets <- listAdministrativeBoundariesDatasets()
  datasetNames <-
    future.apply::future_lapply(adminDatasets$dataset_id, get_name_from_wfs_feature_type_id)
  datasetNames <- do.call(rbind, datasetNames)
  adminDatasets$name <- datasetNames
  datasets_filtered_by_name <- subset(adminDatasets, name == 'Global_Admin_0')
  maxVersion <- max(datasets_filtered_by_name$version)
  return(maxVersion)
}

getDatasetIdForAdminDataGivenAdminLevelAndVersion <- function(admin_level, version) {
  admin_level_numeric <- gsub('admin', '', admin_level) 
  return(paste0('Admin_Units:', version, '_Global_Admin_', admin_level_numeric))
}

#' Builds a cql filter to be used with getFeatures, that will filter based on the given bounding box.
#'
#' @param bbox A matrix representing a bounding box.
#' @return The character string of the cql filter.
build_bbox_filter <- function(bbox) {
  minX <- bbox[2, 1]
  minY <- bbox[1, 1]
  maxX <- bbox[2, 2]
  maxY <- bbox[1, 2]
  bbox_filter <-
    paste(minX,
          ",",
          minY,
          ",",
          maxX,
          ",",
          maxY,
          ",EPSG:4326",
          sep = '')
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
  values_string <- paste(values, collapse = "', '")
  filter <-
    paste0(attribute, " IN ('", values_string, "')")
  return(filter)
}

#' Calls getFeatures on the given type with the given filters, where they are not NULL.
#'
#' @param feature_type Object of WFSFeatureType.
#' @param cql_filter A character string that reflects cql filter e.g. "time_start AFTER 2020-00-00T00:00:00Z AND country IN ('Nigeria')"
#' @param bbox_filter A character string that reflects bbox filter e.g. "120,130,178,187,EPSG:4326"
#' @return The features returned from the getFeatures called on the feature_type with the filter where not NULL.
#' @keywords internal
#'
callGetFeaturesWithFilters <-
  function(feature_type, cql_filter, bbox_filter, ...) {
    if (!is.null(cql_filter) & !is.null(bbox_filter)) {
      features <-
        feature_type$getFeatures(outputFormat = "json",
                                 cql_filter = cql_filter,
                                 bbox = bbox_filter)
    } else if (!is.null(cql_filter) & is.null(bbox_filter)) {
      features <-
        feature_type$getFeatures(outputFormat = "json", cql_filter = cql_filter)
    } else if (is.null(cql_filter) & !is.null(bbox_filter)) {
      features <-
        feature_type$getFeatures(outputFormat = "json", bbox = bbox_filter)
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
  
  cql_filter <- paste(cql_filters_not_null, collapse = ' AND ')
  if (length(cql_filter) == 0) {
    cql_filter <- NULL
  }
  return(cql_filter)
}

#' Get the WCS coverage summary for a raster ID.
#'
#' @param raster The raster ID.
#' @return A \link{WCSCoverageSummary} object from the \pkg{ows4R} package.
#' @keywords internal
#'
get_wcs_coverage_summary_from_raster_id <- function(raster) {
  id_parts <- get_workspace_and_version_from_coverage_id(raster)
  wcs_client <- getOption("malariaatlas.wcs_clients")[[id_parts$workspace]]
  coverageSummary <- wcs_client$getCapabilities()$findCoverageSummaryById(raster, exact = TRUE)
  coverageSummary
}

#' Get the WCS client for a raster ID.
#'
#' @param raster The raster ID.
#' @return A \link{WCSClient} object from the \pkg{ows4R} package.
#' @keywords internal
#'
get_wcs_client_from_raster_id <- function(raster) {
  id_parts <- get_workspace_and_version_from_coverage_id(raster)
  wcs_client <- getOption("malariaatlas.wcs_clients")[[id_parts$workspace]]
  wcs_client
}

