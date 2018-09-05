context('Test Raster autoplotting is working.')

# add more types of rasters to plot


test_that('Plotting works for 4 years of the same raster', {
  #time varying range
  skip_on_cran()
    
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  MDG_PfPR2_10_range <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2012:2015)
    
  p <- autoplot_MAPraster(MDG_PfPR2_10_range, printed = FALSE) # this works
  pp <- autoplot(as.MAPraster(MDG_PfPR2_10_range), printed = FALSE) # This goes funky. Need invisible()
  expect_true(inherits(MDG_PfPR2_10_range, 'RasterBrick'))
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
    
  p <- autoplot_MAPraster(MDG_PfPR2_10_range, printed = TRUE) # this works
  pp <- autoplot(as.MAPraster(MDG_PfPR2_10_range), printed = TRUE) # This goes funky. Need invisible()
  expect_true(inherits(MDG_PfPR2_10_range, 'RasterBrick'))
  expect_true(inherits(p, "list"))
  expect_true(inherits(pp, "list"))
  expect_true(all(sapply(p, inherits, "gg")))
  expect_true(all(sapply(pp, inherits, "gg")))
  expect_true(length(p) == 4)
  expect_true(length(pp) == 4)

})
