listAllRaster <- function(printed = TRUE){

  if(exists('available_rasters_stored', envir = .MAPdataHidden)){
    available_rasters <- .MAPdataHidden$available_rasters_stored

    #print out message of long raster names
    if(printed == TRUE){
      message("Rasters Available for Download: \n ",paste(available_rasters$title_extended, collapse = " \n "))
    }

    return(invisible(available_rasters))

  }else{

  #query the geoserver to return xml containing a list of all available rasters & convert this to a list
  xml <- XML::xmlParse("http://map-prod3.ndph.ox.ac.uk:8080/geoserver/ows?service=wms&version=1.3.0&request=GetCapabilities")
  xml_data <- XML::xmlToList(xml)

  #subset this list to only include list of rasters
  layers <- xml_data$Capability$Layer[names(xml_data$Capability$Layer)=="Layer"]

  #extract raster metadata from layers list & turn this into dataframe
  codes <- unname(lapply(layers, "[[", 1))
  title <- unname(lapply(layers, "[[", 2))
  abstracts <- unname(lapply(layers, "[[", 3))

  available_rasters <- data.frame(cbind("raster_code" = codes, "title" = title, "abstract" = abstracts))

  #define small function to remove html tags from raster titles
  html2text <- function(htmlString) {
    htmlString <-  gsub("<small>", ":", htmlString)
    return(gsub("<.*?>", "", htmlString))
  }

  #adjust text in various dataframe columns & order these as desired
  available_rasters$raster_code <- sub("Explorer:", "", available_rasters$raster_code)
  available_rasters$title_extended <- sub("^.*:","",html2text(available_rasters$title))
  available_rasters$title <- sub(":.*$","",html2text(available_rasters$title))
  available_rasters$abstract <- html2text(available_rasters$abstract)
  available_rasters <- dplyr::select(available_rasters, 1,2,4,3)

  #print out message of long raster names
  if(printed == TRUE){
    message("Rasters Available for Download: \n ",paste(available_rasters$title_extended, collapse = " \n "))
  }

  .MAPdataHidden$available_rasters_stored <- available_rasters
  return(available_rasters)
  }
}

## z <- listAllRaster()

