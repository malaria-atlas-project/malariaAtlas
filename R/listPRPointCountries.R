



listPRPointCountries <- function(printed = TRUE, version = NULL) {
  message("Creating list of countries for which MAP data is available, please wait...")
  
  wfs_client <- get_wfs_clients()$Malaria
  
  if (is.null(version)) {
    version <- getLatestPRPointVersion()
    message(
      'Please Note: Because you did not provide a version, by default the version being used is ',
      version,
      ' (This is the most recent version of PR data. To see other version options use function listPRPointVersions)'
    )
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
