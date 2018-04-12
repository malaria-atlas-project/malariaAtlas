context('Test other autoplotting is working.')




test_that('Plotting works for shapes', {
#time varying range
skip_on_cran()

MDG_shp <- getShp(ISO = "MDG", admin_level = "both")
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

})


