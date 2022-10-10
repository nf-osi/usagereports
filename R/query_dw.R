#' Query wrapper to get data warehouse data
#'
#' Requires devtools::install_github("Sage-Bionetworks/synapseusagereports")
#' This is a wrapper building on synapseusagereports to download NF-relevant data,
#' which saves data for each project as a separate .csv within folders organized by report type.
#'
#' @param con Connection object. If not given, `config_file` should be given.
#' @param config_file YAML config file. See `synapseusagereports` package docs for example config file.
#' @param fundingAgency An NF funding agency to query for.
#' @param all Download for all projects associated with `fundingAgency`.
#' @param start_date The start data of the report period -- should be first day of some month.
#' @param end_date End date of report period, should be last day of the month six months from `start_date`.
#' @export
query_data_by_funding_agency <- function(con = NULL,
                                         config_file = NULL,
                                         start_date,
                                         end_date,
                                         fundingAgency = "NTAP",
                                         all = TRUE) {

  if(!exists("con")) con <- connect_to_dw(config_file)

  query_types <- c("filedownloadrecord", "download")

  if(all) {
   FA <- .syn$tableQuery("SELECT studyId,dataStatus FROM syn16787123 WHERE fundingAgency has ('{fundingAgency}')")
  } else {
   FA <- .syn$tableQuery("SELECT studyId,dataStatus FROM syn16787123 WHERE fundingAgency has ('{fundingAgency}') AND dataStatus in ('Available', 'Partially Available')")
  }
  FA <- FA$asDataFrame()
  project_ids <- FA$studyId
  write.csv(FA, glue::glue("{FA}.csv"))

  for(query_type in query_types) {
    dir.create(query_type)

    for (pid in project_ids) {
      try({
        report <- synapseusagereports::report_data_query(con, pid, query_type, start_date, end_date)
        write.csv(report, glue::glue("{query_type}/{pid}.csv"), row.names = F)
      })
    }

  }
}

#' Helper for establishing connection
#'
#' @inheritParams query_data_by_funding_agency
#'
#' @return Connection object.
#' @export
connect_to_dw <- function(config_file) {

  config <- yaml::yaml.load_file(config_file)
  con <- DBI::dbConnect(RMySQL::MySQL(),
                        port = config$port,
                        user = config$username,
                        password = config$password,
                        host = config$host,
                        dbname = config$db)

  cat("Connection details...\n")
  message(dbplyr::db_connection_describe(con))
  cat("Tables...\n")
  cat(DBI::dbListTables(con), sep = "\n")
  return(con)
}

