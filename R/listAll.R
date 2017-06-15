#' List countries with available PR data.
#'
#' \code{listAll} lists all countries for which there are publicly visible PR datapoints in the MAP database.
#'
#' @return \code{listAll} returns a list of countries for which PR points are publicly available.
#'
#' @examples
#' listAll()
#' @export
listAll <- function(printed = TRUE) {
  message("Creating list of countries for which PR data is available, please wait...")
  x <- unique(read.csv("http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr&PROPERTYNAME=country,country_id", encoding = "UTF-8")[,c("country", "country_id")])
  x$country_and_iso <- paste(x$country," (",x$country_id, ")", sep = "")
  if(printed == TRUE){
    message("Countries with PR Data: \n ",paste(x$country_and_iso, collapse = " \n "))
  }

  return(invisible(x))
  }


#listAll()
#xx <-  listAll(printed = FALSE)



