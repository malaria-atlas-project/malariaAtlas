##  getVecOcc() Test

 context("Using getVecOcc to download vector occurrence points")

 test_that("data is downloaded as a data.frame", {
   
   skip_on_cran()
   
   Brazil_all <- getVecOcc(country = "Brazil")
   Brazil_darlingi <- getVecOcc(country = "Brazil", species = "Anopheles darlingi")
   
   americas_multiple <- getVecOcc(country = c("Brazil", "Argentina", "Bolivia", "Paraguay"))
   americas_multiple_albitarsis <- getVecOcc(country = c("Brazil", "Argentina", "Bolivia", "Paraguay"), species = "Anopheles albitarsis")
   africa_all <- getVecOcc(continent = "Africa")
   america_all <- getVecOcc(continent = "Americas")
   
   available_countries <- paste(listPoints(printed = FALSE, sourcedata = "vector points")$country)
   ALL <- getVecOcc(country = available_countries)    
   
   #confirm that more than 0 rows are downloaded for brazil
   expect_true(nrow(Brazil_all)>0)
   expect_true(nrow(america_all)>0)
   #checking that getVecOcc returns a data.frame
   expect_true(inherits(Brazil_all,"data.frame"))
   expect_true(inherits(Brazil_darlingi,"data.frame"))
   expect_true(inherits(africa_all,"data.frame"))
   expect_true(inherits(americas_multiple,"data.frame"))
   
   expect_true(length(unique(Brazil_darlingi$species)) == 1)
   
   
   
# })

# test_that("dataframe contains expected data", {
   #confirm column names are as expected
   expect_equal(sort(names(Brazil_all)),sort(c("site_id","latitude","longitude","country","country_id","continent_id","month_start","year_start","month_end","year_end","anopheline_id","species","species_plain","id","id_method1","id_method2","sample_method1","sample_method2","sample_method3","sample_method4","assi","citation","geometry","time_start","time_end")))
   expect_equal(sort(names(Brazil_darlingi)),sort(c("site_id","latitude","longitude","country","country_id","continent_id","month_start","year_start","month_end","year_end","anopheline_id","species","species_plain","id","id_method1","id_method2","sample_method1","sample_method2","sample_method3","sample_method4","assi","citation","geometry","time_start","time_end")))
   #checking country name specificaion works
   expect_equal(levels(factor(Brazil_all$country)), "Brazil")
   expect_equal(levels(factor(Brazil_darlingi$country)), "Brazil")
   expect_equal(levels(factor(americas_multiple$country)), c("Argentina",  "Bolivia", "Brazil", "Paraguay"))
   expect_equal(levels(factor(americas_multiple_albitarsis$country)), c("Argentina",  "Bolivia", "Brazil", "Paraguay"))

   # This test was originally like this.
   #  Not sure what has changed.
   # expect_equal(levels(americas_multiple_albitarsis$country), c("Argentina", "Bolivia", "Brazil", "Paraguay"))

   
   #checking years fall between 1800 & 2050
   expect_true(unique(Brazil_all$year_start[!is.na(Brazil_all$year_start)]>1800 & Brazil_all$year_start[!is.na(Brazil_all$year_start)]<2030))
   expect_true(unique(Brazil_all$year_end[!is.na(Brazil_all$year_end)]>1800 & Brazil_all$year_end[!is.na(Brazil_all$year_end)]<2030))
   expect_true(unique(Brazil_darlingi$year_start[!is.na(Brazil_darlingi$year_start)]>1800 & Brazil_darlingi$year_start[!is.na(Brazil_darlingi$year_start)]<2030))
   expect_true(unique(Brazil_darlingi$year_end[!is.na(Brazil_darlingi$year_end)]>1800 & Brazil_darlingi$year_end[!is.na(Brazil_darlingi$year_end)]<2030))
   #checking month values are between 1 & 12
   expect_true(unique(Brazil_all$month_start[!is.na(Brazil_all$month_start)] %in% c(1:12)))
   expect_true(unique(Brazil_all$month_end[!is.na(Brazil_all$month_end)] %in% c(1:12)))
   expect_true(unique(Brazil_darlingi$month_start[!is.na(Brazil_darlingi$month_start)] %in% c(1:12)))
   expect_true(unique(Brazil_darlingi$month_end[!is.na(Brazil_darlingi$month_end)] %in% c(1:12)))
   
   
   
   
   # Test two species.
   two_sp <- getVecOcc(country = "Brazil", species = c("Anopheles darlingi", "Anopheles albitarsis"))
   
   expect_true(length(unique(two_sp$species)) == 2)
   
   
 })


test_that("error messages are appropriate to given error", {
  
  skip_on_cran()
  expect_error(getVecOcc(country = "madgascar"), regexp = "Vector occurrence data is not available?")
  expect_error(getVecOcc(country = "xxxx"), regexp = "Vector occurrence data is not available")
})




test_that("all option works", {
  
  skip_on_cran()

  d <- getVecOcc(country = 'all', species = 'Anopheles darlingi')
  expect_true(inherits(d, 'vector.points'))
  expect_true(nrow(d) > 0)
  expect_true(length(unique(d$country)) > 1)
  
  expect_true(length(unique(d$species)) == 1)

  
  
})



test_that("extent argument works", {
  
  skip_on_cran()
  d1 <- getVecOcc(extent = matrix(c(100,13,110,18), nrow = 2), species = 'all')
  expect_true(inherits(d1, 'vector.points'))
  expect_true(nrow(d1) > 0)
  expect_true(length(unique(d1$country)) > 1)
  
  d2 <- getVecOcc(extent = matrix(c(100,13,110,18), nrow = 2), species = 'Anopheles dirus')
  expect_true(inherits(d2, 'vector.points'))
  expect_true(nrow(d2) > 0)
  expect_true(length(unique(d2$country)) > 1)
  
  
})

