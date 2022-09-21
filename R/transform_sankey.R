#' Auto-select most interesting timepoints and make data for sankey

#' Helper to construct a table of most prominent transition points to help select which ones to use
sum_data_status_changes <- function(status_data) {
  # Find timepoints other than start and end
  PA <- apply(status_data, 1, function(x) match("Partially Available", x))
  A <- apply(status_data, 1, function(x) match("Available", x))
  timepoints <- table(c(PA, A))
  names(timepoints) <- names(status_data)[as.numeric(names(timepoints))]
  timepoints
}

#' Selected should be timepoints *other* than first and last
to_sankey_data <- function(status_data, selected) {
  first_last <- names(status_data)[c(2, length(status_data))]
  selected <- as.character(sort(as.Date(unique(c(first_last, selected)))))
  status_data_selected <- status_data[, ..selected]
  sankey_data <- ggsankey::make_long(status_data, {{ selected }} )
  return(sankey_data)
}


check_transition <- function(status_data) {
  
  is_valid_transition <- function(x1, x2) {
    if(x1 == 1) return(1L)
    valid_transitions <- list(
      c("Pre-Synapse", "None"),
      c("None", "Under Embargo"),
      c("Under Embargo", "Partially Available"),
      c("Under Embargo", "Available"),
      c("Partially Available", "Available")
    )
    
    # invalid_transition <- list(
    #   c("Pre-Synapse", "None"),
    #   c("None", "Under Embargo"),
    #   c("Under Embargo", "Partially Available"),
    #   c("Under Embargo", "Available"),
    #   c("Partially Available", "Available")
    # )
    if(x1 != x2) {
      pair <- c(x1, x2)
      ok <- sapply(valid_transitions, function(transition) identical(transition, pair))
      if(!any(ok)) return(1L) else return(x2)
    } else {
      return(x2)
    }
  }
  
  result <- apply(status_data, 1, function(i) Reduce(check_transition, i))
  return(result)
}
