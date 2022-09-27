#' Convenience wrapper for Google Analytics
#'
#' Wrapper to query for pageviews and users.
#' Make sure already authenticated with `googleAnalyticsR::ga_auth()`.
#'
#' @param projects List of project syn ids, used for pagepath filters.
#' @param date_range Start and end date.
#' @import googleAnalyticsR
#' @export
query_ga <- function(projects,
                     date_range) {

  ga_id <- 57135211 # Use "Synapse" view id
  project_filters <- lapply(projects, function(x) dim_filter("pagePath", "BEGINS_WITH", paste0("/#!Synapse:", x)))
  filter_clause <- filter_clause_ga4(project_filters, "OR")

  pv <- google_analytics(ga_id,
                         date_range = date_range,
                         metrics = c("pageviews", "users"),
                         dimensions = c("pagePath"),
                         dim_filters = filter_clause)

  pv <- as.data.table(pv)
  # Parse pagePath to synIds
  pv[, synId := regmatches(pagePath, regexpr("syn[0-9]+", pagePath))]

  return(pv)
}
