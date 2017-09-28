as.MAPraster <- function(raster_object){

  if("RasterLayer" %in% class(raster_object)){
  raster_df <- as(raster_object, "SpatialPixelsDataFrame")
  raster_df <- as.data.frame(raster_df)
  raster_df$raster_name <- names(raster_df[1])
  names(raster_df) <- c("z","x","y","raster_name")
  class(raster_df) <- c(class(raster_df), "MAPraster")
  return(raster_df)
  }else if("RasterBrick"%in% class(raster_object)){
    raster_df <- as(raster_object, "SpatialPixelsDataFrame")
    raster_df <- as.data.frame(raster_df)
    raster_df <- tidyr::gather(raster_df, key = "raster_name", value = "z", -x,-y)

    class(raster_df) <- c(class(raster_df), "MAPraster")

    return(raster_df)
  }#else if ("list" %in% class(raster_object))

    }

