#' List all MAP Rasters available to download.
#'
#' \code{listRaster} lists all rasters available to download from the Malaria Atlas Project database.
#' @return \code{listRaster} returns a data.frame detailing the following information for each raster available to download from the Malaria Atlas Project database.
#'
#' \enumerate{
#' \item \code{raster_code} unique identifier for each raster
#' \item \code{title} abbreviated title for each raster, used as \code{surface} argument in getRaster()
#' \item \code{title_extended} extended title for each raster, detailing raster content
#' \item \code{abstract} full description of each raster, outlining raster creation methods, raster content and more.
#' \item \code{citation} citation of peer-reviewed article in which each raster has been published
#' \item \code{pub_year} year in which raster was published, used as \code{pub_year} argument in getRaster() to updated raster versions from their predecessor(s).
#' \item \code{min_raster_year} earliest year for which each raster is available
#' \item \code{max_raster_year} latest year for which each raster is available
#' }
#' @examples
#' available_rasters <- listRaster()
#' @export listRaster

listRaster <- function(printed = TRUE){

  if(exists('available_rasters_stored', envir = .malariaAtlasHidden)){
    available_rasters <- .malariaAtlasHidden$available_rasters_stored

    #print out message of long raster names
    if(printed == TRUE){
      message("Rasters Available for Download: \n ",paste(available_rasters$title_extended, collapse = " \n "))
    }

    return(invisible(available_rasters))

  }else{

  #query the geoserver to return xml containing a list of all available rasters & convert this to a list
    xml <- xml2::read_xml(httr::GET("https://map.ox.ac.uk/geoserver/ows?service=wms&version=1.3.0&request=GetCapabilities", httr::content_type_xml()))
    xml_data <- xml2::as_list(xml)

  #subset this list to only include list of rasters
  layers <- xml_data$Capability$Layer[names(xml_data$Capability$Layer)=="Layer"]

  #define small function to remove html tags from raster titles
  html2text <- function(htmlString) {
    htmlString <-  gsub("<small>", ":", htmlString)
    return(gsub("<.*?>", "", htmlString))
  }

  #extract raster metadata from layers list & turn this into dataframe
  available_rasters <- data.frame(cbind("raster_code" = unname(sapply( X = sapply(layers, function(x){sub("^Explorer:", "", x[["Name"]])}), FUN = function (x) ifelse (is.null (x), NA, x))),
                                        "title"= sub(":.*$", "", html2text(unname(sapply( X = sapply(layers, function(x){x[["Title"]]}), FUN = function (x) ifelse (is.null (x), NA, x))))),
                                        "title_extended" = sub("^.*:", "", html2text(unname(sapply( X = sapply(layers, function(x){x[["Title"]]}), FUN = function (x) ifelse (is.null (x), NA, x))))),
                                        "abstract" = html2text(unname(sapply( X = sapply(layers, function(x){x[["Abstract"]]}), FUN = function (x) ifelse (is.null (x), NA, x)))),
                                        "citation"= unname(sapply( X = sapply(layers, function(x){x[["Attribution"]][["Title"]]}), FUN = function (x) ifelse (is.null (x), NA, x))),
                                        # "pub_year" = as.numeric(as.character(unname(sapply( X = sapply(layers, function(x){sub("^pub_year:","",grep("^pub_year:",unname(unlist(x[["KeywordList"]])), value = TRUE))}), FUN = function (x) ifelse (is.null (x), NA, x))))),
                                        # "min_raster_year" = unname(sapply( X = sapply(layers, function(x){sub("^min_raster_year:","",grep("^min_raster_year:",unname(unlist(x[["KeywordList"]])), value = TRUE))}),
                                        #                                    FUN = function (x) ifelse (is.null (x), NA, x))),
                                        # "max_raster_year" =  unname(sapply( X = sapply(layers,function(x){sub("^max_raster_year:","",grep("^max_raster_year:",unname(unlist(x[["KeywordList"]])), value = TRUE))}),
                                        #                                                           FUN = function (x) ifelse (is.null (x), NA, x))),
                                        "category" = unname(sapply( X = sapply(layers, function(x){sub("^category:","",grep("^category:",unname(unlist(x[["KeywordList"]])), value = TRUE))}), FUN = function (x) ifelse (is.null (x), NA, x)))))

  #available_rasters$min_raster_year <- as.numeric(as.character(available_rasters$min_raster_year))
  #available_rasters$max_raster_year <- as.numeric(as.character(available_rasters$max_raster_year))
  #available_rasters$pub_year <- suppressWarnings(as.numeric(as.character(available_rasters$pub_year)))

  available_rasters <- available_rasters[available_rasters$category == "surfaces",-which(names(available_rasters)=="category")]

  #print out message of long raster names
  if(printed == TRUE){
    message("Rasters Available for Download: \n ",paste(available_rasters$title_extended, collapse = " \n "))
  }

  .malariaAtlasHidden$available_rasters_stored <- available_rasters
  return(invisible(available_rasters))
  }
}

## z <- listRaster()

