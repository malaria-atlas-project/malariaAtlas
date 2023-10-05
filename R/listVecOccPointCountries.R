#' List countries where there is vector occurrence point data available
#'
#' \code{listVecOccPointCountries} 
#' @return \code{listVecOccPointCountries} returns a data.frame detailing the countries for which vector occurrence points are publicly available.
#'
#' @param printed Should the list be printed to the console?
#' @param version (optional) The vector occurrence dataset version to use If not provided, will just use the most recent version of vector occurrence data. (To see available version options, 
#' use listVecOccPointVersions)
#' 
#' @export listVecOccPointCountries

listVecOccPointCountries <- function(printed = TRUE, version = NULL) {
  if(printed == TRUE) {
    message(
      "Creating list of countries for which MAP vector occurrence point data is available, please wait..."
    )
  }

  wfs_client <- get_wfs_clients()$Vector_Occurrence
  
  if (is.null(version)) {
    version <- getLatestVecOccPointVersion()
    message('Please Note: Because you did not provide a version, by default the version being used is ', version, 
            ' (This is the most recent version of vector data. To see other version options use function listVecOccPointVersions)')
  } else {
    df_available_versions <- listVecOccPointVersions(printed = FALSE)
    if (!version %in% df_available_versions$version) {
      stop(
        paste0(
          'Version provided is not valid. Valid versions for vector point data can be found using listVecOccPointVersions() and are ["',
          paste(df_available_versions$version, collapse = '", "'),
          '"]. Otherwise, you can choose to not specify a version, and the most recent version will be automatically selected'
        )
      )
    }
  }
  
  vec_dataset_id <- getVecOccPointDatasetIdFromVersion(version)
  
  available_countries_vec <-
    fetchCountriesGivenDatasetId(wfs_client, vec_dataset_id)
  
  if (printed == TRUE) {
    message("Countries with vector occurrence point data: \n ",
            paste(
              paste(
                available_countries_vec$country,
                " (",
                available_countries_vec$country_id,
                ")",
                sep = ""
              ),
              collapse = " \n "
            ))
  }
  
  return(invisible(available_countries_vec))
  
}
