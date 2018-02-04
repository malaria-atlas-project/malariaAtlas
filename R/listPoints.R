#' List countries with available PR Point data.
#'
#' \code{listPoints} lists all countries for which there are publicly visible PR datapoints in the MAP database.
#'
#' @return \code{listPoints} returns a data.frame detailing the countries for which PR points are publicly available.
#'
#' @examples
#' listPoints()
#' @export listPoints


listPoints <- function(printed = TRUE) {
  message("Creating list of countries for which PR data is available, please wait...")


  # If we've already downloaded a list of available countries, print that.
  # Otherwise download a list from the geoserver
  if(exists('available_countries_stored', envir = .malariaAtlasHidden)){
    available_countries <- .malariaAtlasHidden$available_countries_stored

    if(printed == TRUE){
      message("Countries with PR Data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
    }

    return(invisible(available_countries))

  } else {

  available_countries <- unique(utils::read.csv("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr&PROPERTYNAME=country,country_id", encoding = "UTF-8")[,c("country", "country_id")])

  if(printed == TRUE){
    message("Countries with PR Data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
  }

  .malariaAtlasHidden$available_countries_stored <- available_countries

  return(invisible(available_countries))
  }
}
#listPoints()
#xx <-  listPoints(printed = FALSE)






