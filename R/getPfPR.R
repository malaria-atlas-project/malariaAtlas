




#' @examples
#' getPfPR(country = c("Nigeria", "Kenya"))
#' getPfPR(country = "ALL")

getPfPR <- function(country, myData = "subset") {

URL <- "http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pfpr"

if(country == "ALL") {
  message("Importing PfPR point data for all locations, please wait...")
  df <-   utils::read.csv(URL)
  assign("PfPR_points_ALL",df, envir = .GlobalEnv)

}else{
  message(paste("Importing PfPR point data for", paste(country, collapse = ", "), "please wait..."))
  country.list <- paste("%27",country, "%27", sep = "", collapse = "," )
  df <- utils::read.csv(paste(URL,"&cql_filter=country%20IN%20(",country.list,")", sep = ""))
  assign("PfPR_points_subset",df, envir = .GlobalEnv)
}
}














