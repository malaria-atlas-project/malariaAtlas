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
  
  if(exists('available_countries_stored', envir = .malariaAtlasHidden)){
    available_countries <- .malariaAtlasHidden$available_countries_stored
    
    #URL1 <- "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=PR_Data"
    #URL2 <- "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=Anopheline_Data"
    
    if(tolower(sourcedata) == "pr points" ){
      URL <-
        "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=PR_Data"
      columns <- 
        "&PROPERTYNAME=country,country_id,continent_id"
    }   else if(tolower(sourcedata) == "vector points"){
      URL <-
        "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=Anopheline_Data"
      columns <- 
        "&PROPERTYNAME=country,country_id,continent_id"
    }   else {
      stop("source data not detected, use one of: 'pr points' or 'vector points'.")
    }
    
    
    if((printed == TRUE) & (sourcedata ==  "pr points")){
      message("Countries with PR Data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
    }   else if ((printed == TRUE) & (sourcedata == "vector points")){
      message("Countries with Vector Occurrence data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
    }
    
    return(invisible(available_countries))
    
  } else {
    
    available_countries <- unique(utils::read.csv(paste(URL, columns, sep = ""), encoding = "UTF-8")[,-1])
    available_countries <- available_countries[available_countries$continent_id!= "",]
    names(available_countries) <- c("country", "country_id", "continent")
    
    
    
    if((printed == TRUE) & (sourcedata == "pr points")){
      message("Countries with PR Data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
    } else if ((printed == TRUE) & (sourcedata == "vector points")){
      message("Countries with Vector Occurrence data: \n ",paste(paste(available_countries$country," (",available_countries$country_id, ")", sep = ""), collapse = " \n "))
    }
    
    .malariaAtlasHidden$available_countries_stored <- available_countries
    
    return(invisible(available_countries))
  }
}
#listPoints()
#xx <-  listPoints(printed = FALSE, sourcedata = "")