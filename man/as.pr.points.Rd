% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getPR.R
\name{as.pr.points}
\alias{as.pr.points}
\title{Convert data.frames to pr.points objects.}
\usage{
as.pr.points(x)
}
\arguments{
\item{x}{A data.frame}
}
\description{
Will create empty columns for any missing columns expected in a pr.points data.frame.
This function is particularly useful for use with packages like dplyr that strip
objects of their classes.
}
\examples{
#Download PfPR data for Nigeria and Cameroon and map the locations of these points using autoplot
\dontrun{
library(dplyr)
NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")

# Filter the data frame then readd pr.points class so that autoplot can be used.
NGA_CMR_PR \%>\%
  filter(year_start > 2010) \%>\%
  as.pr.points \%>\%
  autoplot

}
}
