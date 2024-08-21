context('Test all raster combinations.')

test_that('All combinations of spatially aligned requests work', {
  skip_on_cran()
  
  # Static
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")

  # Time varying single
  MDG_PfPR2_10 <- getRaster(dataset_id = "Malaria__202206_Global_Pf_Parasite_Rate", shp = MDG_shp, year = 2015)
  expect_true(inherits(MDG_PfPR2_10, 'SpatRaster'))

  #time varying range
  MDG_PfPR2_10_range <- getRaster(dataset_id = "Malaria__202206_Global_Pf_Parasite_Rate", shp = MDG_shp, year = 2012:2015)
  expect_true(inherits(MDG_PfPR2_10_range, 'SpatRasterCollection'))

  # Time varying default
  MDG_PfPR2_10_def <- getRaster(dataset_id = "Malaria__202206_Global_Pf_Parasite_Rate", shp = MDG_shp, year = NA)
  expect_true(inherits(MDG_PfPR2_10_def, 'SpatRaster'))


  # two time varying single
  MDG_tvs_tvs <- getRaster(dataset_id = c("Malaria__202206_Global_Pf_Parasite_Rate", 'Interventions__202106_Africa_Insecticide_Treated_Net_Use'), shp = MDG_shp, year = list(2012, 2010))
  expect_true(inherits(MDG_tvs_tvs, 'SpatRasterCollection'))

  # time varying range plus time varying single
  MDG_tvr_tvs <- getRaster(dataset_id = c("Malaria__202206_Global_Pf_Parasite_Rate", 'Interventions__202106_Africa_Insecticide_Treated_Net_Use'), shp = MDG_shp, year = list(2009:2012, 2010))
  expect_true(inherits(MDG_tvr_tvs, 'SpatRasterCollection'))

  # two time varying range
  MDG_tvr_tvr <- getRaster(dataset_id = c("Malaria__202206_Global_Pf_Parasite_Rate", 'Interventions__202106_Africa_Insecticide_Treated_Net_Use'), shp = MDG_shp, year = list(2009:2012, 2005:2007))
  expect_true(inherits(MDG_tvr_tvr, 'SpatRasterCollection'))

  # two static
  MDG_stat_stat <- getRaster(dataset_id = c("Accessibility__202001_Global_Motorized_Travel_Time_to_Healthcare", 'Accessibility__202001_Global_Walking_Only_Travel_Time_To_Healthcare'), 
                             shp = MDG_shp, year = c(NA, NA))
  expect_true(inherits(MDG_stat_stat, 'SpatRasterCollection'))

 # one time varying single plus one static
  MDG_tvs_stat <- getRaster(dataset_id = c("Interventions__202106_Africa_Insecticide_Treated_Net_Use", 'Blood_Disorders__201201_Africa_HbC_Allele_Frequency'), shp = MDG_shp, year = c(2012, NA))
  expect_true(inherits(MDG_tvs_stat, 'SpatRasterCollection'))

# time varying range plus static
  MDG_tvr_tvs <- getRaster(
    dataset_id = c("Interventions__202106_Africa_Insecticide_Treated_Net_Use", 'Blood_Disorders__201201_Africa_HbC_Allele_Frequency'), 
    shp = MDG_shp, year = list(2009:2012, NA))
  expect_true(inherits(MDG_tvr_tvs, 'SpatRasterCollection'))

# two time varying range plus static.
  MDG_tvr_tvr_s <- getRaster(
    dataset_id = c("Interventions__202106_Africa_Insecticide_Treated_Net_Use", 'Malaria__202406_Global_Pf_Parasite_Rate', 'Blood_Disorders__201201_Africa_HbC_Allele_Frequency'), 
    shp = MDG_shp, 
    year = list(2009:2012, 2005:2007, NA)
    )
  expect_true(inherits(MDG_tvr_tvr_s, 'SpatRasterCollection'))
  # p <- autoplot_MAPraster(MDG_tvr_tvr_s)
  
  
  # Different resolutions 
  MDG_res <- getRaster(
    dataset_id = c("Interventions__202106_Africa_Insecticide_Treated_Net_Use", 
                'Accessibility__202001_Global_Motorized_Friction_Surface'), 
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
    MDG_rasters <- getRaster(dataset_id = c("Malaria__202206_Global_Pf_Mortality_Count",
                                         'Malaria__202206_Global_Pf_Mortality_Rate',
                                         'Malaria__202206_Global_Pf_Incidence_Count'),
                             year = list(2009:2011)),
      regexp = "If downloading multiple different rasters, 'year' must be a list of the same length as 'dataset_id'.")
})


test_that('Wrong name errors correctly', {
  skip_on_cran()
  
  expect_error(
    MDG_rasters <- getRaster(dataset_id = "Plasmodium falciparum PR2",
                             year = NA))
})



test_that('Wrong year errors correctly', {
  skip_on_cran()
 
  MDG_rasters <- expect_warning(getRaster(dataset_id = "Malaria__202206_Global_Pf_Incidence_Count",
                           year = 1902))
  
  expect_true(inherits(MDG_rasters, 'character'))
  expect_true(grepl('not available for all requested years', MDG_rasters))
})

test_that('Using surface works', {
  skip_on_cran()
  
  # Trying to handle new and old data depending on whether the database has been updated yet

  # fails with new data
  tryCatch({
    r <- getRaster(surface = "Number of deaths from Plasmodium falciparum during a defined year 2000-2020", year = 2015)
    MDG_surface <- r
  }, error = function(e) {
    print("Failed with new data")
  })
  
  # fails with old data
  tryCatch({
    r <- getRaster(surface = "Number of deaths from Plasmodium falciparum during a defined year", year = 2015)
    MDG_surface <- r
  }, error = function(e) {
    print("Failed with old data")
  })

  expect_true(inherits(MDG_surface, 'SpatRaster'))
})

test_that('Explorer datasets work', {
  skip_on_cran()
  
  MDG_surface <- getRaster(dataset_id = c("Explorer__2020_Global_Pv_Cases", "Explorer__2020_Global_PvPR", "Explorer__2020_Global_Pf_Reproductive_Number"),
                           year = list(2015, 2004:2007, NA))
  
  expect_true(inherits(MDG_surface, 'SpatRasterCollection'))
  
  #TODO: Failing
})


