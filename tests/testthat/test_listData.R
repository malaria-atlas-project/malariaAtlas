# listPoints(sourcedata = "pr points") tests

context("Using listPoints to check which countries have available PR data.")
if(exists("available_countries_stored_pr", envir = .malariaAtlasHidden)){
rm(available_countries_stored_pr, envir = .malariaAtlasHidden)
}


test_that("downloaded data.frame is in the correct format",{
  
  skip_on_cran()
  available_countries_pr <- listPoints(printed = FALSE, sourcedata = "pr points")
  
  expect_true(nrow(available_countries_pr)>0)
  expect_true(inherits(available_countries_pr,"data.frame"))
#})

#test_that("downloaded dataframe contains has correct content",{
  expect_equal(sort(names(available_countries_pr)),sort(c("country","country_id", "continent")))
  expect_true("Kenya" %in% available_countries_pr$country)
  expect_true("KEN" %in% available_countries_pr$country_id)
  expect_true("Oceania" %in% available_countries_pr$continent)
  expect_true(inherits(available_countries_pr$country, "factor"))
  expect_true(inherits(available_countries_pr$country_id, "factor"))
  expect_true(inherits(available_countries_pr$continent, "factor"))
#})

#test_that("available_countries_stored_pr object is stored in hidden environment",{
  expect_true(exists("available_countries_stored_pr", envir = .malariaAtlasHidden))
})




# listPoints(sourcedata = "vector points") tests

context("Using listPoints to check which countries have available Vector Occurrence data.")
if(exists("available_countries_stored_vec", envir = .malariaAtlasHidden)){
  rm(available_countries_stored_vec, envir = .malariaAtlasHidden)
}


test_that("downloaded data.frame is in the correct format",{
  
  skip_on_cran()
  
  available_countries_vec <- listPoints(printed = FALSE, sourcedata = "vector points")
  
  expect_true(nrow(available_countries_vec)>0)
  expect_true(inherits(available_countries_vec,"data.frame"))
#})

#test_that("downloaded dataframe contains has correct content",{
  expect_equal(sort(names(available_countries_vec)),sort(c("country","country_id", "continent")))
  expect_true("Kenya" %in% available_countries_vec$country)
  expect_true("KEN" %in% available_countries_vec$country_id)
  expect_true("Oceania" %in% available_countries_vec$continent)
  expect_true(inherits(available_countries_vec$country, "factor"))
  expect_true(inherits(available_countries_vec$country_id, "factor"))
  expect_true(inherits(available_countries_vec$continent, "factor"))
#})

#test_that("available_countries_stored_vec object is stored in hidden environment",{
  expect_true(exists("available_countries_stored_vec", envir = .malariaAtlasHidden))
})

# listRaster() tests

context("Using listRaster to check which Rasters are available for downlaod.")

if(exists("available_rasters_stored", envir = .malariaAtlasHidden)){
rm(available_rasters_stored, envir = .malariaAtlasHidden)
}


test_that("downloaded data.frame is in the correct format",{
  
  skip_on_cran()
  
  available_rasters <- listRaster()
  
  expect_true(nrow(available_rasters)>0)
  expect_true(inherits(available_rasters,"data.frame"))
#})

#test_that("downloaded dataframe contains has correct number of columns",{
  expect_equal(sort(names(available_rasters)),sort(c("raster_code","title","title_extended", "abstract","citation", "min_raster_year", "max_raster_year")))
#})

#test_that("available_countries_stored object is stored in hidden environment",{
  expect_true(exists("available_rasters_stored", envir = .malariaAtlasHidden))
})

# listShp() tests

context("Using listShp to check which shapes are available for downlaod.")

if(exists("available_admin_stored", envir = .malariaAtlasHidden)){
  rm(available_admin_stored, envir = .malariaAtlasHidden)
}


test_that("downloaded data.frame is in the correct format",{
  
  skip_on_cran()
  available_admin <- listShp()
  
  expect_true(nrow(available_admin)>0)
  expect_true(inherits(available_admin,"data.frame"))
#})

#test_that("downloaded dataframe contains has correct number of columns",{
  expect_equal(sort(names(available_admin)),sort(c("iso","admn_level","name_0","id_0","type_0","source","name_1","id_1","type_1")))
#})

#test_that("available_admin_stored object is stored in hidden environment",{
  expect_true(exists("available_admin_stored", envir = .malariaAtlasHidden))
})



