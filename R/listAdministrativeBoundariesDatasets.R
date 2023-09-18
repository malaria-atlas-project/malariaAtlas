#' List all datasets from the Web Feature Services provided by the Malaria Atlas Project within the Admin Units workspace.
#' 
#' \code{listAdministrativeBoundariesDatasets} lists minimal information of all the feature datasets in the Admin Units workspace 
#' from the Web Feature Services provided by the Malaria Atlas Project.
#' 
#' @return A data.frame with columns 'dataset_id', 'version', and 'workspace' representing the unique identifier, version, and domain/workspace of the datasets.
#' The version can then be provided to other functions to fetch the data within that dataset. e.g. in getShp
#' @examples
#' \donttest{
#' vecOccDatasets <- listAdministrativeBoundariesDatasets()
#' @export listAdministrativeBoundariesDatasets

listAdministrativeBoundariesDatasets <- function(){
  cached <- .malariaAtlasHidden$list_admin_boundaries_datasets
  if(!is.null(cached)) {
    return(cached)
  }
  
  wfs_client <- get_wfs_clients()$Admin_Units
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
  
  .malariaAtlasHidden$list_admin_boundaries_datasets <- df_datasets # add to cache
  return(df_datasets)
}