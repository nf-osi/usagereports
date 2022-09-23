# install.packages("googleAnalyticsR")
library(googleAnalyticsR)

#' Convenience wrapper for Google Analytics
#' 
#' Make sure already authenticated. Queries for pageviews and users.
#' @param projects List of project syn ids, used for pagepath filters.
#' @param date_range Start and end date. 
query_ga <- function(projects, 
                     date_range) {
  
  ga_id <- 57135211 # Use "Synapse" view id
  filter <- lapply(projects, function(x) dim_filter("pagePath", "BEGINS_WITH", paste0("/#!Synapse:", x)))
  filter_clause <- filter_clause_ga4(project_filters, "OR")
  
  pv <- google_analytics(ga_id,
                         date_range = date_range,
                         metrics = c("pageviews", "users"), 
                         dimensions = c("pagePath"),
                         dim_filters = filter_clause)
  return(pv)
}
