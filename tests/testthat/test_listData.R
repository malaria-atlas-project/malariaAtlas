# listPoints() tests

context("Using listPoints to check which countries have available PR data.")
if(exists("available_countries_stored", envir = .malariaAtlasHidden)){
rm(available_countries_stored, envir = .malariaAtlasHidden)
}

available_countries <- listPoints(printed = FALSE)

test_that("downloaded data.frame is in the correct format",{
  expect_true(nrow(available_countries)>0)
  expect_true(inherits(available_countries,"data.frame"))
})

test_that("downloaded dataframe contains has correct content",{
  expect_equal(sort(names(available_countries)),sort(c("country","country_id", "continent")))
  expect_true("Kenya" %in% available_countries$country)
  expect_true("KEN" %in% available_countries$country_id)
  expect_true("Oceania" %in% available_countries$continent)
  expect_true(inherits(available_countries$country, "factor"))
  expect_true(inherits(available_countries$country_id, "factor"))
  expect_true(inherits(available_countries$continent, "factor"))
})

test_that("available_countries_stored object is stored in hidden environment",{
  expect_true(exists("available_countries_stored", envir = .malariaAtlasHidden))
})

# listRaster() tests

context("Using listRaster to check which Rasters are available for downlaod.")

if(exists("available_rasters_stored", envir = .malariaAtlasHidden)){
rm(available_rasters_stored, envir = .malariaAtlasHidden)
}

available_rasters <- listRaster()

test_that("downloaded data.frame is in the correct format",{
  expect_true(nrow(available_rasters)>0)
  expect_true(inherits(available_rasters,"data.frame"))
})

test_that("downloaded dataframe contains has correct number of columns",{
  expect_equal(sort(names(available_rasters)),sort(c("raster_code","title","title_extended", "abstract","citation", "min_raster_year", "max_raster_year")))
})

test_that("available_countries_stored object is stored in hidden environment",{
  expect_true(exists("available_rasters_stored", envir = .malariaAtlasHidden))
})

# listShp() tests

context("Using listShp to check which shapes are available for downlaod.")

if(exists("available_admin_stored", envir = .malariaAtlasHidden)){
  rm(available_admin_stored, envir = .malariaAtlasHidden)
}

available_admin <- listShp()

test_that("downloaded data.frame is in the correct format",{
  expect_true(nrow(available_admin)>0)
  expect_true(inherits(available_admin,"data.frame"))
})

test_that("downloaded dataframe contains has correct number of columns",{
  expect_equal(sort(names(available_admin)),sort(c("country_id","gaul_code","admn_level","parent_id","name")))
})

test_that("available_admin_stored object is stored in hidden environment",{
  expect_true(exists("available_admin_stored", envir = .malariaAtlasHidden))
})



