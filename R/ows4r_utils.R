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

