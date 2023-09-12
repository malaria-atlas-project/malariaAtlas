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






