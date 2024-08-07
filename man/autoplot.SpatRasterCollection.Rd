% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/autoplot.SpatRasterCollection.R
\name{autoplot.SpatRasterCollection}
\alias{autoplot.SpatRasterCollection}
\title{Quickly visualise Rasters downloaded from MAP}
\usage{
\method{autoplot}{SpatRasterCollection}(
  object,
  ...,
  shp_df = NULL,
  legend_title = "",
  plot_titles = TRUE,
  fill_scale_transform = "identity",
  fill_colour_palette = "RdYlBu",
  printed = TRUE
)
}
\arguments{
\item{object}{SpatRasterCollection object to be visualised.}

\item{...}{Other arguments passed to specific methods}

\item{shp_df}{Shapefile(s) (data.frame) to plot with downloaded raster.}

\item{legend_title}{String used as title for all colour scale legends.}

\item{plot_titles}{Plot name of raster object as header for each individual raster plot?}

\item{fill_scale_transform}{String givning a transformation for the fill aesthetic.
See the trans argument in \code{\link[ggplot2]{continuous_scale}} for possible values.}

\item{fill_colour_palette}{String referring to a colorbrewer palette to be used for raster colour scale.}

\item{printed}{Logical vector indicating whether to print maps of supplied rasters.}
}
\value{
\code{autoplot.SpatRasterCollection} returns a list of plots (gg objects) for each
  supplied raster.

gg object
}
\description{
\code{autoplot.SpatRasterCollection} creates a map of all rasters in a autoplot.SpatRasterCollection object and
  displays these in a grid.
}
