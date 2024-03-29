% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/listVecOccPointVersions.R
\name{listVecOccPointVersions}
\alias{listVecOccPointVersions}
\title{List all dataset versions from the Web Feature Services provided by the Malaria Atlas Project within the Vector Occurrence workspace.}
\usage{
listVecOccPointVersions(printed = TRUE)
}
\arguments{
\item{printed}{Should the list be printed to the console?}
}
\value{
A data.frame with column 'version'.
The version can then be provided to other functions to fetch the data within that dataset. e.g. in getVecOcc
}
\description{
\code{listVecOccPointVersions} lists available versions of all the feature datasets in the Vector Occurrence workspace 
from the Web Feature Services provided by the Malaria Atlas Project.
}
\examples{
\dontrun{
vecOccDatasets <- listVecOccPointVersions()
}
}
