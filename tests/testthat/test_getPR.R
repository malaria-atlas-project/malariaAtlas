# Tests

## question - should tests always be repeated over all species options?

context("Using getPR to download PR points")

kenya_pv <- getPR(country = "Kenya", species = "Pv")
kenya_pf <- getPR(country = "Kenya", species = "Pf")
kenya_BOTH <- getPR(country = "Kenya", species = "BOTH")

multiple_pv <- getPR(country = c("Madagascar","Nigeria","Suriname"), species = "Pv")
multiple_pf <- getPR(country = c("Madagascar","Nigeria","Suriname"), species = "Pf")
multiple_BOTH <- getPR(country = c("Madagascar","Nigeria","Suriname"), species = "BOTH")

ALL_pv <- getPR(country = "ALL", species = "Pv")
ALL_pf <- getPR(country = "ALL", species = "Pf")
ALL_BOTH <- getPR(country = "ALL", species = "BOTH")

test_that("data is downloaded as a data.frame", {
  #confirm that more than 0 rows are downloaded for Kenya
  expect_true(length(kenya_pv$country)>0)
  expect_true(length(kenya_pf$country)>0)
  expect_true(length(kenya_BOTH$country)>0)
  expect_true(length(ALL_pv$country)>0)
  expect_true(length(ALL_pf$country)>0)
  expect_true(length(ALL_BOTH$country)>0)
  #checking that getPR returns a data.frame
  expect_true(inherits(kenya_pv,"data.frame"))
  expect_true(inherits(kenya_pf,"data.frame"))
  expect_true(inherits(kenya_BOTH,"data.frame"))
  expect_true(inherits(ALL_pv,"data.frame"))
  expect_true(inherits(ALL_pf,"data.frame"))
  expect_true(inherits(ALL_BOTH,"data.frame"))
  })

test_that("dataframe contains expected data", {
  #confirm column names are as expected
  expect_equal(sort(names(kenya_pv)),sort(c("site_id","dhs_id","site_name","latitude","longitude","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pv_pos","pv_pr","method","rdt_type","pcr_type","rural_urban","country_id","country","continent_id","malaria_metrics_available","location_available","permissions_info","citation1","citation2","citation3")))
  expect_equal(sort(names(kenya_pf)),sort(c("site_id","dhs_id","site_name","latitude","longitude","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pf_pos","pf_pr","method","rdt_type","pcr_type","rural_urban","country_id","country","continent_id","malaria_metrics_available","location_available","permissions_info","citation1","citation2","citation3")))
  expect_equal(sort(names(kenya_BOTH)),sort(c("site_id","dhs_id","site_name","latitude","longitude","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","pv_pos","pv_pr","pf_pos","pf_pr","method","rdt_type","pcr_type","rural_urban","country_id","country","continent_id","malaria_metrics_available","location_available","permissions_info","citation1","citation2","citation3")))
  # checking country name specification works
  expect_equal(levels(kenya_pf$country), "Kenya")
  expect_equal(levels(kenya_pv$country), "Kenya")
  expect_equal(levels(kenya_BOTH$country), "Kenya")
  expect_equal(levels(multiple_pv$country), c("Madagascar","Nigeria","Suriname"))
  expect_equal(levels(multiple_pf$country), c("Madagascar","Nigeria","Suriname"))
  expect_equal(levels(multiple_BOTH$country), c("Madagascar","Nigeria","Suriname"))
  #checking years fall between 1800 & 2050
  expect_true(unique(kenya_pv$year_start[!is.na(kenya_pv$year_start)]>1800 & kenya_pv$year_start[!is.na(kenya_pv$year_start)]<2030))
  expect_true(unique(kenya_pv$year_end[!is.na(kenya_pv$year_end)]>1800 & kenya_pv$year_end[!is.na(kenya_pv$year_end)]<2030))
  expect_true(unique(kenya_pf$year_start[!is.na(kenya_pf$year_start)]>1800 & kenya_pf$year_start[!is.na(kenya_pf$year_start)]<2030))
  expect_true(unique(kenya_pf$year_end[!is.na(kenya_pf$year_end)]>1800 & kenya_pf$year_end[!is.na(kenya_pf$year_end)]<2030))
  expect_true(unique(kenya_BOTH$year_start[!is.na(kenya_BOTH$year_start)]>1800 & kenya_BOTH$year_start[!is.na(kenya_BOTH$year_start)]<2030))
  expect_true(unique(kenya_BOTH$year_end[!is.na(kenya_BOTH$year_end)]>1800 & kenya_BOTH$year_end[!is.na(kenya_BOTH$year_end)]<2030))
  #checking month values are between 1 & 12
  expect_true(unique(kenya_pv$month_start[!is.na(kenya_pv$month_start)] %in% c(1:12)))
  expect_true(unique(kenya_pv$month_end[!is.na(kenya_pv$month_end)] %in% c(1:12)))
  expect_true(unique(kenya_pf$month_start[!is.na(kenya_pf$month_start)] %in% c(1:12)))
  expect_true(unique(kenya_pf$month_end[!is.na(kenya_pf$month_end)] %in% c(1:12)))
  expect_true(unique(kenya_BOTH$month_start[!is.na(kenya_BOTH$month_start)] %in% c(1:12)))
  expect_true(unique(kenya_BOTH$month_end[!is.na(kenya_BOTH$month_end)] %in% c(1:12)))
})


test_that("species specification works as desired",{
  expect_true(any(tolower(names(kenya_pv)) == "pv_pos"))
  expect_false(any(tolower(names(kenya_pv)) == "pf_pos"))
  expect_true(any(tolower(names(kenya_pf)) == "pf_pos"))
  expect_false(any(tolower(names(kenya_pf)) == "pv_pos"))
  expect_true(any(tolower(names(kenya_BOTH)) == "pf_pos"))
  expect_true(any(tolower(names(kenya_BOTH)) == "pv_pos"))
})



#confirm that the correct error is returned if user inputs country with no PR data (here - New Zealand)




