
#' Query available files within the first and last month of report period
#'
#' The first file snapshot scope (first month of report period) includes unique files for the projects listed in `start_id_file`.
#' The second file snapshot scope (last month of report period) includes unique files for projects listed in `end_id_file`.
#' Usually, there are more projects in the `end_id_file` because of new project releases during the report period;
#' and unless something is wrong, all projects in `start` should be in `end` (there should be no "un-release" phenomenon).
#' For each snapshot, we filter for "available" files, which are either public or controlled access, and calculate a simple delta.
#' @inheritParams query_data_by_funding_agency
#' @param start_id_file Text files of all study ids with released data at start of report period.
#' @param end_id_file Text files of all study ids with released data at end of report period.
query_file_snapshot <- function(con,
                                config_file = NULL,
                                start_date,
                                end_date,
                                start_id_file,
                                end_id_file) {

  PROJECT_ID <- NULL

  if(!exists("con")) con <- connect_to_dw(config_file)

  start_ids <- as.numeric(gsub("syn", "", readLines(start_id_file)))
  end_ids <- as.numeric(gsub("syn", "", readLines(end_id_file)))

  build_query <- function(ids, index_date, add_filter = "AND (IS_PUBLIC = 1 OR IS_CONTROLLED = 1)") {

    ids_list <- glue::glue_collapse(ids, sep = ",")

    # Construct timestamp ranges
    start_ts <- as.numeric(as.POSIXct(lubridate::ymd(index_date))) * 1000
    end_ts <- as.numeric(as.POSIXct(lubridate::`%m+%`(lubridate::ymd(index_date), months(1)))) * 1000
    # DATE_FORMAT(from_unixtime(TIMESTAMP / 1000), "%Y-%m-%d") AS DATE
    query <- glue::glue('SELECT ID,DATE_FORMAT(from_unixtime(TIMESTAMP / 1000), "%Y-%m-%d") AS DATE,PROJECT_ID,FILE_HANDLE_ID,NAME,IS_PUBLIC,IS_CONTROLLED,IS_RESTRICTED
                        FROM NODE_SNAPSHOT
                        WHERE TIMESTAMP > {start_ts} AND TIMESTAMP < {end_ts} AND NODE_TYPE = "file" AND PROJECT_ID IN ({ids_list}) {add_filter} GROUP BY ID') #
    return(query)
  }

  options(scipen = 999)
  start_query <- build_query(start_ids, start_date)
  message(start_query)
  start_data <- DBI::dbGetQuery(con, start_query)
  start_data <- as.data.table(start_data)
  start_avail <- start_data[, .N, by = PROJECT_ID]
  fwrite(start_avail, "start_available_files.csv")

  end_query <-  build_query(end_ids, end_date)
  message(end_query)
  end_data <- DBI::dbGetQuery(con, end_query)
  end_data <- as.data.table(end_data)
  end_avail <- end_data[, .N, by = PROJECT_ID]

  fwrite(end_avail, "end_available_files.csv")

  return(end_avail)
}

#' Query data status snapshots
#'
#' There are two ways to get the history of data status changes for studies:
#' 1) Download the weekly snapshots of the portal study table.
#' 2) Look up the permissions history of the `Raw Data` folder (this is not possible).
#' Both are overly complicated workarounds because data status changes are not recorded
#' with dates in an official manner. Because the second is not possible anyway,
#' this implements the first to create a data object representing transition states
#' for the specific funder (default: NTAP) projects
#' Once there are better data/methods for data status changes, this can be deprecated.
#'
#' @param vRange Start and end of versions to look at, e.g. version #1 to version #10.
#' @param ref Synapse table to use for query.
#' @inheritParams query_data_by_funding_agency
#' @export
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

#' Query annotations
#'
#' Query annotations for files to faciliate assay, etc. breakdown
#'
#' @param file_ids Vector of numeric file ids (without "syn" prefix).
#' @param fileview Fileview id, which may vary for the portal. Defaults to NF's `Portal - Files`.
#' If `NULL`, for when the fileview does not exist or contain the files in scope,
#' this will use alternative method of `get_annotations`, which will be slower but retrieves most up-to-date data,
#' which is not guaranteed with a fileview.
#' @param attributes Vector of relevant metadata attributes for breakdown, which may vary for the portal.
#' Defaults to NF core attributes.
query_annotation <- function(file_ids,
                             fileview = "syn16858331",
                             attributes = c("resourceType", "assay", "dataType")) {

  if(is.null(fileview)) {
    meta <- list()
    for(i in file_ids) {
      dict <- .syn$get_annotations(i)
      metaset <- lapply(attributes, function(x) tryCatch(dict[[x]], error = function(e) NA_character_))
      meta[[paste0("syn", i)]] <- metaset
    }
    meta <- rbindlist(meta, idcol = "id")
    setnames(meta, c("id", attributes))
  } else {
    ids_list <- glue::glue_collapse(file_ids, sep = ",")
    attributes <- glue::glue_collapse(attributes, sep = ",")
    meta <- .syn$tableQuery(glue::glue("SELECT id,{attributes} FROM {fileview} WHERE id in ({ids_list})"))
    meta <- as.data.table(meta$asDataFrame())
  }
  return(meta)
}
