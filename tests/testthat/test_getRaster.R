context('Test all raster combinations.')

test_that('All combinations of spatially aligned requests work', {
  # Static
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  skip_on_cran()
  # Time varying single
  MDG_PfPR2_10 <- getRaster(surface = "PfPR2-10", shp = MDG_shp, year = 2015)
  expect_true(inherits(MDG_PfPR2_10, 'RasterLayer'))

  #time varying range
  MDG_PfPR2_10_range <- getRaster(surface = "PfPR2-10", shp = MDG_shp, year = 2012:2015)
  expect_true(inherits(MDG_PfPR2_10_range, 'RasterBrick'))

  # Time varying default
  MDG_PfPR2_10_def <- getRaster(surface = "PfPR2-10", shp = MDG_shp, year = NA)
  expect_true(inherits(MDG_PfPR2_10_range, 'RasterBrick'))


  # two time varying single
  MDG_tvs_tvs <- getRaster(surface = c("PfPR2-10", 'Pf Incidence'), shp = MDG_shp, year = list(2012, 2010))
  expect_true(inherits(MDG_tvs_tvs, 'RasterBrick'))


  # time varying range plus time varying single
  MDG_tvr_tvs <- getRaster(surface = c("PfPR2-10", 'Pf Incidence'), shp = MDG_shp, year = list(2009:2012, 2010))
  expect_true(inherits(MDG_tvr_tvs, 'RasterBrick'))


  # two time varying range
  MDG_tvr_tvr <- getRaster(surface = c("PfPR2-10", 'Pf Incidence'), shp = MDG_shp, year = list(2009:2012, 2005:2007))
  expect_true(inherits(MDG_tvr_tvr, 'RasterBrick'))


  # two static
  MDG_stat_stat <- getRaster(surface = c("ACTs", 'G6PD Deficiency'), shp = MDG_shp, year = c(NA, NA))
  expect_true(inherits(MDG_stat_stat, 'RasterBrick'))

 # one time varying single plus one static
  MDG_tvs_stat <- getRaster(surface = c("PfPR2-10", 'G6PD Deficiency'), shp = MDG_shp, year = c(2012, NA))
  expect_true(inherits(MDG_tvs_stat, 'RasterBrick'))

# time varying range plus static
  MDG_tvr_tvs <- getRaster(surface = c("PfPR2-10", 'ACTs'), shp = MDG_shp, year = list(2009:2012, NA))
  expect_true(inherits(MDG_tvr_tvs, 'RasterBrick'))

# two time varying range plus static.
  MDG_tvr_tvr_s <- getRaster(surface = c("PfPR2-10", 'Pf Incidence', 'ACTs'), shp = MDG_shp, year = list(2009:2012, 2005:2007, NA))
  expect_true(inherits(MDG_tvr_tvr_s, 'RasterBrick'))
  # p <- autoplot_MAPraster(MDG_tvr_tvr_s)
})
