getRaster <- function(surface = "PfPR2010", shp = NULL, bbox = NULL, file_path = tempdir(), format = "rasterlayer"){

  if(!is.null(bbox)){
    bbox <- bbox
  }else if (!is.null(shp)){
  bbox <- sp::bbox(shp)
  }

  if(surface == "PfPR2010"){
    raster_code <- "ST_PR_mean"
  }else if(surface == "PvPR2010"){
    raster_code <- "PvPR_mean_2010"
  }else if(surface == "Pk2016"){
    raster_code <- "Pk_SEAsia_masked_280216"
  }else if(surface == "Pf Limits 2010"){
    raster_code <- "Pf_Limits_2010_decomp_tiled"
  }else if(surface == "funestus"){
    raster_code <- "Anophele funestus"
  }else if(surface == "G6PDd2010"){
    raster_code <- "G6PDd_allele_freq"
  }else if(surface == "Duffy2010"){
    raster_code <- "duffy_neg_tiled"
  }else if (surface == "Africa_ACT_2000-2015"){
    raster_code <- "africa-act-2000-2015"
  }else if (surface == "Africa_Pf_Incidence_2000-2015"){
    raster_code <- "africa-inc-2000-2015"
  }

  xml_rqst <- paste("<?xml version=\"1.0\" encoding=\"UTF-8\"?><GetCoverage version=\"1.0.0\" service=\"WCS\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.opengis.net/wcs\" xmlns:ows=\"http://www.opengis.net/ows/1.1\" xmlns:gml=\"http://www.opengis.net/gml\" xmlns:ogc=\"http://www.opengis.net/ogc\" xsi:schemaLocation=\"http://www.opengis.net/wcs http://schemas.opengis.net/wcs/1.0.0/getCoverage.xsd\">
  <sourceCoverage>Explorer:",paste(raster_code),"</sourceCoverage>
  <domainSubset>
    <spatialSubset>
      <gml:Envelope srsName=\"EPSG:4326\">
        <gml:pos>",paste(bbox[,1], collapse = " "),"</gml:pos>
        <gml:pos>",paste(bbox[,2], collapse = " "),"</gml:pos>
      </gml:Envelope>
      <gml:Grid dimension=\"2\">
        <gml:limits>
          <gml:GridEnvelope>
            <gml:low>0 0</gml:low>
            <gml:high>288 230</gml:high>
          </gml:GridEnvelope>
        </gml:limits>
        <gml:axisName>x</gml:axisName>
        <gml:axisName>y</gml:axisName>
      </gml:Grid>
    </spatialSubset>
  </domainSubset>
  <output>
    <crs>EPSG:4326</crs>
    <format>GeoTIFF</format>
  </output>
</GetCoverage>", sep = "")

  rstdir <- file.path(file_path,"getRaster")
  dir.create(rstdir, showWarnings = FALSE)
  temp_rst <- tempfile(pattern = paste(surface,"_",sep = ""), tmpdir = rstdir, fileext = ".tiff")

  r <- httr::POST(url = "http://map-prod3.ndph.ox.ac.uk/geoserver/wps",
            body = xml_rqst,
            httr::write_disk(temp_rst, overwrite = TRUE))

  if(!"image/tiff" %in% r$headers$`content-type`){
    stop("Raster download error - check surface is available for specified extent at map.ox.ac.uk/explorer.")
  }


  rst_dl <- raster::raster(temp_rst)

  if(!is.null(shp)){
    rst_dl <- raster::mask(rst_dl, shp)
  }

  if(tolower(format) == "rasterlayer"){
    return(rst_dl)
  } else if(tolower(format) == "df"){
    rst_spdf <- as(rst_dl, "SpatialPixelsDataFrame")
    rst_df <- as.data.frame(rst_spdf)
    class(rst_df) <- c(class(rst_df), "MAPraster")
    return(rst_df)
  }
}

## TEST <- getRaster(shp_df = tcdshp$admin0, file_path = "C:/Users/whgu0734/Test/")
## TEST2 <- getRaster(shp_df = MDGshp$admin0, file_path = "C:/Users/whgu0734/Test/")
