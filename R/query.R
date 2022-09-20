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

