#' List countries with available MAP Point data.
#'
#' \code{listPoints} lists all countries for which there are publicly visible datapoints in the MAP database required.
#'
#' @param printed Should the list be printed to the console?
#' @param sourcedata String contining desired dataset within the Malaria Atlas database to be searched, e.g \code{"pr points"} OR \code{"vector points"}
#'
#' @return \code{listPoints} returns a data.frame detailing the countries for which PR points are publicly available.
#'
#' @examples
#' \donttest{
#' listPoints(sourcedata = "pr points")
#' listPoints(sourcedata = "vector points")
#' }
#' @export listPoints
#' @importFrom rlang .data


listPoints <- function(printed = TRUE, sourcedata) {
  message("Creating list of countries for which MAP data is available, please wait...")

  if(sourcedata == "pr points"){

    # If we've already downloaded a list of available countries, print that.
    # Otherwise download a list from the geoserver
    
    if(exists('available_countries_stored_pr', envir = .malariaAtlasHidden)){
    available_countries_pr <- .malariaAtlasHidden$available_countries_stored_pr

      if(printed == TRUE){
        message("Countries with PR Data: \n ",paste(paste(available_countries_pr$country," (",available_countries_pr$country_id, ")", sep = ""), collapse = " \n "))
      }

      return(invisible(available_countries_pr))

    } else {
      
      available_countries_pr <- try(unique(utils::read.csv("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=PR_Data&PROPERTYNAME=country,country_id,continent_id", encoding = "UTF-8")[,c("country", "country_id","continent_id")]))
      if(inherits(available_countries_pr, 'try-error')){
        message(available_countries_pr[1])
        return(available_countries_pr)
      }
      
      
      available_countries_pr <- available_countries_pr[available_countries_pr$continent_id!= "",]
      names(available_countries_pr) <- c("country", "country_id", "continent")
  
      if(printed == TRUE){
          message("Countries with PR Data: \n ",paste(paste(available_countries_pr$country," (",available_countries_pr$country_id, ")", sep = ""), collapse = " \n "))
      }
  
      .malariaAtlasHidden$available_countries_stored_pr <- available_countries_pr
  
      return(invisible(available_countries_pr))
    }

  } else if(sourcedata == "vector points"){
      if(exists('available_countries_stored_vec', envir = .malariaAtlasHidden)){
      available_countries_vec <- .malariaAtlasHidden$available_countries_stored_vec
  
        if(printed == TRUE){
        message("Countries with vector occurrence data: \n ",paste(paste(available_countries_vec$country," (",available_countries_vec$country_id, ")", sep = ""), collapse = " \n "))
        }
  
        return(invisible(available_countries_vec))
  
      } else {
  
        available_countries_vec <- try(unique(utils::read.csv("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=PR_Data&PROPERTYNAME=country,country_id,continent_id", encoding = "UTF-8")[,c("country", "country_id","continent_id")]))
        if(inherits(available_countries_vec, 'try-error')){
          message(available_countries_vec[1])
          return(available_countries_vec)
        }
        
        available_countries_vec <- available_countries_vec[available_countries_vec$continent_id!= "",]
        names(available_countries_vec) <- c("country", "country_id", "continent")
  
        if(printed == TRUE){
          message("Countries with vector occurrence data: \n ",paste(paste(available_countries_vec$country," (",available_countries_vec$country_id, ")", sep = ""), collapse = " \n "))
        }
  
        .malariaAtlasHidden$available_countries_stored_vec <- available_countries_vec
  
        return(invisible(available_countries_vec))
      } 
   }  
}

