#' Download PR points from the MAP database
#'
#' \code{getPR} downloads all publicly available PR points for a specified country (or countries) and returns this as a dataframe.
#'
#' \code{country} and \code{ISO} refer to countries and a lower-level administrative regions such as Mayotte and French Guiana.
#'
#' @param country string containing name of desired country, e.g. \code{ c("Country1", "Country2", ...)} OR \code{ = "ALL"}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param ISO string containing ISO3 code for desired country, e.g. \code{c("XXX", "YYY", ...)} OR \code{ = "ALL"}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param continent string containing continent (one of "Africa", "Americas", "Asia", "Oceania") for desired data, e.g. \code{c("continent1", "continent2", ...)}. (Use one of \code{country} OR \code{ISO} OR \code{continent}, not combined)
#' @param species string specifying the Plasmodium species for which to find PR points, options include: \code{"Pf"} OR \code{"Pv"} OR \code{"BOTH"}
#' @param extent 2x2 matrix specifying the spatial extent within which PR data is desired, as returned by sp::bbox() - the first column has the minimum, the second the maximum values; rows 1 & 2 represent the x & y dimensions respectively (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max"))))
#'
#'
#' @return \code{getPR} returns a dataframe containing the below columns, in which each row represents a distinct data point/ study site.
#'
#' \enumerate{
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' \item \code{COLUMNNAME} description of contents
#' }
#'
#' @examples
#' #Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
#' \donttest{
#' NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
#' autoplot(NGA_CMR_PR)
#'
#' #Download PfPR data for Madagascar and map the locations of these points using autoplot
#' Madagascar_pr <- getPR(ISO = "MDG", species = "Pv")
#' autoplot(Madagascar_pr)
#'
#' getPR(country = "ALL", species = "BOTH")
#' }
#'
#'
#' @seealso \code{autoplot} method for quick mapping of PR point locations (\code{\link{autoplot.pr.points}}).
#'
#'
#' @export getPR

getPR <- function(country = NULL,
                  ISO = NULL,
                  continent = NULL,
                  species,
                  extent = NULL) {
  if (exists('available_countries_stored_pr', envir = .malariaAtlasHidden)) {
    available_countries_pr <-
      .malariaAtlasHidden$available_countries_stored_pr
  } else{
    available_countries_pr <- listPoints(printed = FALSE, sourcedata = "pr points")
  }
  
  if (is.null(country) &
      is.null(ISO) & is.null(continent) & is.null(extent)) {
    stop("Must specify one of: 'country', 'ISO', 'continent', or 'extent'.")
  }
  
  
  URL <-
    "https://map.ox.ac.uk/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=PR_Data"
  
  if (tolower(species) == "both") {
    columns <-
      "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"
    
  } else if (tolower(species) == "pf") {
    columns <-
      "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pf_pos,pf_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"
    
  } else if (tolower(species) == "pv") {
    columns <-
      "&PROPERTYNAME=site_id,dhs_id,site_name,latitude,longitude,month_start,year_start,month_end,year_end,lower_age,upper_age,examined,pv_pos,pv_pr,method,rdt_type,pcr_type,rural_urban,country_id,country,continent_id,malaria_metrics_available,location_available,permissions_info,citation1,citation2,citation3"
    
  } else {
    stop("Species not recognized, use one of: \n   \"Pf\" \n   \"Pv\" \n   \"BOTH\"")
  }
  
  
  if ("all" %in% tolower(c(country, ISO))) {
    message(paste(
      "Importing PR point data for all locations, please wait...",
      sep = ""
    ))
    df <-
      utils::read.csv(paste(URL, columns, sep = ""), encoding = "UTF-8")[, -1]
    message("Data downloaded for all available locations.")
  } else{
    if (any(c(!is.null(country),!is.null(ISO),!is.null(continent)))) {
      if (!(is.null(country))) {
        cql_filter <- "country"
        colname <- "country"
      } else if (!(is.null(ISO))) {
        cql_filter <- "country_id"
        colname <- "country_id"
      } else if (!(is.null(continent))) {
        cql_filter <- "continent_id"
        colname <- "continent"
      }
      

      checked_availability_pr <-
        isAvailable_pr(
          sourcedata = "pr points",
          country = country,
          ISO = ISO,
          continent = continent,
          full_results = TRUE
        )
      message(paste(
        "Attempting to download PR point data for",
        paste(available_countries_pr$country[available_countries_pr[, colname] %in% checked_availability_pr$location[checked_availability_pr$is_available ==
                                                                                                              1]], collapse = ", "),
        "..."
      ))
      country_URL <-
        paste("%27",
              curl::curl_escape(gsub(
                "'", "''", checked_availability_pr$location[checked_availability_pr$is_available ==
                                                           1]
              )),
              "%27",
              sep = "",
              collapse = ",")
      full_URL <- paste(URL,
                        columns,
                        "&cql_filter=",
                        cql_filter,
                        "%20IN%20(",
                        country_URL,
                        ")",
                        sep = "")
    } else if (!is.null(extent)) {
      bbox_filter <-
        paste0("&srsName=EPSG:4326&bbox=",
               extent[2, 1],
               ",",
               extent[1, 1],
               ",",
               extent[2, 2],
               ",",
               extent[1, 2])
      full_URL <- paste0(URL, columns, bbox_filter)
    }
    
    
    df <- utils::read.csv(full_URL, encoding = "UTF-8")[, -1]
    
    # Just to avoid visible binding notes
    pf_pr <- pv_pr <- permissions_info <- NULL
    
    # removing points that are publicly available but are for the opposite species to what is currently queried.
    if (tolower(species) == "pf") {
      df <-
        dplyr::filter(df,!(is.na(pf_pr) & permissions_info %in% c("", NA)))
    } else if (tolower(species) == "pv") {
      df <-
        dplyr::filter(df,!(is.na(pv_pr) & permissions_info %in% c("", NA)))
    }
    
    if (!nrow(df) > 0 & !is.null(extent)) {
      stop(
        "Error in downloading data for extent: (",
        paste0(extent, collapse = ","),
        "),\n try query using country or continent name OR check data availability at map.ox.ac.uk/explorer."
      )
    }
    
    if (nrow(df) == 0) {
      stop(
        "PR data points are not available for the specified species in requested countries; \n confirm species-specific data availability at map.ox.ac.uk/explorer."
      )
    }
    
    if (any(c(!is.null(country),!is.null(ISO),!is.null(continent)))) {
      message(
        "Data downloaded for ",
        paste(checked_availability_pr$location[checked_availability_pr$is_available ==
                                              1], collapse = ", "),
        "."
      )
    } else if (!is.null(extent)) {
      message("Data downloaded for extent: ",
              paste0(extent, collapse = ","))
    }
    
  }
  
  if (tolower(species) == "both") {
    if (all(is.na(unique(df$pv_pos)))) {
      message(
        "NOTE: All available data for this query was downloaded for both species,\n but there are no PR points for P. vivax in this region in the MAP database. \nTo check endemicity patterns or to contribute data, visit map.ox.ac.uk OR email us at map@bdi.ox.ac.uk."
      )
    } else if (all(is.na(unique(df$pf_pos)))) {
      message(
        "NOTE: All available data for this query was downloaded for both species,\n but there are no PR points for P. falciparum in this region in the MAP database. \nTo check endemicity patterns or to contribute data, visit map.ox.ac.uk OR email us at map@bdi.ox.ac.uk."
      )
    }
  }
  
  if (any(grepl("dhs", df$permissions_info))) {
    message(
      "NOTE: Downloaded data includes data points from DHS surveys. \nMAP cannot share DHS survey cluster coordinates, but these are available from www.measuredhs.com."
    )
  }
  
  class(df) <- c("pr.points", class(df))
  
  df <- pr_wide2long(df)
  
  return(df)
  
}


pr_wide2long <- function(object) {
  object$species <- NA
  
  if (all(c("pv_pr", "pf_pr") %in% colnames(object))) {
    pf <-
      rbind(object[is.na(object$pv_pos) &
                     !is.na(object$pf_pos), -which(names(object) %in% grep("pv", names(object), value = T))],
            object[!is.na(object$pv_pos) &
                     !is.na(object$pf_pos), -which(names(object) %in% grep("pv", names(object), value = T))])
    pv <-
      rbind(object[!is.na(object$pv_pos) &
                     is.na(object$pf_pos), -which(names(object) %in% grep("pf", names(object), value = T))],
            object[!is.na(object$pv_pos) &
                     !is.na(object$pf_pos), -which(names(object) %in% grep("pf", names(object), value = T))])
    conf <-
      object[is.na(object$pv_pos) &
               is.na(object$pf_pos), -which(names(object) %in% grep("pf", names(object), value = T))]
    
    names(pf)[which(names(pf) %in% grep("pos", names(pf), value = T))] <-
      "positive"
    names(pv)[which(names(pv) %in% grep("pos", names(pv), value = T))] <-
      "positive"
    names(conf)[which(names(conf) %in% grep("pos", names(conf), value = T))] <-
      "positive"
    names(pf)[which(names(pf) %in% grep("pr", names(pf), value = T))] <-
      "pr"
    names(pv)[which(names(pv) %in% grep("pr", names(pv), value = T))] <-
      "pr"
    names(conf)[which(names(conf) %in% grep("pr", names(conf), value = T))] <-
      "pr"
    
    if (nrow(pf) != 0) {
      pf$species <- "P. falciparum"
    }
    if (nrow(pv) != 0) {
      pv$species <- "P. vivax"
    }
    if (nrow(conf) != 0) {
      conf$species <- "Confidential"
    }
    
    # To avoid no visible bindings. But maybe need to learn tidyeval.
    object <-
      dhs_id <- site_id <- site_name <- latitude <-  longitude <- NULL
    rural_urban <-
      country <- country_id <- continent_id <- month_start <- NULL
    year_start <-
      month_end <- year_end <- lower_age <- upper_age <- examined <- NULL
    positive <-
      pr <- species <- method <- rdt_type <- pcr_type <- NULL
    malaria_metrics_available <-
      location_available <- permissions_info <- NULL
    citation1 <- citation2 <- citation3 <- NULL
    
    object <- rbind(pf, pv, conf)
    object <-
      dplyr::select(
        object,
        dhs_id,
        site_id,
        site_name,
        latitude,
        longitude,
        rural_urban,
        country,
        country_id,
        continent_id,
        month_start,
        year_start,
        month_end,
        year_end,
        lower_age,
        upper_age,
        examined,
        positive,
        pr,
        species,
        method,
        rdt_type,
        pcr_type,
        malaria_metrics_available,
        location_available,
        permissions_info,
        citation1,
        citation2,
        citation3
      )
    
  } else if ("pv_pr" %in% colnames(object) &
             !("pf_pr" %in% colnames(object))) {
    pv <- object[!is.na(object$pv_pos), ]
    conf <- object[is.na(object$pv_pos), ]
    
    names(pv)[which(names(pv) %in% grep("pos", names(pv), value = T))] <-
      "positive"
    names(conf)[which(names(conf) %in% grep("pos", names(conf), value = T))] <-
      "positive"
    
    names(pv)[which(names(pv) %in% grep("pr", names(pv), value = T))] <-
      "pr"
    names(conf)[which(names(conf) %in% grep("pr", names(conf), value = T))] <-
      "pr"
    
    if (nrow(pv) != 0) {
      pv$species <- "P. vivax"
    }
    if (nrow(conf) != 0) {
      conf$species <- "Confidential"
    }
    
    object <- rbind(pv, conf)
    object <-
      dplyr::select(
        object,
        dhs_id,
        site_id,
        site_name,
        latitude,
        longitude,
        rural_urban,
        country,
        country_id,
        continent_id,
        month_start,
        year_start,
        month_end,
        year_end,
        lower_age,
        upper_age,
        examined,
        positive,
        pr,
        species,
        method,
        rdt_type,
        pcr_type,
        malaria_metrics_available,
        location_available,
        permissions_info,
        citation1,
        citation2,
        citation3
      )
    
  } else if (!("pv_pr" %in% colnames(object)) &
             "pf_pr" %in% colnames(object)) {
    pf <- object[!is.na(object$pf_pos), ]
    conf <- object[is.na(object$pf_pos), ]
    
    names(pf)[which(names(pf) %in% grep("pos", names(pf), value = T))] <-
      "positive"
    names(conf)[which(names(conf) %in% grep("pos", names(conf), value = T))] <-
      "positive"
    
    names(pf)[which(names(pf) %in% grep("pr", names(pf), value = T))] <-
      "pr"
    names(conf)[which(names(conf) %in% grep("pr", names(conf), value = T))] <-
      "pr"
    
    if (nrow(pf) != 0) {
      pf$species <- "P. falciparum"
    }
    if (nrow(conf) != 0) {
      conf$species <- "Confidential"
    }
    
    object <- rbind(pf, conf)
    object <-
      dplyr::select(
        object,
        dhs_id,
        site_id,
        site_name,
        latitude,
        longitude,
        rural_urban,
        country,
        country_id,
        continent_id,
        month_start,
        year_start,
        month_end,
        year_end,
        lower_age,
        upper_age,
        examined,
        positive,
        pr,
        species,
        method,
        rdt_type,
        pcr_type,
        malaria_metrics_available,
        location_available,
        permissions_info,
        citation1,
        citation2,
        citation3
      )
    
  }
  
  return(object)
}

#' Convert data.frames to pr.points objects.
#' 
#' Will create empty columns for any missing columns expected in a pr.points data.frame.
#' This function is particularly useful for use with packages like dplyr that strip 
#' objects of their classes.
#' 
#' @param x A data.frame
#' 
#' 
#' @export
#' 
#' @examples
#' #Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
#' \donttest{
#' library(magrittr)
#' NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
#' 
#' # Filter the data frame then readd pr.points class so that autoplot can be used.
#' NGA_CMR_PR %>% 
#'   filter(year_start > 2010) %>% 
#'   as.pr.points %>% 
#'   autoplot
#'
#' }

as.pr.points <- function(x){
  
  expected_col_names <- c("dhs_id", "site_id", "site_name", "latitude", "longitude", 
                          "rural_urban", "country", "country_id", "continent_id", "month_start", 
                          "year_start", "month_end", "year_end", "lower_age", "upper_age", 
                          "examined", "positive", "pr", "species", "method", "rdt_type", 
                          "pcr_type", "malaria_metrics_available", "location_available", 
                          "permissions_info", "citation1", "citation2", "citation3")
  
  missing_columns <- expected_col_names[!(expected_col_names %in% names(x))]
  
  stopifnot(inherits(x, 'data.frame'))
  
  if(length(missing_columns < 0)){
    warning('Creating columns of NAs: ', paste0(missing_columns, collapse = ', '))
    newcols <- data.frame(matrix(NA, ncol = length(missing_columns), nrow = nrow(x)))
    names(newcols) <- missing_columns
    x <- cbind(x, newcols)
  }
  
  class(x) <- c('pr.points', class(x))
  return(x)
}




