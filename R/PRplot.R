#fiddling 

class(pr_data) <- c("pr.points",class(pr_data))

autoplot.pr.points <- function(x, ...){
  ggmap(ggmap = get_stamenmap(bbox = c(min(pr_data$longitude[!is.na(pr_data$longitude)]), min(pr_data$latitude[!is.na(pr_data$latitude)]), max(pr_data$longitude[!is.na(pr_data$longitude)]), max(pr_data$latitude[!is.na(pr_data$latitude)])), zoom = 5, maptype = "toner")
  ) + geom_point(data = x, aes(x = longitude, y = latitude, colour = country_id), size = 0.5)
}


autoplot(pr_data)
