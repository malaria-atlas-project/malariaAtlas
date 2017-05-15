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

  message("Confirming availability of PR data for: ", paste(country, collapse = ", "), "...")
  available_countries <- c(levels(utils::read.csv(paste(URL, "&PROPERTYNAME=country", sep = ""))$country))

country_list <- list()
unused_countries <- list()
  for(i in 1:length(unique(country))) {
    if(!(country[i] %in% available_countries)){
      unused_countries[i] <- country[i]
      } else {
      country_list <- country[i]
    }
    }

  if(length(country_list) == 0) {
    stop("No data available for - ",paste(unused_countries, collapse = ", ")," - check specified country matches one of: \n",
              paste(available_countries, collapse = " \n "))}


  if(species == "BOTH") {

    columns <- "&PROPERTYNAME=month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_positive,pf_pr,pv_positive,pv_pr,method,rdt_type,pcr_type,latitude,longitude,name,rural_urban,country_id,country,continent_id,who_region_id,citation1,citation2,citation3,site_id"

  } else if(species == "Pf") {

    columns <- "&PROPERTYNAME=month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_positive,pf_pr,method,rdt_type,pcr_type,latitude,longitude,name,rural_urban,country_id,country,continent_id,who_region_id,citation1,citation2,citation3,site_id"

  } else if(species == "Pv") {

    columns <- "&PROPERTYNAME=month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pv_positive,pv_pr,method,rdt_type,pcr_type,latitude,longitude,name,rural_urban,country_id,country,continent_id,who_region_id,citation1,citation2,citation3,site_id"

  } else {stop("Species not recognized, use one of: \n   \"Pf\" \n   \"Pv\" \n   \"BOTH\"")}

  if("ALL" %in% country){
    message(paste("Importing PR point data for all locations, please wait...", sep = ""))
    df <-   utils::read.csv(paste(URL,columns,"&cql_filter=is_available=%27true%27",sep = ""))[,-1]
    return(df)

  }else{

    message(paste("Importing PR point data for", paste(country, collapse = ", "), "..."))
    country_URL <- paste("%27",country_list, "%27", sep = "", collapse = "," )
    df <- utils::read.csv(paste(URL,
                                columns,
                                "&cql_filter=country%20IN%20(",
                                country_URL,")", sep = ""))[,-1]

      return(df)
  }
message("Done.")
}

# pr_data <- getPR(country = c("Australia", "xxxx"), species = "Pf")
# pr_data <- getPR(country = c("Nigeria", "Madagascar"), species = "Pf")

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



