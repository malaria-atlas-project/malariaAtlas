#' Check whether PR points are available for a given country
#'
#' \code{is_available} checks whether the MAP database contains PR points for the specified country/countries.
#'
#' @return \code{is_available} returns a list of countries for which PR points are publicly available.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param full_results By default this is FALSE meaning the function only gives a message outlining whether specified country is available, if \code{full_results == TRUE}, the function returns a data.frame outlining data availability.
#'
#' @return if \code{full_results == TRUE}, a dataframe is returned with the following columns:
#' \enumerate{
#' \item \code{available} - those of the specified countries for which PR data points are available
#' \item \code{not_available}- those of the specified countries for which PR data points are not available
#' \item \code{possible_match}- agrep-matched country names indicating potential mispellings of countries marked as'not available'
#' }
#'
#' @examples
#' is_available(country = "Suriname")
#' x <- is_available(ISO = "NGA", full_results = TRUE)
#' @export





is_available <- function(country = NULL, ISO = NULL, full_results = FALSE) {


  capwords <- function(s, strict = FALSE) {
    cap <- function(s) paste(toupper(substring(s, 1, 1)),
                             {s <- substring(s, 2); if(strict) tolower(s) else s},
                             sep = "", collapse = " " )
    sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
  }


  if(!(is.null(country))){
    country_input <- as.character(capwords(country))
    country_input <- gsub("And", "and", country_input)
    available_countries <- listAll(printed = FALSE)$country
  } else if(!(is.null(ISO))){
    country_input <- as.character(toupper(ISO))
    if(nchar(country_input)!= 3){
      stop("Specifying by iso-code only works with ISO3, use listAll() to check available countries & their ISO3")
    }
    available_countries <- listAll(printed = FALSE)$country_id
  }


  message("Confirming availability of PR data for: ", paste(country_input, collapse = ", "), "...")

  checked_availability <- data.frame("available"=rep(NA,length = length(country_input)), "not_available"=rep(NA,length = length(country_input)), "possible_match"=rep(NA,length = length(country_input)))


  for(i in 1:length(unique(country_input))) {
    if(!(country_input[i] %in% available_countries)){
      checked_availability$not_available[i] <- country_input[i]

      matches <- agrep(checked_availability$not_available[i], x = available_countries, ignore.case = TRUE, value = TRUE, max.distance = 1)
      checked_availability$possible_match[i] <- paste(matches, collapse = " OR ")
    } else {
      checked_availability$available[i] <- country_input[i]
    }
    checked_availability$possible_match[checked_availability$possible_match %in% c("NULL","")] <- NA
  }


  if(FALSE %in% is.na(checked_availability$available)) {
    message("Data is available for ", paste(checked_availability$available[!is.na(checked_availability$available)], collapse = ", "), ".")
  }

  error_message <- character()

  if(FALSE %in% is.na(unique(checked_availability[,c("not_available","possible_match")]))){
    for(i in 1:length(checked_availability$not_available)) {

      if(!(checked_availability$possible_match[i] %in% c("character(0)","",NA))) {
        error_message[i] <- paste("Data not found for '",checked_availability$not_available[i],"', did you mean ", checked_availability$possible_match[i], "?", sep = "")
      } else {
        error_message[i] <- paste("Data not found for '",checked_availability$not_available[i],"', use listAll() to check data availability. ", sep = "")
      }
    }

    error_message <- error_message[grep('NA' , error_message,invert = TRUE)]
  }

  if(identical(checked_availability$not_available, country_input)) {
    stop("Specified countries not found, see below comments: \n \n",
         paste(error_message, collapse = " \n"))
  } else if (length(error_message) != 0) {
    warning(paste(error_message, collapse = " \n"),call. = FALSE)
  }


      if(full_results == TRUE) {

    return(checked_availability)

  }


}


# is_available(country = c("Australia", "xxxx"), full_results = TRUE)
# x <- is_available(country = c("Nigeria", "Madagascar", "São Tomé and Príncipe"), full_results = TRUE)
# x <- is_available(country = c("Nigeria", "Madagascar", "Sao Tome and Principe"), full_results = TRUE)
# x <- is_available(country = c("Kenya", "Australia", "Ngeria"), full_results = TRUE)
# x <- is_available(country = c("Krnya"), full_results = TRUE)
# x <- is_available(country = c("Madagascar"), full_results = TRUE)
