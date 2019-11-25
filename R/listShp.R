#' List administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' \code{listShp} lists all administrative units for which shapefiles are stored on the MAP geoserver.
#'
#' @param printed Should the list be printed to the console?
#' @param admin_level Specifies which administrative unit level for which to return available polygon shapefiles. A string vector including one or more of\code{"admin0"}, \code{"admin1"}, \code{"admin2"} OR \code{"admin3"}. Default: \code{c("admin0", "admin1")} 
#' @return \code{listShp} returns a data.frame detailing the administrative units for which shapefiles are stored on the MAP geoserver.
#' @examples
#' \donttest{
#' available_admin_units <- listShp()
#' }
#' @export listShp


listShp <- function(printed = TRUE, admin_level = c("admin0", "admin1")){

  # Avoid viible bindings.
  admn_level <- NULL
  # Make a numeric for comparing with the dataframe.
  admin_level_numeric <- as.numeric(gsub('admin', '', admin_level))
  
  if(exists('available_admin_stored', envir = .malariaAtlasHidden)){
    available_admin <- .malariaAtlasHidden$available_admin_stored
  } else {
    available_admin <- NULL
  }
  
  if(!all(admin_level_numeric %in% available_admin$admn_level)){
    
    URL_list <- c("admin0" = utils::URLencode("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=mapadmin_0_2018&PROPERTYNAME=iso,admn_level,name_0,id_0,type_0,source"),
                  "admin1" = utils::URLencode("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=mapadmin_1_2018&PROPERTYNAME=iso,admn_level,name_0,id_0,type_0,name_1,id_1,type_1,source"),
                  "admin2" = utils::URLencode("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=mapadmin_2_2018&PROPERTYNAME=iso,admn_level,name_0,id_0,type_0,name_1,id_1,type_1,name_2,id_2,type_2,source" ),
                  "admin3" = utils::URLencode("https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=mapadmin_3_2018&PROPERTYNAME=iso,admn_level,name_0,id_0,type_0,name_1,id_1,type_1,name_2,id_2,type_2,name_3,id_3,type_3,source"))
    
    use_URL_list <- URL_list[names(URL_list) %in% admin_level & !(0:3) %in% available_admin$admn_level]
    available_admin_new <- try(lapply(X = use_URL_list, FUN = utils::read.csv, encoding = "UTF-8"))
    if(inherits(available_admin_new, 'try-error')){
      message(available_admin_new[1])
      return(available_admin_new)
    }
    
    
    available_admin <- suppressWarnings(dplyr::bind_rows(available_admin_new, available_admin))
    
    available_admin <- dplyr::select(available_admin, names(available_admin)[names(available_admin) %in% c("iso","admn_level","name_0","id_0",
                                                                                                           "type_0","name_1","id_1","type_1","name_2","id_2","type_2",
                                                                                                           "name_3","id_3","type_3","source")])
    
    .malariaAtlasHidden$available_admin_stored <- available_admin
  }
  
  
  if(printed == TRUE){
    message("Shapefiles Available to Download for: \n ",paste(sort(unique(available_admin$name_0[available_admin$admn_level==0])), collapse = " \n "))
  }

  available_admin <- available_admin[,!names(available_admin)%in%c("FID","gid")]
  
  available_admin <- dplyr::filter(available_admin, admn_level %in% admin_level_numeric)
  
  return(invisible(available_admin))
}
