### add raster_code specification to zonalStats
### add a thing that changes the XML list to a dataframe.

listAdmin <- function(){

  if(exists('available_admin_stored', envir = .malariaAtlasHidden)){
    available_admin <- .malariaAtlasHidden$available_admin_stored

    return(invisible(available_admin))
  } else {

  URL_admin1 <- "http://map-prod3.ndph.ox.ac.uk:8080/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=admin1_map_2013&PROPERTYNAME=GAUL_CODE,COUNTRY_ID,ADMN_LEVEL,PARENT_ID,NAME"
  URL_admin0 <- "http://map-prod3.ndph.ox.ac.uk:8080/geoserver/Explorer/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=csv&TypeName=admin0_map_2013&PROPERTYNAME=GAUL_CODE,COUNTRY_ID,ADMN_LEVEL,PARENT_ID,NAME"

  available_admin <- rbind(read.csv(URL_admin0, encoding = "UTF-8"), read.csv(URL_admin1, encoding = "UTF-8"))
  .malariaAtlasHidden$available_admin_stored <- available_admin
  }
  return(available_admin)
}

getGAUL <- function(loc_name = NULL, ISO = NULL){

  ## If only ISO is supplied, assume asking for national zonal stats and return ADMIN0 GAUL_CODE associated with that ISO
  if(is.null(loc_name) & !is.null(ISO)){
    GAUL_CODE <- available_admin[available_admin$COUNTRY_ID %in% ISO & available_admin$ADMN_LEVEL==0, c("GAUL_CODE", "NAME")]

    if(length(GAUL_CODE$GAUL_CODE==0) | length(GAUL_CODE$GAUL_CODE)>length(ISO)){
      stop("Could not match all specified ISO codes to a GAUL_CODE, double check specification, or check all available units using listAdmin().")
    }else{
      return(GAUL_CODE)
    }
  }

  if(is.null(loc_name) & is.null(ISO)){
    stop("If specifying a loc_name, must also specify an ISO3.")
  }

  available_admin <- listAdmin()

  ## if specifying loc_name, check if this directly matches admin_unit names we have.
  if(all(loc_name %in% available_admin$NAME)){
    GAUL_CODE <- available_admin[available_admin$COUNTRY_ID %in% ISO & available_admin$NAME %in% loc_name, c("GAUL_CODE", "NAME")]

    if(length(GAUL_CODE$GAUL_CODE)!=length(loc_name)){
      stop("More matched GAUL_CODEs than specified loc_names, double check specification, or check all available units using listAdmin().")
    }else{
      return(GAUL_CODE)
    }

  ##if loc_name doesnt directly match admin_units, check for fuzzy match via agrep
  }else if(!loc_name %in% available_admin$NAME){
    match <- unlist(lapply(loc_name, agrep, x = available_admin$NAME[available_admin$COUNTRY_ID==ISO], ignore.case = TRUE, value = TRUE, max.distance = 1))

    if(length(match)!=length(loc_name)){
      stop(paste0("More matches found than supplied loc_name, select from the following:\n", paste(match, collapse = "\n")))
      }else if(length(match)==lenth(loc_name)){
      GAUL_CODE <- available_admin[available_admin$NAME %in% match, c("GAUL_CODE", "NAME")]
      return(GAUL_CODE)
    }
  }
}

zonalStatDownload <- function(GAUL_CODE,shp, surface){
  ##polygon specification
  if(is.null(shp)){
    poly_xml <-  paste0('<p0:Input>',
                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">zones</p1:Identifier>',
                        '<p0:Reference xmlns:p7="http://www.w3.org/1999/xlink" p7:href="http://geoserver/wps" method="POST" mimeType="text/xml; subtype=wfs-collection/1.0">',
                        '<p0:Body><p0:Execute service="WPS" version="1.0.0">',
                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">vec:Query</p1:Identifier>',
                        '<p0:DataInputs>',
                        '<p0:Input>',
                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">features</p1:Identifier>',
                        '<p0:Reference xmlns:p6="http://www.w3.org/1999/xlink" p6:href="http://geoserver/wfs" method="POST" mimeType="text/xml">',
                        '<p0:Body>',
                        '<p5:GetFeature xmlns:p5="http://www.opengis.net/wfs" service="WFS" version="1.1.0" outputFormat="GML3">',
                        '<p5:Query typeName="Explorer:admin0_map_2013" srsName="EPSG:3857" />',
                        '</p5:GetFeature>',
                        '</p0:Body>',
                        '</p0:Reference>',
                        '</p0:Input>',
                        '<p0:Input>',
                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">filter</p1:Identifier>',
                        '<p0:Data>',
                        '<p0:ComplexData mimeType="text/plain; subtype=cql">GAUL_CODE=',GAUL_CODE,'</p0:ComplexData>',
                        '</p0:Data>',
                        '</p0:Input>',
                        '</p0:DataInputs>',
                        '<p0:ResponseForm>',
                        '<p0:RawDataOutput>',
                        '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">result</p1:Identifier>',
                        '</p0:RawDataOutput>',
                        '</p0:ResponseForm>',
                        '</p0:Execute>',
                        '</p0:Body>',
                        '</p0:Reference>',
                        '</p0:Input>',
                        '</p0:DataInputs>')
  }else if(!is.null(shp)){
    shp_epsg3857 <- sp::spTransform(shp, sp::CRS("+init=epsg:3857"))
    shp_wkt <- rgeos::writeWKT(shp_epsg3857)

    poly_xml <- paste0('<p0:Input>',
                       '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">zones</p1:Identifier>',
                       '<p0:Reference xmlns:p5="http://www.w3.org/1999/xlink" p5:href="http://geoserver/wps" method="POST" mimeType="text/xml; subtype=wfs-collection/1.0">',
                       '<p0:Body>',
                       '<p0:Execute service="WPS" version="1.0.0">',
                       '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">vec:Feature</p1:Identifier>',
                       '<p0:DataInputs>',
                       '<p0:Input>',
                       '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">geometry</p1:Identifier>',
                       '<p0:Data>',
                       '<p0:ComplexData mimeType="application/wkt">',
                       paste(shp_wkt),
                       '</p0:ComplexData>',
                       '</p0:Data>',
                       '</p0:Input>',
                       '<p0:Input>',
                       '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">crs</p1:Identifier>',
                       '<p0:Data>',
                       '<p0:LiteralData>EPSG:3857</p0:LiteralData>',
                       '</p0:Data>',
                       '</p0:Input>',
                       '<p0:Input>',
                       '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">typeName</p1:Identifier>',
                       '<p0:Data>',
                       '<p0:LiteralData>zones</p0:LiteralData>',
                       '</p0:Data>',
                       '</p0:Input>',
                       '</p0:DataInputs>',
                       '<p0:ResponseForm>',
                       '<p0:RawDataOutput>',
                       '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">result</p1:Identifier>',
                       '</p0:RawDataOutput>',
                       '</p0:ResponseForm>',
                       '</p0:Execute>',
                       '</p0:Body>',
                       '</p0:Reference>',
                       '</p0:Input>',
                       '</p0:DataInputs>')
  }

  xml_rqst <- paste0("",
                     ## Initial block
                     '<?xml version="1.0" encoding="UTF-8"?>',
                     '<p0:Execute xmlns:p0="http://www.opengis.net/wps/1.0.0" xmlns:Explorer="uk.ac.ox.ndph.map.explorer" service="WPS" version="1.0.0">',
                     '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">ras:RasterZonalStatistics</p1:Identifier>',
                     '<p0:DataInputs>',
                     '<p0:Input>',
                     '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">data</p1:Identifier>',
                     '<p0:Reference xmlns:p4="http://www.w3.org/1999/xlink" p4:href="http://geoserver/wcs" method="POST" mimeType="image/tiff">',
                     '<p0:Body>',
                     '<p2:GetCoverage xmlns:p2="http://www.opengis.net/wcs/1.1.1" service="WCS" version="1.1.1">',
                     '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">Explorer:africa-pr-2000-2015</p1:Identifier>',
                     '<p2:DomainSubset>',
                     '<p1:BoundingBox xmlns:p1="http://www.opengis.net/ows/1.1" crs="http://www.opengis.net/gml/srs/epsg.xml#4326">',
                     '<p1:LowerCorner>-18.0000648 -35.00001</p1:LowerCorner>',
                     '<p1:UpperCorner>52.04157385 37.54162765</p1:UpperCorner>',
                     '</p1:BoundingBox>',
                     '<p2:TemporalSubset>',
                     '<p3:timePosition xmlns:p3="http://www.opengis.net/gml">2000-01-01T00:00:00.00Z</p3:timePosition>',
                     '</p2:TemporalSubset>',
                     '</p2:DomainSubset>',
                     '<p2:Output format="image/tiff" />',
                     '</p2:GetCoverage>',
                     '</p0:Body>',
                     '</p0:Reference>',
                     '</p0:Input>',
                     ## polygon specification
                     poly_xml,
                     ## end block
                     '<p0:ResponseForm>',
                     '<p0:RawDataOutput mimeType="text/xml; subtype=wfs-collection/1.1">',
                     '<p1:Identifier xmlns:p1="http://www.opengis.net/ows/1.1">statistics</p1:Identifier>',
                     '</p0:RawDataOutput>',
                     '</p0:ResponseForm>',
                     '</p0:Execute>')

  hdl <- curl::new_handle()
  curl::handle_setopt(hdl,
                      copypostfields = paste(xml_rqst))
  curl::handle_setheaders(hdl,
                          "Content-Type" = "application/xml",
                          "Cache-Control" = "no-cache")

  rstdir <- file.path(file_path,"zonalStats")
  dir.create(rstdir)
  temp_zs_dl <- tempfile(pattern = paste("test","_",sep = ""), tmpdir = rstdir, fileext = ".xml")

  curl::curl_download(url = "http://map-prod3.ndph.ox.ac.uk/geoserver/wps", destfile = temp_zs_dl, handle = hdl)

  zs_dl <- XML::xmlToList(temp_zs_dl)

  return(zs_dl)
}

zonalStats <- function(surface = "PfPR2-10", shp = NULL, GAUL_CODE = NULL,ISO = NULL, loc_name = NULL, file_path = tempdir()){


  #if both GAUL_CDOE and shp are NULL, need to convert ISO and/or loc_name to GAUL_CODE(s)
  if(!is.null(GAUL_CODE) & !is.null(shp)){
    GAUL_CODE <- getGAUL(loc_name = loc_name, ISO = ISO)
    }

  available_rasters <- listAllRaster()

  raster_code <- unlist(available_rasters$raster_code[match(surface, available_rasters$title)])

  if(is.null(shp)){
    if(length(GAUL_CODE$GAUL_CODE)>1){
      x <- lapply(GAUL_CODE$GAUL_CODE, zonalStatDownload, surface = surface, shp = NULL)
    }else{
    x <- zonalStatDownload(GAUL_CODE = GAUL_CODE, shp = NULL, surface = surface)
  }
  }

  if(is.null(GAUL_CODE)){
    if(length(shp$GAUL_CODE)>1){
      x <- lapply(shp$GAUL_CODE, function(x){shp_2 = shp[shp$GAUL_CODE==x,]
      zonalStatDownload(GAUL_CODE = NULL, shp = shp_2, surface = surface)})
    }
  }



}


