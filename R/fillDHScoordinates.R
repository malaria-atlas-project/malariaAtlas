#' Add DHS locations to malaria data
#'
#' We cannot directly share DHS data. We can share coordinates,
#'   but not the data values. This function attempts to fill
#'   the data gaps directly from the DHS server using the package
#'   rdhs. To use the function you will need to setup an 
#'   account on the DHS website and request any datasets you wish
#'   to use (including requesting the GPS data). Confirmation
#'   can take a few days. Once this has been verified, you should be 
#'   able to use this function.
#'
#' This function requires the package \code{rdhs} which is currently
#'   only suggested by the package (not a dependency). So you will
#'   need to install it. 
#'
#' Note that the \code{project} has to be the exact name in your
#'   DHS project.
#'  
#' 
#' @export
#' @param data Data to add DHS coordinates to
#' @param email Character for email used to login to the DHS website.
#' @param project Character for the name of the DHS project from which
#'   datasets should be downloaded.
#' @param cache_path Character for directory path where datasets and API calls
#'   will be cached. If left bank, a suitable directory will be created within
#'   your user cache directory for your operating system (permission granting).
#' @param config_path Character for where the config file should be saved.
#'   For a global configuration, `config_path` must be '~/.rdhs.json'.
#'   For a local configuration, `config_path` must be 'rdhs.json'.
#'   If left bank, the config file will be stored within
#'   your user cache directory for your operating system (permission granting).
#' @param global Logical for the config_path to be interpreted as a global
#'   config path or a local one. Default = TRUE.
#' @param verbose_setup Logical for rdhs setup and messages to be printed.
#'   Default = TRUE.
#' @param verbose_download Logical for dataset download progress bars to be
#'   shown. Default = FALSE.
#' @param data_frame Function with which to convert API calls into. If left
#'   blank \code{data_frame} objects are returned. Must be passed as a
#'   character. Examples could be:
#'   \code{data.table::as.data.table}
#'   \code{tibble::as.tibble}
#' @param timeout Numeric for how long in seconds to wait for the DHS API to
#'   respond. Default = 30.
#' @param password_prompt Logical whether user is asked to type their password,
#'   even if they have previously set it. Default = FALSE. Set to TRUE if you
#'   have mistyped your password when using \code{set_rdhs_config}.
#' @param prompt Logical for whether the user should be prompted for
#'   permission to write to files. This should not need be
#' @author OJ Watson
#' @examples 
#' \dontrun{
#' pf <- malariaAtlas::getPR("all",species = "pf")
#' pf <- fillDHSCoordinates(pf, 
#' email = "pretend_email@emaildomain.com",
#' project = "pretend project name")
#' }

fillDHSCoordinates <- function(data,
                               email = NULL, project = NULL, 
                               cache_path = NULL, config_path = NULL, 
                               global = TRUE, verbose_download = FALSE, 
                               verbose_setup = TRUE, data_frame = NULL, 
                               timeout = 30, password_prompt = FALSE, 
                               prompt = TRUE) {
  
  if(!requireNamespace('rdhs')){
    stop('The function fillDHSCoordinates needs the package rdhs. Please install it with install.packages("rdhs")')
  }
  
  # set up a config for rdhs
  rdhs::set_rdhs_config(email = email, project = project, cache_path = cache_path, config_path = config_path, 
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
  message('Downloading DHS data.')
  geo <- rdhs::get_datasets(dats)
  

  no_permission <- "Dataset is not available with your DHS login credentials"
  
  # filter to only those that successful downloaded and had data for
  no_matches <- which(unlist(geo) == no_permission)
  if (length(no_matches) > 0) {
    geo <- geo[-no_matches]
  }
  
  # now only do the next step if we found at least 1 survey
  if (length(geo) > 0) {
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
        shp <- readRDS(geo[[file_name]])
        matches <- match(shp$DHSID,data$dhs_id)

        data[stats::na.omit(matches), mis_info] <- shp[which(!is.na(matches)), dhs_info]
      }
    }
  }
  
  return(data)
}
