#' Deprecated function. Please instead use listPRPointCountries for pr points, and listVecOccPointCountries for vector points
#'
#' \code{listPoints} deprecated function Please remove it from your code.
#'
#' @export listPoints
#' @importFrom rlang .data

listPoints <- function(printed = TRUE, sourcedata, version = NULL) {
  
  lifecycle::deprecate_warn("1.5.0", "listPoints()", details = "The function 'listPoints' has been deprecated. It will be removed in the next version. Please switch to using listPRPointCountries for pr points, and listVecOccPointCountries for vector points.")

  if(sourcedata == "pr points"){

    available_countries_pr <- listPRPointCountries(printed = printed, version = version)
  
    return(invisible(available_countries_pr))
  } 
  
  if(sourcedata == "vector points"){
    
    available_countries_vec <- listVecOccPointCountries(printed = printed, version = version)
        
    return(invisible(available_countries_vec))
   }  
}




