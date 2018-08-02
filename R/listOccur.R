#' List countries with available vecto occurrrence Data, copy of listPoints function but how else to change the message that is returned.
#'
#' \code{listPoints} lists all countries for which there are publicly visible vector occurrence dataponints in the MAP database.
#'
#' @param printed Should the list be printed to the console?
#'
#' @return \code{listPoints} returns a data.frame detailing the countries for which vector occurrences are publicly available.
#'
#' @examples
#' \donttest{
#' listOccur()
#' }
#' @export listOccur


listOccur <- function(printed = TRUE) {
  message("Creating list of countries for which vector occurrence data is available, please wait...")
  
  
  # If we've already downloaded a list of available countries, print that.
  # Otherwise download a list from the geoserver
  if(exists('available_countries_stored', envir = .malariaAtlasHidden)){
    available_countries <- .malariaAtlasHidden$available_countries_stored
    
    if(printed == TRUE){
      message("Countries with vector occurrences Data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
    }
    
    return(invisible(available_countries))
    
  } else {
    
    available_countries <- unique(utils::read.csv("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=Anopheline_Data&PROPERTYNAME=country,country_id", encoding = "UTF-8")[,c("country", "country_id")])
    names(available_countries) <- c("country", "country_id")
    
    if(printed == TRUE){
      message("Countries with Vector Occurrence Data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
    }
    
    .malariaAtlasHidden$available_countries_stored <- available_countries
    
    return(invisible(available_countries))
  }
}
#listOccur()
#xx <-  listOccur(printed = FALSE)



