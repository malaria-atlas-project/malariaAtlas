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
  #expect_true(inherits(available_countries_pr$country, "factor"))
  #expect_true(inherits(available_countries_pr$country_id, "factor"))
  #expect_true(inherits(available_countries_pr$continent, "factor"))
#})

#test_that("available_countries_stored_pr object is stored in hidden environment",{
  expect_equal(length(grep("Pv_Parasite_Rate_Surveys", names(.malariaAtlasHidden$list_points))), 1)
  expect_equal(length(grep("Pf_Parasite_Rate_Surveys", names(.malariaAtlasHidden$list_points))), 1)
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
  #expect_true(inherits(available_countries_vec$country, "factor"))
  #expect_true(inherits(available_countries_vec$country_id, "factor"))
  #expect_true(inherits(available_countries_vec$continent, "factor"))
#})

#test_that("available_countries_stored_vec object is stored in hidden environment",{
  expect_equal(length(grep("Global_Dominant_Vector_Surveys", names(.malariaAtlasHidden$list_points))), 1)
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
  expect_equal(sort(names(available_rasters)),sort(c("dataset_id","version","raster_code","title","title_extended", "abstract","min_raster_year", "max_raster_year")))
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


#test_that("available_admin_stored object is stored in hidden environment",{
  expect_equal(length(names(.malariaAtlasHidden$list_shp$admin0)), 1)

  
  # Test that admin level works.
  
  dd1 <- listShp(printed = FALSE, admin_level = 'admin0')
  expect_true(all(dd1$admn_level == 0))
  
  returned_rows1 <- nrow(dd1)
  #stored_rows1 <- nrow(malariaAtlas:::.malariaAtlasHidden$available_admin_stored)
  
  dd2 <- listShp(printed = FALSE, admin_level = 'admin1')
  expect_true(all(dd2$admn_level == 1))
  expect_equal(length(names(.malariaAtlasHidden$list_shp$admin1)), 1)
  
  returned_rows2 <- nrow(dd2)
  #stored_rows2 <- nrow(malariaAtlas:::.malariaAtlasHidden$available_admin_stored)
  
  expect_true(returned_rows1 < returned_rows2)
  #expect_true(returned_rows1 == stored_rows1)
  
  #expect_true(stored_rows2 == (returned_rows1 + returned_rows2))
  
  dd3 <- listShp(printed = FALSE, admin_level = c('admin1', 'admin0'))
  expect_true(nrow(dd3) == returned_rows1 + returned_rows2)
  
})


context("Test listData wrapper.")

test_that('All options for list data work.', {
    
  skip_on_cran()
  d1 <- listData(datatype = 'pr points', printed = FALSE)
  d2 <- listData(datatype = 'vector points', printed = FALSE)
  d3 <- listData(datatype = 'raster', printed = FALSE)
  d4 <- listData(datatype = 'shape', printed = FALSE)
  expect_true(inherits(d1, 'data.frame'))
  expect_true(inherits(d2, 'data.frame'))
  expect_true(inherits(d3, 'data.frame'))
  expect_true(inherits(d4, 'data.frame'))
  
  expect_error(
    de <- listData(datatype = 'awdd'),
    regexp = 'Please choose one of'
  )
    
  # Defaults to NULL. Maybe this is not a useful default but not terrible
  expect_error(
    de <- listData()
  )
  
  # Check that dots work
  d5 <- listData(datatype = 'shape', printed = FALSE, admin_level = 'admin0')

  expect_true(inherits(d5, 'data.frame'))
  expect_true(nrow(d4) > nrow(d5))
  
            
  }
)



