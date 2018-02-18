#' #' Download zonal statistics for Malaria Atlas Project rasters for specified administrative units/polygons.
#' #'
#' #' \code{zonalStats} downloads zonal statistics for Malaria Atlas Project rasters for specified administrative units/polygons.
#' #'
#' #' @param surface string containing 'title' of desired raster(s). Only one surface can be specified at a time. Defaults to "PfPR2-10" - the most recent global raster of PfPR 2-10.
#' #' Check \code{\link{listRaster}} to find titles of available rasters.
#' #' @param year vector containing the years for which zonal statistics are desired (for time-varying rasters) if raster is time-varying and no year is specified, zonalStats uses the most recent available year for the specifed surface; for static rasters use NA.
#' #' @param shp SpatialPolygons or SpatialPolygonsDataFrame object for which zonal statistics are desired. See \code{\link{getShp}} to download polygons at administrative levels 0 or 1. Use one of \code{shp} OR \code{GAUL_CODE} OR \code{ISO}+\code{loc_name}.
#' #' @param GAUL_CODE GAUL_CODE of administrative unit for which zonal statistics are desired. Use one of \code{shp} OR \code{GAUL_CODE} OR \code{ISO}+\code{loc_name}.
#' #' @param loc_name If not specifying shp or GAUL_CODE, you can specify administrative units by location_name + ISO3 combination (BOTH are required). See available admin units and spelling with listShp(). Use one of \code{shp} OR \code{GAUL_CODE} OR \code{ISO}+\code{loc_name}.
#' #' @param ISO If not specifying shp or GAUL_CODE, you can specify administrative units by location_name + ISO3 combination (BOTH are required). See available admin units and spelling with listShp(). Use one of \code{shp} OR \code{GAUL_CODE} OR \code{ISO}+\code{loc_name}.
#' #' @param file_path (optional) user-specified path to which zonalStats intermediate results are stored. If not specified, tempdir() is used instead.
#' #'
#' #' @return \code{zonalStats} returns a dataframe with the below columns.
#' #'
#' #' N.B. If inputing a \code{SpatialPolygon} zonal stats are identifiable by POLYGON_ID (slot @@Polygon, slot @@ID));
#' #' if inputing a \code{SpatialPolygonsDataFrame} zonal stats are appended to shp@data.
#' #' if using \code{GAUL_CODE} or \code{ISO} + \code{loc_name} zonal stats are appended to columns returned by \code{listShp()}
#' #'
#' #' \enumerate{
#' #' \item \code{min} minimum pixel value in Polygon.
#' #' \item \code{max} maximum pixel value in Polygon
#' #' \item \code{avg} average pixel value across Polygon
#' #' \item \code{stddev} standard deviation of pixel values across Polygon
#' #' \item \code{year} year to which extracted values refer
#' #' \item \code{raster_title} raster surface from which values have been summarised
#' #' }
#' #'
#' #' @examples
#' #' #Download zonal statistics for PfPR2-10 for administrative level 1 units in Nigeria  in 2015 & visualise these on a map.
#' #' \dontrun{
#' #' NGA_admin1_shp <- getShp(ISO = "NGA", admin_level = "admin1")
#' #' NGA_admin1_pfpr_zs <- zonalStats(surface = "PfPR2-10", shp = NGA_admin1_shp)
#' #' NGA_admin1_pfpr_shp <- dplyr::left_join(as.MAPshp(NGA_admin1_shp), NGA_admin1_pfpr_zs, by = c("GAUL_CODE"))
#' #'
#' #' p <- autoplot(as.MAPshp(NGA_admin1_shp))
#' #' p <- p + geom_polygon(data = NGA_admin1_pfpr_shp, aes(x = long, y = lat, group = group, fill = avg), colour = "grey20")+
#' #' scale_fill_distiller(name = "Mean PfPR",palette = "RdYlBu")+
#' #' ggtitle("Mean PfPR in Nigeria: ADMIN1")
#' #' p}
#' #'
#' #' #Download zonal statistics for mean travel time to cities for West Papua, Indonesia.
#' #' \dontrun{
#' #' available_admin_units <- listShp()
#' #' papua_barat_GAUL_CODE <- 1013664
#' #' papua_barat_access_zs <- zonalStats(surface = "A global map of travel time to cities to assess inequalities in accessibility in 2015", GAUL_CODE = papua_barat_GAUL_CODE)
#' #' }
#' #'
#' #' #Download zonal statistics for predicted all-cause fever prevalence in Melaky, Madagascar in 2006, 2010 & 2014
#' #' #' \dontrun{
#' #' melaky_all_cause_fever_zs <- zonalStats(surface = "All-cause fever", loc_name = "Melaky", ISO = "MDG", year = c(2006, 2010, 2014))
#' #' }
#' #'#' @seealso
#' #' \code{autoplot} method for quick mapping of shapefiles \code{\link{autoplot.MAPshp}}.
#' #' \code{getRaster} to download full/clipped rasters from MAP \code{\link{getRaster}}.
#' #'
#' #'
#' #' @export
#'
#'
#' zonalStats <- function(surface = "PfPR2-10",
#'                        year = NA,
#'                        shp = NULL,
#'                        GAUL_CODE = NULL,
#'                        ISO = NULL,
#'                        loc_name = NULL,
#'                        file_path = tempdir()){
#'
#'   #if both GAUL_CODE and shp are NULL, need to convert ISO and/or loc_name to GAUL_CODE(s)
#'   if(is.null(GAUL_CODE) & is.null(shp)){
#'     GAUL_CODE <- getGAUL(loc_name = loc_name, ISO = ISO)
#'     GAUL_CODE <- GAUL_CODE$GAUL_CODE
#'   }
#'
#'   available_rasters <- listRaster(printed = FALSE)
#'
#'   raster_code <- available_rasters$raster_code[match(surface, available_rasters$title)]
#'
#'   # check that surface has been specified correctly (i.e. has been converted to a raster_code)
#'   if(is.na(raster_code)){
#'     stop("Surface has been incorrectly specified, use listRaster to confirm spelling of raster 'title'.")
#'   }
#'
#'   # if year is NA and raster is dynamic, choose most recent year to download zonal stats.
#'   if(all(is.na(year))&!is.na(available_rasters$max_raster_year[available_rasters$raster_code==raster_code])){
#'     year <- available_rasters$max_raster_year[available_rasters$raster_code==raster_code]
#'   }
#'
#'   # check whether specified years are available for specified rasters
#'   year_warnings = 0
#'
#'     for(y in year){
#'       if(!is.na(y)){
#'         if(!y %in% seq(available_rasters$min_raster_year[available_rasters$raster_code==raster_code&!is.na(available_rasters$min_raster_year)],
#'                        available_rasters$max_raster_year[available_rasters$raster_code==raster_code&!is.na(available_rasters$max_raster_year)],
#'                        by = 1)){
#'           warning(paste0("Raster: \"",available_rasters$title[available_rasters$raster_code==raster_code],"\" not available for specified year: ", y, "\n  - check available raster years using listRaster()."))
#'           year_warnings = year_warnings+1
#'         }
#'       }
#'     }
#'
#'   if(year_warnings>0){
#'     stop("Specified surfaces are not available for all requested years, \n try downloading surfaces separately or double-check availability of 'surface'-'year' combinations using listRaster()\n see warnings() for more info.")
#'   }
#'
#'   if(is.null(shp)&!is.null(GAUL_CODE)){
#'
#'     if(length(GAUL_CODE)>1){
#'       zs_df_list <- lapply(GAUL_CODE, zonalStatDownload, raster_code = raster_code, shp = NULL, year = year)
#'       zs_df <- do.call(rbind, zs_df_list)
#'     }else{
#'       zs_df <- zonalStatDownload(GAUL_CODE = GAUL_CODE, shp = NULL, raster_code = raster_code, year = year)
#'     }
#'   }
#'
#'   if(is.null(GAUL_CODE)&!is.null(shp)){
#'     if(length(shp@polygons)>1){
#'       zs_df_list <- lapply(1:length(shp), function(x){zonalStatDownload(GAUL_CODE = NULL, shp = shp[x,], raster_code = raster_code, year = year)})
#'       zs_df <- do.call(rbind, zs_df_list)
#'     }else{
#'       zs_df <- zonalStatDownload(GAUL_CODE = NULL, shp = shp, raster_code = raster_code, year = year)
#'     }
#'   }
#'
#'   return(zs_df)
#' }
#'
#' zonalStatDownload <- function(GAUL_CODE = NULL,shp = NULL, year = NA, raster_code = NULL, file_path = tempdir()){
#'   zs_y_list <- list()
#'   available_rasters <- listRaster(printed = FALSE)
#'   for(y in year){
#'
#'   if(is.null(shp)){
#'     available_admin <- listShp(printed = FALSE)
#'     admin_level <- available_admin$ADMN_LEVEL[available_admin$GAUL_CODE==GAUL_CODE]
#'
#'     poly_xml <-  paste0('<p0:Input>',
#'                         '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">zones</p1:Identifier>',
#'                         '<p0:Reference xmlns:p7="http://www.w3.org/1999/xlink" p7:href="http://geoserver/wps" method="POST" mimeType="text/xml; subtype=wfs-collection/1.0">',
#'                         '<p0:Body><p0:Execute service="WPS" version="1.0.0">',
#'                         '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">vec:Query</p1:Identifier>',
#'                         '<p0:DataInputs>',
#'                         '<p0:Input>',
#'                         '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">features</p1:Identifier>',
#'                         '<p0:Reference xmlns:p6="http://www.w3.org/1999/xlink" p6:href="http://geoserver/wfs" method="POST" mimeType="text/xml">',
#'                         '<p0:Body>',
#'                         '<p5:GetFeature xmlns:p5="http://www.opengis.net/wfs" service="WFS" version="1.1.0" outputFormat="GML3">',
#'                         '<p5:Query typeName="Explorer:admin',paste(admin_level),'_map_2013" srsName="EPSG:3857" />',
#'                         '</p5:GetFeature>',
#'                         '</p0:Body>',
#'                         '</p0:Reference>',
#'                         '</p0:Input>',
#'                         '<p0:Input>',
#'                         '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">filter</p1:Identifier>',
#'                         '<p0:Data>',
#'                         '<p0:ComplexData mimeType="text/plain; subtype=cql">GAUL_CODE=',GAUL_CODE,'</p0:ComplexData>',
#'                         '</p0:Data>',
#'                         '</p0:Input>',
#'                         '</p0:DataInputs>',
#'                         '<p0:ResponseForm>',
#'                         '<p0:RawDataOutput>',
#'                         '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">result</p1:Identifier>',
#'                         '</p0:RawDataOutput>',
#'                         '</p0:ResponseForm>',
#'                         '</p0:Execute>',
#'                         '</p0:Body>',
#'                         '</p0:Reference>',
#'                         '</p0:Input>',
#'                         '</p0:DataInputs>')
#'   }else if(!is.null(shp)){
#'     shp_epsg3857 <- sp::spTransform(shp, sp::CRS("+init=epsg:3857"))
#'     shp_wkt <- rgeos::writeWKT(shp_epsg3857)
#'
#'     poly_xml <- paste0('<p0:Input>',
#'                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">zones</p1:Identifier>',
#'                        '<p0:Reference xmlns:p5="http://www.w3.org/1999/xlink" p5:href="http://geoserver/wps" method="POST" mimeType="text/xml; subtype=wfs-collection/1.0">',
#'                        '<p0:Body>',
#'                        '<p0:Execute service="WPS" version="1.0.0">',
#'                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">vec:Feature</p1:Identifier>',
#'                        '<p0:DataInputs>',
#'                        '<p0:Input>',
#'                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">geometry</p1:Identifier>',
#'                        '<p0:Data>',
#'                        '<p0:ComplexData mimeType="application/wkt">',
#'                        paste(shp_wkt),
#'                        '</p0:ComplexData>',
#'                        '</p0:Data>',
#'                        '</p0:Input>',
#'                        '<p0:Input>',
#'                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">crs</p1:Identifier>',
#'                        '<p0:Data>',
#'                        '<p0:LiteralData>EPSG:3857</p0:LiteralData>',
#'                        '</p0:Data>',
#'                        '</p0:Input>',
#'                        '<p0:Input>',
#'                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">typeName</p1:Identifier>',
#'                        '<p0:Data>',
#'                        '<p0:LiteralData>zones</p0:LiteralData>',
#'                        '</p0:Data>',
#'                        '</p0:Input>',
#'                        '</p0:DataInputs>',
#'                        '<p0:ResponseForm>',
#'                        '<p0:RawDataOutput>',
#'                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">result</p1:Identifier>',
#'                        '</p0:RawDataOutput>',
#'                        '</p0:ResponseForm>',
#'                        '</p0:Execute>',
#'                        '</p0:Body>',
#'                        '</p0:Reference>',
#'                        '</p0:Input>',
#'                        '</p0:DataInputs>')
#'   }
#'
#'   xml_rqst <- paste0("",
#'                      ## Initial block
#'                      '<?xml version="1.0" encoding="UTF-8"?>',
#'                      '<p0:Execute xmlns:p0="http://www.opengis.net/wps/1.0.0" xmlns:Explorer="uk.ac.ox.ndph.map.explorer" service="WPS" version="1.0.0">',
#'                      '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">ras:RasterZonalStatistics</p1:Identifier>',
#'                      '<p0:DataInputs>',
#'                      '<p0:Input>',
#'                      '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">data</p1:Identifier>',
#'                      '<p0:Reference xmlns:p4="http://www.w3.org/1999/xlink" p4:href="http://geoserver/wcs" method="POST" mimeType="image/tiff">',
#'                      '<p0:Body>',
#'                      '<p2:GetCoverage xmlns:p2="http://www.opengis.net/wcs/1.1.1" service="WCS" version="1.1.1">',
#'                      '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">Explorer:',raster_code,'</p1:Identifier>',
#'                      '<p2:DomainSubset>',
#'                      '<p1:BoundingBox xmlns:p1="http://www.opengis.net/ows/1.1" crs="http://www.opengis.net/gml/srs/epsg.xml#4326">',
#'                      '<p1:LowerCorner>-18.0000648 -35.00001</p1:LowerCorner>',
#'                      '<p1:UpperCorner>52.04157385 37.54162765</p1:UpperCorner>',
#'                      '</p1:BoundingBox>',
#'                      '<p2:TemporalSubset>',
#'                      '<p3:timePosition xmlns:p3="http://www.opengis.net/gml">',y,'-01-01T00:00:00.00Z</p3:timePosition>',
#'                      '</p2:TemporalSubset>',
#'                      '</p2:DomainSubset>',
#'                      '<p2:Output format="image/tiff"/>',
#'                      '</p2:GetCoverage>',
#'                      '</p0:Body>',
#'                      '</p0:Reference>',
#'                      '</p0:Input>',
#'                      ## polygon specification
#'                      poly_xml,
#'                      ## end block
#'                      '<p0:ResponseForm>',
#'                      '<p0:RawDataOutput mimeType="text/xml; subtype=wfs-collection/1.1">',
#'                      '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">statistics</p1:Identifier>',
#'                      '</p0:RawDataOutput>',
#'                      '</p0:ResponseForm>',
#'                      '</p0:Execute>')
#'
#'   hdl <- curl::new_handle()
#'   curl::handle_setopt(hdl,
#'                       copypostfields = paste(xml_rqst))
#'   curl::handle_setheaders(hdl,
#'                           "Content-Type" = "application/xml",
#'                           "Cache-Control" = "no-cache")
#'
#'   zsdir <- file.path(file_path,"zonalStats")
#'   dir.create(zsdir, showWarnings = FALSE)
#'   temp_zs_dl <- tempfile(pattern = paste("test","_",sep = ""), tmpdir = zsdir, fileext = ".xml")
#'
#'   curl::curl_download(url = "https://map.ox.ac.uk/geoserver/wps", destfile = temp_zs_dl, handle = hdl)
#'
#'   zs_dl <- XML::xmlToList(temp_zs_dl)
#'
#'   zs_dl_df <- as.data.frame(zs_dl$featureMember[[1]][names(zs_dl$featureMember[[1]]) %in% c("z_COUNTRY_ID", "z_GAUL_CODE", "z_ADMN_LEVEL", "z_PARENT_ID", "z_NAME", "min", "max", "avg", "stddev")])
#'   zs_dl_df$year <- y
#'   zs_dl_df$raster_title <- available_rasters$title[available_rasters$raster_code==raster_code]
#'   zs_dl_df$avg <- as.numeric(as.character(zs_dl_df$avg))
#'   zs_dl_df$min <- as.numeric(as.character(zs_dl_df$min))
#'   zs_dl_df$max <- as.numeric(as.character(zs_dl_df$max))
#'   zs_dl_df$stddev <- as.numeric(as.character(zs_dl_df$stddev))
#'
#'   if(!is.null(shp)){
#'   zs_dl_df$POLYGON_ID <- shp@polygons[[1]]@ID
#'   }
#'
#'   if(inherits(shp, "SpatialPolygonsDataFrame")){
#'     zs_dl_df <- cbind(shp@data, zs_dl_df)
#'   }
#'
#'   if(any(grepl("z_", names(zs_dl_df)))){
#'     names(zs_dl_df) <- gsub("z_", "", names(zs_dl_df))
#'   }
#'
#'   zs_y_list[[which(year == y)]] <- zs_dl_df
#'   }
#'
#'   zs_dl_df_full <- do.call(rbind, zs_y_list)
#'
#'   return(zs_dl_df_full)
#' }
#'
#' getGAUL <- function(loc_name = NULL, ISO = NULL){
#'
#'   ## If only ISO is supplied, assume asking for national zonal stats and return ADMIN0 GAUL_CODE associated with that ISO
#'   if(is.null(loc_name) & !is.null(ISO)){
#'     GAUL_CODE <- available_admin[available_admin$COUNTRY_ID %in% ISO & available_admin$ADMN_LEVEL==0, c("GAUL_CODE", "NAME")]
#'
#'     if(length(GAUL_CODE$GAUL_CODE==0) | length(GAUL_CODE$GAUL_CODE)>length(ISO)){
#'       stop("Could not match all specified ISO codes to a GAUL_CODE, double check specification, or check all available units using listShp().")
#'     }else{
#'       return(GAUL_CODE)
#'     }
#'   }
#'
#'   if(is.null(loc_name) & is.null(ISO)){
#'     stop("If specifying a loc_name, must also specify an ISO3.")
#'   }
#'
#'   available_admin <- listShp(printed = FALSE)
#'
#'   ## if specifying loc_name, check if this directly matches admin_unit names we have.
#'   if(all(loc_name %in% available_admin$NAME)){
#'     GAUL_CODE <- available_admin[available_admin$COUNTRY_ID %in% ISO & available_admin$NAME %in% loc_name, c("GAUL_CODE", "NAME")]
#'
#'     if(length(GAUL_CODE$GAUL_CODE)!=length(loc_name)){
#'       stop("More matched GAUL_CODEs than specified loc_names, double check specification, or check all available units using listShp().")
#'     }else{
#'       return(GAUL_CODE)
#'     }
#'
#'     ##if loc_name doesnt directly match admin_units, check for fuzzy match via agrep
#'   }else if(!loc_name %in% available_admin$NAME){
#'     match <- unlist(lapply(loc_name, agrep, x = available_admin$NAME[available_admin$COUNTRY_ID==ISO], ignore.case = TRUE, value = TRUE, max.distance = 1))
#'
#'     if(length(match)!=length(loc_name)){
#'       stop(paste0("More matches found than supplied loc_name, select from the following:\n", paste(match, collapse = "\n")))
#'     }else if(length(match)==lenth(loc_name)){
#'       GAUL_CODE <- available_admin[available_admin$NAME %in% match, c("GAUL_CODE", "NAME")]
#'       return(GAUL_CODE)
#'     }
#'   }
#' }
#'
