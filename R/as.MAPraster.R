as.MAPraster <- function(raster){

  raster_df <- as(raster, "SpatialPixelsDataFrame")
  raster_df <- as.data.frame(raster_df)
  class(raster_df) <- c(class(raster_df), "MAPraster")
  return(raster_df)
}
