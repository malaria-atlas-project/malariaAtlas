test_coverage <- function(path){
  
  coverage_obj <- covr::package_coverage(path = path, type = "tests")
  coverage_percent <- covr::percent_coverage(coverage_obj)
  
  message(paste("Code coverage: ", coverage_percent, "%", sep = ""))
  
  if(coverage_percent<30){
    stop("Code coverage less than 30%")
  }else{
    message("Code coverage is greater than 30%.")
  }
}

install.packages("covr")
test_coverage(path = ".")
