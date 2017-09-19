test_coverage <- function(path){
  
  coverage_obj <- package_coverage(path = path, type = "tests")
  coverage_percent <- percent_coverage(coverage_obj)
  
  if(coverage_percent<30){
    stop("Code coverage less than 30%")
  }else{
    message("Code coverage is greater than 30%.")
  }
}

test_coverage(path = ".")
