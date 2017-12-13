autoplot_MAPraster <- function(object,...){
  object <- as.MAPraster(object)

  plot <- autoplot.MAPraster(object, ...)
return(plot)
}
