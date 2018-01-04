#' Extract pixel values from MAP rasters using point coordinates.
#'
#' \code{extractRaster} extracts pixel values from MAP rasters at user-specified point locations (without downloading the entire raster).
#'
#' @param df data.frame containing coordinates of input point locations, must contain columns named 'latitude'/'lat'/'x'  & 'longitude'/'long'/'y')
#'
#' ADD MORE
#'
#' @param csv_path string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"} (use either \code{country} OR \code{ISO}, not both)
#' @param surface string specifying the Plasmodium species for which to find PR points, options include: \code{"Pf"} OR \code{"Pv"} OR \code{"BOTH"}
#' @param year string specifying the Plasmodium species for which to find PR points, options include: \code{"Pf"} OR \code{"Pv"} OR \code{"BOTH"}
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
#' @export extractRaster

extractRaster <- function(df = NULL,
                          csv_path = NULL,
                          surface = "PfPR2-10",
                          year = rep(NA, length(surface))){
  min_year <- min(year)
  max_year <- max(year)

  available_rasters <- suppressMessages(listAllRaster())

  surface_code <- unlist(available_rasters$raster_code[available_rasters$title %in% surface])

  working_dir <- file.path(tempdir(), "extractRaster")
  dir.create(working_dir)

  #create a random foldername
  temp_foldername <- stringi::stri_rand_strings(1, 10)
  #create POST request body from temp foldername
  body = paste('{"name":','"',paste(temp_foldername),'"}',sep = "")

  #create folder on MAP server via POST request
  r1 <- httr::POST("https://map-dev1.ndph.ox.ac.uk/explorer-api/containers",
                  body = body,
                  httr::add_headers("content-type" = "application/json;charset=UTF-8"))

  if(r1$status_code != 200){
    stop("Error uploading coords, could not create temporary directory.")
  }

  if(!is.null(df)){
    write.csv(df, file.path(working_dir, "extractRaster_coords.csv"))
    csv_path <- file.path(working_dir, "extractRaster_coords.csv")
  }

  file_name <- basename(csv_path)

  r2 <- httr::POST(paste("https://map-dev1.ndph.ox.ac.uk/explorer-api/containers/",temp_foldername,"/upload", sep = ""),
             body = list(data = httr::upload_file(csv_path, "text/csv")))

  if(r2$status_code != 200){
    stop("Error uploading coords, could not upload file.")
  }

  r3 <- httr::GET(paste("https://map-dev1.ndph.ox.ac.uk/explorer-api/ExtractLayerValues?container=",temp_foldername,"&endYear=",max_year,"&file=",file_name,"&raster=",surface_code,"&startYear=",min_year, sep = ""))

  if(r3$status_code != 200){
    stop("Error performing extraction, check server status.")
  }


  download.file(paste("https://map-dev1.ndph.ox.ac.uk/explorer-api/containers/",temp_foldername,"/download/analysis_",file_name, sep = ""), file.path(working_dir, "extractRaster_results.csv"), mode = "wb")

  new_df <- read.csv(file.path(working_dir, "extractRaster_results.csv"))

  r4 <- httr::DELETE(paste("https://map-dev1.ndph.ox.ac.uk/explorer-api/containers/", temp_foldername, sep = ""))

  if(r4$status_code != 200){
    stop("Error deleting file, check deletion from server.")
  }
  return(new_df)
}
# x <- getPR(ISO = "MDG", species = "both")
# xx <- extractRaster(df = x, year = 2000)
# xy <- extractRaster(csv_path = file.path(tempdir(),"extractRaster/extractRaster_coords.csv"), year = 2000)



