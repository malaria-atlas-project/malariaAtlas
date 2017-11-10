
temp_foldername <- stringi::stri_rand_strings(1, 10)

body = paste('{"name":','"',paste(temp_foldername),'"}',sep = "")
body = '{"name":"R7Uw26vvqv"}'

library(httr)

r <- httr::POST("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers",
                body = '{"name":"R7Uw26vvqv"}',
                add_headers("content-type" = "application/json;charset=UTF-8"))
content(r)

r$status_code

x <- head(getPR(ISO = "MDG", species = "pf"))

write.csv(x, file = "J:/extraction_api_test.csv")


r2 <- POST("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers/R7Uw26vvqv/upload",
        body = list(data = upload_file("J:/extraction_api_test.csv", "text/csv")))

content(r2)


r3 <- GET("http://map-prod3.ndph.ox.ac.uk/explorer-api/ExtractLayerValues?container=R7Uw26vvqv&endYear=2015&file=extraction_api_test.csv&raster=africa-pr-2000-2015&startYear=2000")

content(r3)

download.file("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers/R7Uw26vvqv/download/analysis_extraction_api_test.csv", "J:/test_download_extraction_api_test.csv", mode = "wb")

x2 <- read.csv("J:/test_download_extraction_api_test.csv")

r4 <- DELETE("http://map-prod3.ndph.ox.ac.uk/explorer-api/containers/R7Uw26vvqv")

content(r4)
