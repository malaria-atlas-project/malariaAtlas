# isAvailable() tests

context("Using isAvailable to check whether there are PR and Vector points for specified locations in the MAP database")


# specify the example sets that I want to be available to test the returned data frame


test_that("correct error messages are returned for various combinations of countries and sourcedata", {
  
  skip_on_cran()
#one right
  expect_message(isAvailable(country = "Madagascar", sourcedata = "pr points"), "PR points are available for Madagascar")
  expect_message(isAvailable(country = "Myanmar", sourcedata = "vector points"), "Vector points are available for Myanmar")
#one right, one wrong
  expect_warnings_and_messages(
    isAvailable(country = c("Madagascar","Australia"), sourcedata = "pr points"),
    expected_messages = "PR points are available for Madagascar",
    expected_warnings = "Data not found for 'Australia', use listPRPointCountries()"
  )
  
  expect_warnings_and_messages(
    isAvailable(country = c("Brazil","Libya"), sourcedata = "vector points"),
    expected_messages = "Vector points are available for Brazil",
    expected_warnings = "Data not found for 'Libya', use listVecOccPointCountries()"
  )

#one right, one mispelled
  expect_warnings_and_messages(
    isAvailable(country = c("Madagascar","Ngeria"), sourcedata = "pr points"),
    expected_messages = "PR points are available for Madagascar",
    expected_warnings =  "Data not found for 'Ngeria', did you mean Nigeria"
  )
  
  expect_warnings_and_messages(
    isAvailable(country = c("Brazil","Ngeria"), sourcedata = "vector points"),
    expected_messages = "Vector points are available for Brazil",
    expected_warnings = "Data not found for 'Ngeria', did you mean Nigeria"
  )

#one right, one wrong, one mispelled
  expect_warnings_and_messages(
    isAvailable(country = c("Madagascar","Australia","Ngeria"), sourcedata = "pr points"),
    expected_messages = "PR points are available for Madagascar",
    expected_warnings = c(
      "Data not found for 'Australia', use listPRPointCountries()",
      "Data not found for 'Ngeria', did you mean Nigeria"
    )
  )
  
  expect_warnings_and_messages(
    isAvailable(country = c("Brazil","Libya","Ngeria"), sourcedata = "vector points"),
    expected_messages = "Vector points are available for Brazil",
    expected_warnings = c(
      "Data not found for 'Libya', use listVecOccPointCountries()",
      "Data not found for 'Ngeria', did you mean Nigeria"
    )
  )
  
#one wrong
  expect_message(isAvailable(country = "Australia", sourcedata = "pr points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = "Australia", sourcedata = "pr points"), "Data not found for 'Australia', use listPRPointCountries()")
  expect_message(isAvailable(country = "Libya", sourcedata = "vector points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = "Libya", sourcedata = "vector points"), "Data not found for 'Libya', use listVecOccPointCountries()")
#one mispelled
  expect_message(isAvailable(country = "Ngeria", sourcedata = "pr points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = "Ngeria", sourcedata = "pr points"), "Data not found for 'Ngeria', did you mean Nigeria")
  expect_message(isAvailable(country = "Ngeria", sourcedata = "vector points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = "Ngeria", sourcedata = "vector points"), "Data not found for 'Ngeria', did you mean Nigeria")
#one wrong, one mispelled
  expect_message(isAvailable(country = c("Australia","Ngeria"), sourcedata = "pr points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = c("Australia","Ngeria"), sourcedata = "pr points"), "Data not found for 'Australia', use listPRPointCountries()")
  expect_message(isAvailable(country = c("Australia","Ngeria"), sourcedata = "pr points"), "Data not found for 'Ngeria', did you mean Nigeria")
  expect_message(isAvailable(country = c("Libya","Ngeria"), sourcedata = "vector points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = c("Libya","Ngeria"), sourcedata = "vector points"), "Data not found for 'Libya', use listVecOccPointCountries()")
  expect_message(isAvailable(country = c("Libya","Ngeria"), sourcedata = "vector points"), "Data not found for 'Ngeria', did you mean Nigeria")
#nonsense
  expect_message(isAvailable(country = "XfUEC43", sourcedata = "pr points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = "XfUEC43", sourcedata = "pr points"), "Data not found for 'Xfuec43', use listPRPointCountries()")
  expect_message(isAvailable(country = "XfUEC43", sourcedata = "vector points"), "Specified location not found, see below comments:")
  expect_message(isAvailable(country = "XfUEC43", sourcedata = "vector points"), "Data not found for 'Xfuec43', use listVecOccPointCountries()")
  
  })


