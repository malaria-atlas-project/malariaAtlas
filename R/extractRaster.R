### NOTE you can only currently use a sequence of years for the query, the URL only takes a min and a max. Making the user remove excess years at the end is probably easier than splitting up the query into multiples.


extractRaster <- function(df = NULL,
                          csv_path = NULL,
                          surface = "PfPR2-10",
                          year = NULL){
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
  r1 <- httr::POST("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers",
                  body = body,
                  httr::add_headers("content-type" = "application/json;charset=UTF-8"))

  if(r1$status_code != 200){
    error("Error uploading coords, could not create temporary directory.")
  }

  if(!is.null(df)){
    write.csv(df, file.path(working_dir, "extractRaster_coords.csv"))
    csv_path <- file.path(working_dir, "extractRaster_coords.csv")
  }

  file_name <- basename(csv_path)

  r2 <- httr::POST(paste("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers/",temp_foldername,"/upload", sep = ""),
             body = list(data = httr::upload_file(csv_path, "text/csv")))

  if(r2$status_code != 200){
    error("Error uploading coords, could not upload file.")
  }

  r3 <- httr::GET(paste("http://map-prod3.ndph.ox.ac.uk/explorer-api/ExtractLayerValues?container=",temp_foldername,"&endYear=",max_year,"&file=",file_name,"&raster=",surface_code,"&startYear=",min_year, sep = ""))

  if(r3$status_code != 200){
    stop("Error performing extraction, check server status.")
  }


  download.file(paste("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers/",temp_foldername,"/download/analysis_",file_name, sep = ""), file.path(working_dir, "extractRaster_results.csv"), mode = "wb")

  new_df <- read.csv(file.path(working_dir, "extractRaster_results.csv"))

  r4 <- httr::DELETE(paste("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers/", temp_foldername, sep = ""))

  if(r4$status_code != 200){
    stop("Error deleting file, check deletion from server.")
  }
  return(new_df)
}
# x <- getPR(ISO = "MDG", species = "both")
# xx <- extractRaster(df = x, year = 2000)
# xy <- extractRaster(csv_path = file.path(tempdir(),"extractRaster/extractRaster_coords.csv"), year = 2000)



