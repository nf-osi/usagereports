#' There are two ways to get the history of data status changes for studies:
#' 1) Download the weekly snapshots of the portal study table.
#' 2) Look up the permissions history of the `Raw Data` folder (this is not possible).
#' Both are overly complicated workarounds because data status changes are not recorded
#' with dates in an official manner. Because the second is not possible anyway,
#' this implements the first to create a data object representing transition states 
#' for the specific funder (default: NTAP) projects
#' Once there are better data/methods for data status changes, this can be deprecated.
to_data_status_transitions <- function(fundingAgency = "NTAP", 
                                       ref = "syn16787123", 
                                       vRange = c(14,41)) {
  
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
  longitudinal <- Reduce(function(x, y) merge(x, y, by = "studyId", all = TRUE), records)
  return(longitudinal)
}

#' This processes the `download` or `filedownloadrecord` output from `synapseusagereports` 
#' to create the main intermediate used by later downstream wrangling.
#' 1) Remove certain Sage users with defaults: 3421893 (nf-osi-service), 3413689 (Bruno), 3389310 (Jineta).
#' 2) Recode and anonymize user ids. 
#' 3) Join with project status to add information on whether the file was downloaded
#' when the project had been released.
#' @param data A `data.table` or path to file, which will be read in as a data.table
#' @param exclude List of ids to exclude.
to_filtered_user_stats <- function(data, exclude = c(3421893, 3413689, 3389310)) {

  fdata <- data[!userId %in% exclude]
  return(fdata)
}

