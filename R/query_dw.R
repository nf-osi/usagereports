#' Generate query to get users and downloads parameterized by project ids and date range
#'
#' This just helps generate a useful query, which can be submitted through whichever preferred interface,
#' e.g. Rstudio connection or the Snowflake Worksheets UI.
#' The result is a table with user and file download records for the projects specified.
#' It is a good precursor for deriving many other summaries of interest without making more calls,
#' e.g. from we can get total unique users, distribution of downloads (to identify "power users"),
#' the network of projects and users via downloads as edges, etc.
#'
#' If you wish to go to just one of the summaries directly, then it's best to use a different query.
#'
#' @param start_date Start date for report window in format "YYYY-MM-DD".
#' @param end_date End date for report window in format "YYYY-MM-DD".
#' @param ids Character vector of project ids, e.g. `c("syn124", "syn999")`.
#' @export
query_filedownload_scoped <- function(start_date, end_date, ids) {

  ids <- gsub("syn", "", ids)
  ids <- glue::glue_collapse(shQuote(ids, "sh"), sep = ",")
  query <- glue::glue("SELECT distinct file_handle_id,user_id,record_date,project_id FROM filedownload WHERE record_date between date('{{start_date}}') and date('{{end_date}}') and PROJECT_ID in ({{ids}})",
                      .open = "{{", .close = "}}")
  query
}
