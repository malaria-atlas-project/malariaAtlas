context('Test Raster autoplotting is working.')

# add more types of rasters to plot


test_that('Plotting works for 4 years of the same raster', {
  #time varying range
  skip_on_cran()
    
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  MDG_PfPR2_10_range <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2012:2015)
    
  p <- autoplot_MAPraster(MDG_PfPR2_10_range, printed = FALSE) # this works
  pp <- autoplot(MDG_PfPR2_10_range, printed = FALSE) # This goes funky. Need invisible()
  expect_true(inherits(MDG_PfPR2_10_range, 'SpatRasterCollection'))
  expect_true(inherits(p, "list"))
  expect_true(inherits(pp, "list"))
  expect_true(all(sapply(p, inherits, "gg")))
  expect_true(all(sapply(pp, inherits, "gg")))
  expect_true(length(p) == 4)
  expect_true(length(pp) == 4)
})


test_that('Printing plot works', {
  skip_on_cran()
  
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  MDG_PfPR2_10_range <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2012:2015)
    
  pp <- autoplot(MDG_PfPR2_10_range, printed = TRUE) # This goes funky. Need invisible()
  expect_true(inherits(MDG_PfPR2_10_range, 'SpatRasterCollection'))
  expect_true(inherits(pp, "list"))
  expect_true(all(sapply(pp, inherits, "gg")))
  expect_true(length(pp) == 4)
})

test_that('Single masked plot works', {
  skip_on_cran()
  
  VEN_shp <- getShp(ISO = "VEN", admin_level = "admin0")
  VEN_PfPR2_10_2022 <- getRaster(dataset_id = "Malaria__202406_Global_Pf_Parasite_Rate", shp = VEN_shp, year = 2022)
  
  pp <- autoplot(VEN_PfPR2_10_2022)
  
  expect_true(terra::nlyr(VEN_PfPR2_10_2022) == 2)
  expect_true(inherits(pp, "list"))
  expect_true(inherits(VEN_PfPR2_10_2022, 'SpatRaster'))
  expect_true(length(pp) == 1)
  
  # Contains mask, so 2 rasters plotted
  layer_geoms <- sapply(pp[[1]]$layers, function(x) class(x$geom)[1])
  expect_true(sum(grepl("GeomRaster", layer_geoms)) == 2)
})

test_that('Plots with mask, where all pixels are NaN works', {
  skip_on_cran()
  
  PAK_shp <- getShp(ISO = "PAK", admin_level = "admin0")
  PAK_PfPR2_10 <- getRaster(dataset_id = "Malaria__202406_Global_Pf_Parasite_Rate", shp = PAK_shp, year = 2022)
  pp <- autoplot(PAK_PfPR2_10)
  
  expect_true(terra::nlyr(PAK_PfPR2_10) == 2)
  expect_true(inherits(pp, "list"))
  expect_true(inherits(PAK_PfPR2_10, 'SpatRaster'))
  expect_true(length(pp) == 1)
  
  # doesn't plot mask layer so just single raster layer is plotted
  layer_geoms <- sapply(pp[[1]]$layers, function(x) class(x$geom)[1])
  expect_true(sum(grepl("GeomRaster", layer_geoms)) == 1)
})

test_that('Multiple plots with mask works', {
  skip_on_cran()
  
  VEN_shp <- getShp(ISO = "VEN", admin_level = "admin0")
  VEN_PfPR2_10 <- getRaster(dataset_id = "Malaria__202406_Global_Pf_Parasite_Rate", shp = VEN_shp, year = 2020:2022)
  pp <- autoplot(VEN_PfPR2_10)
  
  expect_true(all(terra::nlyr(VEN_PfPR2_10) == c(2,2,2)))
  expect_true(inherits(VEN_PfPR2_10, 'SpatRasterCollection'))
  expect_true(inherits(pp, "list"))
  expect_true(length(pp) == 3)
  
  # Contains mask, so 2 rasters plotted
  layer_geoms <- sapply(pp[[1]]$layers, function(x) class(x$geom)[1])
  expect_true(sum(grepl("GeomRaster", layer_geoms)) == 2)
})