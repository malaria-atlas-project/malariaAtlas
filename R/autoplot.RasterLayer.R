autoplot.RasterLayer <- function(object, boundaries = NULL, shp_df = NULL, legend = ""){

  object <- as.MAPraster(object)

  autoplot(object = object, boundaries = boundaries, shp_df = shp_df, legend = legend)

}
