#' Default autoplot method
#' @param object object to plot
#' @param ... other arguments
#' @export
autoplot.default <- function(object, ...) {
  if (is.null(object)) {
    return()
  }
  stop(paste0("Objects of class <", class(object),"> are not supported by autoplot"))
}