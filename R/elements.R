#-- Block text elements --------------------------------------------------------#

#' Notes block element
#'
#' @inheritParams summary_stat
#' @export
notes <- function(header, description) {
  htmltools::div(style = "display: flex; margin-bottom: 10px;",
                 htmltools::div(style="flex: 1 1 0; margin-right: 20px; font-size: 13px;", header),
                 htmltools::div(style="flex: 3 1 0;", class="description", description)
  )
}


#' Summary stat block element
#'
#' @param header Title for stat value.
#' @param value Stat value, e.g. "+1,243" or "+30%".
#' @param description Description or stat value (1-2 sentences).
#' @export
summary_stat <- function(value,
                         header = NULL,
                         description = NULL) {

  htmltools::div(class = "stat-box",
                 htmltools::div(class="stat-header", header),
                 htmltools::div(class="stat-value", value),
                 htmltools::span(class="description", description),
  )
}


#' Apply all formatting for infographic values
#'
#' Convenience function to apply a number of formatting options at once.
#'
#' @param value Numeric value.
#' @param delta Whether to prepend "+" or "-" if this is a delta value that needs the emphasis.
#' @export
info_format <- function(value, delta = TRUE) {
  formatted <- formatC(value, big.mark = ",")
  formatted <- paste0(formatted, "%")
  if(delta) {
    if(value > 0) paste0("+", formatted) else paste0("-", formatted)
  }
  formatted
}


#' Placeholder
#'
placeholder <- function() {
  ggplot() + theme_void() +
    geom_text(aes(0,0, label = "Place plot here"), size = 20) +
    theme(panel.background = element_rect("lightgray"))
}
