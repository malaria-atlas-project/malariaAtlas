## Run devtools check and see whether or not it returns any errors

install.packages("devtools", repos = "https://cran.ma.imperial.ac.uk/")

library(devtools)

devtools::install_deps()

library(ggplot2)

test_results <- devtools::check()

if(length(test_results$errors)>0){
  stop(paste("Pipeline failed due to the following errors:\n",paste(test_results$errors, collapse = "\n"), sep = ""))
}

