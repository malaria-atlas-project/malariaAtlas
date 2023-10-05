#' Deprecated function. Please instead use listPRPointCountries for pr points, and listVecOccPointCountries for vector points
#'
#' \code{listPoints} deprecated function Please remove it from your code.
#' 
#' @param printed whether to pretty print the output in console
#' @param sourcedata "pr points" or "vector points"
#' @param version (optional) The PR dataset version to use If not provided, will just use the most recent version of PR data. (To see available version options, 
#' use listPRPointVersions)
#' 
#' @export listPoints
#' @importFrom rlang .data

listPoints <- function(printed = TRUE, sourcedata, version = NULL) {
  
  lifecycle::deprecate_warn("1.6.0", "listPoints()", details = "The function 'listPoints' has been deprecated. It will be removed in the next version. Please switch to using listPRPointCountries for pr points, and listVecOccPointCountries for vector points.")

  if(sourcedata == "pr points"){

    available_countries_pr <- listPRPointCountries(printed = printed, version = version)
  
    return(invisible(available_countries_pr))
  } 
  
  if(sourcedata == "vector points"){
    
    available_countries_vec <- listVecOccPointCountries(printed = printed, version = version)
        
    return(invisible(available_countries_vec))
   }  
}




