#' List countries with available PR data.
#'
#' \code{listAll} lists all countries for which there are publicly available PR datapoints.
#'
#' @return \code{listAll} returns a list of countries for which PR points are publicly available.
#'
#' @examples
#' listAll()
#' @export
listAll <- function() {
  message("Creating list of countries for which PR data is available, please wait...")
  x <- utils::read.csv("http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr&PROPERTYNAME=country", encoding = "UTF-8")
  message("Countries with PR Data: \n ",paste(levels(x$country), collapse = " \n "))
  return(invisible(levels(x$country)))
  }


#xx <-  listAll()



