#' List countries with available MAP Point data.
#'
#' \code{listPoints} lists all countries for which there are publicly visible datapoints in the MAP database required.
#'
#' @param printed Should the list be printed to the console?
#' @param sourcedata String contining desired dataset within the Malaria Atlas database to be searched, e.g \code{"pr points"} OR \code{"vector points"}
#' @param dataset_id A character string specifying the dataset ID. Is NULL by default, and the most recent version of the pr points or vector points will be selected. 
#' @return \code{listPoints} returns a data.frame detailing the countries for which PR points are publicly available.
#'
#' @examples
#' \donttest{
#' listPoints(sourcedata = "pr points")
#' listPoints(sourcedata = "vector points")
#' }
#' @export listPoints
#' @importFrom rlang .data


listPoints <- function(printed = TRUE, sourcedata, dataset_id = NULL) {
  message("Creating list of countries for which MAP data is available, please wait...")

  if(sourcedata == "pr points"){

    # If we've already downloaded a list of available countries, print that.
    # Otherwise download a list from the geoserver

    wfs_client <- get_wfs_client()$Malaria
    
    if(is.null(dataset_id)) {
      pf_dataset_id = getLatestDatasetIdForPfPrData()
      pv_dataset_id = getLatestDatasetIdForPvPrData()
      message('Please Note: Because you did not provide a dataset_id, by default the two datasets being used are ', pf_dataset_id, ' and ', 
              pv_dataset_id, ' (These are the most recent versions of parasite rate data. To see other dataset options use function listParasiteRateDatasets)')
      
      available_countries_pr_pf <- fetchCountriesGivenDatasetId(wfs_client, pf_dataset_id)
      available_countries_pr_pv <- fetchCountriesGivenDatasetId(wfs_client, pv_dataset_id)
      available_countries_pr <- unique(rbind(available_countries_pr_pf, available_countries_pr_pv))
    } else {
      available_countries_pr <- fetchCountriesGivenDatasetId(wfs_client, dataset_id)
    }

    if(printed == TRUE){
      message("Countries with PR Data: \n ",paste(paste(available_countries_pr$country," (",available_countries_pr$country_id, ")", sep = ""), collapse = " \n "))
    }
  
    return(invisible(available_countries_pr))
  
  } 
  
  if(sourcedata == "vector points"){

    wfs_client <- get_wfs_client()$Vector_Occurrence

    if(is.null(dataset_id)) {
      dataset_id <- getLatestDatasetIdForVecOccData()
      message('Please Note: Because you did not provide a dataset_id, by default the dataset being used is ', dataset_id, 
              ' (This is the most recent version of vector occurrence data. To see other dataset options use function listVectorOccurrenceDatasets)')
    }
    
    available_countries_vec <- fetchCountriesGivenDatasetId(wfs_client, dataset_id)
        
    if(printed == TRUE){
      message("Countries with vector occurrence data: \n ",paste(paste(available_countries_vec$country," (",available_countries_vec$country_id, ")", sep = ""), collapse = " \n "))
    }
  
    return(invisible(available_countries_vec))
   }  
}


#' Get the list of available countries for a given dataset_id in the Explorer workspace,
#'
#' @param dataset_id The dataset id from which to get the list of available countries from.
#' @return A dataframe with columns for country, country_id and continent_id
#' @keywords internal
#'
fetchCountriesGivenDatasetId <- function(wfs_client, dataset_id) {
  wfs_cap <- wfs_client$getCapabilities()
  wfs_feature_type <- wfs_cap$findFeatureTypeByName(dataset_id)
  suppressWarnings({
    features <- wfs_feature_type$getFeatures(outputFormat="json", propertyName='country,country_id,continent_id')
  })
  available_countries <- unique(data.frame(country = features$country, country_id = features$country_id, continent_id = features$continent_id))
  available_countries <- available_countries[available_countries$continent_id!= "",]
  available_countries <- na.omit(available_countries)
  return(available_countries)
}

