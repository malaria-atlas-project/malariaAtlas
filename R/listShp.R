#' List administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' \code{listShp} lists all administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @return \code{listShp} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#' @examples
#' available_admin_units <- listShp()
#' @export listShp


listShp <- function(printed = FALSE){

  if(exists('available_admin_stored', envir = .malariaAtlasHidden)){
    available_admin <- .malariaAtlasHidden$available_admin_stored

    if(printed == TRUE){
      message("Shapefiles Available to Download for: \n ",paste(sort(unique(available_admin$NAME[available_admin$ADMN_LEVEL==0])), collapse = " \n "))
    }

    return(invisible(available_admin))
  } else {

    URL_admin1 <- "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=admin1_map_2013&PROPERTYNAME=GAUL_CODE,COUNTRY_ID,ADMN_LEVEL,PARENT_ID,NAME"
    URL_admin0 <- "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=admin0_map_2013&PROPERTYNAME=GAUL_CODE,COUNTRY_ID,ADMN_LEVEL,PARENT_ID,NAME"

    available_admin <- rbind(utils::read.csv(URL_admin0, encoding = "UTF-8"), read.csv(URL_admin1, encoding = "UTF-8"))
    .malariaAtlasHidden$available_admin_stored <- available_admin
  }
  return(available_admin)
}
