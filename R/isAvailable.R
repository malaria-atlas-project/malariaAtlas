#' Available data to download from the MAP geoserver.
#'
#' \code{isAvaiable} is a wrapper for isAvailable_pr and isAvailable_vec, listing data (PR survey point location data and vector occurrence locations available to download from the MAP geoserver.
#'
#' @return \code{isAvailable} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @param sourcedata One of 'pr points' or 'vector points'
#' @param full_results Should the list be printed to the console?
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param continent string containing continent for desired data, e.g. \code{c("continent1", "continent2", ...)} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ... passed on to isAvailable_vec and isAvailable_pr
#' @examples
#' \dontrun{
#' available_pr_locations <- isAvailable_pr(ISO = 'IDN')
#' available_vector_locations <- isAvailable_vec(ISO = 'IDN')
#' }
#' @seealso
#' \code{link{isAvailable_pr}}
#' \code{\link{isAvailable_vec}}
#'
#' @export isAvailable

isAvailable <- function(sourcedata = NULL, full_results = FALSE, country = NULL, ISO = NULL, continent = NULL, ...){
  
  if(!sourcedata %in% c("vector points", "pr points")){
    stop("Please choose one of:\n sourcedata = \"pr points\"  \n sourcedata = \"vector points\"")
  }
  
  if(sourcedata == "pr points"){
   isAvailable_pr(sourcedata = sourcedata, country = country, ISO = ISO, continent = continent, full_results = full_results, ...)      
  }else if(sourcedata == "vector points"){
    isAvailable_vec(sourcedata = sourcedata, country = country, ISO = ISO, continent = continent, full_results = full_results, ...)
  }
  
}

