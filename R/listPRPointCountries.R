#' List countries where there is pr point data available
#'
#' \code{listPRPointCountries} 
#' @return \code{listPRPointCountries} returns a data.frame detailing the countries for which PR points are publicly available.
#'
#' @param printed Should the list be printed to the console?
#' @param version (optional) The PR dataset version to use If not provided, will just use the most recent version of PR data. (To see available version options, 
#' use listPRPointVersions)
#' 
#' @export listPRPointCountries

listPRPointCountries <- function(printed = TRUE, version = NULL) {
  if(printed == TRUE) {
    message("Creating list of countries for which MAP data is available, please wait...")
  }
  
  wfs_client <- get_wfs_clients()$Malaria

  if (is.null(version)) {
    version <- getLatestPRPointVersion()
    message('Please Note: Because you did not provide a version, by default the version being used is ', version, 
            ' (This is the most recent version of PR data. To see other version options use function listPRPointVersions)')
  } else {
    df_available_versions <- listPRPointVersions(printed = FALSE)
    if (!version %in% df_available_versions$version) {
      stop(
        paste0(
          'Version provided is not valid. Valid versions for PR point data can be found using listPRPointVersions() and are ["',
          paste(df_available_versions$version, collapse = '", "'),
          '"]. Otherwise, you can choose to not specify a version, and the most recent version will be automatically selected'
        )
      )
    }
  }
  
  pf_dataset_id <- getPfPRPointDatasetIdFromVersion(version)
  pv_dataset_id <- getPvPRPointDatasetIdFromVersion(version)
  
  available_countries_pr_pf <-
    fetchCountriesGivenDatasetId(wfs_client, pf_dataset_id)
  available_countries_pr_pv <-
    fetchCountriesGivenDatasetId(wfs_client, pv_dataset_id)
  available_countries_pr <-
    unique(rbind(available_countries_pr_pf, available_countries_pr_pv))
  
  if (printed == TRUE) {
    message("Countries with PR point data: \n ", paste(
      paste(
        available_countries_pr$country,
        " (",
        available_countries_pr$country_id,
        ")",
        sep = ""
      ),
      collapse = " \n "
    ))
  }
  
  return(invisible(available_countries_pr))
  
  
}
