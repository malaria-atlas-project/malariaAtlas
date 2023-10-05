#' Extract pixel values from MAP rasters using point coordinates.
#'
#' \code{extractRaster} extracts pixel values from MAP rasters at user-specified point locations (without downloading the entire raster).
#'
#' @param df data.frame containing coordinates of input point locations, must contain columns named 'latitude'/'lat'/'x'  AND 'longitude'/'long'/'y')
#' @param surface deprecated argument. Please remove it from your code.
#' @param year for time-varying rasters: if downloading a single surface for one or more years, \code{year} should be a vector specifying the desired year(s). if downloading more than one surface, use a list the same length as \code{surface}, providing the desired year-range for each time-varying surface in \code{surface} or \code{NA} for static rasters.
#' @param csv_path (optional) user-specified path to which extractRaster coordinates and results are stored. 
#' @param dataset_id  A character string specifying the dataset ID(s) of one or more rasters. These dataset ids can be found in the data.frame returned by listRaster, in the dataset_id column e.g. c('Malaria__202206_Global_Pf_Mortality_Count', 'Malaria__202206_Global_Pf_Parasite_Rate')
#'
#' @return \code{extractRaster} returns the input dataframe (\code{df}), with the following columns appended, providing values for each raster, location and year.
#'
#' \enumerate{
#' \item \code{layerName} dataset id corresponding to extracted raster values for a given row, check \code{\link{listRaster}} for raster metadata.
#' \item \code{year} the year for which raster values were extracted (time-varying rasters only; static rasters do not have this column).
#' \item \code{value} the raster value for the pixel in which a given point location falls.
#' }
#'
#' @examples
#' #Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
#' \dontrun{
#' # Get some data and remove rows with NAs in location or examined or positive columns.
#' NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
#' complete <- complete.cases(NGA_CMR_PR[, c(4, 5, 16, 17)])
#' NGA_CMR_PR <- NGA_CMR_PR[complete, ]
#'
#' # Extract PfPR data at those locations.
#' data <- extractRaster(df = NGA_CMR_PR[, c('latitude', 'longitude')],
#'                       dataset_id = 'Malaria__202206_Global_Pf_Parasite_Rate',
#'                       year=2020)
#'
#' # Some rasters are stored with NA encoded as -9999
#' data$value[data$value == -9999] <- NA
#'
#' # We can quickly plot a summary
#' plot((NGA_CMR_PR$positive / NGA_CMR_PR$examined) ~ data$value)
#'}
#'
#'
#' @seealso \code{autoplot} method for quick mapping of PR point locations (\code{\link{autoplot.pr.points}}).
#'
#'
#' @export extractRaster

extractRaster <- function(df,
                          csv_path = NULL,
                          surface = NULL,
                          year = NULL,
                          dataset_id = NULL) {
  
  #Parameter checking
  
  availableRasters <- suppressMessages(listRaster(printed = FALSE))
  
  if (!is.null(surface)) {
    lifecycle::deprecate_warn("1.6.0", "extractRaster(surface)", details = "The argument 'surface' has been deprecated. It will be removed in the next version. Please use dataset_id to specify the raster instead.")
  }
  
  if(is.null(dataset_id)) {
    if(!is.null(surface)) {
      dataset_id = future.apply::future_lapply(surface, function(individual_surface){
        id <- getRasterDatasetIdFromSurface(availableRasters, individual_surface)
        return(id)
      })
    } else {
      stop('Please provide a value for dataset_id. Options for this variable can be found by running listRaster() and looking in the dataset_id column.')
    }
  } else {
    diff <- setdiff(dataset_id, availableRasters$dataset_id)
    intersect <- intersect(dataset_id, availableRasters$dataset_id)
    if(length(diff) > 0) {
      if(length(intersect) == 0) {
        stop(paste0('All value(s) provided for dataset_id are not valid. All values must be from dataset_id column of listRaster()'))
      } else {
        warning(paste0('Following value(s) provided for dataset_id are not valid and so will be ignored: ', diff, ' . All values must be from dataset_id column of listRaster()'))
        dataset_id <- intersect
      }
    }
  }
  
  if(is.null(year)) {
    year <- as.list(rep(NA, length(dataset_id)))
  }
  
  if (length(dataset_id) > 1) {
    if (length(year) != length(dataset_id)) {
      stop(
        "If downloading multiple different rasters, 'year' must be a list of the same length as 'dataset_id'."
      )
    }
    
  } else if (length(dataset_id) == 1) {
    if (!inherits(year, "list")) {
      year <- list(year)
    }
  }
  
  latitude_column <- getLatitudeColumn(df)
  longitude_column <- getLongitudeColumn(df)
  
  if(is.null(latitude_column)) {
    stop("df has to contain a column named 'latitude', 'lat' or 'y' to represent the latitude")
  }
  
  if(is.null(longitude_column)) {
    stop("df has to contain a column named 'longitude', 'long' or 'x' to represent the longitude")
  }
  
  coords <- c(longitude_column, latitude_column)
  points_to_query <- as.matrix(dplyr::distinct(df[coords]))
  
  
  #Looping through dataset_id and year to fetch data
  
  if(all(sapply(year, function(x) all(abs(diff(x)) == 1)))){
    list_new <- lapply(dataset_id, function(x) extractLayerValues(points_to_query = points_to_query, dataset_id = x, year = year[[which(dataset_id==x)]]))
    if(any(sapply(list_new, inherits, 'try-error'))){
      warning('Problems downloading one or more layers.')
      return(list_new)
    }
    df_new <- do.call(rbind, list_new)
    
  }else{
    
    df_new <- data.frame()
    
    for(d in dataset_id){
      
      for(y in year[which(dataset_id == d)][[1]]){
        
        df_new_i <- extractLayerValues(points_to_query = points_to_query, dataset_id = d, year=y)
        
        if(inherits(df_new_i, 'try-error')){
          warning('Problems downloading one or more layers.')
          return(df_new_i)
        }
        
        df_new <- rbind(df_new, df_new_i)
      }
    }
    
  }
  
  #Added original df information back in
  
  df_new <- dplyr::rename(df_new, !!longitude_column := 'long')
  df_new <- dplyr::rename(df_new, !!latitude_column := 'lat')
  
  df_merged <- dplyr::inner_join(df, df_new, by = c(longitude_column, latitude_column))
  
  
  #Saving to folder if csv_path is provided
  
  if(!is.null(csv_path) & !is.null(df_merged)) {
    working_dir <- file.path(csv_path, "extractRaster")
    dir.create(working_dir, showWarnings = FALSE)
    
    if(!is.null(df_merged)){
      utils::write.csv(df_merged, file.path(working_dir, "extractRaster_coords.csv"))
    }
  }
  
  return(df_merged)
}


#' Returns a data.frame of the extracted raster values with columns for layerName, year, value, long and lat. 
#'
#' @param points_to_query matrix of points to get raster data for, with first column being the latitude and second being the longitude. 
#' @param dataset_id character representing the dataset id.
#' @param year either a single year, or a list of years, or NA. 
#' @keywords internal
extractLayerValues <- function(points_to_query,
                               dataset_id,
                               year) {
  data_json <-
    list(points = points_to_query, layerNames = as.list(dataset_id))
  headers <- c(`Content-Type` = 'application/json')
  res     <-
    httr::POST(
      url = 'https://data.malariaatlas.org/explorer-api/ExtractLayerValues',
      httr::add_headers(.headers = headers),
      body = data_json,
      encode = "json"
    )
  if (!res$status_code == 200) {
    stop("Unable to fetch data.")
  }
  layerValues  <- jsonlite::fromJSON(rawToChar(res$content))
  
  if(all(!is.na(year)) & all(!is.na(layerValues$year))) {
    min_year <- min(year)
    max_year <- max(year)
    
    layerValues <- subset(layerValues, (year >= min_year) & (year <= max_year))
  }
  
  return(layerValues)
}

#' Returns the best latitude column name in df data.frame, if one exists.
#'
#' @param df The data.frame, hopefully containing a column for latitude
#' @return Returns the best column name for latitude - 'latitude', 'lat', or 'y' respectively, or NULL if none of these column names exists in df
#' @keywords internal
getLatitudeColumn <- function(df) {
  colnames <- colnames(df)

  if('latitude' %in% colnames) {
    return('latitude')
  } else if ('lat' %in% colnames) {
    return('lat')
  } else if ('y' %in% colnames) {
    return('y')
  } else {
    return(NULL)
  }
}

#' Returns the best longitude column name in df data.frame, if one exists.
#'
#' @param df The data.frame, hopefully containing a column for longitude.
#' @return Returns the best column name for longitude - 'longitude', 'long', or 'x' respectively, or NULL if none of these column names exists in df
#' @keywords internal
getLongitudeColumn <- function(df) {
  colnames <- colnames(df)
  
  if('longitude' %in% colnames) {
    return('longitude')
  } else if ('long' %in% colnames) {
    return('long')
  } else if ('x' %in% colnames) {
    return('x')
  } else {
    return(NULL)
  }
}


