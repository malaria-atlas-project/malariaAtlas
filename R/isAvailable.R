#' Check whether PR points are available for a given location
#'
#' \code{isAvailable} checks whether the MAP database contains PR points for the specified country/location.
#'
#' @return \code{isAvailable} returns a named list of input locations with information regarding data availability.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param continent  string containing name of continent for desired data, e.g. \code{c("Continent1", "Continent2", ...)}(use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param full_results By default this is FALSE meaning the function only gives a message outlining whether specified country is available, if \code{full_results == TRUE}, the function returns a named list outlining data availability.
#'
#' @return if \code{full_results == TRUE}, a named list is returned with the following elements:
#' \enumerate{
#' \item \code{location} - specified input locations
#' \item \code{is_available}- 1 or 0; indicating whether data is available for this location
#' \item \code{possible_match}- agrep-matched country names indicating potential mispellings of countries where is_available == 0; NA if data is available for this location.
#' }
#'
#' @examples
#' \donttest{
#' isAvailable(country = "Suriname")
#' x <- isAvailable(ISO = "NGA", full_results = TRUE)
#' x <- isAvailable(continent = "Oceania", full_results = TRUE)
#' }
#' @export isAvailable

isAvailable <- function(country = NULL, ISO = NULL, continent = NULL, full_results = FALSE) {


  if(exists('available_countries_stored', envir = .malariaAtlasHidden)){
    available_countries <- .malariaAtlasHidden$available_countries_stored
  }else{available_countries <- listPoints(printed = FALSE)}

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
      return(s)
    }

    string_return <- paste(sapply(unlist(strsplit(string, split = " ")), cap, USE.NAMES = !is.null(names(string))), collapse = " ")

    if(grepl("-",string)){
      string_return <- paste(sapply(unlist(strsplit(string, split = "-")), cap, USE.NAMES = !is.null(names(string))), collapse = "-")
    }
    return(string_return)
  }

  if(!(is.null(country))){
    location_input <- sapply(country, capwords)
    available_locs <- available_countries$country
  } else if(!(is.null(ISO))){
    location_input <- as.character(toupper(ISO))
    if(nchar(location_input)!= 3){
      stop("Specifying by iso-code only works with ISO3, use listPoints() to check available countries & their ISO3")
    }
    available_locs <- available_countries$country_id
  } else if(!(is.null(continent))){
    location_input <- sapply(continent, capwords)
    available_locs <- unique(available_countries$continent)
  }


  message("Confirming availability of PR data for: ", paste(location_input, collapse = ", "), "...")

  checked_availability <- list("location"= location_input, "is_available"=rep(NA,length = length(location_input)), "possible_match"=rep(NA,length = length(location_input)))


  for(i in 1:length(unique(location_input))) {
    if(!(location_input[i] %in% available_locs)){
      checked_availability$is_available[i] <- 0

      matches <- agrep(location_input[i], x = available_locs, ignore.case = TRUE, value = TRUE, max.distance = 1)
      checked_availability$possible_match[i] <- paste(matches, collapse = " OR ")
    } else {
      checked_availability$is_available[i] <- 1
    }
    checked_availability$possible_match[checked_availability$possible_match %in% c("NULL","")] <- NA
  }


  if(1 %in% checked_availability$is_available) {
    message("PR points are available for ", paste(checked_availability$location[checked_availability$is_available==1], collapse = ", "), ".")
  }

  error_message <- character()

  if(0 %in% checked_availability$is_available){
    for(i in 1:length(checked_availability$location[checked_availability$is_available==0])){

      if(!(checked_availability$possible_match[checked_availability$is_available==0][i] %in% c("character(0)","",NA))) {
        error_message[i] <- paste("Data not found for '",checked_availability$location[checked_availability$is_available==0][i],"', did you mean ", checked_availability$possible_match[checked_availability$is_available==0][i], "?", sep = "")
      } else {
        error_message[i] <- paste("Data not found for '",checked_availability$location[checked_availability$is_available==0][i],"', use listPoints() to check data availability. ", sep = "")
      }
    }

  }
  if(identical(checked_availability$location[checked_availability$is_available==0], location_input)) {
    stop("Specified location not found, see below comments: \n \n",
         paste(error_message, collapse = " \n"))
  } else if (length(error_message) != 0) {
    warning(paste(error_message, collapse = " \n"),call. = FALSE)
  }
      if(full_results == TRUE) {
    return(checked_availability)
  }
}


