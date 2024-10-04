#' Helper for looking up studies
#'
#' Studies can be looked up in a Synapse table *or* Snowflake.
#' This queries studies by funding agency and data status using Portal - Studies table.
#' Note: If using a portal table, do not need to log in with `synapser` first as data is anonymous access.
#'
#' @param fundingAgency A single funder name, e.g. "NTAP".
#' @param dataStatus Data status(es), e.g. c("Available", "Partially Available")
#' @param table Synapse id of table to use.
#' @param save Whether to write data to csv. Default `FALSE`.
#' @export
query_study_ids <- function(fundingAgency,
                            dataStatus,
                            table = "syn52694652",
                            save = FALSE) {

    data_status <- glue::glue_collapse(glue::single_quote(dataStatus), sep = ",")
    message(glue::glue("Getting a list of all {fundingAgency} projects with specified statuses..."))
    study_records <- synapser::synTableQuery(glue::glue("SELECT studyId,dataStatus FROM {table} WHERE fundingAgency has ('{fundingAgency}') AND dataStatus in ({data_status})"))
    study_records <- synapser::as.data.frame(study_records)
    if(!nrow(study_records)) stop("No study records found!")
    project_ids <- study_records$studyId
    if(save) utils::write.csv(study_records, file = glue::glue("study_records.csv"))
    return(project_ids)
}

