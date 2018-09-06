# getPR() Tests

context("Using getPR to download PR points")

test_that("data is downloaded as a data.frame", {
  
  skip_on_cran()
  kenya_pv <- getPR(country = "Kenya", species = "Pv")
  kenya_pf <- getPR(country = "Kenya", species = "Pf")
  kenya_BOTH <- getPR(country = "Kenya", species = "BOTH")
  
  multiple_pv <- getPR(country = c("Madagascar","Nigeria","Suriname"), species = "Pv")
  multiple_pf <- getPR(country = c("Madagascar","Nigeria","Suriname"), species = "Pf")
  multiple_BOTH <- getPR(country = c("Madagascar","Nigeria","Suriname"), species = "BOTH")
  
  available_countries_pr <- paste(listPoints(printed = FALSE, sourcedata = "pr points")$country)
  ALL_pv <- getPR(country = available_countries_pr, species = "Pv")
  ALL_pf <- getPR(country = available_countries_pr, species = "Pf")
  ALL_BOTH <- getPR(country = available_countries_pr, species = "BOTH")
  
  #confirm that more than 0 rows are downloaded for Kenya
  expect_true(nrow(kenya_pv)>0)
  expect_true(nrow(kenya_pf)>0)
  expect_true(nrow(kenya_BOTH)>0)
  expect_true(nrow(ALL_pv)>0)
  expect_true(nrow(ALL_pf)>0)
  expect_true(nrow(ALL_BOTH)>0)
  #checking that getPR returns a data.frame
  expect_true(inherits(kenya_pv,"data.frame"))
  expect_true(inherits(kenya_pf,"data.frame"))
  expect_true(inherits(kenya_BOTH,"data.frame"))
  expect_true(inherits(ALL_pv,"data.frame"))
  expect_true(inherits(ALL_pf,"data.frame"))
  expect_true(inherits(ALL_BOTH,"data.frame"))
  # })

# test_that("dataframe contains expected data", {
  #confirm column names are as expected
  expect_equal(sort(names(kenya_pv)),sort(c("site_id","dhs_id","site_name","latitude","longitude","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","positive","pr","species", "method","rdt_type","pcr_type","rural_urban","country_id","country","continent_id","malaria_metrics_available","location_available","permissions_info","citation1","citation2","citation3")))
  expect_equal(sort(names(kenya_pf)),sort(c("site_id","dhs_id","site_name","latitude","longitude","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","positive","pr","species","method","rdt_type","pcr_type","rural_urban","country_id","country","continent_id","malaria_metrics_available","location_available","permissions_info","citation1","citation2","citation3")))
  expect_equal(sort(names(kenya_BOTH)),sort(c("site_id","dhs_id","site_name","latitude","longitude","month_start","year_start","month_end","year_end","lower_age","upper_age","examined","positive","pr","species","method","rdt_type","pcr_type","rural_urban","country_id","country","continent_id","malaria_metrics_available","location_available","permissions_info","citation1","citation2","citation3")))
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
# })


# test_that("species specification works as desired",{

  expect_true("P. vivax" %in% kenya_pv$species & ! "P. falciparum" %in% kenya_pv$species)
  expect_true(!"P. vivax" %in% kenya_pf$species & "P. falciparum" %in% kenya_pf$species)
  expect_true("P. vivax" %in% kenya_BOTH$species &  "P. falciparum" %in% kenya_BOTH$species)
# })


 # test_that("error messages are appropriate to given error",{
  expect_error(getPR(country = "knya", species = "both"), regexp = "did you mean Kenya")
  expect_error(getPR(country = "kenya", species = "both"), regexp = NA)
  expect_error(getPR(country = "xxxx", species = "both"), regexp = "'Xxxx', use listPoints()")
  expect_error(getPR(country = "Australia", species = "both"), regexp = "'Australia', use listPoints()")
  expect_warning(getPR(country = c("kenya","ngeria"), species = "both"), regexp = "did you mean Nigeria")
  expect_message(getPR(country = c("kenya","ngeria"), species = "both"), regexp = "Data downloaded for Kenya")
  expect_error(getPR(country = c("kenya","ngeria"), species = "both"), regexp = NA)
  expect_warning(getPR(country = c("kenya","Australia"), species = "both"), regexp = "'Australia', use listPoints()")
  expect_message(getPR(country = c("kenya","Australia"), species = "both"), regexp = "Data downloaded for Kenya")
  expect_error(getPR(country = c("kenya","Australia"), species = "both"), regexp = NA)
  expect_error(getPR(country = c("Ngeria","Australia"), species = "both"), regexp = "'Australia', use listPoints()")
  expect_error(getPR(country = c("Ngeria","Australia"), species = "both"), regexp = "did you mean Nigeria")
  expect_warning(getPR(country = c("kenya","Ngeria","Australia"), species = "both"), regexp = "did you mean Nigeria")
  expect_warning(getPR(country = c("kenya","Ngeria","Australia"), species = "both"), regexp = "'Australia', use listPoints()")
  expect_message(getPR(country = c("kenya","Ngeria","Australia"), species = "both"), regexp = "Data downloaded for Kenya")
  
  
  
})

test_that('Extent works', {
  skip_on_cran()
  d <- getPR(species = 'both', extent = matrix(c(0, -30, 40, 10), nrow = 2))
  expect_true(inherits(d, 'pr.points'))
  expect_true(nrow(d) > 0)
  
  expect_true(all(d$latitude > -30 & d$latitude < 10))
  expect_true(all(d$longitude > -0 & d$longitude < 40))
  
})


test_that('DL all works', {
  skip_on_cran()
  expect_message(
    d <- getPR(species = 'Pf', country = 'all'),
    regexp = 'Importing PR point data for all'
  )
  expect_true(inherits(d, 'pr.points'))
  expect_true(nrow(d) > 0)
  
})


test_that('No location errors properly', {
  skip_on_cran()
  expect_error(
    d <- getPR(species = 'Pf', country = NULL),
    regexp = 'Must specify one of'
  )

})
