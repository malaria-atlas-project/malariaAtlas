as.MAPraster <- function(raster_object){

  rasterobj2df <- function(object){
    raster_df <- as(object, "SpatialPixelsDataFrame")
    raster_df <- as.data.frame(raster_df)
    raster_df <- tidyr::gather(raster_df, key = "raster_name", value = "z", -x,-y)
    return(raster_df)
    }

    if(inherits(raster_object, c("RasterLayer", "RasterBrick"))){
    raster_df <- rasterobj2df(raster_object)
    class(raster_df) <- c(class(raster_df), "MAPraster")
    return(raster_df)

    }else if(inherits(raster_object, "list")){
      raster_df <- do.call(rbind, lapply(raster_object, rasterobj2df))
      class(raster_df) <- c(class(raster_df), "MAPraster")
      return(raster_df)
    }
}





