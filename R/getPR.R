#' Download PR points from the MAP database
#'
#' \code{getPR} downloads all publicly available PR points for a specified country (or countries) and returns this as a dataframe.
#'
#' \code{country} and \code{ISO} refer to countries and a lower-level administrative regions such as Mayotte and Grench Guiana.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param species string specifying the Plasmodium species for which to find PR points, options include: \code{"Pf"} OR \code{"Pv"} OR \code{"BOTH"}
#'
#'
#' @return \code{getPR} returns a dataframe containing the below columns, in which each row represents a distinct data point/ study site.
#'
#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' #Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
#' NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
#' \dontrun{autoplot(NGA_CMR_PR)}
#'
#' #Download PfPR data for Madagascar and map the locations of these points using autoplot
#' Madagascar_pr <- getPR(ISO = "MDG", species = "Pv")
#' \dontrun{autoplot(Madagascar_pr)}
#'
#' \dontrun{getPR(country = "ALL", species = "BOTH")}
#'
#'
#' @seealso \code{autoplot} method for quick mapping of PR point locations (\code{\link{autoplot.pr.points}}).
#'
#'
#' @export getPR

getPR <- function(country = NULL, ISO = NULL, continent = NULL, species) {

  if(exists('available_countries_stored', envir = .malariaAtlasHidden)){
    available_countries <- .malariaAtlasHidden$available_countries_stored
  }else{available_countries <- listPoints(printed = FALSE)}

URL <- "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr"

if(tolower(species) == "both") {

  columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

} else if(tolower(species) == "pf") {

  columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

} else if(tolower(species) == "pv") {

  columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

} else {stop("Species not recognized, use one of: \n   \"Pf\" \n   \"Pv\" \n   \"BOTH\"")}


if("ALL" %in% c(country, ISO)){
message(paste("Importing PR point data for all locations, please wait...", sep = ""))
df <-   utils::read.csv(paste(URL,columns,sep = ""), encoding = "UTF-8")[,-1]
message("Data downloaded for all available locations.")
}else{

  if(!(is.null(country))){
    cql_filter <- "country"
    column <- "country"
  } else if(!(is.null(ISO))){
    cql_filter <- "country_id"
    column <- "country_id"
  }else if(!(is.null(continent))){
    cql_filter <- "continent_id"
    column <- "continent"
  }

checked_availability <- isAvailable(country = country, ISO = ISO, continent = continent, full_results = TRUE)
message(paste("Importing PR point data for", paste(available_countries$country[available_countries[,column] %in% checked_availability$location[checked_availability$is_available==1]], collapse = ", "), "..."))
country_URL <- paste("%27",curl::curl_escape(gsub("'", "''", checked_availability$location[checked_availability$is_available==1])), "%27", sep = "", collapse = "," )
df <- utils::read.csv(paste(URL,
                            columns,
                            "&cql_filter=",cql_filter,"%20IN%20(",
                            country_URL,")", sep = ""), encoding = "UTF-8")[,-1]

message("Data downloaded for ", paste(checked_availability$location[checked_availability$is_available==1], collapse = ", "), ".")
}

if(tolower(species) == "both"){
  if(all(is.na(unique(df$pv_pos)))) {
    message("NOTE: All available data was downloaded for both species, but there are no PR points for P. vivax in the MAP database. \nTo check endemicity patterns or to contribute data, visit map.ox.ac.uk OR email us at map@well.ox.ac.uk.")
  }else if(all(is.na(unique(df$pf_pos)))){
    message("NOTE: All available data was downloaded for both species, but there are no PR points for P. falciparum in the MAP database. \nTo check endemicity patterns or to contribute data, visit map.ox.ac.uk OR email us at map@well.ox.ac.uk.")
  }
}

if(any(grepl("dhs", df$permissions_info))){
  message("NOTE: Downloaded data includes data points from DHS surveys. \nMAP cannot share DHS survey cluster coordinates, but these are available from www.measuredhs.com.")
}

class(df) <- c("pr.points",class(df))
return(df)

}

