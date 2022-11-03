#' Default palette
#'
#' @export
default_palette <- function() {
  list(primary = "#125E81",
       secondary = "#404B63",
       highlight = "#6fbeb8",
       gray1 = "#DCDCDC",
       gray2 = "#BBBBBC",
       gray3 = "gray",
       purple1 = "#6d5d98",
       danger = "#C9146C",
       warning = "#F7A700",
       success = "#2699A7")
}

#' All-purpose Synapse palette
#'
#' Return max of 10 synapse colors.
#' @export
syn_palette <- function() {

  p <- c("#376b8b", "#e9b4ce", "#392965", "#f2d7a6", "#0e8177", "#bc590b", "#748dcd", "#af316c", "#aac3d4")
  return(p)
}

#' Default project status palette
#'
#' @export
project_status_palette <- function() {
  p <- c(`Pre-Synapse` = default_palette()$gray2,
         Active = default_palette()$highlight,
         Completed = default_palette()$purple)
  return(p)
}

#' Default data status palette
#'
#' @export
data_status_palette <- function() {
  p <- c(`Pre-Synapse` = default_palette()$gray1,
         None = default_palette()$purple1,
         `Under Embargo`= default_palette()$danger,
         `Partially Available`= default_palette()$warning,
         Available = default_palette()$success)
  return(p)
}

#' Default palette for visualizing resource type
#'
#' @export
resource_type_palette <- function() {
  c(experimentalData = default_palette()$primary, `non-experimentalData` = default_palette()$gray1)
}
