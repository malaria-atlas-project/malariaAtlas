#' Add DHS locations to malaria data
#'
#'
#' @inheritParams rdhs::as_factor
#' @param data Data to add DHS coordinates to
#' @examples 
#' \dontrun{
#' pf <- malariaAtlas::getPR("all",species = "pf")
#' pf <- fillDHSCoordinates(pf, 
#' email = "pretend_email@gmail.com",
#' project = "pretend project name")
#' }

fillDHSCoordinates <- function(data,
                               email = NULL, project = NULL, 
                               cache_path = NULL, config_path = NULL, 
                               global = TRUE, verbose_download = FALSE, 
                               verbose_setup = TRUE, data_frame = NULL, 
                               timeout = 30, password_prompt = FALSE, 
                               prompt = TRUE) {
  
  # set up a config for rdhs
  set_rdhs_config(email = email, project = project, cache_path = cache_path, config_path = config_path, 
                  global = global, verbose_download = verbose_download, verbose_setup = verbose_setup, 
                  data_frame = data_frame, timeout = timeout, password_prompt = password_prompt, 
                  prompt = prompt)
  
  # get stems and remove blanks
  dhs_id_stems <- unique(substr(data$dhs_id, 1, 6))
  dhs_id_stems <- dhs_id_stems[nchar(dhs_id_stems)==6]
  
  # then there are some odd dhs ids I noticed
  dhs_id_stems[dhs_id_stems=="MDG201"] <- "MDG2011"
  
  # find the necessary geographic data files from the DHS API
  dats <- rdhs::dhs_datasets(countryIds = unique(substr(dhs_id_stems, 1, 2)),
                             surveyYear = unique(substr(dhs_id_stems, 3, 6)),
                             fileType = "GE")
  dats <- dats[which(substr(dats$SurveyId, 1, 6) %in% dhs_id_stems),]
  
  # download the datasets
  geo <- get_datasets(dats)
  no_permission <- "Dataset is not available with your DHS login credentials"
  geo <- geo[-which(unlist(geo) == no_permission)]
  
  # missing info (can add more depending on factors, e.g. encoding of urban/rural)
  mis_info <- c("dhs_id","site_id", "latitude", "longitude")
  dhs_info <- c("DHSID","DHSCLUST", "LATNUM", "LONGNUM")
  
  # fill in blanks
  for(stem in dhs_id_stems) {
    
    # what file does the stem relate to
    file_name_match <- dats$FileName[which(substr(dats$SurveyId, 1, 6) == stem)]
    file_name <- gsub("(*).zip", "", file_name_match, ignore.case = TRUE)
    
    # did we find that file
    if (length(file_name)==1) {
      
      # read in the data and then fill in blanks
      shp <- readRDS(geo[[file_name]])@data
      matches <- match(shp$DHSID,data$dhs_id)
      
      data[na.omit(matches), mis_info] <- shp[which(!is.na(matches)), dhs_info]
      
    } 
  }
  
  return(data)
  
}