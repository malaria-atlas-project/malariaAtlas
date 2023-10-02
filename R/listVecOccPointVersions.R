#' List all dataset versions from the Web Feature Services provided by the Malaria Atlas Project within the Vector Occurrence workspace.
#' 
#' \code{listVecOccPointVersions} lists available versions of all the feature datasets in the Vector Occurrence workspace 
#' from the Web Feature Services provided by the Malaria Atlas Project.
#' @param printed Should the list be printed to the console?
#' @return A data.frame with column 'version'.
#' The version can then be provided to other functions to fetch the data within that dataset. e.g. in getVecOcc 
#' @examples
#' \dontrun{
#' vecOccDatasets <- listVecOccPointVersions()
#' }
#' @export listVecOccPointVersions

listVecOccPointVersions <- function(printed = TRUE){
  wfs_client <- get_wfs_clients()$Vector_Occurrence
  wfs_cap <- wfs_client$getCapabilities()
  wfs_ft_types <- wfs_cap$getFeatureTypes()
  
  versions <- future.apply::future_lapply(wfs_ft_types, function(wfs_ft_type){
    id <- wfs_ft_type$getName()
    workspace_and_version <- get_workspace_and_version_from_wfs_feature_type_id(id)
    name <- get_name_from_wfs_feature_type_id(id)
    
    if(name == 'Global_Dominant_Vector_Surveys') {
      return(workspace_and_version$version)
    }
  })
  
  versions <- unique(versions)
  
  df_versions <- as.data.frame(do.call(cbind, list(version=versions)))
  
  if(printed == TRUE){
    message("Versions available for vector occurrence point data: \n ",paste(df_versions$version, collapse = " \n "))
  }
  
  return(invisible(df_versions))
  
}