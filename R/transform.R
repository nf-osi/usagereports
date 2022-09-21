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

