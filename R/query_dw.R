#' Query wrapper to get data warehouse data
#'
#' Requires devtools::install_github("Sage-Bionetworks/synapseusagereports")
#' This is a wrapper building on synapseusagereports to download NF-relevant data,
#' which saves data for each project as a separate .csv within folders organized by report type.
#'
#' @param con Connection object. If not given, `config_file` should be given.
#' @param config_file YAML config file. See `synapseusagereports` package docs for example config file.
#' @param start_date The start data of the report period -- should be first day of some month.
#' @param end_date End date of report period, should be last day of the month six months from `start_date`.
#' @param fundingAgency An NF funding agency to query for.
#' @param data_status Character vector values for data status, defaults to all NF status values.
#' @param table Reference studies table or whichever table that has information on studies and funding agency.
#' @param save Whether to save a copy of study records to working directory.
#' @param disconnect Whether to disconnect after query. Default `TRUE`
#' @export
query_data_by_funding_agency <- function(con = NULL,
                                         config_file = NULL,
                                         start_date,
                                         end_date,
                                         fundingAgency = "NTAP",
                                         data_status = c("Available", "Partially Available", "Under Embargo", "None"),
                                         table = "syn16787123",
                                         save = TRUE,
                                         disconnect = TRUE) {

  if(is.null("con")) con <- connect_to_dw(config_file)

  query_types <- c("filedownloadrecord", "download")
  project_ids <- query_study_ids(fundingAgency, data_status, table, save)
  for(query_type in query_types) {
    message(glue::glue("Creating directory to store data for {query_type}"))
    dir.create(query_type)

    for (pid in project_ids) {
      try({
        report <- synapseusagereports::report_data_query(con, pid, query_type, start_date, end_date)
        utils::write.csv(report, glue::glue("{query_type}/{pid}.csv"), row.names = F)
      })
    }
  }
  message(glue::glue("Finished querying data at {Sys.time()}"))
  if(disconnect) DBI::dbDisconnect(con)
}

#' Helper for looking up studies
#'
#' Query studies by funding agency and data status.
#'
#' @inheritParams query_data_by_funding_agency
#' @export
query_study_ids <- function(fundingAgency,
                            data_status,
                            table,
                            save) {

    nfportalutils::.check_login()
    data_status <- glue::glue_collapse(glue::single_quote(data_status), sep = ",")
    message(glue::glue("Getting a list of all {fundingAgency} projects with specified statuses..."))
    study_records <- .syn$tableQuery(glue::glue("SELECT studyId,dataStatus FROM {table} WHERE fundingAgency has ('{fundingAgency}') AND dataStatus in ({data_status})"))
    study_records <- study_records$asDataFrame()
    if(!nrow(study_records)) stop("No study records found!")
    project_ids <- study_records$studyId
    if(save) utils::write.csv(study_records, file = glue::glue("study_records.csv"))
    return(project_ids)
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

