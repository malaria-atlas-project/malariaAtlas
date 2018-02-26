# isAvailable() tests

context("Using isAvailable to check whether there are PR points for specified locations in the MAP database")


# specify the example sets that I want to be available to test the returned data frame


test_that("correct error messages are returned for various combinations of countries", {
#one right
  expect_message(isAvailable(country = "Madagascar"), "PR points are available for Madagascar")
#one right, one wrong
  expect_message(isAvailable(country = c("Madagascar","Australia")), "PR points are available for Madagascar")
  expect_warning(isAvailable(country = c("Madagascar","Australia")), "Data not found for 'Australia', use listPoints()")
#one right, one mispelled
  expect_message(isAvailable(country = c("Madagascar","Ngeria")), "PR points are available for Madagascar")
  expect_warning(isAvailable(country = c("Madagascar","Ngeria")), "Data not found for 'Ngeria', did you mean Nigeria")
#one right, one wrong, one mispelled
  expect_message(isAvailable(country = c("Madagascar","Australia","Ngeria")), "PR points are available for Madagascar")
  expect_warning(isAvailable(country = c("Madagascar","Australia","Ngeria")), "Data not found for 'Australia', use listPoints()")
  expect_warning(isAvailable(country = c("Madagascar","Australia","Ngeria")), "Data not found for 'Ngeria', did you mean Nigeria")
#one wrong
  expect_error(isAvailable(country = "Australia"), "Specified location not found, see below comments:")
  expect_error(isAvailable(country = "Australia"), "Data not found for 'Australia', use listPoints()")
#one mispelled
  expect_error(isAvailable(country = "Ngeria"), "Specified location not found, see below comments:")
  expect_error(isAvailable(country = "Ngeria"), "Data not found for 'Ngeria', did you mean Nigeria")
#one wrong, one mispelled
  expect_error(isAvailable(country = c("Australia","Ngeria")), "Specified location not found, see below comments:")
  expect_error(isAvailable(country = c("Australia","Ngeria")), "Data not found for 'Australia', use listPoints()")
  expect_error(isAvailable(country = c("Australia","Ngeria")), "Data not found for 'Ngeria', did you mean Nigeria")
#nonsense
  expect_error(isAvailable(country = "XfUEC43"), "Specified location not found, see below comments:")
  expect_error(isAvailable(country = "XfUEC43"), "Data not found for 'Xfuec43', use listPoints()")

  })

test_that("isAvailable returnes the proper data frame if full_results is specified", {
  #available column contains the right things
  #not_available column contains the right things
  #possible match column contains the right things


})

