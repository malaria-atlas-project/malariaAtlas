# getShp() tests

# test downloadShp
test_URL <- utils::URLencode("https://map.ox.ac.uk/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&outputFormat=shape-zip&srsName=EPSG:4326&TypeName=mapadmin_0_2013&cql_filter=country_id%20IN%20(%27BDI%27)")

test_dlshp <- downloadShp(test_URL)

test_that("downloadShp downloads shapefiles and loads them correctly",{
  #check that Shp folder is deleted on exit
  expect_false("shp" %in% dir(tempdir()))
  # check that downloaded object is as expected
  expect_true(inherits(test_dlshp, "SpatialPolygonsDataFrame"))
  expect_true(unique(test_dlshp$country_id)=="BDI")
})

# test as.MAPshp
test_dlshp <- getShp(ISO = "BDI", admin_level = "admin0")
test_dlshp_df <- as.MAPshp(test_dlshp)

test_that("as.MAPshp works as expected",{
  expect_true(inherits(test_dlshp_df, "data.frame"))
  expect_true(inherits(test_dlshp_df, "MAPshp"))
  expect_true(unique(test_dlshp_df$country_id)=="BDI")
  #expect_equal(sort(names(test_dlshp_df)),sort(c("gid","id","long","lat","order","hole","piece","group","country_id","gaul_code","admn_level","parent_id","name", "country_level")))
})

#test getShp
#test one country, admin0
test_getshp_poly_0_1 <- getShp(ISO = "BDI", admin_level = "admin0", format = "spatialpolygon")
#test two countries, admin0
test_getshp_poly_0_2 <- getShp(ISO = c("BDI","RWA"), admin_level = "admin0", format = "spatialpolygon")
#test one country, admin1
test_getshp_poly_1_1 <- getShp(ISO = "BDI", admin_level = "admin1", format = "spatialpolygon")
#test two countries, admin1
test_getshp_poly_1_2 <- getShp(ISO = c("BDI","RWA"), admin_level = "admin1", format = "spatialpolygon")
#test one country, admin0 & admin1
test_getshp_poly_b_1 <- getShp(ISO = "BDI", admin_level = "both", format = "spatialpolygon")
#test two countries, admin0 & admin1
test_getshp_poly_b_2 <- getShp(ISO = c("BDI","RWA"), admin_level = "both", format = "spatialpolygon")

test_that("getShp downloads the correct shapefiles and stores them",{
  # check class of returned polygons
  expect_true(inherits(test_getshp_poly_0_1, "SpatialPolygonsDataFrame"))
  expect_true(inherits(test_getshp_poly_0_2, "SpatialPolygonsDataFrame"))
  expect_true(inherits(test_getshp_poly_1_1, "SpatialPolygonsDataFrame"))
  expect_true(inherits(test_getshp_poly_1_2, "SpatialPolygonsDataFrame"))
  expect_true(inherits(test_getshp_poly_b_1, "SpatialPolygonsDataFrame"))
  expect_true(inherits(test_getshp_poly_b_2, "SpatialPolygonsDataFrame"))
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
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
  }
)


