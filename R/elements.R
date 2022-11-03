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
#' @param value Stat value.
#' @param description Description or stat value (1-2 sentences).
#' @param format Whether to format numeric values for commas for display. Default TRUE.
#' @param delta Whether to prefix positive numbers with "+" for delta values.
#' @param percent Whether this value is a percent.
#' @export
summary_stat <- function(value, 
                         header = NULL, 
                         description = NULL, 
                         format = TRUE,
                         delta = FALSE,
                         percent = FALSE) {
  if(format) value <- formatC(value, big.mark = ",")
  if(percent) value <- paste0(value, "%")
  htmltools::div(class = "stat-box",
                 htmltools::div(class="stat-header", header),
                 htmltools::div(class="stat-value", value),
                 htmltools::span(class="description", description),
  )
}


#' Placeholder
#' 
placeholder <- function() {
  ggplot() + theme_void() + 
    geom_text(aes(0,0, label = "Place plot here"), size = 20) +
    theme(panel.background = element_rect("lightgray"))
}