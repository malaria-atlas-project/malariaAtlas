---
output: 
  md_document:
    preserve_yaml: false
---

[![Build Status](https://travis-ci.org/malaria-atlas-project/malariaAtlas.svg)](https://travis-ci.org/malaria-atlas-project/malariaAtlas) [![codecov.io](https://codecov.io/gh/malaria-atlas-project/malariaAtlas/coverage.svg?branch=master)](https://codecov.io/gh/malaria-atlas-project/malariaAtlas?branch=master)



# malariaAtlas

### An R interface to open-access malaria data, hosted by the Malaria Atlas Project.

*The gitlab version of the malariaAtlas package has some additional bugfixes over the stable CRAN package. If you have any issues, try installing the latest github version. See below for instructions.*

# Overview

This package allows you to download parasite rate data (*Plasmodium falciparum* and *P. vivax*), survey occurrence data of the 41 dominant malaria vector species, and modelled raster outputs from the [Malaria Atlas Project](https://malariaatlas.org/).

More details and example analyses can be found in the [published paper)[(<https://malariajournal.biomedcentral.com/articles/10.1186/s12936-018-2500-5>).

## Available Data:

The data can be explored at <https://data.malariaatlas.org/maps>.

### List Versions Functions

The list version functions are used to list the available versions of different datasets, and all return a data.frame with a single column for version. These versions can be passed to functions such as `listShp`, `listSpecies`, `listPRPointCountries`, `listVecOccPointCountries`, `getPR`, `getVecOcc` and `getShp`.

Use:

-   `listPRPointVerions()` to see the available versions for PR point data, which can then be used in `listPRPointCountries` and `getPR`.

-   `listVecOccPointVersions()` to see the available versions for vector occurrence data, which can then be used in `listSpecies`, `listVecOccPointCountries` and `getVecOcc`.

-   `listShpVersions()` to see the available versions for admin unit shape data, which can then be used in `listShp` and `getShp`.


```r
listPRPointVersions()
```


```r
listVecOccPointVersions()
```


```r
listShpVersions()
```

### List Countries and Species Functions

To list the countries where there is available data for PR points or vector occurrence points, use:

-   `listPRPointCountries()` for PR points
-   `listVecOccPointCountries()` for vector occurrence points

To list the species available for vector point data use `listSpecies()`

All three of these functions can optionally take a version parameter (which can be found with the list versions functions). If you choose not to provide a version, the most recent version of the relevant dataset will be selected by default.


```r
listPRPointCountries(version = "202206")
```


```r
listVecOccPointCountries(version = "201201")
```


```r
listSpecies(version = "201201")
```

### List Administrative Units

To list administrative units for which shapefiles are stored on the MAP geoserver, use `listShp()`. Similar to the list countries and species functions, this function can optionally take a version.


```r
listShp(version = "202206")
```

### List Raster Function

`listRaster()` gets minimal information on all available rasters. It returns a data.frame with several columns for each raster such as dataset_id, title, abstract, min_raster_year and max_raster_year. The dataset_id can then be used in `getRaster` and `extractRaster`.


```r
listRaster()
```

### Is Available Functions

`isAvailable_pr` confirms whether or not PR survey point data is available to download for a specified country, ISO3 code or continent.

Check whether PR data is available for Madagascar:


```r
isAvailable_pr(country = "Madagascar")
```

Check whether PR data is available for the United States of America by ISO code:


```r
isAvailable_pr(ISO = "USA")
```

Check whether PR data is available for Asia:


```r
isAvailable_pr(continent = "Asia")
```

`isAvailable_vec` confirms whether or not vector survey point data is available to download for a specified country, ISO3 code or continent.

Check whether vector data is available for Myanmar:


```r
isAvailable_vec(country = "Myanmar")
```

Check whether vector data is available for multiple countries:


```r
isAvailable_vec(country = c("Nigeria", "Ethiopia"))
```

You can also pass these functions a dataset version. If you don't they will default to using the most recent version.


```r
isAvailable_pr(country = "Madagascar", version = "202206")
```

## Downloading & Visualising Data:

### get\* functions & autoplot methods

### Parasite Rate Survey Points

`getPR()` downloads all publicly available PR data points for a specified location (country, ISO, continent or extent) and plasmodium species (Pf, Pv or BOTH) and returns this as a dataframe with the following format:


```r
MDG_pr_data <- getPR(country = "Madagascar", species = "both")
```


```
## Rows: 395
## Columns: 29
## $ dhs_id                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ site_id                   <int> 8689, 6221, 18093, 6021, 15070, 15795, 7374, 13099, 9849, 11961, 21475, 11572, 15943, 7930, 13748, 16323, 19003, 10839, 2790, 15260…
## $ site_name                 <chr> "Vodivohitra", "Andranomasina", "Ankazobe", "Andasibe", "Ambohimarina", "Antohobe", "Ambohimazava", "Ankeribe", "Alatsinainy", "Sah…
## $ latitude                  <dbl> -16.21700, -18.71700, -18.31600, -19.83400, -18.73400, -19.76990, -25.03230, -18.70100, -18.71920, -19.36667, -19.58300, -17.59400,…
## $ longitude                 <dbl> 49.68300, 47.46600, 47.11800, 47.85000, 47.25200, 46.68700, 46.99600, 47.16600, 47.49050, 48.16667, 47.46600, 46.92600, 46.91600, 4…
## $ rural_urban               <chr> "RURAL", "UNKNOWN", "RURAL", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "RURAL", "UNKN…
## $ country                   <chr> "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Mada…
## $ country_id                <chr> "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG"…
## $ continent_id              <chr> "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "…
## $ month_start               <int> 11, 1, 11, 3, 1, 7, 4, 1, 1, 2, 7, 11, 4, 7, 11, 4, 9, 7, 7, 3, 7, 7, 7, 11, 3, 4, 6, 3, 11, 11, 7, 7, 7, 7, 4, 11, 11, 11, 1, 11, …
## $ year_start                <int> 1989, 1987, 1989, 1987, 1987, 1995, 1986, 1987, 1987, 2003, 1995, 1989, 1986, 1995, 1997, 1986, 1991, 1995, 1995, 2005, 1994, 1987,…
## $ month_end                 <int> 11, 1, 12, 3, 1, 8, 6, 1, 1, 2, 8, 12, 4, 8, 11, 6, 9, 8, 8, 6, 7, 7, 7, 12, 3, 6, 6, 6, 11, 11, 7, 8, 8, 8, 4, 11, 11, 11, 1, 11, …
## $ year_end                  <int> 1989, 1987, 1989, 1987, 1987, 1995, 1986, 1987, 1987, 2003, 1995, 1989, 1986, 1995, 1997, 1986, 1991, 1995, 1995, 2005, 1994, 1987,…
## $ lower_age                 <dbl> 5, 0, 5, 0, 0, 2, 7, 0, 0, 0, 2, 5, 6, 2, 2, 7, 0, 2, 2, 0, 2, 0, 0, 5, 0, 7, 0, 0, 6, 5, 0, 2, 2, 2, 13, 2, 2, 6, 0, 2, 2, 0, 2, 0…
## $ upper_age                 <int> 15, 99, 15, 99, 99, 9, 22, 99, 99, 99, 9, 15, 12, 9, 9, 22, 99, 9, 9, 5, 9, 99, 99, 15, 99, 22, 99, 5, 12, 15, 99, 9, 9, 9, 56, 9, …
## $ examined                  <int> 165, 50, 258, 246, 50, 50, 119, 50, 50, 210, 50, 340, 20, 50, 61, 156, 104, 50, 50, 147, 147, 944, 541, 92, 115, 67, 123, 60, 202, …
## $ positive                  <dbl> 144.0, 7.5, 139.0, 126.0, 2.5, 6.0, 37.0, 13.5, 4.5, 34.0, 11.5, 255.0, 8.0, 7.0, 3.0, 97.0, 24.0, 33.0, 0.0, 70.0, 72.0, 137.0, 23…
## $ pr                        <dbl> 0.87272727, 0.15000000, 0.53875969, 0.51219512, 0.05000000, 0.12000000, 0.31092437, 0.27000000, 0.09000000, 0.16190476, 0.23000000,…
## $ species                   <chr> "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falcipar…
## $ method                    <chr> "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Micr…
## $ rdt_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ pcr_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ malaria_metrics_available <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ location_available        <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ permissions_info          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation1                 <chr> "Lepers, J.P. (1989). <i>Rapport sur la situation du paludisme dans la région de Mananara Nord.</i> . Antananarivo. Institut Pasteu…
## $ citation2                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation3                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ geometry                  <POINT [°]> POINT (49.683 -16.217), POINT (47.466 -18.717), POINT (47.118 -18.316), POINT (47.85 -19.834), POINT (47.252 -18.734), POINT …
```


```r
Africa_pvpr_data <- getPR(continent = "Africa", species = "Pv")
```


```
## Rows: 2,696
## Columns: 29
## $ dhs_id                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ site_id                   <int> 3638, 6694, 14021, 8017, 12873, 12260, 21446, 16833, 8689, 3434, 2160, 6533, 6706, 13981, 3196, 10603, 4150, 5506, 8910, 10349, 136…
## $ site_name                 <chr> "Basare Section Kpandai", "Dole School", "Port Sudan (Eastern Sector)", "Gongoma School", "Buriya School", "Chobo 3", "Mekele, Quih…
## $ latitude                  <dbl> 8.47000, 5.90141, 19.61600, 6.31747, 7.56736, 7.89960, 13.47600, 9.40630, -16.21700, -16.46200, 12.60700, 4.71923, 7.91830, 1.85100…
## $ longitude                 <dbl> -0.01000, 38.94115, 37.23200, 39.83618, 40.75210, 34.45080, 39.50200, -0.99000, 49.68300, 26.57510, 37.46100, 38.76500, 34.44430, 4…
## $ rural_urban               <chr> "RURAL", "UNKNOWN", "URBAN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "RURAL", "RURAL", "UNKNOWN", "URBAN", "UNKNOWN", "UNKNOWN"…
## $ country                   <chr> "Ghana", "Ethiopia", "Sudan", "Ethiopia", "Ethiopia", "Ethiopia", "Ethiopia", "Ghana", "Madagascar", "Zambia", "Ethiopia", "Ethiopi…
## $ country_id                <chr> "GHA", "ETH", "SDN", "ETH", "ETH", "ETH", "ETH", "GHA", "MDG", "ZMB", "ETH", "ETH", "ETH", "SOM", "MAR", "SDN", "ETH", "ETH", "CPV"…
## $ continent_id              <chr> "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "…
## $ month_start               <int> 3, 6, 11, 6, 6, 9, 9, 2, 11, 5, 11, 6, 9, 9, 1, 11, 6, 10, 12, 9, 6, 10, 10, 11, 6, 6, 2, 4, 1, 3, 10, 11, 5, 6, 3, 7, 9, 3, 6, 9, …
## $ year_start                <int> 2002, 2009, 1996, 2009, 2009, 1989, 1993, 2002, 1989, 2008, 2004, 2009, 1989, 1985, 2002, 1999, 2009, 1990, 2003, 1989, 2009, 1990,…
## $ month_end                 <int> 3, 6, 11, 6, 6, 10, 12, 2, 11, 5, 12, 6, 10, 9, 1, 11, 6, 11, 12, 10, 6, 11, 11, 12, 6, 6, 2, 4, 1, 3, 11, 11, 5, 6, 3, 8, 1, 3, 6,…
## $ year_end                  <int> 2002, 2009, 1996, 2009, 2009, 1989, 1993, 2002, 1989, 2008, 2004, 2009, 1989, 1985, 2002, 1999, 2009, 1990, 2003, 1989, 2009, 1990,…
## $ lower_age                 <dbl> 0.5, 4.0, 0.0, 4.0, 4.0, 0.0, 0.5, 0.5, 5.0, 0.3, 0.0, 4.0, 0.0, 1.0, 0.0, 0.4, 4.0, 0.0, 2.0, 0.0, 4.0, 0.0, 0.0, 5.0, 4.0, 4.0, 0…
## $ upper_age                 <int> 9, 15, 99, 15, 15, 99, 5, 9, 15, 94, 99, 15, 99, 9, 99, 60, 15, 99, 49, 99, 15, 99, 99, 15, 15, 15, 9, 98, 9, 9, 99, 19, 72, 99, 9,…
## $ examined                  <int> 70, 110, 104, 108, 63, 108, 2080, 69, 165, 48, 103, 56, 260, 70, 664, 90, 109, 92, 22, 138, 107, 100, 50, 258, 110, 64, 71, 78, 81,…
## $ positive                  <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 5.00, 0.00, 0.00, 10.00, 0.00, 1.00, 0.00, 4.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.00, 1.00, 0.00…
## $ pr                        <dbl> 0.000000000, 0.000000000, 0.000000000, 0.000000000, 0.000000000, 0.046296296, 0.000000000, 0.000000000, 0.060606061, 0.000000000, 0…
## $ species                   <chr> "P. vivax", "P. vivax", "P. vivax", "P. vivax", "P. vivax", "P. vivax", "P. vivax", "P. vivax", "P. vivax", "P. vivax", "P. vivax",…
## $ method                    <chr> "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Micr…
## $ rdt_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ pcr_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ malaria_metrics_available <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ location_available        <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ permissions_info          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation1                 <chr> "Ehrhardt, S., Burchard, G.D., Mantel, C., Cramer, J.P., Kaiser, S., Kubo, M., Otchwemah, R.N., Bienzle, U. and Mockenhaupt, F.P. (…
## $ citation2                 <chr> NA, NA, "Le Sueur, D., Binka, F., Lengeler, C., De Savigny, D., Snow, B., Teuscher, T. and Toure, Y. (1997).  <b>An atlas of malari…
## $ citation3                 <chr> NA, NA, "Le Sueur, D., Binka, F., Lengeler, C., De Savigny, D., Snow, B., Teuscher, T. and Toure, Y. (1997).  <b>An atlas of malari…
## $ geometry                  <POINT [°]> POINT (-0.01 8.47), POINT (38.9412 5.9014), POINT (37.232 19.616), POINT (39.8362 6.3175), POINT (40.7521 7.5674), POINT (34.…
```


```r
Extent_pfpr_data <- getPR(extent = rbind(c(-2.460181, 13.581921), c(-3.867188, 34.277344)), species = "Pf")
```


```
## Rows: 2,174
## Columns: 29
## $ dhs_id                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ site_id                   <int> 2247, 3638, 13900, 16864, 16833, 16907, 13201, 13431, 13924, 13197, 13124, 13101, 13122, 13193, 13895, 13096, 21565, 9668, 15368, 1…
## $ site_name                 <chr> "Kuiti", "Basare Section Kpandai", "Akarana", "GS Kuke Mbomo", "Nyankpala", "Kumasi (Bantama)", "Limbe", "Prampram", "Igbanda", "Ny…
## $ latitude                  <dbl> 12.44770, 8.47000, 15.93300, 4.45490, 9.40630, 6.70000, 4.01500, 5.70400, 7.29000, 2.81000, 12.31300, 12.18330, 12.57000, 2.66400, …
## $ longitude                 <dbl> -1.30920, -0.01000, 5.56800, 9.24630, -0.99000, -1.63400, 9.19300, 0.10100, 3.82000, 10.11800, -1.14300, -1.38330, -1.34000, 12.668…
## $ rural_urban               <chr> "RURAL", "RURAL", "RURAL", "UNKNOWN", "RURAL", "URBAN", "URBAN", "RURAL", "RURAL", "RURAL", "RURAL", "RURAL", "RURAL", "URBAN", "RU…
## $ country                   <chr> "Burkina Faso", "Ghana", "Niger", "Cameroon", "Ghana", "Ghana", "Cameroon", "Ghana", "Nigeria", "Cameroon", "Burkina Faso", "Burkin…
## $ country_id                <chr> "BFA", "GHA", "NER", "CMR", "GHA", "GHA", "CMR", "GHA", "NGA", "CMR", "BFA", "BFA", "BFA", "CMR", "NER", "BEN", "CMR", "NGA", "CMR"…
## $ continent_id              <chr> "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "…
## $ month_start               <int> 6, 3, 9, 10, 2, 10, 8, 7, 6, 3, 10, 7, 11, 3, 9, 7, 10, 7, 10, 9, 10, 3, 8, 2, 10, 2, 6, 11, 5, 1, 3, 5, 10, 4, 2, 3, 5, 10, 2, 8, …
## $ year_start                <int> 1985, 2002, 1992, 1998, 2002, 2002, 2001, 1993, 2004, 1989, 2002, 1987, 1992, 1988, 1992, 1987, 1998, 2005, 1998, 2003, 2002, 1986,…
## $ month_end                 <int> 6, 3, 9, 1, 2, 2, 8, 7, 6, 3, 11, 7, 11, 3, 9, 7, 1, 12, 1, 12, 1, 4, 9, 2, 2, 2, 6, 11, 5, 1, 3, 5, 1, 5, 2, 3, 6, 10, 2, 9, 5, 4,…
## $ year_end                  <int> 1985, 2002, 1992, 1999, 2002, 2003, 2001, 1993, 2004, 1989, 2002, 1987, 1992, 1988, 1992, 1987, 1999, 2005, 1999, 2003, 2003, 1986,…
## $ lower_age                 <dbl> 0.5, 0.5, 0.0, 5.0, 0.5, 0.5, 0.0, 6.0, 0.0, 4.0, 0.0, 1.0, 2.0, 0.0, 0.0, 1.0, 5.0, 4.0, 5.0, 2.0, 0.0, 0.0, 5.0, 4.0, 0.5, 0.5, 0…
## $ upper_age                 <int> 9, 9, 9, 16, 9, 5, 99, 15, 8, 13, 9, 5, 8, 15, 9, 12, 16, 15, 16, 9, 4, 10, 70, 13, 5, 9, 65, 10, 9, 9, 9, 13, 16, 4, 14, 9, 5, 99,…
## $ examined                  <int> 143, 70, 62, 30, 69, 189, 208, 354, 412, 284, 58, 119, 210, 310, 91, 770, 50, 216, 28, 102, 219, 47, 100, 94, 145, 71, 885, 208, 34…
## $ positive                  <dbl> 59.00, 39.00, 41.00, 17.00, 34.00, 8.00, 47.00, 115.00, 340.00, 219.00, 51.00, 77.00, 191.00, 169.00, 59.00, 155.00, 22.00, 65.00, …
## $ pr                        <dbl> 0.41258741, 0.55714286, 0.66129032, 0.56666667, 0.49275362, 0.04232804, 0.22596154, 0.32485876, 0.82524272, 0.77112676, 0.87931034,…
## $ species                   <chr> "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falcipar…
## $ method                    <chr> "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Micr…
## $ rdt_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ pcr_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ malaria_metrics_available <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ location_available        <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ permissions_info          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation1                 <chr> "Esposito, F., Lombardi, S., Modiano, D., Zavala, F., Reeme, J., Lamizana, L., Coluzzi, M. and Nussenzweig, R.S. (1988).  <b>Preval…
## $ citation2                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation3                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ geometry                  <POINT [°]> POINT (-1.3092 12.4477), POINT (-0.01 8.47), POINT (5.568 15.933), POINT (9.2463 4.4549), POINT (-0.99 9.4063), POINT (-1.634…
```

You can also pass this function a dataset version. If you don't it will default to using the most recent version.


```r
MDG_pr_data_202206 <- getPR(country = "Madagascar", species = "both", version = "202206")
```

`autoplot.pr.points` configures autoplot method to enable quick mapping of the locations of downloaded PR points.


```r
autoplot(MDG_pr_data)
```

![plot of chunk unnamed-chunk-23](man/figures/unnamed-chunk-23-1.png)

A version without facetting is also available.


```r
autoplot(MDG_pr_data,
         facet = FALSE)
```

![plot of chunk unnamed-chunk-24](man/figures/unnamed-chunk-24-1.png)

### Vector Survey Points

`getVecOcc()` downloads all publicly available Vector survey points for a specified location (country, ISO, continent or extent) and species (options for which can be found with `listSpecies`) and returns this as a dataframe with the following format:


```r
MMR_vec_data <- getVecOcc(country = "Myanmar")
```

```
## Warning: The `sourcedata` argument of `isAvailable_vec()` is deprecated as of malariaAtlas 1.5.0.
## ℹ The argument 'sourcedata' has been deprecated. It will be removed in the next version. It has no meaning.
## ℹ The deprecated feature was likely used in the malariaAtlas package.
##   Please report the issue at <https://github.com/malaria-atlas-project/malariaAtlas/issues>.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.
```


```
## Rows: 2,866
## Columns: 25
## $ id             <int> 1945, 1946, 1951, 1952, 790, 781, 772, 791, 773, 783, 774, 776, 777, 792, 778, 779, 780, 1953, 784, 785, 786, 788, 789, 793, 795, 796, 797, 79…
## $ site_id        <int> 30243, 30243, 30243, 30243, 1000000072, 1000000071, 1000000071, 1000000072, 1000000071, 1000000071, 1000000071, 1000000071, 1000000071, 100000…
## $ latitude       <dbl> 16.2570, 16.2570, 16.2570, 16.2570, 17.3500, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800, 17.3800, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800…
## $ longitude      <dbl> 97.7250, 97.7250, 97.7250, 97.7250, 96.0410, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370, 96.0370, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370…
## $ country        <chr> "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar",…
## $ country_id     <chr> "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "M…
## $ continent_id   <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia"…
## $ month_start    <int> 2, 3, 8, 9, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, …
## $ year_start     <int> 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998…
## $ month_end      <int> 2, 3, 8, 9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, …
## $ year_end       <int> 1998, 1998, 1998, 1998, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 1998, 2000, 2000, 2000, 2000, 2000, 2000…
## $ anopheline_id  <int> 17, 17, 17, 17, 50, 49, 17, 51, 11, 4, 15, 1, 35, 30, 50, 51, 30, 17, 17, 11, 15, 1, 35, 49, 4, 17, 11, 15, 1, 35, 51, 30, 49, 4, 17, 11, 15, …
## $ species        <chr> "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "A…
## $ species_plain  <chr> "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles stephensi", "Anopheles sinensis", "Anopheles dirus", "A…
## $ id_method1     <chr> "unknown", "unknown", "unknown", "unknown", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", …
## $ id_method2     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ sample_method1 <chr> "man biting", "man biting", "man biting", "man biting", "man biting indoors", "man biting indoors", "man biting indoors", "man biting indoors"…
## $ sample_method2 <chr> "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "man biting outdoors", "man biting out…
## $ sample_method3 <chr> NA, NA, NA, NA, "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net tra…
## $ sample_method4 <chr> NA, NA, NA, NA, "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house…
## $ assi           <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""…
## $ citation       <chr> "Oo, T.T., Storch, V. and Becker, N. (2003).  <b><i>Anopheles</i> <i>dirus</i> and its role in malaria transmission in Myanmar.</b> <i>Journal…
## $ time_start     <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-0…
## $ time_end       <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-0…
## $ geometry       <POINT [°]> POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (96.041 17.35), POINT (96.037 17.38), …
```

You can also pass this function a dataset version. If you don't it will default to using the most recent version.


```r
MMR_vec_data_201201 <- getVecOcc(country = "Myanmar", version = "201201")
```


```
## Rows: 2,866
## Columns: 25
## $ id             <int> 1945, 1946, 1951, 1952, 790, 781, 772, 791, 773, 783, 774, 776, 777, 792, 778, 779, 780, 1953, 784, 785, 786, 788, 789, 793, 795, 796, 797, 79…
## $ site_id        <int> 30243, 30243, 30243, 30243, 1000000072, 1000000071, 1000000071, 1000000072, 1000000071, 1000000071, 1000000071, 1000000071, 1000000071, 100000…
## $ latitude       <dbl> 16.2570, 16.2570, 16.2570, 16.2570, 17.3500, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800, 17.3800, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800…
## $ longitude      <dbl> 97.7250, 97.7250, 97.7250, 97.7250, 96.0410, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370, 96.0370, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370…
## $ country        <chr> "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar",…
## $ country_id     <chr> "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "M…
## $ continent_id   <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia"…
## $ month_start    <int> 2, 3, 8, 9, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, …
## $ year_start     <int> 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998…
## $ month_end      <int> 2, 3, 8, 9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, …
## $ year_end       <int> 1998, 1998, 1998, 1998, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 1998, 2000, 2000, 2000, 2000, 2000, 2000…
## $ anopheline_id  <int> 17, 17, 17, 17, 50, 49, 17, 51, 11, 4, 15, 1, 35, 30, 50, 51, 30, 17, 17, 11, 15, 1, 35, 49, 4, 17, 11, 15, 1, 35, 51, 30, 49, 4, 17, 11, 15, …
## $ species        <chr> "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "A…
## $ species_plain  <chr> "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles stephensi", "Anopheles sinensis", "Anopheles dirus", "A…
## $ id_method1     <chr> "unknown", "unknown", "unknown", "unknown", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", …
## $ id_method2     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ sample_method1 <chr> "man biting", "man biting", "man biting", "man biting", "man biting indoors", "man biting indoors", "man biting indoors", "man biting indoors"…
## $ sample_method2 <chr> "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "man biting outdoors", "man biting out…
## $ sample_method3 <chr> NA, NA, NA, NA, "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net tra…
## $ sample_method4 <chr> NA, NA, NA, NA, "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house…
## $ assi           <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""…
## $ citation       <chr> "Oo, T.T., Storch, V. and Becker, N. (2003).  <b><i>Anopheles</i> <i>dirus</i> and its role in malaria transmission in Myanmar.</b> <i>Journal…
## $ time_start     <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-0…
## $ time_end       <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-0…
## $ geometry       <POINT [°]> POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (96.041 17.35), POINT (96.037 17.38), …
```

`autoplot.vector.points` configures autoplot method to enable quick mapping of the locations of downloaded vector points.


```r
autoplot(MMR_vec_data)
```

![plot of chunk unnamed-chunk-29](man/figures/unnamed-chunk-29-1.png)

N.B. Facet-wrapped option is also available for species stratification.


```r
autoplot(MMR_vec_data,
         facet = TRUE)
```

![plot of chunk unnamed-chunk-30](man/figures/unnamed-chunk-30-1.png)

### Shapefiles

`getShp()` downloads a shapefile for a specified country (or countries) and returns this as a simple feature object.


```r
MDG_shp <- getShp(ISO = "MDG", admin_level = c("admin0", "admin1"))
```


```
## Rows: 23
## Columns: 17
## $ iso           <chr> "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MD…
## $ admn_level    <int> 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
## $ name_0        <chr> "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Ma…
## $ id_0          <int> 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 100…
## $ type_0        <chr> "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", …
## $ name_1        <chr> NA, "Analamanga", "Analanjirofo", "Androy", "Anosy", "Atsimo Andrefana", "Atsimo Atsinanana", "Atsinanana", "Betsiboka", "Boeny", "Bongolava", …
## $ id_1          <int> NA, 10022983, 10022999, 10023001, 10023002, 10023003, 10022990, 10023000, 10022994, 10022995, 10022984, 10022998, 10022989, 10022987, 10022991,…
## $ type_1        <chr> NA, "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region",…
## $ name_2        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ id_2          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ type_2        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ name_3        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ id_3          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ type_3        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ source        <chr> "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016",…
## $ country_level <chr> "MDG_0", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1",…
## $ geometry      <MULTIPOLYGON [°]> MULTIPOLYGON (((44.2278 -25..., MULTIPOLYGON (((46.7425 -17..., MULTIPOLYGON (((49.8084 -17..., MULTIPOLYGON (((45.2509 -23..., MULTIPOLYGON ((…
```

`autoplot.sf` configures autoplot method to enable quick mapping of downloaded shapefiles.


```r
autoplot(MDG_shp)
```

![plot of chunk unnamed-chunk-33](man/figures/unnamed-chunk-33-1.png)

N.B. Facet-wrapped option is also available for species stratification.


```r
autoplot(MDG_shp,
         facet = TRUE,
         map_title = "Example of facetted shapefiles.")
```

![plot of chunk unnamed-chunk-34](man/figures/unnamed-chunk-34-1.png)

### Modelled Rasters

`getRaster()`downloads publicly available MAP rasters for a specific dataset_id & year, clipped to a given bounding box or shapefile


```r
MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
MDG_PfPR2_10 <- getRaster(dataset_id = "Explorer__2020_Global_PfPR", shp = MDG_shp, year = 2013)
```

```
## Warning in library(package, lib.loc = lib.loc, character.only = TRUE, logical.return = TRUE, : there is no package called 'sp'
```

```
## Error in .requirePackage(package): unable to find required package 'sp'
```

`autoplot.SpatRaster` & `autoplot.SpatRasterCollection` configures autoplot method to enable quick mapping of downloaded rasters.


```r
p <- autoplot(MDG_PfPR2_10, shp_df = MDG_shp)
```

```
## Error in .Call(structure(list(name = "CppField__get", address = <pointer: (nil)>, : NULL value passed as symbol address
```

### Combined visualisation

By using the above tools along with ggplot, simple comparison figures can be easily produced.


```r
MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
MDG_PfPR2_10 <- getRaster(dataset_id = "Explorer__2020_Global_PfPR", shp = MDG_shp, year = 2013)
```

```
## Error in .requirePackage(package): unable to find required package 'sp'
```

```r
p <- autoplot(MDG_PfPR2_10, shp_df = MDG_shp, printed = FALSE)
```

```
## Error in .Call(structure(list(name = "CppField__get", address = <pointer: (nil)>, : NULL value passed as symbol address
```

```r
pr <- getPR(country = c("Madagascar"), species = "Pf")
p[[1]] +
geom_point(data = pr[pr$year_start==2013,], aes(longitude, latitude, fill = positive / examined, size = examined), shape = 21)+
scale_size_continuous(name = "Survey Size")+
 scale_fill_distiller(name = "PfPR", palette = "RdYlBu")+
 ggtitle("Raw PfPR Survey points\n + Modelled PfPR 2-10 in Madagascar in 2013")
```

![plot of chunk unnamed-chunk-37](man/figures/unnamed-chunk-37-1.png)

Similarly for vector survey data


```r
MMR_shp <- getShp(ISO = "MMR", admin_level = "admin0")
MMR_An_dirus <- getRaster(dataset_id = "Explorer__2010_Anopheles_dirus_complex", shp = MMR_shp)
```

```
## Error in .requirePackage(package): unable to find required package 'sp'
```

```r
p <- autoplot(MMR_An_dirus, shp_df = MMR_shp, printed = FALSE)
```

```
## Error in autoplot(MMR_An_dirus, shp_df = MMR_shp, printed = FALSE): object 'MMR_An_dirus' not found
```

```r
vec <- getVecOcc(country = c("Myanmar"), species = "Anopheles dirus")
p[[1]] +
geom_point(data = vec, aes(longitude, latitude, colour = species))+
  scale_colour_manual(values = "black", name = "Vector survey locations")+
 scale_fill_distiller(name = "Predicted distribution of An. dirus complex", palette = "PuBuGn", direction = 1)+
 ggtitle("Vector Survey points\n + The predicted distribution of An. dirus complex")
```

![plot of chunk unnamed-chunk-38](man/figures/unnamed-chunk-38-1.png)

## Installation

### Latest stable version from CRAN

Just install using `install.packages("malariaAtlas")` or using the package manager in RStudio.

### Latest version from github

While this version is not as well-tested, it may include additional bugfixes not in the stable CRAN version. Install the `devtools` package and then install using `devtools::install_github('malaria-atlas-project/malariaAtlas')`

## Changes

### 1.2.0

-   Removed `rgdal`, `sp`, `raster` packages dependencies and added `terra`, `sf`, `tidyterra`, `lifecycle`
-   As a result `getShp` will now return `sf` objects
-   Similarly, `getRaster` returns `SpatRaster` or `SpatRasterCollection`
-   Some functions have been deprecated. They will still run in this version, with a warning. Please remove them from your code, they will be completely removed in the future.
    -   Deprecated `as.MAPraster`, `as.MAPshp`. They are no longer required for working with `autoplot`
    -   Deprecated `autoplot_MAPraster`. Use `autoplot` directly with the result of `getRaster`
