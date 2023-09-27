#' list all species which have occurrence data within the MAP database.
#' 
#' \code{listSpecies} lists all species occurrence data available to download from the Malaria Atlas Project database.
#' @param printed should the list be printed to the database.
#' @param version (optional) The vector dataset version to use If not provided, will just use the most recent version of vector dataset data. (To see available version options, 
#' use listVecOccPointVersions)
#' @return \code{listSpecies} returns a data.frame detailing the following information for each species available to download from the Malaria Atlas Project database.
#' 
#' \enumerate{
#' \item \code{species} string detailing species
#' }
#' 
#' @examples
#' \donttest{
#' available_species <- listSpecies()
#' }
#' 
#' @export listSpecies

listSpecies <- function(printed = TRUE, version = NULL){
  message("Downloading list of available species, please wait...")
  
  if (is.null(version)) {
    version <- getLatestVecOccPointVersion()
    message('Please Note: Because you did not provide a version, by default the version being used is ', version, 
            ' (This is the most recent version of vector data. To see other version options use function listVecOccPointVersions)')
  }
  
  vec_dataset_id <- getVecOccPointDatasetIdFromVersion(version)
  
  wfs_client <- get_wfs_clients()$Vector_Occurrence
  wfs_cap <- wfs_client$getCapabilities()
  wfs_ft_type <- wfs_cap$findFeatureTypeByName(vec_dataset_id)
  
  suppressWarnings({
    features <- wfs_ft_type$getFeatures(outputFormat = "json", propertyName='species_plain,country')
  })
  
  species <- unique(sf::st_drop_geometry(features[,c("species_plain", "country")]))

  if(printed == TRUE){
    message("Species with availale data: \n ",paste(paste(species$species_plain, " (",species$country, ")", sep = ""), collapse = " \n "))
  }
  return(invisible(species))
  
}

  
  