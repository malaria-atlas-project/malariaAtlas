as.MAPraster <- function(raster_object){

  if("RasterLayer" %in% class(raster_object)){

  raster_df <- as(raster_object, "SpatialPixelsDataFrame")
  raster_df <- as.data.frame(raster_df)
  class(raster_df) <- c(class(raster_df), "MAPraster")
  return(raster_df)
  }else if("RasterBrick"%in% class(raster_object)){
    raster_df <- as(raster_object, "SpatialPixelsDataFrame")
    raster_df <- as.data.frame(raster_df)
    raster_columns <- names(raster_object)[!names(raster_object) %in% c("x", "y")]

    mini_df <- function(column, df){
      df <- df[,c(paste(column),"x","y")]
    }


    raster_df <- lapply(X = raster_columns, FUN = mini_df, df = raster_df)
    raster_df <- lapply(raster_df, rbind)

    raster_df <- gather(raster_df, raster_columns, c("x","y"))

    class(raster_df) <- c(class(raster_df), "MAPraster")




  }else if ("list" %in% class(raster_object))
    res_1 <- raster_object[[1]]
  res_2 <- raster_object[[2]]




    }
