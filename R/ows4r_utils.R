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
  datasetNames <- future.apply::future_lapply(datasets$dataset_id, get_name_from_wfs_feature_type_id)
  datasetNames <- do.call(rbind, datasetNames)
  datasets$name <- datasetNames
  datasets_filtered_by_name <- subset(datasets, name==dataset_name)
  maxVersion <- max(datasets_filtered_by_name$version)
  datasets_filtered_by_name_and_version <- subset(datasets_filtered_by_name, version==maxVersion)
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







