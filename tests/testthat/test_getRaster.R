context('Test all raster combinations.')

test_that('All combinations of spatially aligned requests work', {
  
  skip_on_cran()
  # Static
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")

  skip_on_cran()
  # Time varying single
  MDG_PfPR2_10 <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2015)
  expect_true(inherits(MDG_PfPR2_10, 'SpatRaster'))

  #time varying range
  MDG_PfPR2_10_range <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = 2012:2015)
  expect_true(inherits(MDG_PfPR2_10_range, 'SpatRaster'))

  # Time varying default
  MDG_PfPR2_10_def <- getRaster(surface = "Plasmodium falciparum PR2-10", shp = MDG_shp, year = NA)
  expect_true(inherits(MDG_PfPR2_10_def, 'SpatRaster'))


  # two time varying single
  MDG_tvs_tvs <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence'), shp = MDG_shp, year = list(2012, 2010))
  expect_true(inherits(MDG_tvs_tvs, 'SpatRaster'))


  # time varying range plus time varying single
  MDG_tvr_tvs <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence'), shp = MDG_shp, year = list(2009:2012, 2010))
  expect_true(inherits(MDG_tvr_tvs, 'SpatRaster'))


  # two time varying range
  MDG_tvr_tvr <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence'), shp = MDG_shp, year = list(2009:2012, 2005:2007))
  expect_true(inherits(MDG_tvr_tvr, 'SpatRaster'))


  # two static
  MDG_stat_stat <- getRaster(surface = c("Artemisinin-based combination therapy (ACT) coverage", 'G6PD Deficiency Allele Frequency'), 
                             shp = MDG_shp, year = c(NA, NA))
  expect_true(inherits(MDG_stat_stat, 'SpatRaster'))

 # one time varying single plus one static
  MDG_tvs_stat <- getRaster(surface = c("Plasmodium falciparum PR2-10", 'G6PD Deficiency Allele Frequency'), shp = MDG_shp, year = c(2012, NA))
  expect_true(inherits(MDG_tvs_stat, 'SpatRaster'))

# time varying range plus static
  MDG_tvr_tvs <- getRaster(
    surface = c("Plasmodium falciparum PR2-10", 'Artemisinin-based combination therapy (ACT) coverage'), 
    shp = MDG_shp, year = list(2009:2012, NA))
  expect_true(inherits(MDG_tvr_tvs, 'SpatRaster'))

# two time varying range plus static.
  MDG_tvr_tvr_s <- getRaster(
    surface = c("Plasmodium falciparum PR2-10", 'Plasmodium falciparum Incidence', 'Artemisinin-based combination therapy (ACT) coverage'), 
    shp = MDG_shp, 
    year = list(2009:2012, 2005:2007, NA)
    )
  expect_true(inherits(MDG_tvr_tvr_s, 'SpatRaster'))
  # p <- autoplot_MAPraster(MDG_tvr_tvr_s)
  
  
  # Different resolutions 
  MDG_res <- getRaster(
    surface = c("Plasmodium falciparum PR2-10", 
                'A global map of travel time to cities to assess inequalities in accessibility in 2015'), 
    shp = MDG_shp, 
    year = list(2009, NA)
  )
  
  
  expect_true(inherits(MDG_res, 'SpatRasterCollection'))
  expect_true(!all(terra::res(MDG_res[1]) == terra::res(MDG_res[2])) )
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
    MDG_rasters <- getRaster(surface = "Plasmodium falciparum PR2",
                             year = NA)
    
    expect_true(inherits(MDG_rasters, 'character'))
    expect_true(grepl('following surfaces have been incorrectly specified', MDG_rasters))
  
})



test_that('Wrong year errors correctly', {
  skip_on_cran()
 
  MDG_rasters <- getRaster(surface = "Plasmodium falciparum PR2-10",
                           year = 1902)
  
  expect_true(inherits(MDG_rasters, 'character'))
  expect_true(grepl('not available for all requested years', MDG_rasters))
  
})


test_that('Mosquito layers work correctly', {
  skip_on_cran()
  
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  MDG_anoph1 <- getRaster(surface = "Anopheles arabiensis Patton, 1905", shp = MDG_shp, vector_year = 2010)
  MDG_anoph2 <- getRaster(surface = "Anopheles arabiensis Patton, 1905", shp = MDG_shp, vector_year = 2017)
  
  expect_true(terra::values(MDG_anoph1)[845] != terra::values(MDG_anoph2)[845])
})




