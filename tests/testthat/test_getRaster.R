context('Test all raster combinations.')

test_that('All combinations of spatially aligned requests work', {
  
  skip_on_cran()
  # Static
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")

  skip_on_cran()
  # Time varying single
  MDG_PfPR2_10 <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2015)
  expect_true(inherits(MDG_PfPR2_10, 'RasterLayer'))

  #time varying range
  MDG_PfPR2_10_range <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2012:2015)
  expect_true(inherits(MDG_PfPR2_10_range, 'RasterBrick'))

  # Time varying default
  MDG_PfPR2_10_def <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = NA)
  expect_true(inherits(MDG_PfPR2_10_range, 'RasterBrick'))


  # two time varying single
  MDG_tvs_tvs <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence'), shp = MDG_shp, year = list(2012, 2010))
  expect_true(inherits(MDG_tvs_tvs, 'RasterBrick'))


  # time varying range plus time varying single
  MDG_tvr_tvs <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence'), shp = MDG_shp, year = list(2009:2012, 2010))
  expect_true(inherits(MDG_tvr_tvs, 'RasterBrick'))


  # two time varying range
  MDG_tvr_tvr <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence'), shp = MDG_shp, year = list(2009:2012, 2005:2007))
  expect_true(inherits(MDG_tvr_tvr, 'RasterBrick'))


  # two static
  MDG_stat_stat <- getRaster(surface = c("Artemisinin-based combination therapy (ACT) coverage", 'G6PD Deficiency Allele Frequency'), 
                             shp = MDG_shp, year = c(NA, NA))
  expect_true(inherits(MDG_stat_stat, 'RasterBrick'))

 # one time varying single plus one static
  MDG_tvs_stat <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'G6PD Deficiency Allele Frequency'), shp = MDG_shp, year = c(2012, NA))
  expect_true(inherits(MDG_tvs_stat, 'RasterBrick'))

# time varying range plus static
  MDG_tvr_tvs <- getRaster(
    surface = c("Plasmodium falciparum PR2-10", 'Artemisinin-based combination therapy (ACT) coverage'), 
    shp = MDG_shp, year = list(2009:2012, NA))
  expect_true(inherits(MDG_tvr_tvs, 'RasterBrick'))

# two time varying range plus static.
  MDG_tvr_tvr_s <- getRaster(
    surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence', 'Artemisinin-based combination therapy (ACT) coverage'), 
    shp = MDG_shp, 
    year = list(2009:2012, 2005:2007, NA)
    )
  expect_true(inherits(MDG_tvr_tvr_s, 'RasterBrick'))
  # p <- autoplot_MAPraster(MDG_tvr_tvr_s)
  
  
  # Different resolutions 
  MDG_res <- getRaster(
    surface = c("Plasmodium falciparum PR2-10", 
                'A global map of travel time to cities to assess inequalities in accessibility in 2015'), 
    shp = MDG_shp, 
    year = list(2009, NA)
  )
  
  
  expect_true(inherits(MDG_res, 'list'))
  expect_true(!all(raster::res(MDG_res[[1]]) == raster::res(MDG_res[[2]])) )
  # p <- autoplot_MAPraster(MDG_tvr_tvr_s)
  
})


test_that('arg length mismatched work', {
  skip_on_cran()
  
  expect_error(
    MDG_rasters <- getRaster(surface = c("Plasmodium falciparum PR2-10",
                                         'Plasmodium falciparum Incidence',
                                         'Plasmodium falciparum Support'),
                             year = list(2009:2011)),
      regexp = 'downloading multiple different surfaces')
               
})


test_that('Wrong name errors correctly', {
  skip_on_cran()
  expect_error(
    MDG_rasters <- getRaster(surface = "Plasmodium falciparum PR2",
                             year = NA),
    regexp = 'following surfaces have been incorrectly specified')
  
})



test_that('Wrong year errors correctly', {
  skip_on_cran()
  
  expect_error(
    MDG_rasters <- getRaster(surface = "Plasmodium falciparum PR2-10",
                             year = 1902),
    regexp = 'not available for all requested years')
  
})


test_that('Mosquito layers work correctly', {
  skip_on_cran()
  
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  MDG_anoph1 <- getRaster(surface = "Anopheles arabiensis Patton, 1905", shp = MDG_shp, vector_year = 2010)
  MDG_anoph2 <- getRaster(surface = "Anopheles arabiensis Patton, 1905", shp = MDG_shp, vector_year = 2017)
  
  expect_true(raster::getValues(MDG_anoph1)[845] != raster::getValues(MDG_anoph2)[845])
})




