#' List all MAP Rasters available to download.
#'
#' \code{listRaster} lists all rasters available to download from the Malaria Atlas Project database.
#' @param printed Should the list be printed to the console?
#' @return \code{listRaster} returns a data.frame detailing the following information for each raster available to download from the Malaria Atlas Project database.
#'
#' \enumerate{
#' \item \code{dataset_id} the unique dataset ID of the raster, which can the be used in functions such as getRaster and extractRaster
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
#' \dontrun{
#' available_rasters <- listRaster()
#' }
#' @export listRaster
listRaster <- function(printed = TRUE){
  message("Downloading list of available rasters...")
  
  if(exists('available_rasters_stored', envir = .malariaAtlasHidden)){
    available_rasters <- .malariaAtlasHidden$available_rasters_stored

    #print out message of long raster names
    if(printed == TRUE){
      message("Rasters Available for Download: \n ",paste(available_rasters$dataset_id, collapse = " \n "))
    }
    return(invisible(available_rasters))
  }

  workspaces <- get_workspaces()
  
  available_rasters <- future.apply::future_lapply(workspaces, function(workspace){
    wcs_client <- get_wcs_clients()[[workspace]]
    wms_client <- get_wms_clients()[[workspace]]
    wcs_capabilities <- wcs_client$getCapabilities()
    wms_capabilities <- wms_client$getCapabilities()

    wcs_coverage_summaries <- wcs_capabilities$getCoverageSummaries()

    wcs_coverages <- future.apply::future_lapply(wcs_coverage_summaries, function(wcs_coverage_summary){
      id = wcs_coverage_summary$getId()
      id_parts <- get_workspace_and_version_from_coverage_id(id)

      layer_id <- gsub("__", ":", wcs_coverage_summary$getId())
      wms_layer <- wms_capabilities$findLayerByName(layer_id)
      min_raster_year = NA
      max_raster_year = NA

      if(!is.null(wms_layer$getTimeDimension())) {
        min_and_max_year <- getMinAndMaxYear(wms_layer$getTimeDimension()$values)
        min_raster_year <- min_and_max_year$min
        max_raster_year <- min_and_max_year$max
      }

      titles <- strsplit(wms_layer$getTitle(), "<small>")
      title <- xml2::xml_text(xml2::read_html(charToRaw(titles[[1]][1])))
      title_extended <- xml2::xml_text(xml2::read_html(charToRaw(titles[[1]][2])))
      abstract <- xml2::xml_text(xml2::read_html(charToRaw(wms_layer$getAbstract())))

      return(data.frame(
        dataset_id = id,
        version = id_parts$version,
        raster_code = layer_id,
        title = title,
        title_extended = title_extended,
        abstract = abstract,
        min_raster_year = min_raster_year,
        max_raster_year = max_raster_year
      ))

    })

    wcs_coverages_df <- do.call(rbind, wcs_coverages)
    return(wcs_coverages_df)
    
  })
  
  all_available_rasters <- do.call(rbind, available_rasters)
  all_available_rasters <- clean_mosquito_names(all_available_rasters)
  
  #print out message of long raster names
  if(printed == TRUE){
    message("Rasters Available for Download: \n ",paste(all_available_rasters$dataset_id, collapse = " \n "))
  }
  
  .malariaAtlasHidden$available_rasters_stored <- all_available_rasters
  return(invisible(all_available_rasters))
}
  
#' Function to clean up a bunch of mess in the mosquito names.
#'
#' @param available_rasters data.frame of available rasters, with a column for title..
#' @return The same data.frame inputted, but now with some of the titles corrected.
#' @keywords internal
#'
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

#' Gets the minimum and maximum year for the time dimension values of a WMS Layer. 
#'
#' @param time_dimension_values A string or character vector of date strings that represent the time dimension e.g. can be fetched with wms_layer$getTimeDimension()$values.
#' Can be in the format of "2000-01-01T00:00:00.000Z/2019-01-01T00:00:00.000Z/PT1S" (in which the min year will be 2000 and the max year 2019) or several individual dates, 
#' for which the min and max year will be calculated.
#' @return A named list with a value for min and max. 
#' @keywords internal
#'
getMinAndMaxYear <- function(time_dimension_values) {
  if(length(time_dimension_values) == 1) {
    #In format "2000-01-01T00:00:00.000Z/2019-01-01T00:00:00.000Z/PT1S"
    years <- stringr::str_extract_all(time_dimension_values, "\\d{4}")[[1]]
    return(list(min=years[[1]], max=years[[2]]))
  }
  else if(length(time_dimension_values) > 1) {
    #In format of list of dates
    years <- unlist(lapply(time_dimension_values, function(date) {as.numeric(format(as.Date(date),'%Y'))}))
    return(list(min=min(years), max=max(years)))
  }
  return(list(min=NA, max=NA))
}




