#' Extract pixel values from MAP rasters using point coordinates.
#'
#' \code{extractRaster} extracts pixel values from MAP rasters at user-specified point locations (without downloading the entire raster).
#'
#' @param df data.frame containing coordinates of input point locations, must contain columns named 'latitude'/'lat'/'x'  AND 'longitude'/'long'/'y')
#' @param surface string containing 'title' of desired raster(s), e.g. \code{c("raster1", "raster2")}. Defaults to "PfPR2-10" - the most recent global raster of PfPR 2-10.
#' Check \code{\link{listRaster}} to find titles of available rasters.
#' @param year default = \code{rep(NA, length(surface))}; for time-varying rasters: if downloading a single surface for one or more years, \code{year} should be a vector specifying the desired year(s). if downloading more than one surface, use a list the same length as \code{surface}, providing the desired year-range for each time-varying surface in \code{surface} or \code{NA} for static rasters.
#' @param csv_path (optional) user-specified path to which extractRaster coordinates and results are stored. If not specified, tempdir() is used instead.
#'
#' @return \code{getPR} returns the input dataframe (\code{df}), with the following columns apprended, providing raster values for each surface, location and year.
#'
#' \enumerate{
#' \item \code{layer} raster code corresponding to extracted raster values for a given row, check \code{\link{listRaster}} for raster metadata.
#' \item \code{year} the year for which raster values were extraced (time-varying rasters only; static rasters do not have this column).
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
#'                       surface = 'Plasmodium falciparum PR2-10',
#'                       year = 2015)
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

extractRaster <- function(df = NULL,
                          csv_path = NULL,
                          surface = "PfPR2-10",
                          year = rep(NA, length(surface))){
if(length(surface)==1&!inherits(year, "list")){
    year <- list(year)
}

if(all(sapply(year, function(x) all(abs(diff(x)) == 1)))){
  list_new <- lapply(surface, function(x) extractLayerValues(df = df, csv_path = csv_path, surface = x, year = year[[which(surface==x)]]))
  if(any(sapply(list_new, inherits, 'try-error'))){
    warning('Problems downloading one or more layers.')
    return(list_new)
  }
  df_new <- do.call(rbind, list_new)

  }else{

  df_new <- data.frame()

  for(s in surface){

    for(y in year[which(surface == s)][[1]]){

      df_new_i <- extractLayerValues(df = df, csv_path = csv_path, surface = s, year=y)

      if(inherits(df_new_i, 'try-error')){
        warning('Problems downloading one or more layers.')
        return(df_new_i)
      }
      
      df_new <- rbind(df_new, df_new_i)
      }
    }

}
  return(df_new)
}


extractLayerValues <- function(df = NULL,
                               csv_path = NULL,
                               surface = "PfPR2-10",
                               year = rep(NA, length(surface))){

  if(is.null(csv_path)){
    csv_path <- tempdir()
  }

  working_dir <- file.path(csv_path, "extractRaster")

  dir.create(working_dir, showWarnings = FALSE)

  try(
    available_rasters <- suppressMessages(listRaster())
  )
  
  if(inherits(available_rasters, 'try-error')){
    warning('Could not download list of raster layers. Check internet connection.')
    return(available_rasters)
  }
  
  surface_code <- unlist(available_rasters$raster_code[available_rasters$title %in% surface])


  if(any(is.na(year))){
    min_year = available_rasters$max_raster_year[available_rasters$raster_code==surface_code]
    max_year = available_rasters$max_raster_year[available_rasters$raster_code==surface_code]
  }else{
    min_year <- min(year)
    max_year <- max(year)
  }

  #create a random foldername
  temp_foldername <- stringi::stri_rand_strings(1, 10)
  #create POST request body from temp foldername
  body = paste('{"name":','"',paste(temp_foldername),'"}',sep = "")

  #create folder on MAP server via POST request
  try(
    r1 <- httr::POST("https://malariaatlas.org/explorer-api/containers",
                     body = body,
                     httr::add_headers("content-type" = "application/json;charset=UTF-8"))
  )
  
  if(inherits(r1, 'try-error')){
    warning("Error uploading coords, could not create temporary directory.")
    return(r1)
    
  }
  
  if(r1$status_code != 200){
    warning("Error uploading coords, could not create temporary directory.")
    return(r1)
  }

  if(!is.null(df)){
    utils::write.csv(df, file.path(working_dir, "extractRaster_coords.csv"))
    csv_path <- file.path(working_dir, "extractRaster_coords.csv")
  }

  file_name <- basename(csv_path)

  try(
    r2 <- httr::POST(paste("https://malariaatlas.org/explorer-api/containers/",temp_foldername,"/upload", sep = ""),
                   body = list(data = httr::upload_file(csv_path, "text/csv")))
  )
  if(inherits(r2, 'try-error')){
    warning("Error uploading coords, could not upload file.")
    return(r2)
    
  }
  
  if(r2$status_code != 200){
    warning("Error uploading coords, could not upload file.")
    return(r2)
  }

  try(
    if(!is.na(min_year)&!is.na(max_year)){
      r3 <- httr::GET(utils::URLencode(paste0("https://malariaatlas.org/explorer-api/ExtractLayerValues?container=",temp_foldername,"&endYear=",max_year,"&file=",file_name,"&raster=",surface_code,"&startYear=",min_year)))
    }else{
      r3 <- httr::GET(utils::URLencode(paste0("https://malariaatlas.org/explorer-api/ExtractLayerValues?container=",temp_foldername,"&file=",file_name,"&raster=",surface_code)))
    }
  )
  if(inherits(r3, 'try-error')){
    warning("Error performing extraction, check server status.")
    return(r3)
    
  }
  

  if(r3$status_code != 200){
    warning("Error performing extraction, check server status.")
    return(r3)
  }


  try(
    {
    utils::download.file(paste("https://malariaatlas.org/explorer-api/containers/",temp_foldername,"/download/analysis_",file_name, sep = ""), file.path(working_dir, "extractRaster_results.csv"), mode = "wb")
  
    new_df <- utils::read.csv(file.path(working_dir, "extractRaster_results.csv"))
  
    r4 <- httr::DELETE(paste("https://malariaatlas.org/explorer-api/containers/", temp_foldername, sep = ""))
    }
  )
  if(inherits(new_df, 'try-error')){
    warning("Error reading written csv back into R")
    return(new_df)
  }
  
  if(r4$status_code != 200){
    warning("Error deleting file, check deletion from server.")
  }
  return(new_df)

}


# x <- getPR(ISO = "MDG", species = "both")
# xx <- extractRaster(df = x, year = 2000)
# xy <- extractRaster(csv_path = file.path(tempdir(),"extractRaster/extractRaster_coords.csv"), year = 2000)



