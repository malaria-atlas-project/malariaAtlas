expect_warnings_and_messages <- function(expr, expected_messages, expected_warnings, info=NULL) {
  warnings <- NULL
  messages <- NULL
  withCallingHandlers(expr, warning = function(w) {
    warnings <<- c(warnings, w$message)
    invokeRestart("muffleWarning")
  }, message = function(m) {
    messages <<- c(messages, m$message)
  })
  
  for (expected_warning in expected_warnings) {
    if (!is.null(warnings) && any(grepl(expected_warning, warnings))) {
      testthat::succeed(message=sprintf("Expected warning '%s' was produced.", expected_warning), info)
    } else {
      testthat::fail(message=sprintf("Expected warning '%s' was not produced.", expected_warning), info)
    }
  }
  
  for (expected_message in expected_messages) {
    if (!is.null(messages) && any(grepl(expected_message, messages))) {
      testthat::succeed(message=sprintf("Expected message '%s' was produced.", expected_message), info)
    } else {
      testthat::fail(message=sprintf("Expected message '%s' was not produced.", expected_message), info)
    }
  }
}