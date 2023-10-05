#' Download Vector Occurrence points from the MAP database

#'\code{getVecOcc} downloads all publicly available vector occurrence points for a specified country (or countries) and returns this as a dataframe.

#'\code{country} and \code{ISO} refer to countries and a lower-level administrative regions such as French Guiana.

#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param continent string containing continent (one of "Africa", "Americas", "Asia", "Oceania") for desired data, e.g. \code{c("continent1", "continent2", ...)}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param species string specifying the Anopheles species for which to find vector occurrence points, options include: \code{"Anopheles...."} OR \code{"ALL"}
#' @param extent an object specifying spatial extent within which PR data is desired, as returned by sf::st_bbox(). - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max"))))
#' @param start_date string object representing the lower date to filter the vector occurrence data by (inclusive)
#' @param end_date string object representing the upper date to filter the vector occurrence data by (exclusive)
#' @param version (optional) The vector points dataset version to use. If not provided, will just use the most recent version of vector points data. (To see available version options, 
#' use listVecOccPointVersions)

#'@return \code{getVecOcc} returns a dataframe containing the below columns, in which each row represents a distinct data point/ study site.

#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' # Download vector occurrence data for Brazil and map the locations using autoplot.vector.points
#' \dontrun{
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
                      extent = NULL,
                      start_date = NULL,
                      end_date = NULL,
                      version = NULL) {
  if (is.null(country) &
      is.null(ISO) &
      is.null(continent) & is.null(extent)) {
    stop("Must specify one of: 'country', 'ISO', 'continent' or 'extent'.")
  }
  
  if (is.null(version)) {
    version <- getLatestVecOccPointVersion()
    message('Please Note: Because you did not provide a version, by default the version being used is ', version, 
            ' (This is the most recent version of vector data. To see other version options use function listVecOccPointVersions)')
  } else {
    df_available_versions <- listVecOccPointVersions(printed = FALSE)
    if (!version %in% df_available_versions$version) {
      stop(
        paste0(
          'Version provided is not valid. Valid versions for vector point data can be found using listVecOccPointVersions() and are ["',
          paste(df_available_versions$version, collapse = '", "'),
          '"]. Otherwise, you can choose to not specify a version, and the most recent version will be automatically selected'
        )
      )
    }
  }
  
  vec_dataset_id <- getVecOccPointDatasetIdFromVersion(version)
  
  wfs_client <- get_wfs_clients()$Vector_Occurrence
  wfs_cap <- wfs_client$getCapabilities()
  wfs_feature_type <- wfs_cap$findFeatureTypeByName(vec_dataset_id)
  features <- wfs_feature_type$getFeatures(outputFormat = "json")

  if (!is.null(extent)) {
    extent <- getSpBbox(extent)
  }
  
  species_filter <- NULL
  time_filter <- NULL
  bbox_filter <- NULL
  location_filter <- NULL
  
  #Building time filter
  start_date <-
    convert_to_date_with_trycatch(start_date, 'start_date')
  end_date <- convert_to_date_with_trycatch(end_date, 'end_date')
  
  if (!is.null(start_date) | !is.null(end_date)) {
    time_filter <- build_cql_time_filter(start_date, end_date)
  }
  
  #Building species filter
  
  available_species <-
    listSpecies(printed = FALSE, version = version)
  
  if ("all" %in% tolower(species)) {
    species_filter <- NULL
  } else {
    species_filter <- build_cql_filter('species_plain', species)
    
    if (all(!(species %in% available_species$species_plain))) {
      message("Species not recognised check species availability with listSpecies()")
    } else if (any(!(species %in% available_species$species_plain))) {
      message(
        paste(
          "No data was avilable to download for species'",
          species[!species %in% available_species$species_plain],
          "'please check spelling or species availablility with listSpecies()"
        )
      )
    } else {
      message("All species have available data to download")
    }
  }
  
  #Building location filter or bbox filter
  
  available_countries_vec <-
    listVecOccPointCountries(printed = FALSE,
               version = version)
  
  if ("all" %in% tolower(c(country, ISO))) {
    location_fitler <- NULL
    message("Importing vector occurence data for all locations, please wait...")
    
  } else {
    if (any(c(!is.null(country), !is.null(ISO), !is.null(continent))) &
        !("all" %in% c(country, ISO))) {
      
      if (!(is.null(country))) {
        location_cql_col <- location_col <- "country"
      } else if (!(is.null(ISO))) {
        location_cql_col <- location_col<- "country_id"
      } else if (!(is.null(continent))) {
        location_cql_col <- "continent_id"
        location_col <- "continent"
      }
      
      
      checked_availability_vec <-
        isAvailable_vec(
          sourcedata = "vector points",
          country = country,
          ISO = ISO,
          continent = continent,
          full_results = TRUE
        )
      
      message(paste(
        "Attempting to download vector occurence data for",
        paste(available_countries_vec$country[available_countries_vec[, location_col] %in%
                                                checked_availability_vec$location[checked_availability_vec$is_available == 1]],
              collapse = ", "),
        "..."
      ))
      
      
      valid_locations <-
        checked_availability_vec$location[checked_availability_vec$is_available ==
                                           1]
      location_filter <-
        build_cql_filter(location_cql_col, valid_locations)
      
      
    } else if (!is.null(extent)) {
      bbox_filter <- build_cql_bbox_filter(extent)
    }
  }
  
  cql_filters <- list(time_filter, species_filter, location_filter, bbox_filter)
  cql_filter <- combine_cql_filters(cql_filters)
  
  if (length(cql_filter) == 0) {
    cql_filter <- NULL
  }
  
  wfs_feature_type <- wfs_cap$findFeatureTypeByName(vec_dataset_id)
  df <-
    callGetFeaturesWithFilters(wfs_feature_type, cql_filter)
  
  
  #Just to avoid visible binding notes - moved higher up
  #species_plain <- species_plain <- permissions_info <- NULL
  
  if (!nrow(df) > 0 & !is.null(extent)) {
    stop(
      "Error in downloading data for extent: (",
      paste0(extent, collapse = ","),
      "), \n try query using country or continent name OR check data availability at malariaatlas.org/explorer."
    )
  }
  
  if (nrow(df) == 0) {
    stop(
      "Vector occurrence data is not available for the specificed countries; \n confirm data availability at malariaatlas.org/explorer."
    )
  }
  
  if ("all" %in% tolower(c(country, ISO))) {
    message("Data downloaded for all available locations.")
  }
  
  
  if (any(c(!is.null(country), !is.null(ISO), !is.null(continent)))) {
    message("Data downloaded for ",
            paste0(unique(df$country), sep = ", "))
  } else if (!is.null(extent)) {
    message("Data downloaded for extent: ",
            paste0(extent, collapse = ", "))
  }
  
  if (!("all" %in% species)) {
    message("Data downloaded for species:",
            paste0(unique(df$species_plain), sep = ", "))
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
#' \dontrun{
#' library(dplyr)
#' Brazil_vec <- getVecOcc(country = "Brazil")
#'
#' # Filter data.frame then readd vector points class so autoplot can be used.
#' Brazil_vec %>%
#'   filter(sample_method1 == 'larval collection') %>%
#'   as.vectorpoints %>%
#'   autoplot
#' }

as.vectorpoints <- function(x) {
  expected_col_names <-
    c(
      "site_id",
      "latitude",
      "longitude",
      "country",
      "country_id",
      "continent",
      "month_start",
      "year_start",
      "month_end",
      "year_end",
      "anopheline_id",
      "species",
      "species_plain",
      "id_method1",
      "id_method2",
      "sample_method1",
      "sample_method2",
      "sample_method3",
      "sample_method4",
      "assi",
      "citation",
      "geom",
      "time_start",
      "time_end"
    )
  
  missing_columns <-
    expected_col_names[!(expected_col_names %in% names(x))]
  
  stopifnot(inherits(x, 'data.frame'))
  
  if (length(missing_columns < 0)) {
    warning('Creating columns of NAs: ',
            paste0(missing_columns, collapse = ', '))
    newcols <-
      data.frame(matrix(NA, ncol = length(missing_columns), nrow = nrow(x)))
    names(newcols) <- missing_columns
    x <- cbind(x, newcols)
  }
  
  class(x) <- c('vector.points', class(x))
  return(x)
}
