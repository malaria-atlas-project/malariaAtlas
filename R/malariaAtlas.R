#' An R interface to open-access malaria data, hosted by the Malaria Atlas Project.
#'
#' \code{malariaAtlas} provides a suite of tools to allow you to
#'  download all publicly available PR points for a specified country
#'  (or ALL countries) as a dataframe within R.
#'
#' @section malariaAtlas functions:
#'  \enumerate{
#'  \item \code{listAll} - lists all countries for which there are publicly visible PR datapoints in the MAP database.
#'  \item \code{is_available} - checks whether the MAP database contains PR points for the specified country/countries.
#'  \item \code{getPR} - downloads all publicly available PR points for a specified country (or countries) and returns this as a dataframe.
#'  }
#' @docType package
#' @name malariaAtlas
#' @import ggplot2
#' @importFrom graphics title
#' @import rlang

NULL


