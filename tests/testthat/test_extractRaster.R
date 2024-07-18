
context('Test extract raster')

test_that('Extract raster basics works', {
    
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        dataset_id = 'Malaria__202206_Global_Pf_Mortality_Count',
                        year = 2015)
  
  expect_true(inherits(data, 'data.frame'))
  expect_true(all(data$long %in% c(4, 8)))
  expect_true(all(data$lat %in% c(13, 9)))
  expect_true(all(data$year == 2015))
})

test_that('Extract single raster with year range works', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        dataset_id = 'Malaria__202206_Global_Pf_Mortality_Count',
                        year = list(2015:2017))
  
  expect_true(inherits(data, 'data.frame'))
  expect_true(all(data$year <= 2017 & data$year >= 2015))
})

test_that('Extract multiple rasters with single years works', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count', 'Interventions__202406_Africa_IRS_Coverage'),
                        year = list(2015, 2017))
  
  expect_true(inherits(data, 'data.frame'))
  
  data_first_raster <- subset(data, layerName == 'Malaria__202206_Global_Pf_Mortality_Count')
  expect_true(nrow(data_first_raster) == 2)
  expect_true(all(data_first_raster$year == 2015))
  
  data_second_raster <- subset(data, layerName == 'Interventions__202406_Africa_IRS_Coverage')
  expect_true(nrow(data_second_raster) == 2)
  expect_true(all(data_second_raster$year == 2017))
})


test_that('Extract multiple rasters with single year and year range works', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count', 'Interventions__202406_Africa_IRS_Coverage'),
                        year = list(2015, 2017:2019))
  
  expect_true(inherits(data, 'data.frame'))
  
  data_first_raster <- subset(data, layerName == 'Malaria__202206_Global_Pf_Mortality_Count')
  expect_true(nrow(data_first_raster) == 2)
  expect_true(all(data_first_raster$year == 2015))
  
  data_second_raster <- subset(data, layerName == 'Interventions__202406_Africa_IRS_Coverage')
  expect_true(nrow(data_second_raster) == 6)
  expect_true(all(data_second_raster$year <= 2019 & data_second_raster$year >= 2017))
})

test_that('Extract multiple rasters with both year ranges works', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count', 'Interventions__202406_Africa_IRS_Coverage'),
                        year = list(2014:2017, 2017:2019))
  
  expect_true(inherits(data, 'data.frame'))
  
  data_first_raster <- subset(data, layerName == 'Malaria__202206_Global_Pf_Mortality_Count')
  expect_true(nrow(data_first_raster) == 8)
  expect_true(all(data_first_raster$year <= 2017 & data_first_raster$year >= 2014))
  
  data_second_raster <- subset(data, layerName == 'Interventions__202406_Africa_IRS_Coverage')
  expect_true(nrow(data_second_raster) == 6)
  expect_true(all(data_second_raster$year <= 2019 & data_second_raster$year >= 2017))
})

test_that('Extract multiple rasters with single year, NA and year range', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count', 'Interventions__202406_Africa_IRS_Coverage', 'Malaria__202206_Global_Pf_Parasite_Rate'),
                        year = list(2014, NA, 2017:2019))
  
  expect_true(inherits(data, 'data.frame'))
  
  data_first_raster <- subset(data, layerName == 'Malaria__202206_Global_Pf_Mortality_Count')
  expect_true(nrow(data_first_raster) == 2)
  expect_true(all(data_first_raster$year == 2014))
  
  data_second_raster <- subset(data, layerName == 'Interventions__202406_Africa_IRS_Coverage')
  expect_true(nrow(data_second_raster) > 0)
  
  data_third_raster <- subset(data, layerName == 'Malaria__202206_Global_Pf_Parasite_Rate')
  expect_true(nrow(data_third_raster) == 6)
  expect_true(all(data_third_raster$year <= 2019 & data_third_raster$year >= 2017))
})

test_that('Extract raster with surface works', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        surface = 'Plasmodium falciparum PR2 - 10',
                        year = 2015)
  
  expect_true(inherits(data, 'data.frame'))
})

test_that('Extract raster with incorrect year length', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  expect_error(extractRaster(d,
                        dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count', 'Interventions__202106_Africa_Insecticide_Treated_Net_Use'),
                        year = 2014))
})

test_that('Extract raster with no year', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d, dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count', 'Interventions__202106_Africa_Insecticide_Treated_Net_Use'))
  expect_true(inherits(data, 'data.frame'))
})

test_that('Extract raster with no year as vector', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d, dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count', 'Interventions__202406_Africa_IRS_Coverage'), 
                        year = c(2015, 2014))
  expect_true(inherits(data, 'data.frame'))
})

test_that('Extract raster with no valid latitude column', {
  
  skip_on_cran()
  d <- data.frame(v = c(4, 8), y = c(13, 9))
  expect_error(extractRaster(d, dataset_id = 'Malaria__202206_Global_Pf_Mortality_Count', 
                        year = 2015))
})

test_that('Extract raster with no valid longitude column', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), m = c(13, 9))
  expect_error(extractRaster(d, dataset_id = 'Malaria__202206_Global_Pf_Mortality_Count', 
                             year = 2015))
})

test_that('Extract raster with incorrect dataset_id', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  expect_error(extractRaster(d, dataset_id = 'gibberish', 
                             year = 2015))
})

test_that('Extract raster with one incorrect dataset_id and one correct', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- expect_warning(extractRaster(d, dataset_id = c('gibberish', 'Malaria__202206_Global_Pf_Mortality_Count'), 
                             year = list(2014, 2015)))
  
  expect_true(inherits(data, 'data.frame'))
  expect_true(all(data$layerName == 'Malaria__202206_Global_Pf_Mortality_Count'))
})


test_that('Extract raster keeps additional rows of original df', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9), test=c('Y', 'N'))
  data <- extractRaster(d, dataset_id = c('Malaria__202206_Global_Pf_Mortality_Count'))
  
  expect_true(inherits(data, 'data.frame'))
  expect_true('test' %in% colnames((data)))
})


test_that('Extract raster with static raster, but given year', {
  
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d, dataset_id = c('Explorer__2010_Anopheles_koliensis'), year = 2014)
  
  expect_true(inherits(data, 'data.frame'))
  expect_true(nrow(data) == 2)
})

test_that('Output in same order as input', {
  NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
  complete <- complete.cases(NGA_CMR_PR[, c(4, 5, 16, 17)])
  NGA_CMR_PR <- NGA_CMR_PR[complete, ]
  
  # Extract PfPR data at those locations.
  data <- extractRaster(df = NGA_CMR_PR[, c('latitude', 'longitude')], dataset_id = 'Malaria__202206_Global_Pf_Parasite_Rate', year=2020)
  
  # Data are returned in the same order.
  expect_equal(data$longitude, NGA_CMR_PR$longitude)
})
