# Tests

## question - should tests always be repeated over all species options?


library(MAPdata)
context("Downloading PR data with getPR")

test_that("data is downloaded", {
  #checking that getPR returns a data.frame
  expect_output(str(getPR(country = "Kenya", species = "Pv")),"data.frame")
  expect_output(str(getPR(country = "Kenya", species = "Pf")),"data.frame")
  expect_output(str(getPR(country = "Kenya", species = "BOTH")),"data.frame")
  #confirm that more than 0 rows are downloaded for Kenya
  expect_true(length(getPR(country = "Kenya", species = "Pf")$country)>0)
  #confirm that the correct error is returned if user inputs country with no PR data (here - New Zealand)
  expect_error(getPR(country = "New Zealand", species = "Pf"),"No data available for - New Zealand - check specified country matches one of:")
})


test_that("dataframe contains expected data", {
  #confirm column names are as expected
  expect_equal(names(getPR(country = "Kenya", species = "Pf")),c("month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pf_pr","pf_positive","method","rdt_type","pcr_type","site_id","latitude","longitude","name","country_id","rural_urban","country","continent_id","who_region_id","citation1","citation2","citation3"))
  expect_equal(names(getPR(country = "Kenya", species = "Pv")),c("month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pv_pr","pv_positive","method","rdt_type","pcr_type","site_id","latitude","longitude","name","country_id","rural_urban","country","continent_id","who_region_id","citation1","citation2","citation3"))
  expect_equal(names(getPR(country = "Kenya", species = "BOTH")),c("month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pf_pr","pv_pr","pf_positive","pv_positive","method","rdt_type","pcr_type","site_id","latitude","longitude","name","country_id","rural_urban","country","continent_id","who_region_id","citation1","citation2","citation3"))
  # checking country name specification works
  expect_equal(levels(getPR(country = "Kenya", species = "Pf")$country), "Kenya")
  expect_equal(levels(getPR(country = c("Kenya", "Nigeria", "Malaysia"), species = "Pf")$country), sort(c("Kenya", "Nigeria", "Malaysia")))
  #checking years fall between 1800 & 2050
  expect_true(unique((getPR(country = "Kenya", species = "Pf")$year_start>1800 & getPR(country = "Kenya", species = "Pf")$year_start<2050)))
  expect_true(unique((getPR(country = "Kenya", species = "Pf")$year_end>1800 & getPR(country = "Kenya", species = "Pf")$year_end<2050)))
  #checking month values are between 1 & 12
  expect_true(unique(getPR(country = "Kenya", species = "Pf")$month_start %in% c(1:12)))
  expect_true(unique(getPR(country = "Kenya", species = "Pf")$month_end %in% c(1:12)))

  #each column's specific data type


})


