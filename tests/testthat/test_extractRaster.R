
context('Test extract raster')

test_that('Extract raster basics works', {
    
  skip_on_cran()
  d <- data.frame(x = c(4, 8), y = c(13, 9))
  data <- extractRaster(d,
                        surface = 'Plasmodium falciparum PR2-10',
                        year = 2015)
  
  expect_true(inherits(d, 'data.frame'))
  expect_true(all(d$value < 1 & d$value > 0))
})




