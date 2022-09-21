# Requires
# devtools::install_github("Sage-Bionetworks/synapseusagereports")

# This is a wrapper building on synapseusagereports to download NF-relevant data,
# which saves data for each project as a separate .csv within folders
# organized by report type.

library(synapseusagereports)
library(dbplyr)
library(dplyr)
library(nfportalutils)

syn_login()

# See synapseusagereports for example config file
get_data_by_funding_agency <- function(config_file, fundingAgency = "NTAP", all = TRUE) {
  
  config <- yaml::yaml.load_file(config_file)
  con <- DBI::dbConnect(RMySQL::MySQL(),
                      port = config$port,
                      user = config$username,
                      password = config$password,
                      host = config$host,
                      dbname = config$db)
  
  cat("Connection details...\n")
  dbplyr::db_connection_describe(con) # dbListTables(con)

  query_types <- c("filedownloadrecord", "download")
  end_date <- Sys.Date()
  start_date <- Sys.Date() - 180
  
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
        report <- report_data_query(con, pid, query_type, start_date, end_date)
        write.csv(report, glue::glue("{query_type}/{pid}.csv"), row.names = F)
      })
    }
    
  }
}

#' There are two ways to get the history of data status changes for studies:
#' 1) Download the weekly snapshots of the portal study table.
#' 2) Look up the permissions history of the `Raw Data` folder (this is not possible).
#' Both are overly complicated workarounds because data status changes are not recorded
#' with dates in an official manner. Because the second is not possible anyway,
#' this implements the first to create a data object representing transition states 
#' for the specific funder (default: NTAP) projects
#' Once there are better data/methods for data status changes, this can be deprecated.
#' @param vRange Start and end of versions to look at, e.g. version #1 to version #10.
query_data_status_snapshots <- function(vRange,
                                        fundingAgency = "NTAP", 
                                        ref = "syn16787123") {
  
  versions <- vRange[1]:vRange[2]
  vlist <- c()
  for(v in versions) {
    x <- .syn$get(ref, version = v)
    vdate <- as.character(as.Date(x$properties$modifiedOn)) # Do not use 'createdOn'
    vlist <- c(vlist, vdate)
  }
  records <- list()
  for(v in versions) {
    res <- .syn$tableQuery(glue::glue("SELECT studyId,dataStatus FROM {ref}.{v} WHERE fundingAgency has ('{fundingAgency}')"),
                           includeRowIdAndRowVersion = F)
    res <- res$asDataFrame()
    records <- append(records, list(res))
  }
  
  # Rename dataStatus using the snapshot date and merge into table
  for(i in seq_along(records)) {
    records[[i]] <- as.data.table(records[[i]])
    records[[i]] <- setnames(records[[i]], old = "dataStatus", new = vlist[i])
  }
  data_status <- Reduce(function(x, y) merge(x, y, by = "studyId", all = TRUE), records)
  
  # Clean up data_status -- project can be removed from the funder list so changes,
  # e.g. NTAP says this is not an NTAP project but a CTF project
  data_status <- data_status[!is.na(get(vdate)), ]
  
  # Fill in NA as "Pre-Synapse"
  for(col in names(data_status)[-1]) {
    data_status[[col]] <- fifelse(is.na(data_status[[col]]), "Pre-Synapse", data_status[[col]])
  }
  return(data_status)
}

