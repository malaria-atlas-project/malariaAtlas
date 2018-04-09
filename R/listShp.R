#' List administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' \code{listShp} lists all administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @param printed Should the list be printed to the console?
#' @return \code{listShp} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#' @examples
#' \donttest{
#' available_admin_units <- listShp()
#' }
#' @export listShp


listShp <- function(printed = TRUE){

  if(exists('available_admin_stored', envir = .malariaAtlasHidden)){
    available_admin <- .malariaAtlasHidden$available_admin_stored

    if(printed == TRUE){
      message("Shapefiles Available to Download for: \n ",paste(sort(unique(available_admin$name[available_admin$admn_level==0])), collapse = " \n "))
    }

    return(invisible(available_admin))
  } else {

    URL_admin1 <- utils::URLencode("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=mapadmin_1_2013&PROPERTYNAME=gaul_code,country_id,admn_level,parent_id,name")
    URL_admin0 <- utils::URLencode("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=mapadmin_0_2013&PROPERTYNAME=gaul_code,country_id,admn_level,parent_id,name")

    available_admin <- rbind(utils::read.csv(URL_admin0, encoding = "UTF-8"),
                             utils::read.csv(URL_admin1, encoding = "UTF-8"))
    .malariaAtlasHidden$available_admin_stored <- available_admin
  }

available_admin <- available_admin[,!names(available_admin)%in%c("FID","gid")]
  return(invisible(available_admin))
}
