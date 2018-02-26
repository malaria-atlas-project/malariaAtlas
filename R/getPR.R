#' Download PR points from the MAP database
#'
#' \code{getPR} downloads all publicly available PR points for a specified country (or countries) and returns this as a dataframe.
#'
#' \code{country} and \code{ISO} refer to countries and a lower-level administrative regions such as Mayotte and Grench Guiana.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param continent string containing continent for desired data, e.g. \code{c("continent1", "continent2", ...)} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param species string specifying the Plasmodium species for which to find PR points, options include: \code{"Pf"} OR \code{"Pv"} OR \code{"BOTH"}
#' @param extent 2x2 matrix specifying the spatial extent within which PR data is desired, as returned by sp::bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max"))))
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

getPR <- function(country = NULL, ISO = NULL, continent = NULL, species, extent = NULL) {

  if(exists('available_countries_stored', envir = .malariaAtlasHidden)){
    available_countries <- .malariaAtlasHidden$available_countries_stored
  }else{available_countries <- listPoints(printed = FALSE)}

  if(is.null(country)&is.null(ISO)&is.null(continent)&is.null(extent)){
    stop("Must specify one of: 'country', 'ISO', 'continent', or 'extent'.")
  }


URL <- "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr"

if(tolower(species) == "both") {

  columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

} else if(tolower(species) == "pf") {

  columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

} else if(tolower(species) == "pv") {

  columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

} else {stop("Species not recognized, use one of: \n   \"Pf\" \n   \"Pv\" \n   \"BOTH\"")}


if("all" %in% tolower(c(country, ISO))){
message(paste("Importing PR point data for all locations, please wait...", sep = ""))
df <-   utils::read.csv(paste(URL,columns,sep = ""), encoding = "UTF-8")[,-1]
message("Data downloaded for all available locations.")
}else{

  if(any(c(!is.null(country), !is.null(ISO), !is.null(continent)))){
  if(!(is.null(country))){
    cql_filter <- "country"
    colname <- "country"
  } else if(!(is.null(ISO))){
    cql_filter <- "country_id"
    colname <- "country_id"
  }else if(!(is.null(continent))){
    cql_filter <- "continent_id"
    colname <- "continent"
  }

checked_availability <- isAvailable(country = country, ISO = ISO, continent = continent, full_results = TRUE)
message(paste("Importing PR point data for", paste(available_countries$country[available_countries[,colname] %in% checked_availability$location[checked_availability$is_available==1]], collapse = ", "), "..."))
country_URL <- paste("%27",curl::curl_escape(gsub("'", "''", checked_availability$location[checked_availability$is_available==1])), "%27", sep = "", collapse = "," )
full_URL <-paste(URL,
                 columns,
                 "&cql_filter=",cql_filter,"%20IN%20(",
                 country_URL,")", sep = "")
  }else if(!is.null(extent)){

    bbox_filter <- paste0("&srsName=EPSG:4326&bbox=",extent[2,1],",",extent[1,1],",",extent[2,2],",",extent[1,2])
    full_URL <- paste0(URL, columns, bbox_filter)
  }


df <- utils::read.csv(full_URL, encoding = "UTF-8")[,-1]

if(!nrow(df)>0 & !is.null(extent)){
  stop("Error in downloading data for extent: (", paste0(extent, collapse = ","),"),\n try query using country or continent name OR check data availability at map.ox.ac.uk/explorer.")
}

if(any(c(!is.null(country), !is.null(ISO), !is.null(continent)))){
message("Data downloaded for ", paste(checked_availability$location[checked_availability$is_available==1], collapse = ", "), ".")
}else if(!is.null(extent)){
  message("Data downloaded for extent: ", paste0(extent, collapse = ","))
}

}

if(tolower(species) == "both"){
  if(all(is.na(unique(df$pv_pos)))) {
    message("NOTE: All available data for this query was downloaded for both species,\n but there are no PR points for P. vivax in this region in the MAP database. \nTo check endemicity patterns or to contribute data, visit map.ox.ac.uk OR email us at map@bdi.ox.ac.uk.")
  }else if(all(is.na(unique(df$pf_pos)))){
    message("NOTE: All available data for this query was downloaded for both species,\n but there are no PR points for P. falciparum in this region in the MAP database. \nTo check endemicity patterns or to contribute data, visit map.ox.ac.uk OR email us at map@bdi.ox.ac.uk.")
  }
}

if(any(grepl("dhs", df$permissions_info))){
  message("NOTE: Downloaded data includes data points from DHS surveys. \nMAP cannot share DHS survey cluster coordinates, but these are available from www.measuredhs.com.")
}

class(df) <- c("pr.points",class(df))

# removing points that are publicly available but are for the opposite species to what is currently queried.
if(tolower(species) == "pf"){
  df <- df[!(is.na(df$pf_pr)&df$permissions_info==""),]
}else if(tolower(species) == "pv"){
  df <- df[!(is.na(df$pv_pr)&df$permissions_info==""),]
  }

return(df)

}

