test_that("get_workspace_and_version_from_coverage_id works", {
  malaria_wrkspace_version <- get_workspace_and_version_from_coverage_id('Malaria__202206_Global_Pf_Mortality_Count')
  explorer_wrkspace_version <- get_workspace_and_version_from_coverage_id('Explorer__2010_Secondary-Dominant_Vector_Species_Africa')
  
  expect_equal(malaria_wrkspace_version$workspace, 'Malaria')
  expect_equal(malaria_wrkspace_version$version, '202206')
  
  expect_equal(explorer_wrkspace_version$workspace, 'Explorer')
  expect_equal(explorer_wrkspace_version$version, '2010')
})


test_that("get_workspace_and_version_from_wfs_feature_type_id works", {
  malaria_wrkspace_version <- get_workspace_and_version_from_wfs_feature_type_id('Malaria:202206_Global_Pf_Parasite_Rate_Surveys')
  admin_wrkspace_version <- get_workspace_and_version_from_wfs_feature_type_id('Admin_Units:202206_Global_Admin_0')
  
  expect_equal(malaria_wrkspace_version$workspace, 'Malaria')
  expect_equal(malaria_wrkspace_version$version, '202206')
  
  expect_equal(admin_wrkspace_version$workspace, 'Admin_Units')
  expect_equal(admin_wrkspace_version$version, '202206')
})

test_that("get_name_from_wfs_feature_type_id works", {
  malaria_name <- get_name_from_wfs_feature_type_id('Malaria:202206_Global_Pf_Parasite_Rate_Surveys')
  vector_name <- get_name_from_wfs_feature_type_id('Vector_Occurrence:201201_Global_Dominant_Vector_Surveys')
  
  expect_equal(malaria_name, 'Global_Pf_Parasite_Rate_Surveys')
  expect_equal(vector_name, 'Global_Dominant_Vector_Surveys')
})

test_that("getDatasetIdForAdminDataGivenAdminLevelAndVersion works", {
  admin0_dataset <- getDatasetIdForAdminDataGivenAdminLevelAndVersion(0, '202206')
  admin1_dataset <- getDatasetIdForAdminDataGivenAdminLevelAndVersion('1', '202206')
  
  expect_equal(admin0_dataset, 'Admin_Units:202206_Global_Admin_0')
  expect_equal(admin1_dataset, 'Admin_Units:202206_Global_Admin_1')
})

test_that("getDatasetIdForAdminDataGivenAdminLevelAndVersion works", {
  admin0_dataset <- getDatasetIdForAdminDataGivenAdminLevelAndVersion(0, '202206')
  admin1_dataset <- getDatasetIdForAdminDataGivenAdminLevelAndVersion('1', '202206')
  
  expect_equal(admin0_dataset, 'Admin_Units:202206_Global_Admin_0')
  expect_equal(admin1_dataset, 'Admin_Units:202206_Global_Admin_1')
})

test_that("build_cql_bbox_filter works", {
  valid_bbox <- rbind(c(-2.460181, 13.581921), c(-3.867188, 34.277344))
  expect_equal(build_cql_bbox_filter(valid_bbox), "BBOX(geom,-2.460181,-3.867188,13.581921,34.277344,'EPSG:4326')")
})

test_that("build_bbox_filter works", {
  valid_bbox <- rbind(c(-2.460181, 13.581921), c(-3.867188, 34.277344))
  expect_equal(build_bbox_filter(valid_bbox), "-2.460181,-3.867188,13.581921,34.277344,EPSG:4326")
})

test_that("build_cql_filter works", {
  cql_filter_one_continent <- build_cql_filter('continent', 'Africa')
  cql_filter_multiple_countries <- build_cql_filter('country', c('Nigeria', 'Sudan', 'Ethiopia'))
  
  expect_equal(cql_filter_one_continent, "continent IN ('Africa')")
  expect_equal(cql_filter_multiple_countries, "country IN ('Nigeria', 'Sudan', 'Ethiopia')")
})

test_that("build_cql_time_filter works", {
  expect_equal(
    build_cql_time_filter(
      start_date = as.Date('2010-01-01'),
      end_date = as.Date('2012-01-01')
    ),
    "time_start AFTER 2009-12-31T00:00:00Z AND time_end BEFORE 2012-01-01T00:00:00Z"
  )
})

test_that("combine_cql_filters works", {
  one_filter <- combine_cql_filters(list('time_start AFTER 2009-12-31T00:00:00Z'))
  multiple_filters <- combine_cql_filters(list('time_start AFTER 2009-12-31T00:00:00Z', "country IN ('Nigeria', 'Sudan', 'Ethiopia')", "continent IN ('Africa')"))
  
  expect_equal(one_filter, 'time_start AFTER 2009-12-31T00:00:00Z')
  expect_equal(multiple_filters, "time_start AFTER 2009-12-31T00:00:00Z AND country IN ('Nigeria', 'Sudan', 'Ethiopia') AND continent IN ('Africa')")
})

test_that("getRasterDatasetIdFromSurface works with one match", {
  rasterList <- data.frame (dataset_id  = c('Explorer__2019_Global_PfPR', 'Explorer__2020_Global_Pv_Cases', 'Explorer__2019_Global_Pv_Incidence'),
                        title = c('Plasmodium falciparum PR2 - 10', 'Plasmodium vivax Cases', 'Plasmodium vivax Incidence'),
                        version = c('2019', '2020', '2019')
  )
  
  expect_equal(getRasterDatasetIdFromSurface(rasterList, 'Plasmodium vivax Incidence'), 'Explorer__2019_Global_Pv_Incidence')
})

test_that("getRasterDatasetIdFromSurface works with multiple matches", {
  rasterList <- data.frame (dataset_id  = c('Explorer__2019_Global_PfPR', 'Explorer__2019_Global_Pv_Cases', 'Explorer__2020_Global_Pv_Cases'),
                            title = c('Plasmodium falciparum PR2 - 10', 'Plasmodium vivax Cases', 'Plasmodium vivax Cases'),
                            version = c('2019', '2019', '2020')
  )
  
  expect_equal(getRasterDatasetIdFromSurface(rasterList, 'Plasmodium vivax Cases'), 'Explorer__2020_Global_Pv_Cases')
})
