#' Available data to download from the MAP geoserver.
#'
#' \code{availableData} is a wrapper for isAvailable_pr and isAvailable_vec, listing data (PR survey point location data and vector occurrence locations available to download from the MAP geoserver.
#'
#' @return \code{availableData} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @param sourcedata One of 'pr points' or 'vector points'
#' @param full_results Should the list be printed to the console?
#' @examples
#' \donttest{
#' available_pr_locations <- isAvailable_pr()
#' available_vector_locations <- isAvailable_vec()
#' }
#' @seealso
#' \code{link{isAvailable_pr}}
#' \code{\link{isAvailable_vec}}
#'
#' @export AvailableData

availableData <- function(sourcedata = NULL, full_results = FALSE, country = NULL, ISO = NULL, continent = NULL){
  
  if(is.null(sourcedata)){
    message("Choose a type of data using one of: \n sourcedata = \"pr points\"  \n sourcedata = \"vector points\"")
  }
  
  if(sourcedata == "pr points"){
   isAvailable_pr(sourcedata = "pr points", country = country, ISO = ISO, continent = continent, full_results = full_results)      
  }else if(sourcedata == "vector points"){
    isAvailable_vec(sourcedata = "vector points", country = country, ISO = ISO, continent = continent, full_results = full_results)
  }
  
}

