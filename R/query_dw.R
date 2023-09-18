#' Query wrapper to get data warehouse data
#'
#' Requires `devtools::install_github("Sage-Bionetworks/synapseusagereports")`.
#' This is a wrapper building on queries refined in synapseusagereports to download NF-relevant data;
#' for details, see [code](https://github.com/Sage-Bionetworks/synapseusagereports/blob/master/R/lib.R#L13).
#' Data is saved for each project as a separate `.csv` within folders organized by report type.
#'
#' @param con Connection object; use `connect_to_dw` to connect.
#' @param start_date Start date of the report range in YYYY-MM-DD format -- should be first day of some month, e.g. "2022-03-01".
#' @param end_date End date of report range, defaults to six months from `start_date`, e.g., "2022-09-01",
#' but pass in manually if using a different report interval (though can't exceed six months)
#' @param fundingAgency An NF funding agency to query for.
#' @param data_status Character vector values for data status, defaults to all NF status values.
#' @param table Reference studies table or whichever table that has information on studies and funding agency.
#' @param save Whether to save a copy of study records to working directory.
#' @param disconnect Whether to disconnect after query. Default `TRUE`.
#' @export
query_data_by_funding_agency <- function(con,
                                         start_date,
                                         end_date = NULL,
                                         fundingAgency = "NTAP",
                                         data_status = c("Available", "Partially Available", "Under Embargo", "None"),
                                         table = "syn16787123",
                                         save = TRUE,
                                         disconnect = TRUE) {

  if(is.null(end_date)) {
    end_date <- lubridate::ymd(start_date) %m+% months(6)
    message(glue::glue("Defaulting the end date to {end_date}!"))
  }
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

    data_status <- glue::glue_collapse(glue::single_quote(data_status), sep = ",")
    message(glue::glue("Getting a list of all {fundingAgency} projects with specified statuses..."))
    study_records <- synapser::synTableQuery(glue::glue("SELECT studyId,dataStatus FROM {table} WHERE fundingAgency has ('{fundingAgency}') AND dataStatus in ({data_status})"))
    study_records <- synapser::as.data.frame(study_records)
    if(!nrow(study_records)) stop("No study records found!")
    project_ids <- study_records$studyId
    if(save) utils::write.csv(study_records, file = glue::glue("study_records.csv"))
    return(project_ids)
}

#' Helper for establishing connection
#'
#' @param config_file YAML config storing db connection creds,
#' see [example](https://github.com/Sage-Bionetworks/synapseusagereports/blob/master/example-db-config.yml).
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

#' Query file snapshot for settings
#'
#' The intent is to give a general sense of what files are actually visible and
#' how easy they are to access (based on restrictions in place, which could of course slow down downloads/usage).
#' Implementation uses `NODE_SNAPSHOT`, which has snapshots files when they are created/modified.
#' This table is used to check the public/controlled/restricted flags:
#' - `IS_PUBLIC` : Can public see entity?
#' - `IS_CONTROLLED` : Is entity under Tier 3 access?
#' - `IS_RESTRICTED` : Is entity under Tier 2 access?
#'
#' More definitions...
#' - `Tier 1` : User agrees to a second EULA specific to certain data layers.
#' - `Tier 2` : (Tier 1) + User agrees to a second EULA specific to certain data layers.
#' - `Tier 3` : (Tier 1) + (Tier 2) + User access must be requested/approved through ACT.
#'
#' @inheritParams query_data_by_funding_agency
#' @param project_ids Vector of project ids without the "syn" prefix.
#' @param end_date Latest date to consider for file snapshots, corresponding to the report end date.
#' @export
query_file_snapshot <- function(con, end_date, project_ids) {

  project_ids <- glue::glue_collapse(project_ids, sep = ",")
  # Get the access settings on the latest snapshot of a file within the report period
  # Avoid counting files that become public *after* report period, so consider only up to {end_date}
  query <- glue::glue(
  'SELECT ID,DATE_FORMAT(from_unixtime(MAX(TIMESTAMP) / 1000), "%Y-%m-%d") AS DATE,PARENT_ID,IS_PUBLIC,IS_CONTROLLED,IS_RESTRICTED
  FROM NODE_SNAPSHOT
  WHERE NODE_TYPE = "file" AND TIMESTAMP < unix_timestamp("{end_date}")*1000 AND PROJECT_ID IN ({project_ids})
  GROUP BY ID')
  message(query)
  result <- dbGetQuery(con, query)
  result <- as.data.table(result)
  return(result)
}
