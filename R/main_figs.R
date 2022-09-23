#-- Block text elements --------------------------------------------------------#

#' Summary stat block element
#'
#' @param header Title for stat value.
#' @param value Stat value.
#' @param description Description or stat value (1-2 sentences).
#' @export
summary_stat <- function(value, header = NULL, description = NULL) {
  htmltools::div(class = "stat-box",
                 htmltools::div(class="stat-header", header),
                 htmltools::div(class="stat-value", value),
                 htmltools::span(class="description", description),
  )
}

#' Notes block element
#' @inheritParams summary_stat
#' @export
notes <- function(header, description) {
  htmltools::div(style = "display: flex; margin-bottom: 10px;",
                 htmltools::div(style="flex: 1 1 0; margin-right: 20px; font-size: 13px;", header),
                 htmltools::div(style="flex: 3 1 0;", class="description", description)
  )
}

#-- Graphs ---------------------------------------------------------------------#

#' Sankey status transitions
#'
#' @param data The data.
#' @param palette Color palette.
#' @export
#' @import ggplot2
plot_sankey_status <- function(data, palette = data_status_palette) {
  p <- ggplot(data, aes(x = x, next_x = next_x, node = node, next_node = next_node, fill = factor(node), label = node)) +
    geom_sankey(flow.alpha = .4,
                node.color = "gray30") +
    # geom_sankey_text(size = 5, color = "black") +
    scale_fill_manual(values = palette) +
    theme_sankey(base_size = 18) +
    labs(x = NULL) +
    #theme(legend.position = "none",
    #      plot.title = element_text(hjust = .5)) +
    ggtitle("Status Changes")
  return(p)
}

#' Bar plot of downloads by data type
#'
#' @inheritParams plot_sankey_status
#' @param title Title of plot.
#' @export
#' @import ggplot2
plot_bar_data_segment <- function(data, title) {

  p <- ggplot(data, aes(x = Type, y = n, fill = Type)) +
      geom_bar(stat="identity") +
      scale_fill_manual(values = c(Genomics = "#4DBBD5FF", Imaging = "#E64B35FF", `Other` = "gray")) +
      theme_minimal() +
      xlab("Data Type Category") +
      ylab("Downloads") +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
      coord_flip()
  return(p)

}

#' Lollipop plot of downloads by project.
#' Expects a `data.frame` with `project` and `downloads`.
#'
#' @inheritParams plot_sankey_status
#' @export
#' @import ggplot2
plot_lollipop_download_by_project <- function(data, palette) {
  # Horizontal
  p <- ggplot(data, aes(x = reorder(project, downloads), y = downloads)) +
      geom_segment(aes(x = reorder(project, downloads),
                       xend = reorder(project, downloads),
                       y = 0,
                       yend = downloads),
                   color = palette$secondary) +
      geom_point(color = palette$highlight, size = 5) +
      theme_light() +
      labs(x = NULL) +
      coord_flip() +
      theme(
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        axis.ticks.y = element_blank()
        )
  return(p)
}

#' Column plot of downloads over time
#'
#' Bar of downloads over time (day), grouped by project or Sage (NF-OSI) vs. regular users
#' Grouping by project becomes problematic when in the future there are 8+ projects, making this hard to read
#' @inheritParams plot_sankey_status
#' @param fill Variable to fill by, defaults to "project".
#' @export
#' @import ggplot2
plot_downloads_datetime <- function(data, fill = "project", palette) {
  p <- ggplot(data, aes_string(x = "date", fill = fill)) +
    geom_bar(stat = "count") +
    theme_void() +
    scale_fill_manual(values = palette) +
    theme(legend.position="bottom")

  return(p)
}




