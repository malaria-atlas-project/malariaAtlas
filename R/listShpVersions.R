#' List all versions of admin unit shapes from the Web Feature Services provided by the Malaria Atlas Project within the Admin Units workspace.
#' 
#' \code{listShpVersions} lists available versions of Admin Unit shapefiles from the Web Feature Services provided by the Malaria Atlas Project.
#' @param printed Should the list be printed to the console?
#' @return A data.frame with column 'version'.
#' The version can then be provided to other functions to fetch the data within that dataset. e.g. in getShp
#' @examples
#' \dontrun{
#' vecOccDatasets <- listShpVersions()
#' }
#' @export listShpVersions

listShpVersions <- function(printed = TRUE){
  cached <- .malariaAtlasHidden$list_shp_versions
  if(!is.null(cached)) {
    return(cached)
  }
  
  wfs_client <- get_wfs_clients()$Admin_Units
  wfs_cap <- wfs_client$getCapabilities()
  wfs_ft_types <- wfs_cap$getFeatureTypes()
  
  versions <- future.apply::future_lapply(wfs_ft_types, function(wfs_ft_type){
    id <- wfs_ft_type$getName()
    workspace_and_version <- get_workspace_and_version_from_wfs_feature_type_id(id)
    
    return(workspace_and_version$version)
  })
  
  versions <- unique(versions)
  
  df_versions <- as.data.frame(do.call(cbind, list(version=versions)))
  
  if(printed == TRUE){
    message("Versions available for admin unit shape data: \n ",paste(df_versions$version, collapse = " \n "))
  }
  
  .malariaAtlasHidden$list_shp_versions <- df_versions # add to cache
  return(invisible(df_versions))
}

