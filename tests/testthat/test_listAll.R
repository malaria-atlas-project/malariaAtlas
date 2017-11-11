# listAll() tests

context("Using listAll to check which countries have available PR data.")

rm(available_countries_stored, envir = .malariaAtlasHidden)

available_countries <- listAll()

test_that("downloaded data.frame is in the correct format",{
  expect_true(length(available_countries$country)>0)
  expect_true(inherits(available_countries,"data.frame"))
})

test_that("downloaded dataframe contains has correct content",{
  expect_equal(sort(names(available_countries)),sort(c("country","country_id","country_and_iso")))
  expect_true("Kenya" %in% available_countries$country)
  expect_true("KEN" %in% available_countries$country_id)
  expect_true(inherits(available_countries$country, "factor"))
  expect_true(inherits(available_countries$country_id, "factor"))
})

test_that("available_countries_stored object is stored in hidden environment",{
  expect_true(exists("available_countries_stored", envir = .malariaAtlasHidden))
})

# listAllRaster() tests

context("Using listAllRaster to check which Rasters are available for downlaod.")

rm(available_rasters_stored, envir = .malariaAtlasHidden)

available_rasters <- listAllRaster()

test_that("downloaded data.frame is in the correct format",{
  expect_true(length(available_rasters$raster_code)>0)
  expect_true(inherits(available_rasters,"data.frame"))
})

test_that("downloaded dataframe contains has correct numer of columns",{
  expect_equal(sort(names(available_rasters)),sort(c("raster_code","title","title_extended", "abstract","citation","pub_year")))
})

test_that("available_countries_stored object is stored in hidden environment",{
  expect_true(exists("available_rasters_stored", envir = .malariaAtlasHidden))
})






