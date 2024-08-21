context('Test other autoplotting is working.')

test_that('Plotting works for shapes', {
#time varying range
  skip_on_cran()
  
  MDG_shp <- getShp(ISO = "MDG", admin_level = c("admin0", "admin1"))
  p1 <- autoplot(as.MAPshp(MDG_shp), map_title = 'a title')
  p2 <- autoplot(as.MAPshp(MDG_shp), map_title = 'a title', printed = T)
  p3 <- autoplot(as.MAPshp(MDG_shp), facet = TRUE)
  
  
  # Check facetting without multiple admin units doesn't break
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin1")
  p4 <- autoplot(as.MAPshp(MDG_shp), facet = TRUE)
  
  
  expect_true(inherits(p1, 'gg'))
  expect_true(inherits(p2, 'gg'))
  expect_true(inherits(p3, 'gg'))
  expect_true(inherits(p4, 'gg'))
})

test_that('Plotting works for PR', {
  #time varying range
  skip_on_cran()
  
  MDG_shp <- getShp(ISO = "MDG", admin_level = c("admin0", "admin1"))
  NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "Pf")
  p1 <- autoplot(NGA_CMR_PR)
  p2 <- autoplot(NGA_CMR_PR, hide_confidential = TRUE)
  p3 <- autoplot(NGA_CMR_PR, shp_df = MDG_shp)
  p3b <- autoplot(NGA_CMR_PR, printed = TRUE)
  
  expect_true(inherits(p1, 'gg'))
  expect_true(inherits(p2, 'gg'))
  expect_true(inherits(p3, 'gg'))
  expect_true(inherits(p3b, 'gg'))
  
  
  NGA_CMR_PR <- getPR(country = c("Nigeria", "Cameroon"), species = "both")
  p4 <- autoplot(NGA_CMR_PR)
  p5 <- autoplot(NGA_CMR_PR, facet = FALSE)
  expect_true(inherits(p4, 'gg'))
  expect_true(inherits(p5, 'gg'))
  
  
  p6 <- autoplot(NGA_CMR_PR, admin_level = 'admin1')
  expect_true(inherits(p6, 'gg'))
  p6 <- autoplot(NGA_CMR_PR, admin_level = 'both')
  expect_true(inherits(p6, 'gg'))
})

test_that('Plotting works for vectors', {
  #time varying range
  skip_on_cran()
  
  PAK_vec <- getVecOcc(country = "Pakistan")
  p1 <- autoplot(PAK_vec)
  p2 <- autoplot(PAK_vec, facet = TRUE)
  expect_true(inherits(p1, 'gg'))
  expect_true(inherits(p2, 'gg'))
  
  PAK_shp <- getShp(ISO = "PAK", admin_level = c("admin0", "admin1"))
  p3 <- autoplot(PAK_vec, shp_df = as.MAPshp(PAK_shp))
  expect_true(inherits(p3, 'gg'))
  
  # Check all admin levels
  p4 <- autoplot(PAK_vec, admin_level = 'admin1')
  p5 <- autoplot(PAK_vec, admin_level = 'both')
  expect_true(inherits(p4, 'gg'))
  expect_true(inherits(p5, 'gg'))
})
