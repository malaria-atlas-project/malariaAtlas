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
#' getPR(country = c("Nigeria", "Kenya"))
#' getPR(country = "ALL")
#' @export
getPR <- function(country, species) {
  if(species == "BOTH") {

    ### SET UP AND TEST A SECTION TO COMBINE/MERGE BOTH PF&PV

  } else if(species == "Pf") {

    URL <- "http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pfpr"
    columns <- "&PROPERTYNAME=id,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_positive,pf_pr,method,rdt_type,pcr_type,latitude,longitude,name,area_type_id,rural_urban,country_id,country,continent_id,who_region_id,citation1,site_id"

    if("ALL" %in% country){
      message("Importing PfPR point data for all locations, please wait...")
      df <-   utils::read.csv(paste(URL,columns,"&cql_filter=is_available=%27true%27",sep = ""))[,-1]
      return(df)

    }else{
      message(paste("Importing PfPR point data for", paste(country, collapse = ", "), "please wait..."))
      country.list <- paste("%27",country, "%27", sep = "", collapse = "," )
      df <- utils::read.csv(paste(URL,
                                  columns,
                                  "&cql_filter=country%20IN%20(",
                                  country.list,
                                  ")%20AND%20is_available=%27true%27", sep = ""))[,-1]
      if(length(df$id) == 0) {
        message("No data downloaded - check spelling of country name and/or availability of data for specificed country.")
      } else {
        return(df)
      }
    }
  } else if(species == "Pv") {

    URL <- "http://map-prod3.ndph.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=surveys_pvpr"
    columns <- "&PROPERTYNAME=id,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pv_pos,pv_positive,pv_pr,method,rdt_type,pcr_type,latitude,longitude,name,area_type_id,rural_urban,country_id,country,continent_id,who_region_id,citation1,site_id"

    if("ALL" %in% country){
      message("Importing PvPR point data for all locations, please wait...")
      df <-   utils::read.csv(paste(URL,columns,"&cql_filter=is_available=%27true%27",sep = ""))[,-1]
      return(df)

    }else{
      message(paste("Importing PvPR point data for", paste(country, collapse = ", "), "please wait..."))
      country.list <- paste("%27",country, "%27", sep = "", collapse = "," )
      df <- utils::read.csv(paste(URL,
                                  columns,
                                  "&cql_filter=country%20IN%20(",
                                  country.list,
                                  ")%20AND%20is_available=%27true%27", sep = ""))[,-1]
      if(length(df$id) == 0) {
        message("No data downloaded - check spelling of country name and/or availability of data for specificed country.")
      } else {
        return(df)
      }
    }

  } else {stop("Provided species argument not recognized, use one of: \n   \"Pf\" \n   \"Pv\" \n   \"BOTH\"")}

}

# all possible columns:
# names(PfPR_points_ALL)
#
# names(PfPR_points_ALL)
# > [1] "FID"                 "id"                  "month_start"         "year_start"          "month_end"
# > [6] "year_end"            "lower_age"           "upper_age"           "examined"            "pf_pos"
# > [11] "pf_pr"               "pf_positive"         "dhs_id"              "admin1_paper"        "admin2_paper"
# > [16] "admin3_paper"        "method"              "rdt_type"            "survey_notes"        "pcr_type"
# > [21] "site_id"             "admin_id"            "latitude"            "longitude"           "name"
# > [26] "latlong_source_id"   "site_notes"          "forest"              "rice"                "country_id"
# > [31] "area_type_id"        "rural_urban"         "geom"                "country_code"        "country"
# > [36] "pf_endemic"          "pv_endemic"          "continent_id"        "area"                "eliminating"
# > [41] "geo_region_id"       "map_region_id"       "who_region_id"       "source_id1"          "year1"
# > [46] "pdf_status_id1"      "title1"              "citation1"           "source_type_id1"     "contact_id1"
# > [51] "permission_type_id1" "cinfidential2"       "pdf_status_id2"      "title2"              "citation2"
# > [56] "source_id2"          "source_type_id2"     "contact_id2"         "year2"               "permission_type_id2"
# > [61] "confidential3"       "pdf_status_id3"      "title3"              "citation3"           "source_type_id3"
# > [66] "contact_id3"         "source_id3"          "year3"               "permission_type_id3" "time_start"
# > [71] "time_end"            "is_available"
