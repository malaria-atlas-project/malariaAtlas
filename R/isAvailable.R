#' Check whether PR points are available for a given country
#'
#' \code{isAvailable} checks whether the MAP database contains PR points for the specified country/countries.
#'
#' @return \code{isAvailable} returns a list of countries for which PR points are publicly available.
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
#' isAvailable(country = "Suriname")
#' x <- isAvailable(ISO = "NGA", full_results = TRUE)
#' @export isAvailable

isAvailable <- function(country = NULL, ISO = NULL, full_results = FALSE) {


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
    country_input <- sapply(country, capwords)
    available_countries <- available_countries$country
  } else if(!(is.null(ISO))){
    country_input <- as.character(toupper(ISO))
    if(nchar(country_input)!= 3){
      stop("Specifying by iso-code only works with ISO3, use listPoints() to check available countries & their ISO3")
    }
    available_countries <- available_countries$country_id
  }


  message("Confirming availability of PR data for: ", paste(country_input, collapse = ", "), "...")

  checked_availability <- list("country"= country_input, "is_available"=rep(NA,length = length(country_input)), "possible_match"=rep(NA,length = length(country_input)))


  for(i in 1:length(unique(country_input))) {
    if(!(country_input[i] %in% available_countries)){
      checked_availability$is_available[i] <- 0

      matches <- agrep(country_input[i], x = available_countries, ignore.case = TRUE, value = TRUE, max.distance = 1)
      checked_availability$possible_match[i] <- paste(matches, collapse = " OR ")
    } else {
      checked_availability$is_available[i] <- 1
    }
    checked_availability$possible_match[checked_availability$possible_match %in% c("NULL","")] <- NA
  }


  if(1 %in% checked_availability$is_available) {
    message("Data is available for ", paste(checked_availability$country[checked_availability$is_available==1], collapse = ", "), ".")
  }

  error_message <- character()

  if(0 %in% checked_availability$is_available){
    for(i in 1:length(checked_availability$country[checked_availability$is_available==0])){

      if(!(checked_availability$possible_match[checked_availability$is_available==0][i] %in% c("character(0)","",NA))) {
        error_message[i] <- paste("Data not found for '",checked_availability$country[checked_availability$is_available==0][i],"', did you mean ", checked_availability$possible_match[checked_availability$is_available==0][i], "?", sep = "")
      } else {
        error_message[i] <- paste("Data not found for '",checked_availability$country[checked_availability$is_available==0][i],"', use listPoints() to check data availability. ", sep = "")
      }
    }

  }
  if(identical(checked_availability$country[checked_availability$is_available==0], country_input)) {
    stop("Specified countries not found, see below comments: \n \n",
         paste(error_message, collapse = " \n"))
  } else if (length(error_message) != 0) {
    warning(paste(error_message, collapse = " \n"),call. = FALSE)
  }
      if(full_results == TRUE) {
    return(checked_availability)
  }
}


# isAvailable(country = c("Australia", "xxxx"), full_results = TRUE)
# x <- isAvailable(country = c("Nigeria", "Madagascar", "São Tomé and Príncipe"), full_results = TRUE)
# x <- isAvailable(country = c("Nigeria", "Madagascar", "Sao Tome and Principe"), full_results = TRUE)
# x <- isAvailable(country = c("Kenya", "Australia", "Ngeria"), full_results = TRUE)
# x <- isAvailable(country = c("Krnya"), full_results = TRUE)
# x <- isAvailable(country = c("Madagascar"), full_results = TRUE)
