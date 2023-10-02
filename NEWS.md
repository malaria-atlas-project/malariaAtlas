# malariaAtlas 1.5.0

* A number of underlying data sources have been updated. All datasets are now versioned, this is reflected in the `get*` functions. We have tried to keep the API changes small so as to minimise breaking your code. 
More specifically:
    * `getPR`, `listPRPointCountries`, and `isAvailable_pr` can now take a `version` parameter. These are listed in `listPRPointVersions`. If no version is passed, the data for the newest version will be returned.
    * `getVecOcc`, `listVecOccPointCountries`, and `isAvailable_Vec`similarly take a `version` parameter. These are listed in `listVecOccPointVersions`. If no version is passed, the data for the newest version will be returned.

* `getRaster` and `extractRaster` now prefer the new `dataset_id` over the deprecated `surface` parameter. `dataset_id` is included in `listRaster`


* Some more functions have been deprecated
    * `listData`, in favour of the more specific `listPRPointCountries`, `listVecOccPointCountries`, `listRaster`, `listShp`
    * `listPoints`, in favour of the more specific `listPRPointCountries` and `listVecOccPointCountries`


# malariaAtlas 1.2.0

*   Removed `rgdal`, `sp`, `raster` packages dependencies and added `terra`, `sf`, `tidyterra`, `lifecycle`

*   As a result `getShp` will now return `sf` objects

*   Similarly, `getRaster` returns `SpatRaster` or `SpatRasterCollection`

*   Some functions have been deprecated. They will still run in this version, with a warning. Please remove them from your code, they will be completely removed in the future.
    *   Deprecated `as.MAPraster`, `as.MAPshp`. They are no longer required for working with `autoplot`
    *   Deprecated `autoplot_MAPraster`. Use `autoplot` directly with the result of `getRaster`
