
#skip_if_no_auth <- function(config_path = "rdhs.json") {
  
#  testthat::skip_on_cran()
  
#  have_cred_path <- file.exists(config_path)
#  if (!have_cred_path) {
#    skip("No authentication available")
#  }
  
#  skip_if_slow_API()
  
#}

# The function fillDHScoordinates needs verification
#   as there's no way around this, I can't see how to test this
#   function yet.

#context("Test fillDHScoordinates")

#test_that("data is downloaded as a data.frame", {
  
#  skip_if_no_auth()
#  pf <- getPR(country = "all", species = "Pf")
  
#  missing <- nrow(pf %>% filter(is.na(positive)))
  
#  expect_error(
#    pf2 <- fillDHSCoordinates(pf),
#    NA
#  )
#  missing2 <- nrow(pf2 %>% filter(is.na(positive)))
  
#  expect_that(missing > missing2)
    
#})


                           
                                                      
                           
