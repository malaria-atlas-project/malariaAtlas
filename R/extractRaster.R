#' Extract pixel values from MAP rasters using point coordinates.
#'
#' \code{extractRaster} extracts pixel values from MAP rasters at user-specified point locations (without downloading the entire raster).
#'
#' @param df data.frame containing coordinates of input point locations, must contain columns named 'latitude'/'lat'/'x'  AND 'longitude'/'long'/'y')
#' @param surface deprecated argument. Please remove it from your code.
#' @param year deprecated argument. Please remove it from your code.
#' @param csv_path (optional) user-specified path to which extractRaster coordinates and results are stored. If not specified, tempdir() is used instead.
#' @param dataset_id  A character string specifying the dataset ID(s) of one or more rasters. These dataset ids can be found in the data.frame returned by listRaster, in the dataset_id column e.g. c('Malaria__202206_Global_Pf_Mortality_Count', 'Malaria__202206_Global_Pf_Parasite_Rate')
#'
#' @return \code{getPR} returns the input dataframe (\code{df}), with the following columns apprended, providing raster values for each surface, location and year.
#'
#' \enumerate{
#' \item \code{layer} dataset id corresponding to extracted raster values for a given row, check \code{\link{listRaster}} for raster metadata.
#' \item \code{year} the year for which raster values were extracted (time-varying rasters only; static rasters do not have this column).
#' \item \code{value} the raster value for the pixel in which a given point location falls.
#' }
#'
#' @examples
#' #Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
#' \donttest{
#' # Get some data and remove rows with NAs in location or examined or positive columns.
#' NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
#' complete <- complete.cases(NGA_CMR_PR[, c(4, 5, 16, 17)])
#' NGA_CMR_PR <- NGA_CMR_PR[complete, ]
#'
#' # Extract PfPR data at those locations.
#' data <- extractRaster(NGA_CMR_PR[, c('latitude', 'longitude')],
#'                       dataset_id = 'Malaria__202206_Global_Pf_Parasite_Rate')
#'
#' # Data are returned in the same order.
#' all(data$longitude == NGA_CMR_PR$longitude)
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
                          csv_path = tempdir(),
                          surface = NULL,
                          year = NULL,
                          dataset_id) {
  if (!is.null(surface)) {
    lifecycle::deprecate_warn("1.5.0", "extractRaster(surface)", details = "The argument 'surface' has been deprecated. It will be removed in the next version. Please use dataset_id to specify the raster instead.")
  }
  
  if (!is.null(year)) {
    lifecycle::deprecate_warn("1.5.0", "extractRaster(year)", details = "The argument 'year' has been deprecated. It will be removed in the next version. ")
  }
  
  if(is.null(dataset_id)) {
    stop('You must provide a value for dataset_id.')
  }
  
  latitude_column <- getLatitudeColumn(df)
  longitude_column <- getLongitudeColumn(df)
  
  if(is.null(latitude_column)) {
    stop("df has to contain a column named 'latitude', 'lat' or 'x' to represent the latitude")
  }
  
  if(is.null(longitude_column)) {
    stop("df has to contain a column named 'latitude', 'lat' or 'x' to represent the latitude")
  }
  
  coords <- c(latitude_column, longitude_column)
  points_to_query <- as.matrix(df[coords])

  data_json <-
    list(points = points_to_query, layerNames = as.list(dataset_id))
  headers <- c(`Content-Type` = 'application/json')
  res     <-
    httr::POST(
      url = 'https://data-dev.malariaatlas.org/explorer-api/ExtractLayerValues',
      httr::add_headers(.headers = headers),
      body = data_json,
      encode = "json"
    )
  if (!res$status_code == 200) {
    stop("Unable to fetch data.")
  }
  data    <- jsonlite::fromJSON(rawToChar(res$content))
  
  working_dir <- file.path(csv_path, "extractRaster")
  dir.create(working_dir, showWarnings = FALSE)
  
  if(!is.null(data)){
    utils::write.csv(data, file.path(working_dir, "extractRaster_coords.csv"))
  }
  
  return(data)
}

#' Returns the best latitude column name in df data.frame, if one exists.
#'
#' @param df The data.frame, hopefully containing a column for latitude
#' @return Returns the best column name for latitude - 'latitude', 'lat', or 'x' respectively, or NULL if none of these column names exists in df
#' @keywords internal
getLatitudeColumn <- function(df) {
  colnames <- colnames(df)

  if('latitude' %in% colnames) {
    return('latitude')
  } else if ('lat' %in% colnames) {
    return('lat')
  } else if ('x' %in% colnames) {
    return('x')
  } else {
    return(NULL)
  }
}

#' Returns the best longitude column name in df data.frame, if one exists.
#'
#' @param df The data.frame, hopefully containing a column for longitude.
#' @return Returns the best column name for longitude - 'longitude', 'long', or 'y' respectively, or NULL if none of these column names exists in df
#' @keywords internal
getLongitudeColumn <- function(df) {
  colnames <- colnames(df)
  
  if('longitude' %in% colnames) {
    return('longitude')
  } else if ('long' %in% colnames) {
    return('long')
  } else if ('y' %in% colnames) {
    return('y')
  } else {
    return(NULL)
  }
}
