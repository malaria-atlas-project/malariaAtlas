# Tests

## question - should tests always be repeated over all species options?


library(MAPdata)
context("Downloading PR data with getPR")

test_that("data is downloaded", {
  expect_output(str(getPR(country = "Kenya", species = "Pv")),"data.frame")
  expect_output(str(getPR(country = "Kenya", species = "Pf")),"data.frame")
  expect_true(length(getPR(country = "Kenya", species = "Pf")$id)>0)
  expect_true(length(getPR(country = "New Zealand", species = "Pf")$id)==0)
  expect_message(getPR(country = "New Zealand", species = "Pf"),"No data downloaded - check spelling of country name and/or availability of data for specificed country.")
})


test_that("dataframe contains expected data", {
  expect_equal(names(getPR(country = "Kenya", species = "Pv")),c("id","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pv_pos","pv_pr","pv_positive","method","rdt_type","pcr_type","site_id","latitude","longitude","name","country_id","area_type_id","rural_urban","country","continent_id","who_region_id","citation1"))
  expect_equal(names(getPR(country = "Kenya", species = "Pf")),c("id","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pf_pos","pf_pr","pf_positive","method","rdt_type","pcr_type","site_id","latitude","longitude","name","country_id","area_type_id","rural_urban","country","continent_id","who_region_id","citation1"))
  #more than just NAs
  #each columns specific data type
  #correct species/country name
  #year range makes sense
  #months make sense
})


