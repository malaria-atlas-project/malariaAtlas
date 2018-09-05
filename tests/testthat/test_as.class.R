
context("Test as.class functions")


test_that('as.pr.points function works.', {
  
  skip_on_cran()
  
  d <- as.pr.points(mtcars)
  expect_true(inherits(d, 'pr.points'))
  expect_true(inherits(d, 'data.frame'))
  
  d2 <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
  d3 <- dplyr::filter(d2, year_start > 2010)
  
  expect_false(inherits(d3, 'pr.points'))
  
  d4 <- as.pr.points(d3)
  expect_true(inherits(d4, 'pr.points'))
  expect_true(inherits(d4, 'data.frame'))
  
  
})


test_that('as.pr.points function works.', {
  
  skip_on_cran()
  
  d <- as.vectorpoints(mtcars)
  expect_true(inherits(d, 'vector.points'))
  expect_true(inherits(d, 'data.frame'))
  

})