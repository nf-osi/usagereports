# Reference resources:
# - https://developers.google.com/analytics/devguides/reporting/data/v1/api-schema#dimensions
# - https://developers.google.com/analytics/devguides/reporting/data/v1/api-schema#metrics

#' Query project stats with GA4
#'
#' Convenience wrapper to query for selected project stats: pageviews and users.
#' Result is a list of tables matching number of projects; each table breaks down the stats for the pages (wiki, files, etc.) of that project.
#'
#' Make sure already authenticated with `googleAnalyticsR::ga_auth()`.
#'
#' @param projects Character vector of one or more project syn ids.
#' @param date_range Start and end date.
#' @param ga_property_id Google Analytics property id.
#' @import googleAnalyticsR
#' @export
query_ga_project_stats <- function(projects,
                                 date_range,
                                 ga_property_id = 311611973) {

  project <- pagePath <- NULL # this is just to appease CMD check

  pstats <- list()
  for(p in projects) {

    project_filter <- ga_data_filter(pageTitle %contains% p)

    pstats[[p]] <- ga_data(ga_property_id,
                          date_range = date_range,
                          metrics = c("screenPageViews", "totalUsers"),
                          dimensions = c("pageTitle"),
                          dim_filters = project_filter)
  }

  return(pstats)
}
