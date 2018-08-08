#' Download Vector Occurrence points from the MAP database

#'\code{getVecOcc} downloads all publicly available vector occurrence points for a specified country (or countries) and returns this as a dataframe.

#'\code{country} and \code{ISO} refer to countries and a lower-level administrative regions such as French Guiana.

#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param species string specifying the Anopheles species for which to find vector occurrence points, options include: \code{"Anopheles...."} OR \code{"ALL"}
#' @param continent string containing continent for desired data, e.g. \code{c("continent1", "continent2", ...)} (use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)   
#' @param extent 2x2 matrix specifying the spatial extent within which vector occurrence data is desired, as returned by sp::bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max"))))


#'@return \code{getVecOcc} returns a dataframe containing the below columns, in which each row represents a distinct data point/ study site.

#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' #Download vector occurrence data for Brazil and map the locations of these points using autoplot.vector.points
#' \donttest{
#' brazil_vec <- getVecOcc(country = "Brazil")
#' autoplot(brazil_vec)
#'
#' Download vector occurrence data for Madagascar and map the locations of these points using autoplot
#' Madagascar_vec <- getVecOcc(ISO = "MDG", species = "All")
#' autoplot(Madagascar_vec)
#
#' }
#'
#'
#'@seealso \code{autoplot} method for quick mapping of Vector occurrence point locations (\code{\link{autoplot.pr.points}}).    ##### NEED TO CHECK THIS!!! ######
#'
#'
#' @export getVecOcc

getVecOcc <- function(country = NULL,
                      ISO = NULL,
                      continent = NULL,
                      species = "All",   #would this make a difference with NULL?
                      extent = NULL) {
  if (exists('available_countries_stored_vec', envir =  .malariaAtlasHidden)) {
    available_countries_vec <- .malariaAtlasHidden$available_countries_stored_vec
  } else{
    available_countries_vec <- listPoints4(printed = FALSE, sourcedata = "vector points")     ##New listPoints function, would have to be updated in other functions to
  }
  
  
  if (exists('available_species_stored', envir = .malariaAtlasHidden)) {
    available_species <- .malariaAtlasHidden$available_species_stored
  } else{
    available_species <- listSpecies(printed = FALSE)
  }

  if(is.null(country) & 
     is.null(ISO) & is.null(continent) & is.null(extent)) {
    stop("Must specify one of: 'country', 'ISO', 'continent' or 'extent'.")
  }
  
  # if(exists('species', where = available_species)){
  #   message("Compliling data please wait...")
  # }  else{
  #   stop("Species not recognised, check species availaility with 'listSpecies()'")
  # }
  URL <-
    "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=Anopheline_Data"
  
  columns <-
    "&PROPERTYNAME=site_id,latitude,longitude,country,country_id,continent_id,month_start,year_start,month_end,year_end,anopheline_id,species,assi,species_plain,id_method1,id_method2,sample_method1,sample_method2,sample_method3,sample_method4,assi,citation,geom,time_start,time_end"
  
  
  if("all" %in% tolower(c(country, ISO))) {
    message(paste(
      "Importing vector occurence data for all locations, please wait...",
      sep = ""
    ))
    

    df <- 
      utils::read.csv(paste(URL, columns, sep = ""), encoding = "UTF-8")[,-1]
    message("Data downloaded for all available locations.")
  } else{
    if (any(c(!is.null(country),!is.null(ISO),!is.null(continent),!is.null(species)))) {  ##added the species part
      if (!(is.null(country))) {
        cql_filter <- "country"
        colname <-"country"
      } else if (!(is.null(ISO))) {
        cql_filter <- "country_id"
        colname <- "country_id"
      } else if (!(is.null(continent))) {
        cql_filter <- "continent_id"
        colname <- "continent"
      } else if (!(is.null(species))) {
        cql_filter <- "species_plain"
        colname <- "species_plain"
      }
      
      checked_availability <- 
        isAvailable_vec(sourcedata = "vector points",
                    country = country,
                    ISO = ISO,
                    continent = continent,
                    full_results = TRUE)
      message(paste(
        "Attempting to download vector occurence data for",
        paste(available_countries_vec$country[available_countries_vec[, colname] %in% checked_availability_vec$location[checked_availability_vec$is_availalbe == 1]], collapse = ", "),
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
                        "&species%20IN%20",
                        ") ",
                        sep = "")
    } else if (!is.null(extent)) {
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
    }
    
    
    
    df <- utils::read.csv(full_URL, encoding = "UTF-8")[, -1]
    
    if (!nrow(df) > 0 & !is.null(extent)) {
      stop(
        "Error in downloading data for extent: (",
        paste0(extent, collapse = ","), 
        "), \n try query using country or continent name OR check data availability at map.ox.ac.uk/explorer."
      )
    }
    
    if (nrow(df) == 0) {
      stop(
        "Vector occurrence data is not available for the specificed countries; \n confirm data availability at map.ox.ac.uk/explorer."
      )
    }
    
    if (any(c(!is.null(country),!is.null(ISO),!is.null(continent)))) {
      message("Data donwloaded for ", 
        paste(checked_availability_vec$location[checked_availability_vec$is_available == 
                                              1], collapse = ", "),
        "."
      )
    } else if (!is.null(extent)) {
      message("Data downloaded for extent: ",
              paste0(extent, collapse = ", "))
    
    if (!is.null(species)){
      message("Data downloaded for species: ",
              paste(checked_availability_vec$species[checked_availaiblity_vec$is_available == 1], collapse = ", "),
              ","
      )
    }
    
    class(df) <- c("vector.points", class(df))
    
    return(df)
  }
}}


 