library(tidyverse)
library(ggsankey)

#-- Block text elements --------------------------------------------------------#
summary_stat <- function(value, header = NULL, description = NULL) {
  htmltools::div(class = "stat-box",
                 htmltools::div(class="stat-header", header),
                 htmltools::div(class="stat-value", value),
                 htmltools::span(class="description", description),
  )
}

notes <- function(header, description) {
  htmltools::div(style = "display: flex; margin-bottom: 10px;",
                 htmltools::div(style="flex: 1 1 0; margin-right: 20px;", header),
                 htmltools::div(style="flex: 3 1 0;", class="description", description)
  )
}

#-- Graphs ---------------------------------------------------------------------#

#' Sankey status transitions
plot_sankey_status <- function(data, palette) {
  p <- ggplot(data, aes(x = x, next_x = next_x, node = node, next_node = next_node, fill = factor(node), label = node)) +
    geom_sankey(flow.alpha = .4,
                node.color = "gray30") +
    # geom_sankey_text(size = 5, color = "black") +
    scale_fill_manual(values = c(Intake = palette$gray2, 
                                 Active= palette$highlight, 
                                 Completed= palette$purple1)) +
    theme_sankey(base_size = 18) +
    labs(x = NULL) +
    #theme(legend.position = "none",
    #      plot.title = element_text(hjust = .5)) +
    ggtitle("Project Status")
  return(p)
}

#' Bar of downloads by data type
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

#' Expects a `data.frame` with `project` and `downloads`.
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

#' Bar of downloads over time (day), grouped by project
plot_bar_project_date <- function(data, sum_data = NULL, palette) {
  p <- ggplot(data, aes(x = date, fill = project)) + 
    geom_bar(stat = "count") +
    theme_void() +
    scale_fill_manual(values = palette) +
    theme(legend.position="bottom")
         
  return(p)  
}




