context('Test getShp')

test_that("getShp downloads the correct shapefiles and stores them",{
  skip_on_cran()
  
  #test getShp
  #test one country, admin0
  test_getshp_poly_0_1 <- getShp(ISO = "BDI", admin_level = "admin0")
  #test two countries, admin0
  test_getshp_poly_0_2 <- getShp(ISO = c("BDI","RWA"), admin_level = "admin0")
  #test one country, admin1
  test_getshp_poly_1_1 <- getShp(ISO = "BDI", admin_level = "admin1")
  #test two countries, admin1
  test_getshp_poly_1_2 <- getShp(ISO = c("BDI","RWA"), admin_level = "admin1")
  #test one country, admin0 & admin1
  test_getshp_poly_b_1 <- getShp(ISO = "BDI", admin_level = "all")
  #test two countries, admin0 & admin1
  test_getshp_poly_b_2 <- getShp(ISO = c("BDI","RWA"), admin_level = "all")
  
  # check class of returned polygons
  expect_true(inherits(test_getshp_poly_0_1, "sf"))
  expect_true(inherits(test_getshp_poly_0_2, "sf"))
  expect_true(inherits(test_getshp_poly_1_1, "sf"))
  expect_true(inherits(test_getshp_poly_1_2, "sf"))
  expect_true(inherits(test_getshp_poly_b_1, "sf"))
  expect_true(inherits(test_getshp_poly_b_2, "sf"))
  # check that the right countries' polygons are downloaded at the right admin_level
  expect_true(all(c("BDI_0") %in% unique(test_getshp_poly_0_1$country_level)))
  expect_true(all(c("BDI_0", "RWA_0") %in% unique(test_getshp_poly_0_2$country_level)))
  expect_true(all(c("BDI_1") %in% unique(test_getshp_poly_1_1$country_level)))
  expect_true(all(c("BDI_1", "RWA_1") %in% unique(test_getshp_poly_1_2$country_level)))
  expect_true(all(c("BDI_1", "BDI_0") %in% unique(test_getshp_poly_b_1$country_level)))
  expect_true(all(c("BDI_1","BDI_0", "RWA_1","RWA_0") %in% unique(test_getshp_poly_b_2$country_level)))
  expect_false(all(c("BDI_1") %in% unique(test_getshp_poly_0_1$country_level)))
  expect_false(all(c("BDI_1", "RWA_1") %in% unique(test_getshp_poly_0_2$country_level)))
  expect_false(all(c("BDI_0") %in% unique(test_getshp_poly_1_1$country_level)))
  expect_false(all(c("BDI_0", "RWA_0") %in% unique(test_getshp_poly_1_2$country_level)))
  expect_false(all(c("RWA_1", "RWA_0") %in% unique(test_getshp_poly_b_1$country_level)))
  })


#test bbox
#test lat, long
#test ISO = "ALL"

test_that('Repeated getSHP works. That getting shapes from .malariaAtlasHidden does not break.', {
  skip_on_cran()
  
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  }
)

test_that("getShp works with ISO='all' argument", {
    skip_on_cran()
  
    shp <- malariaAtlas::getShp(ISO = "ALL")
    expect_true(inherits(shp, "sf"))
  }
)


test_that('Broken arguments get handled nicely.', {
  skip_on_cran()
  
  expect_error(DRC <- getShp(ISO = "DRC"), "One or more ISO codes are wrong")

  expect_error(DRC <- getShp(ISO = c("DRC", "BTN")), "One or more ISO codes are wrong")


  expect_error(x1 <- getShp(country = "hshshs"), "One or more country names are wrong")

  expect_error(x2 <- getShp(country = c("hshshs", "China")), "One or more country names are wrong")
})




