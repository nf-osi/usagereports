#' Query internal data status snapshots
#'
#' This gets data status changes on a project tracking level.
#' See `query_file_snapshot` for a related function that tries to look at permissions on a file level,
#' though not really changes over time.
#' There are several ways to get the history of data status changes for studies:
#' 1) Download the weekly snapshots of the portal study table.
#' 2) Get the settings of different folders over time, maybe "Raw Data" as the primary folder.
#' This does the first, and the second can be done to see the actual correspondence at a later point,
#' e.g. if data status was changed to "Available" in our tracking, the "Raw Data" `IS_PUBLIC` flag
#' should change to TRUE around the same time, right? However, this gets complicated with partial data releases
#' where there's a whole bunch of other folders to consider...
#'
#' In any case, the project data status is represented as transition states, though for downstream summary
#' we don't show all time points, just "key" points where most of the changes actually happen,
#' because changes often happen in batch with many projects going from one state to another within the same month.
#' Transitions should be one-way, e.g. see `check_transition`, but it's possible to have weird stuff going on,
#' such as "Available" and then somehow moving back to "Under Embargo".
#' This is like a "revert release" that can mean either a data entry error,
#' or we released data that shouldn't have been released and had to make a correction.
#'
#' Once there are better data/methods for data status changes, this can be deprecated.
#'
#' @param vRange Start and end of versions to look at, e.g. version #1 to version #10.
#' @param fundingAgency Funding agency.
#' @param ref Synapse table to use for query.
#' @export
query_data_status_snapshots <- function(vRange,
                                        fundingAgency = "NTAP",
                                        ref = "syn16787123") {

  versions <- vRange[1]:vRange[2]
  vlist <- c()
  for(v in versions) {
    x <- synapser::synGet(ref, version = v)
    vdate <- as.character(as.Date(x$properties$modifiedOn)) # Do not use 'createdOn'
    vlist <- c(vlist, vdate)
  }
  records <- list()
  for(v in versions) {
    res <- synapser::synTableQuery(glue::glue("SELECT studyId,dataStatus FROM {ref}.{v} WHERE fundingAgency has ('{fundingAgency}')"),
                                   includeRowIdAndRowVersion = F)
    res <- synapser::as.data.frame(res)
    records <- append(records, list(res))
  }

  # Rename dataStatus using the snapshot date and merge into table
  for(i in seq_along(records)) {
    records[[i]] <- as.data.table(records[[i]])
    records[[i]] <- setnames(records[[i]], old = "dataStatus", new = vlist[i])
  }
  data_status <- Reduce(function(x, y) merge(x, y, by = "studyId", all = TRUE), records)

  # Clean up data_status -- project can be removed from the funder list due to changes,
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
#' @export
query_annotation <- function(file_ids,
                             fileview = "syn16858331",
                             attributes = c("resourceType", "assay", "dataType")) {

  if(is.null(fileview)) {
    meta <- list()
    for(i in file_ids) {
      dict <- synapser::synGetAnnotations(i)
      metaset <- lapply(attributes, function(x) tryCatch(dict[[x]], error = function(e) NA_character_))
      meta[[paste0("syn", i)]] <- metaset
    }
    meta <- rbindlist(meta, idcol = "id")
    setnames(meta, c("id", attributes))
  } else {
    ids_list <- glue::glue_collapse(file_ids, sep = ",")
    attributes <- glue::glue_collapse(attributes, sep = ",")
    meta <- synapser::synTableQuery(glue::glue("SELECT id,{attributes} FROM {fileview} WHERE id in ({ids_list})"))
    meta <- as.data.table(synapser::as.data.frame(meta))
  }
  return(meta)
}


#' Check public download access
#'
#' This returns whether a benefactor id allows public download and view access to the public as
#' `list(READ = bool, DOWNLOAD = bool)`.
#'
#' @param benefactor_id A benefactor id to check; usually a higher-level container, but files can be their own benefactor.
#' @param principal_id Defaults to "All Synapse users logged in", can use other ids 273949 or 273950 as well. 
#' @export
check_public_access <- function(benefactor_id, principal_id = 273948) {

  tryCatch({
    acl_result <- synapser::synRestGET(glue::glue("https://repo-prod.prod.sagebase.org/repo/v1/entity/{benefactor_id}/acl"))$resourceAccess %>%
      rbindlist(.)
    }, error = function(e) stop(glue::glue("Error for {benefactor_id}: {e$message}")))

  access <- setNames(as.list(c("READ", "DOWNLOAD") %in% acl_result[principalId == public, accessType]), c("READ", "DOWNLOAD"))
  return(access)
}
