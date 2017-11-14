
zonalStats <- function(surface = "PfPR2-10", shp = NULL, GAUL_CODE = NULL, file_path = tempdir()){

  #add way to move between ISO and GAUL_CODE where

  available_rasters <- listAllRaster()

  raster_code <- unlist(available_rasters$raster_code[match(surface, available_rasters$title)])
  GAUL_CODE <- 94
  GAUL_CODE <- 1237
  countrycode("GHA", "iso3c", "iso2c")


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

}


