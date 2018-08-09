#' List countries with available MAP data.
#'
#' \code{listPoints} lists all countries for which there are publicly visible datapoints in the MAP database for a required dataset.
#'
#' @param printed Should the list be printed to the console?
#'
#' @return \code{listPoints} returns a data.frame detailing the countries for which data points are publicly available.
#'
#' @examples
#' \donttest{
#' listPoints()
#' }
#' @export listPoints



listPoints <- function(printed = TRUE, sourcedata) {
  if(sourcedata == "pr points"){
    message("Creating list of countries for which PR data is available, please wait...")
  } else if (sourcedata == "vector points"){
    message(" Creating list of countries for which vector occurrence data is available, please wait...")
  } else{
    stop("Source data not found, use one of: 'pr points' or 'vector points'.")
  } 
  
  if(exists('available_countries_stored_pr', envir = .malariaAtlasHidden)){
    available_countries_pr <- .malariaAtlasHidden$available_countries_stored_pr
  }else if(exists('available_countries_stored_vec', envir = .malariaAtlasHidden)){
    available_countries_vec <- .malariaAtlasHidden$available_countries_stored_vec
  }
    
    if((printed == TRUE) & (sourcedata ==  "pr points")){
      message("Countries with PR Data: \n ",paste(paste(available_countries_pr$country," (",available_countries_pr$country_id, ")", sep = ""), collapse = " \n "))
      return(invisible(available_countries_pr))
    } else if ((printed == TRUE) & (sourcedata == "vector points")){
      message("Countries with Vector Occurrence data: \n ",paste(paste(available_countries_vec$country," (",available_countries_vec$country_id, ")", sep = ""), collapse = " \n "))
      return(invisible(available_countries_vec))
  
    

    
  } else {
    
    if(tolower(sourcedata) == "pr points" ){
      URL <-
        "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=PR_Data"
      columns <- 
        "&PROPERTYNAME=country,country_id,continent_id"
      
      available_countries_pr <- unique(utils::read.csv(paste(URL, columns, sep = ""), encoding = "UTF-8")[,-1])
      available_countries_pr <- available_countries_pr[available_countries_pr$continent_id!= "",]
      names(available_countries_pr) <- c("country", "country_id", "continent")
      
    } else if(tolower(sourcedata) == "vector points"){
      URL <-
        "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=Anopheline_Data"
      columns <- 
        "&PROPERTYNAME=country,country_id,continent_id"
      
      available_countries_vec <- unique(utils::read.csv(paste(URL, columns, sep = ""), encoding = "UTF-8")[,-1])
      available_countries_vec <- available_countries_vec[available_countries_vec$continent_id!= "",]
      names(available_countries_vec) <- c("country", "country_id", "continent")
      
    } else {
      stop("source data not detected, use one of: 'pr points' or 'vector points'.")
    }
    

    
    if((printed == TRUE) & (sourcedata == "pr points")){
      message("Countries with PR Data: \n ",paste(paste(available_countries_pr$country," (",available_countries_pr$country_id, ")", sep = ""), collapse = " \n "))
      
      .malariaAtlasHidden$available_countries_stored_pr <- available_countries_pr
      
      return(invisible(available_countries_pr))
      
    } else if ((printed == TRUE) & (sourcedata == "vector points")){
      message("Countries with Vector Occurrence data: \n ",paste(paste(available_countries_vec$country," (",available_countries_vec$country_id, ")", sep = ""), collapse = " \n "))
      
      .malariaAtlasHidden$available_countries_stored_vec <- available_countries_vec
      
      return(invisible(available_countries_vec))
    }
    
  }
}
#listPoints()
#xx <-  listPoints(printed = FALSE, sourcedata = "")