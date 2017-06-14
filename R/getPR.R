#' Download publicly available PR points from MAP's geoserver.
#'
#' \code{getPR} downloads all publicly available PR points for a specified country and returns this as a dataframe.
#'
#'
#' @param country \code{ = c("Country1", "Country2", ...)} OR \code{ = "ALL"}
#'
#' specifies which country/countries you wish to include in your download
#' @return \code{getPR} returns a dataframe containing the below columns, in which each row represents a distinct data point/ study site.
#'
#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' getPR(country = c("Nigeria", "Kenya"), species = "Pf")
#' getPR(country = "ALL", species = "Pv")
#' @export

getPR <- function(country, species) {

  URL <- "http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr"

  country <- as.character(country)

  message("Confirming availability of PR data for: ", paste(country, collapse = ", "), "...")
  available_countries <- listAll(printed = FALSE)

country_list <- list()
unused_countries <- list()
agrep_list <- list()

  for(i in 1:length(unique(country))) {
    if(!(country[i] %in% available_countries)){
      unused_countries[i] <- country[i]

      matches <- agrep(unused_countries[i], x = available_countries, ignore.case = TRUE, value = TRUE, max.distance = 1)
      agrep_list[i] <- paste(matches, collapse = " OR ")
      } else {
      country_list[i] <- country[i]
      }
    }

if(length(agrep_list) != 0){
agrep_list[agrep_list == "NULL"] <- NA

  x <- character()
  for(i in 1:length(unused_countries)) {

      if(!(agrep_list[i] %in% c("character(0)","","NA"))) {
      x[i] <- paste("Data not found for '",unused_countries[i],"', did you mean", agrep_list[i], "?")
      } else {
      x[i] <- paste("Data not found for '",unused_countries[i],"', use listAll() to check data availability. ")
      }
    }
  x <- x[x!= "NA"]
  x <- x[grep("NULL", x,invert = TRUE)]
}

  if(length(country_list) == 0) {
  stop("No data downloaded, see below comments: \n \n",
       paste(x, collapse = " \n"))
    } else if (length(unused_countries) != 0) { warning(paste(x, collapse = " \n"),call. = FALSE)
}
country <- curl::curl_escape(country)

  if(tolower(species) == "both") {

    columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

  } else if(tolower(species) == "pf") {

    columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

  } else if(tolower(species) == "pv") {

    columns <- "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"

  } else {stop("Species not recognized, use one of: \n   \"Pf\" \n   \"Pv\" \n   \"BOTH\"")}

  if("ALL" %in% country){
    message(paste("Importing PR point data for all locations, please wait...", sep = ""))
    df <-   utils::read.csv(paste(URL,columns,"&cql_filter=is_available=%27true%27",sep = ""), encoding = "UTF-8")[,-1]

  }else{

    message(paste("Importing PR point data for", paste(country_list, collapse = ", "), "..."))
    country_URL <- paste("%27",country_list, "%27", sep = "", collapse = "," )
    df <- utils::read.csv(paste(URL,
                                columns,
                                "&cql_filter=country%20IN%20(",
                                country_URL,")", sep = ""), encoding = "UTF-8")[,-1]
  }
message("Data downloaded for ", paste(country_list, collapse = ", "), ".")
return(df)
}

# pr_data <- getPR(country = c("Australia", "xxxx"), species = "Pf")
# pr_data <- getPR(country = c("Nigeria", "Madagascar", "São Tomé and Príncipe"), species = "Pf")
# pr_data <- getPR(country = c("Nigeria", "Madagascar", "Sao Tome and Principe"), species = "Pf")
# pr_data <- getPR(country = c("Kenya", "Australia", "Ngeria"), species = "Pv")
# pr_data <- getPR(country = c("Krnya"), species = "Pv")
# pr_data <- getPR(country = c("Madagascar"), species = "BOTH")


# all possible columns:
#
# names(PR_points_ALL)
# [1] "FID"                 "id"                  "month_start"         "year_start"          "month_end"           "year_end"
# [7] "lower_age"           "upper_age"           "examined"            "pf_pos"              "pv_pos"              "pf_pr"
# [13] "pv_pr"               "pf_positive"         "pv_positive"         "dhs_id"              "admin1_paper"        "admin2_paper"
# [19] "admin3_paper"        "method"              "rdt_type"            "survey_notes"        "pcr_type"            "site_id"
# [25] "admin_id"            "latitude"            "longitude"           "name"                "latlong_source_id"   "site_notes"
# [31] "forest"              "rice"                "country_id"          "area_type_id"        "rural_urban"         "country"
# [37] "pf_endemic"          "pv_endemic"          "continent_id"        "area"                "eliminating"         "geo_region_id"
# [43] "map_region_id"       "who_region_id"       "source_id1"          "year1"               "pdf_status_id1"      "title1"
# [49] "citation1"           "source_type_id1"     "contact_id1"         "permission_type_id1" "cinfidential2"       "pdf_status_id2"
# [55] "title2"              "citation2"           "source_id2"          "source_type_id2"     "contact_id2"         "year2"
# [61] "permission_type_id2" "pdf_status_id3"      "title3"              "citation3"           "source_type_id3"     "contact_id3"
# [67] "source_id3"          "year3"               "permission_type_id3"


# to check columns

# x <- read.csv("http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pr&cql_filter=country%20IN%20(%27Kenya%27)", encoding = "UTF-8")
