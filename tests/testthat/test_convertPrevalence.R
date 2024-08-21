context('Test convertPrevalence.')

test_that('convertPrevalence works for all reasonable inputs', {
    
  pr <- seq(0, 1, 0.2)
  min_in <- c(1, 5, 10)
  max_in <- c(6, 15, 20)
  min_out <- c(2, 6, 9)
  max_out <- c(5, 13, 16)
  
  all_combs <- expand.grid(pr, min_in, max_in, min_out, max_out)
  names(all_combs) <- c('pr', 'min_in', 'max_in', 'min_out', 'max_out')
  
  all_combs <- all_combs[all_combs$min_in < all_combs$max_in & 
                         all_combs$min_out < all_combs$max_out, ]
  
  pr_standardised <- convertPrevalence(all_combs$pr, 
                                       all_combs$min_in, 
                                       all_combs$max_in,
                                       all_combs$min_out, 
                                       all_combs$max_out)
  
  expect_true(all(pr_standardised <= 1))
  expect_true(all(pr_standardised >= 0))
})



test_that('convertPrevalence works with gething parameters', {
  pr <- seq(0, 1, 0.2)
  min_in <- c(1, 5, 10)
  max_in <- c(6, 15, 20)
  min_out <- c(2, 6, 9)
  max_out <- c(5, 13, 16)
  
  all_combs <- expand.grid(pr, min_in, max_in, min_out, max_out)
  names(all_combs) <- c('pr', 'min_in', 'max_in', 'min_out', 'max_out')
  
  all_combs <- all_combs[all_combs$min_in < all_combs$max_in & 
                           all_combs$min_out < all_combs$max_out, ]
  
  pr_standardised <- convertPrevalence(all_combs$pr, 
                                       all_combs$min_in, 
                                       all_combs$max_in,
                                       all_combs$min_out, 
                                       all_combs$max_out,
                                       parameters = 'Pv_Gething2012')
  
  
  expect_true(all(pr_standardised <= 1))
  expect_true(all(pr_standardised >= 0))
})




test_that('NAs get handled right', {
  set.seed(1)
  pr <- runif(20, 0.1, 0.15)
  min_in <- sample(1:5, 20, replace = TRUE)
  max_in <- rep(8, 20)
  min_out <- rep(2, 20)
  max_out <- rep(10, 20)
  
  pr[2] <- NA
  min_in[3] <- NA
  max_in[4] <- NA

  pr_standardised <- convertPrevalence(pr, min_in, max_in,
                                       min_out, max_out)

  expect_true(all(is.na(pr_standardised[2:4])))
  expect_true(all(!is.na(pr_standardised[c(1, 5:20)])))
  

  expect_error(convertPrevalence(0.1, 2, 5, NA, 10))
  expect_error(convertPrevalence(0.1, 2, 5, 2, NA))
})
