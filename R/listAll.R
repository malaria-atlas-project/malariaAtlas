#' List countries with available PR data.
#'
#' \code{listAll} lists all countries for which there are publicly visible PR datapoints in the MAP database.
#'
#' @return \code{listAll} returns a list of countries for which PR points are publicly available.
#'
#' @examples
#' listAll()
#' @export
listAll <- function(printed = TRUE) {
  message("Creating list of countries for which PR data is available, please wait...")

  # Check if we've made an environment called MAPdataHidden yet
  # If not make one.
  if(!exists(".MAPdataHidden", mode = 'environment')){
    .MAPdataHidden <- new.env(parent = .GlobalEnv)
  }

  # If we've already downloaded a list of available countries, print that.
  # Otherwise download a list from the geoserver
  if(exists('available_countries_stored', envir = .MAPdataHidden)){
    available_countries <- .MAPdataHidden$available_countries_stored

    if(printed == TRUE){
      message("Countries with PR Data: \n ",paste(available_countries$country_and_iso, collapse = " \n "))
    }

    return(invisible(available_countries))

  } else {

  available_countries <- unique(read.csv("http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr&PROPERTYNAME=country,country_id", encoding = "UTF-8")[,c("country", "country_id")])
  available_countries$country_and_iso <- paste(available_countries$country," (",available_countries$country_id, ")", sep = "")

  if(printed == TRUE){
    message("Countries with PR Data: \n ",paste(available_countries$country_and_iso, collapse = " \n "))
  }

  .MAPdataHidden$available_countries_stored <- available_countries

  return(invisible(available_countries))
  }
}

#listAll()
#xx <-  listAll(printed = FALSE)






