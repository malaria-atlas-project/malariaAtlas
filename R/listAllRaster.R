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

  #define small function to remove html tags from raster titles
  html2text <- function(htmlString) {
    htmlString <-  gsub("<small>", ":", htmlString)
    return(gsub("<.*?>", "", htmlString))
  }

  #extract raster metadata from layers list & turn this into dataframe
  available_rasters <- data.frame(cbind("raster_code" = unname(lapply(layers, function(x){sub("^Explorer:", "", x[["Name"]])})),
                                        "title"= sub(":.*$", "", html2text(unname(lapply(layers, function(x){x[["Title"]]})))),
                                        "title_extended" = sub("^.*:", "", html2text(unname(lapply(layers, function(x){x[["Title"]]})))),
                                        "abstract" = html2text(unname(lapply(layers, function(x){x[["Abstract"]]}))),
                                        "citation"= unname(lapply(layers, function(x){x[["Attribution"]][["Title"]]})),
                                        "pub_year" = unname(lapply(layers, function(x){sub("^category:","",grep("^category:",unname(unlist(x[["KeywordList"]])), value = TRUE))}))))

  #print out message of long raster names
  if(printed == TRUE){
    message("Rasters Available for Download: \n ",paste(available_rasters$title_extended, collapse = " \n "))
  }

  .MAPdataHidden$available_rasters_stored <- available_rasters
  return(available_rasters)
  }
}

## z <- listAllRaster()

