#' List all MAP Rasters available to download.
#'
#' \code{listRaster} lists all rasters available to download from the Malaria Atlas Project database.
#' @param printed Should the list be printed to the console?
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
#' \donttest{
#' available_rasters <- listRaster()
#' }
#' @export listRaster

listRaster <- function(printed = TRUE){
message("Downloading list of available rasters...")
  if(exists('available_rasters_stored', envir = .malariaAtlasHidden)){
    available_rasters <- .malariaAtlasHidden$available_rasters_stored

    #print out message of long raster names
    if(printed == TRUE){
      message("Rasters Available for Download: \n ",paste(available_rasters$title, collapse = " \n "))
    }

    return(invisible(available_rasters))

  }else{

  #query the geoserver to return xml containing a list of all available rasters & convert this to a list
    xml <- xml2::read_xml("http://map.ox.ac.uk/geoserver/ows?service=wms&version=1.3.0&request=GetCapabilities")

    layer_xml <-xml2::xml_find_first(xml2::xml_ns_strip(xml), ".//Layer")
    layer_xml <-  xml2::xml_find_all(layer_xml, ".//Layer")

    layers <- xml2::as_list(layer_xml)
    names(layers) <- xml2::xml_name(layer_xml)

  #define small function to remove html tags from raster titles
  html2text <- function(htmlString) {
    htmlString <-  gsub("<small>", ":", htmlString)
    return(gsub("<.*?>", "", htmlString))
  }

  titles <-  sub(":.*$", "", html2text(unname(sapply( X = sapply(layers, function(x){x[["Title"]]}), FUN = function (x) ifelse (is.null (x), NA, x)))))
  extended_titles <- sub("^.*:", "", html2text(unname(sapply( X = sapply(layers, function(x){x[["Title"]]}), FUN = function (x) ifelse (is.null (x), NA, x)))))
  codes <- unname(sapply( X = sapply(layers, function(x){sub("^Explorer:", "", x[["Name"]])}), FUN = function (x) ifelse (is.null (x), NA, x)))
  abstracts <- html2text(unname(sapply( X = sapply(layers, function(x){x[["Abstract"]]}), FUN = function (x) ifelse (is.null (x), NA, x))))
  citations <- unlist(unname(sapply( X = sapply(layers, function(x){x[["Attribution"]][["Title"]]}), FUN = function (x) ifelse (is.null (x), NA, x))))
  dims <-  html2text(unname(sapply( X = sapply(layers, function(x){x[["Dimension"]]}), FUN = function (x) ifelse (is.null (x), NA, x))))
  min_raster_years <- suppressWarnings(as.numeric(unname(sapply(X = gsub("^(.*?)/.*", "\\1", dims),FUN = substr, 1,4))))
  max_raster_years <- suppressWarnings(as.numeric(unname(sapply(X = gsub(".*/(.*?)/.*$","\\1", dims),FUN = substr, 1,4))))
  #pub_years <- as.numeric(as.character(unname(sapply( X = sapply(layers, function(x){sub("^pub_year:","",grep("^pub_year:",unname(unlist(x[["KeywordList"]])), value = TRUE))}), FUN = function (x) ifelse (is.null (x), NA, x)))))
  categories <- unname(sapply( X = sapply(layers, function(x){sub("^category:","",grep("^category:",unname(unlist(x[["KeywordList"]])), value = TRUE))}), FUN = function (x) ifelse (is.null (x), NA, x)))


  # extract raster metadata from layers list & turn this into dataframe
  available_rasters <- data.frame("title"= titles,
                                  "title_extended" = extended_titles,
                                  "raster_code" = codes,
                                  "abstract" = abstracts,
                                  "citation"= citations,
                                  # "pub_year" = pub_years,
                                  "min_raster_year" = min_raster_years,
                                  "max_raster_year" =  max_raster_years,
                                  "category" = categories,
                                  stringsAsFactors = FALSE)

  available_rasters <- available_rasters[available_rasters$category %in% "surfaces",-which(names(available_rasters)=="category")]

  available_rasters <- clean_mosquito_names(available_rasters)
  
  available_rasters <- dplyr::arrange(available_rasters, .data$title)
  #print out message of long raster names
  if(printed == TRUE){
    message("Rasters Available for Download: \n ",paste(available_rasters$title, collapse = " \n "))
  }

  .malariaAtlasHidden$available_rasters_stored <- available_rasters
  return(invisible(available_rasters))
  }
}

## z <- listRaster()

# Function to clean up a bunch of mess in the mosquito names.
clean_mosquito_names <- function(available_rasters){
  available_rasters$title[available_rasters$title== "An. dirus species complex"&grepl("^Moyes", available_rasters$citation)] <- "An. dirus species complex (2016)"
  available_rasters$title[available_rasters$title== "An. dirus species complex"&grepl("^Sinka", available_rasters$citation)] <- "An. dirus species complex (2011)"
  
  available_rasters$title[available_rasters$title== "An. arabiensis Patton, 1905"&grepl("^Wiebe", available_rasters$citation)] <- "An. arabiensis Patton, 1905 (2017)"
  available_rasters$title[available_rasters$title== "An. arabiensis Patton, 1905"&grepl("^Sinka", available_rasters$citation)] <- "An. arabiensis Patton, 1905 (2010)"
  
  available_rasters$title[available_rasters$title== "An. melas Theobald, 1903"&grepl("^Wiebe", available_rasters$citation)] <- "An. melas Theobald, 1903 (2017)"
  available_rasters$title[available_rasters$title== "An. melas Theobald, 1903"&grepl("^Sinka", available_rasters$citation)] <- "An. melas Theobald, 1903 (2010)"
  
  available_rasters$title[available_rasters$title== "An. merus D\u0246nitz, 1902"&grepl("^Wiebe", available_rasters$citation)] <- "An. merus D\0246nitz, 1902 (2017)"
  available_rasters$title[available_rasters$title== "An. merus D\u0246nitz, 1902"&grepl("^Sinka", available_rasters$citation)] <- "An. merus D\u0246nitz, 1902 (2010)"
  return(available_rasters)
}

