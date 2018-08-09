###  getVecOcc Test

 context("Using getVecOcc to download vector occurrence points")

 Brazil_all <- getVecOcc(country = "Brazil")
 Brazil_darlingi <- getVecOcc(country = "Brazil", species = "Anopheles darlingi")

 americas_multiple <- getVecOcc(country = c("Brazil", "Argentina", "Bolivia", "Paraguay"))
 americas_multiple_albitarsis <- getVecOcc(country = c("Brazil", "Argentina", "Bolivia", "Paraguay"), species = "Anopheles albitarsis")
 africa_all <- getVecOcc(continent = "Africa")
 america_all <- getVecOcc(continent = "Americas")

 available_countries <- paste(listPoints4(printed = FALSE, sourcedata = "vector points")$country)
 ALL <- getVecOcc(country = available_countries)    ## error, tolower(country) -- something like this missing?
 
 test_that("data is downloaded as a data.frame", {
   #confirm that more than 0 rows are downloaded for brazil
   expect_true(nrow(Brazil_all)>0)
   expect_true(nrow(america_all)>0)
   #checking that getVecOcc returns a data.frame
   expect_true(inherits(Brazil_all,"data.frame"))
   expect_true(inherits(Brazil_darlingi,"data.frame"))
   expect_true(inherits(africa_all,"data.frame"))
   expect_true(inherits(americas_multiple,"data.frame"))
 })

 test_that("dataframe contains expected data", {
   #confirm column names are as expected
   expect_equal(sort(names(Brazil_all)),sort(c("site_id","latitude","longitude","country","country_id","continent_id","month_start","year_start","month_end","year_end","anopheline_id","species","species_plain","id_method1","id_method2","sample_method1","sample_method2","sample_method3","sample_method4","assi","citation","geom","time_start","time_end")))
   expect_equal(sort(names(Brazil_darlingi)),sort(c("site_id","latitude","longitude","country","country_id","continent_id","month_start","year_start","month_end","year_end","anopheline_id","species","species_plain","id_method1","id_method2","sample_method1","sample_method2","sample_method3","sample_method4","assi","citation","geom","time_start","time_end")))
   #checking country name specificaion works
   expect_equal(levels(Brazil_all$country), "Brazil")
   expect_equal(levels(Brazil_darlingi$country), "Brazil")
   expect_equal(levels(americas_multiple$country), c("Brazil", "Argentina", "Bolivia", "Paraguay"))
   expect_equal(levels(americas_multiple_albitarsis$country), c("Brazil", "Argentina", "Bolivia", "Paraguay"))
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
 })
 
 
test_that("error messages are appropriate to given error", {
  
})
