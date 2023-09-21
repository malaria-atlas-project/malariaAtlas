#' Download Vector Occurrence points from the MAP database

#'\code{getVecOcc} downloads all publicly available vector occurrence points for a specified country (or countries) and returns this as a dataframe.

#'\code{country} and \code{ISO} refer to countries and a lower-level administrative regions such as French Guiana.

#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param continent string containing continent (one of "Africa", "Americas", "Asia", "Oceania") for desired data, e.g. \code{c("continent1", "continent2", ...)}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param species string specifying the Anopheles species for which to find vector occurrence points, options include: \code{"Anopheles...."} OR \code{"ALL"}
#' @param extent an object specifying spatial extent within which PR data is desired, as returned by sf::st_bbox().


#'@return \code{getVecOcc} returns a dataframe containing the below columns, in which each row represents a distinct data point/ study site.

#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' # Download vector occurrence data for Brazil and map the locations using autoplot.vector.points
#' \donttest{
#' Brazil_vec <- getVecOcc(country = "Brazil")
#' autoplot(Brazil_vec)
#'
#' # Download vector data for Madagascar and map the locations using autoplot
#' Madagascar_vec <- getVecOcc(ISO = "MDG", species = "All")
#' autoplot(Madagascar_vec)
#' 
#' # Subset by extent.
#' extent_vec <- getVecOcc(extent = matrix(c(100,13,110,18), nrow = 2), species = 'all')
#
#' }
#'
#'
#'@seealso \code{autoplot} method for quick mapping of Vector occurrence point locations (\code{\link{autoplot.vector.points}}).
#'
#'
#' @export getVecOcc

getVecOcc <- function(country = NULL,
                      ISO = NULL,
                      continent = NULL,
                      species = "all",  
                      extent = NULL) {

  if (exists('available_countries_stored_vec', envir =  .malariaAtlasHidden)) {
    available_countries_vec <- .malariaAtlasHidden$available_countries_stored_vec
  } else{
    available_countries_vec <- listPoints(printed = FALSE, sourcedata = "vector points")
    if(inherits(available_countries_vec, 'try-error')){
      message(available_countries_vec)
      return(available_countries_vec)
    }
  }
  
  if(is.null(country) & 
     is.null(ISO) & is.null(continent) & is.null(extent)) {
    stop("Must specify one of: 'country', 'ISO', 'continent' or 'extent'.")
  }
  
  if (!is.null(extent)) {
    extent <- getSpBbox(extent)
  }
  
  if (exists('available_species_stored', envir = .malariaAtlasHidden)) {
    available_species <- .malariaAtlasHidden$available_species_stored
  } else {
    available_species <- listSpecies(printed = FALSE)
  }
  
  
  if("all" %in% tolower(species)){
    species_URL <- ""  
  } else {
    species_names <-  paste("%27",
                            curl::curl_escape(gsub("'", "''", species)),
                            "%27",
                            sep = "",
                            collapse = ",")
    species_URL <- paste0("%20AND%20species_plain%20IN%20(",species_names, ")")
  }
  
  if(!("all" %in% tolower(species))){ 
    if(all(!(species %in% available_species$species_plain))){
      message("Species not recognised check species availability with listSpecies()")
    } else if(any(!(species %in% available_species$species_plain))){
     message(paste("No data was avilable to download for species'",
                   species[!species %in% available_species$species_plain],
                   "'please check spelling or species availablility with listSpecies()"))
    } else {
     message("All species have available data to download")
    }
  }
  
  #Just to avoid visible binding notes
  #species_plain <- species_plain <- permissions_info <- NULL
  
  URL <-
    "https://malariaatlas.org/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=Anopheline_Data"
  
  columns <-
    "&PROPERTYNAME=site_id,latitude,longitude,country,country_id,continent_id,month_start,year_start,month_end,year_end,anopheline_id,species,species_plain,id_method1,id_method2,sample_method1,sample_method2,sample_method3,sample_method4,assi,citation,geom,time_start,time_end"
  
  
  if("all" %in% tolower(c(country, ISO))) {
    message(paste(
      "Importing vector occurence data for all locations, please wait...",
      sep = ""
    ))

    if("all" %in% country) {
        cql_filter <- "country"
        colname <-"country"
    } else if ("all" %in% ISO) {
        cql_filter <- "country_id"
        colname <- "country_id"
    }
  
      country_URL <-
          paste("%27",
                curl::curl_escape(gsub("'", "''", available_countries_vec$country)),
                "%27",
                sep = "",
                collapse = ",")
      full_URL <- paste(URL,
                        columns,
                        "&cql_filter=",
                        cql_filter,
                        "%20IN%20(", 
                        country_URL,
                        ")",
                        species_URL,
                        sep = "")
  
    df <-
      try(utils::read.csv(full_URL, encoding = "UTF-8")[, -1])
    if(inherits(df, 'try-error')){
      message(df[1])
      return(df)
    }
    
    message(paste("Data downloaded for all available locations.",
    "Data downloaded for species:",
            paste(unique(df$species_plain))
    ))
    class(df) <- c("vector.points", class(df))
    return(df)
    
  } else {
    if(any(c(!is.null(country),!is.null(ISO),!is.null(continent))) & !("all" %in% c(country, ISO))) {  

      if (!(is.null(country))) {
        cql_filter <- "country"
        colname <-"country"
      } else if (!(is.null(ISO))) {
        cql_filter <- "country_id"
        colname <- "country_id"
      } else if (!(is.null(continent))) {
        cql_filter <- "continent_id"
        colname <- "continent"
      } 
      
      
    checked_availability_vec <- 
      isAvailable_vec(sourcedata = "vector points",
                    country = country,
                    ISO = ISO,
                    continent = continent,
                    full_results = TRUE)
      message(paste(
        "Attempting to download vector occurence data for",
        paste(available_countries_vec$country[available_countries_vec[, colname] %in% 
                checked_availability_vec$location[checked_availability_vec$is_available == 1]], 
              collapse = ", "),
        "..."
      ))
      country_URL <-
        paste("%27",
              curl::curl_escape(gsub(
                "'", "''", checked_availability_vec$location[checked_availability_vec$is_available ==
                                                           1]
              )),
              "%27",
              sep = "",
              collapse = ",")
      
      full_URL <- paste(URL,
                        columns,
                        "&cql_filter=",
                        cql_filter,
                        "%20IN%20(", 
                        country_URL,
                        ")",
                        species_URL,
                        sep = "")
    } else if(!is.null(extent)) {
      if(species == 'all'){
        bbox_filter <-
          paste0("&srsName=EPSG:4326&bbox=",
                 extent[2, 1],
                 ",",
                 extent[1, 1],
                 ",",
                 extent[2, 2],
                 ",",
                 extent[1, 2])
      
        full_URL <- paste0(URL, columns, bbox_filter)
      } else {
        bbox_filter <-
          paste0("BBOX(geom,",
                 extent[2, 1],
                 ",",
                 extent[1, 1],
                 ",",
                 extent[2, 2],
                 ",",
                 extent[1, 2],
                 ')&srsName=EPSG:4326')
        species_URL <- gsub('%20AND%20', '', species_URL)
        full_URL <- paste0(URL, columns,  "&cql_filter=", species_URL, '%20AND%20', bbox_filter)
      }
    }
  
    
    df <-
      try(utils::read.csv(full_URL, encoding = "UTF-8")[, -1])
    if(inherits(df, 'try-error')){
      message(df[1])
      return(df)
    }
    
    #Just to avoid visible binding notes - moved higher up
    #species_plain <- species_plain <- permissions_info <- NULL 
    
    if (!nrow(df) > 0 & !is.null(extent)) {
      stop(
        "Error in downloading data for extent: (",
        paste0(extent, collapse = ","), 
        "), \n try query using country or continent name OR check data availability at https://data.malariaatlas.org/maps."
      )
    }
    
    if (nrow(df) == 0) {
      stop(
        "Vector occurrence data is not available for the specificed countries; \n confirm data availability at https://data.malariaatlas.org/maps."
      )
    }
    
    
    if (any(c(!is.null(country),!is.null(ISO),!is.null(continent)))) {
      message("Data downloaded for ", 
              paste0(unique(df$country), sep = ", ")
        # paste(checked_availability_vec$location[checked_availability_vec$is_available == 
        #                                       1], collapse = ", "),
        # "."
      )
    } else if (!is.null(extent)) {
      message("Data downloaded for extent: ",
              paste0(extent, collapse = ", "))
    }
    
    if (!("all" %in% species)){   
      message("Data downloaded for species:",
              paste0(unique(df$species_plain), sep = ", ")
      )
    }
  }

  
  class(df) <- c("vector.points", class(df))
  
  return(df)
  
}





#' Convert data.frames to vector.points objects.
#' 
#' Will create empty columns for any missing columns expected in a vector.points data.frame.
#' This function is particularly useful for use with packages like dplyr that strip 
#' objects of their classes.
#' 
#' @param x A data.frame
#' 
#' 
#' @export
#' 
#' @examples
#' \donttest{
#' library(dplyr)
#' Brazil_vec <- getVecOcc(country = "Brazil")
#' 
#' # Filter data.frame then readd vector points class so autoplot can be used. 
#' Brazil_vec %>% 
#'   filter(sample_method1 == 'larval collection') %>% 
#'   as.vectorpoints %>% 
#'   autoplot
#' }

as.vectorpoints <- function(x){
  
  expected_col_names <- c("site_id", "latitude", "longitude", "country", "country_id", 
                          "continent_id", "month_start", "year_start", "month_end", "year_end", 
                          "anopheline_id", "species", "species_plain", "id_method1", "id_method2", 
                          "sample_method1", "sample_method2", "sample_method3", "sample_method4", 
                          "assi", "citation", "geom", "time_start", "time_end")
  
  missing_columns <- expected_col_names[!(expected_col_names %in% names(x))]
  
  stopifnot(inherits(x, 'data.frame'))
  
  if(length(missing_columns < 0)){
    warning('Creating columns of NAs: ', paste0(missing_columns, collapse = ', '))
    newcols <- data.frame(matrix(NA, ncol = length(missing_columns), nrow = nrow(x)))
    names(newcols) <- missing_columns
    x <- cbind(x, newcols)
  }
  
  class(x) <- c('vector.points', class(x))
  return(x)
}



 
