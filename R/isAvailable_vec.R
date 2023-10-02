#' Check whether Vector Occurrence points are available for a given location
#'
#' \code{isAvailable_vec} checks whether the MAP database contains Vector Occurrence points for the specified country/location.
#'
#' @return \code{isAvailable_Vec} returns a named list of input locations with information regarding data availability.
#'
#' @param sourcedata deprecated argument. Please remove it from your code.
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param continent  string containing name of continent for desired data, e.g. \code{c("Continent1", "Continent2", ...)}(use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param full_results By default this is FALSE meaning the function only gives a message outlining whether specified country is available, if \code{full_results == TRUE}, the function returns a named list outlining data availability.
#' @param version (optional) The vector points dataset version to use. If not provided, will just use the most recent version of vector points data. (To see available version options, 
#' use listVecOccPointVersions)
#' 
#' @return if \code{full_results == TRUE}, a named list is returned with the following elements:
#' \enumerate{
#' \item \code{location} - specified input locations
#' \item \code{is_available}- 1 or 0; indicating whether data is available for this location
#' \item \code{possible_match}- agrep-matched country names indicating potential mispellings of countries where is_available == 0; NA if data is available for this location.
#' }
#'
#' @examples
#' \dontrun{
#' isAvailable_vec(country = "Suriname")
#' x <- isAvailable_vec(ISO = "NGA", full_results = TRUE)
#' x <- isAvailable_vec(continent = "Oceania", full_results = TRUE)
#' }
#' @export isAvailable_vec

isAvailable_vec <- function(sourcedata = NULL, country = NULL, ISO = NULL, continent = NULL, full_results = FALSE, version = NULL) {
  
  if (!is.null(sourcedata)) {
    lifecycle::deprecate_warn("1.6.0", "isAvailable_vec(sourcedata)", details = "The argument 'sourcedata' has been deprecated. It will be removed in the next version. It has no meaning.")
  }
  
  if(is.null(country) & is.null(ISO) & is.null(continent)){
    stop('Must specify one of country, ISO or continent.')
  }
  
  available_countries_vec <- listVecOccPointCountries(printed = FALSE, version = version)
  
  capwords <- function(string) {
    cap <- function(s) {
      
      if(grepl("\\(", s)){
        l1 <- toupper(substring(s, 2, 2))
      }else{
        l1 <- toupper(substring(s, 1, 1))
      }
      
      if(grepl("\\(", s)){
        l2 <- tolower(substring(s, 3))
      }else{
        l2 <- tolower(substring(s, 2))
      }
      
      if(grepl("\\(", s)){
        s <- paste(strtrim(s,1),l1,l2,sep = "", collapse = " ")
      }else{
        s <- paste(l1,l2,sep = "", collapse = " ")
      }
      
      if(grepl("d'ivo",s, ignore.case = TRUE)){
        s <- gsub("d'ivo", "d'Ivo",s, ignore.case = TRUE)
      }
      if(grepl("of",s, ignore.case = TRUE)){
        s <- gsub("of", "of",s, ignore.case = TRUE)
      }
      if(grepl("the",s, ignore.case = TRUE)& !grepl("gambia", string, ignore.case =TRUE)){
        s <- gsub("the", "the",s, ignore.case = TRUE)
      }
      if(grepl("and",s, ignore.case = TRUE)){
        s <- gsub("and", "and",s, ignore.case = TRUE)
      }
      if(grepl("Former",s, ignore.case = TRUE)){
        s <- gsub("Former", "former",s, ignore.case = TRUE)
      }
      return(s)
    }
    
    string_return <- paste(sapply(unlist(strsplit(string, split = " ")), cap, USE.NAMES = !is.null(names(string))), collapse = " ")
    
    if(grepl("-",string)){
      string_return <- paste(sapply(unlist(strsplit(string, split = "-")), cap, USE.NAMES = !is.null(names(string))), collapse = "-")
    }
    return(string_return)
  }
  
  if(!(is.null(country))){
    location_input_vec <- sapply(country, capwords)
    available_locs_vec <- available_countries_vec$country
  } else if(!(is.null(ISO))){
    location_input_vec <- as.character(toupper(ISO))
    if(nchar(location_input_vec)!= 3){
      stop("Specifying by iso-code only works with ISO3, use listVecOccPointCountries() to check available countries & their ISO3")
    }
    available_locs_vec <- available_countries_vec$country_id
  } else if(!(is.null(continent))){
    location_input_vec <- sapply(continent, capwords)
    available_locs_vec <- unique(available_countries_vec$continent)
  }
  
  
  message("Confirming availability of Vector data for: ", paste(location_input_vec, collapse = ", "), "...")
  
  checked_availability_vec <- list("location"= location_input_vec, "is_available"=rep(NA,length = length(location_input_vec)), "possible_match"=rep(NA,length = length(location_input_vec)))
  
  
  for(i in 1:length(unique(location_input_vec))) {
    if(!(location_input_vec[i] %in% available_locs_vec)){
      checked_availability_vec$is_available[i] <- 0
      
      matches <- agrep(location_input_vec[i], x = available_locs_vec, ignore.case = TRUE, value = TRUE, max.distance = 1)
      checked_availability_vec$possible_match[i] <- paste(matches, collapse = " OR ")
    } else {
      checked_availability_vec$is_available[i] <- 1
    }
    checked_availability_vec$possible_match[checked_availability_vec$possible_match %in% c("NULL","")] <- NA
  }
  
  
  if(1 %in% checked_availability_vec$is_available) {
    message("Vector points are available for ", paste(checked_availability_vec$location[checked_availability_vec$is_available==1], collapse = ", "), ".")
  }
  
  error_message <- character()
  
  if(0 %in% checked_availability_vec$is_available){
    for(i in 1:length(checked_availability_vec$location[checked_availability_vec$is_available==0])){
      
      if(!(checked_availability_vec$possible_match[checked_availability_vec$is_available==0][i] %in% c("character(0)","",NA))) {
        error_message[i] <- paste("Data not found for '",checked_availability_vec$location[checked_availability_vec$is_available==0][i],"', did you mean ", checked_availability_vec$possible_match[checked_availability_vec$is_available==0][i], "?", sep = "")
      } else {
        error_message[i] <- paste("Data not found for '",checked_availability_vec$location[checked_availability_vec$is_available==0][i],"', use listVecOccPointCountries() to check data availability. ", sep = "")
      }
    }
    
  }
  if(identical(checked_availability_vec$location[checked_availability_vec$is_available==0], location_input_vec)) {
    message("Specified location not found, see below comments: \n \n",
         paste(error_message, collapse = " \n"))
  } else if (length(error_message) != 0) {
    warning(paste(error_message, collapse = " \n"),call. = FALSE)
  }
  if(full_results == TRUE) {
    return(checked_availability_vec)
  }
}