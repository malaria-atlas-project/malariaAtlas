# malariaAtlas 1.2.0

*   Removed `rgdal`, `sp`, `raster` packages dependencies and added `terra`, `sf`, `tidyterra`, `lifecycle`

*   As a result `getShp` will now return `sf` objects

*   Similarly, `getRaster` returns `SpatRaster` or `SpatRasterCollection`

*   Some functions have been deprecated. They will still run in this version, with a warning. Please remove them from your code, they will be completely removed in the future.
    *   Deprecated `as.MAPraster`, `as.MAPshp`. They are no longer required for working with `autoplot`
    *   Deprecated `autoplot_MAPraster`. Use `autoplot` directly with the result of `getRaster`
