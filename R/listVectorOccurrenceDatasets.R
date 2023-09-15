#' List all datasets from the Web Feature Services provided by the Malaria Atlas Project within the Vector Occurrence workspace.
#' 
#' \code{listVectorOccurrenceDatasets} lists minimal information of all the feature datasets in the Vector Occurrence workspace 
#' from the Web Feature Services provided by the Malaria Atlas Project.
#' 
#' @return A data.frame with columns 'dataset_id', 'version', and 'workspace' representing the unique identifier, version, and domain/workspace of the datasets.
#' The dataset_id can then be provided to other functions to fetch the data within that dataset. e.g. in getVecOcc 
#' @examples
#' \donttest{
#' vecOccDatasets <- listVectorOccurrenceDatasets()
#' @export listVectorOccurrenceDatasets

listVectorOccurrenceDatasets <- function(){
  wfs_client <- get_wfs_client()$Vector_Occurrence
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