#' list all species which have occurrence data within the MAP database.
#' 
#' \code{listSpecies} lists all species occurrence data available to download from the Malaria Atlas Project database.
#' @param printed should the list be printed to the database.
#' @return \code{listSpecies} returns a data.frame detailing the following information for each species available to download from the Malaria Atlas Project database.
#' 
#' \enumerate{
#' \item \code{species} string detailing species
#' }
#' 
#' @examples
#' \donttest{
#' available_species <- listSpecies()
#' }
#' 
#' @export listSpecies

listSpecies <- function(printed = TRUE){
  message("Downloading list of available species, please wait...")
  
  if(exists('available_species_stored', envir = .malariaAtlasHidden)){
    available_species <- .malariaAtlasHidden$available_species_stored
  
 
  if(printed == TRUE){
     message("Species with available data: \n ",paste(paste(available_species$species, " (",available_species$country, ")", sep = ""), collapse = " \n ")) 
  }
    
  return(invisible(available_species))
  
  } else {
    
    URL <- 
      "https://malariaatlas.org/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=Anopheline_Data"
    
    columns <- 
      "&PROPERTYNAME=species_plain,country"
    
    available_species <- try(unique(utils::read.csv(paste(URL, columns, sep = ""), encoding = "UTF-8")[,c("species_plain", "country")]) )
    if(inherits(available_species, 'try-error')){
      message(available_species[1])
      return(available_species)
    }
    
    available_species <- dplyr::select(available_species, species_plain, country)

    #Just to avoid visible binding notes
    species_plain <- species_plain <- permissions_info <- NULL #### check this is right, any others needed?
    country <- country <- permissions_info <- NULL
    
    if(printed == TRUE){
     message("Species with availale data: \n ",paste(paste(available_species$species, " (",available_species$country, ")", sep = ""), collapse = " \n "))
    }
  
    .malariaAtlasHidden$available_species_stored <- available_species
  
  
    return(invisible(available_species))
  }
}
#listSpecies()
#xx <- listSpecies(printed = F)

  
  