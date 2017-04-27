#'
#'
#'
#'
#'
#'
#'
#'
#'

listAll <- function() {
  message("Creating list of countries for which data is available, please wait...")
  x <- read.csv("http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pfpr&PROPERTYNAME=country")
  print("Countries with PfPR Data:")
  return(unique(x$country))
  }

listAll()

