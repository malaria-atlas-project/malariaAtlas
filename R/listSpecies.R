#' list all species which have occurrence data within the MAP database.
#' 
#' \code{listSpecies} lists all species occurrence data available to download from the Malaria Atlas Project database.
#' @param printed should the list be printed to the database.
#' @param dataset_id A character string specifying the dataset ID. Is NULL by default, and the most recent version of the vector points dataset will be selected. 
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

listSpecies <- function(printed = TRUE, dataset_id = NULL){
  message("Downloading list of available species, please wait...")
  
  if(is.null(dataset_id)) {
    dataset_id <- getLatestDatasetIdForVecOccData()
    message('Please Note: Because you did not provide a dataset_id, by default the dataset being used is ', dataset_id, 
            ' (This is the most recent version of vector occurrence data. To see other dataset options use function listVecOccPointVersions)')
  }

  wfs_client <- get_wfs_clients()$Vector_Occurrence
  wfs_cap <- wfs_client$getCapabilities()
  wfs_ft_type <- wfs_cap$findFeatureTypeByName(dataset_id)
  
  suppressWarnings({
    features <- wfs_ft_type$getFeatures(outputFormat = "json", propertyName='species_plain,country')
  })
  
  species <- unique(sf::st_drop_geometry(features[,c("species_plain", "country")]))

  if(printed == TRUE){
    message("Species with availale data: \n ",paste(paste(species$species_plain, " (",species$country, ")", sep = ""), collapse = " \n "))
  }
  return(invisible(species))
  
}

  
  