#-- Plots ---------------------------------------------------------------------#

#' Sankey status transitions
#'
#' @param data The data.
#' @param palette Color palette.
#' @export
#' @import ggplot2
plot_sankey_status <- function(data, palette = data_status_palette) {

  x <- next_x <- node <- next_node <- NULL
  p <- ggplot(data, aes(x = x, next_x = next_x, node = node, next_node = next_node, fill = factor(node), label = node)) +
    ggsankey::geom_sankey(flow.alpha = .4,
                node.color = "gray30") +
    # geom_sankey_text(size = 5, color = "black") +
    scale_fill_manual(values = palette, name = "Data status") +
    ggsankey::theme_sankey(base_size = 18) +
    labs(x = NULL) +
    #theme(legend.position = "none",
    #      plot.title = element_text(hjust = .5)) +
    ggtitle("Status Changes")
  return(p)
}

#' Bar plot comparing files available
#'
#' This expects a summary of files available by month.
#' @inheritParams plot_sankey_status
#' @export
plot_col_files_available <- function(data, palette = c("#af316c", "#125E81")) {

  Month <- Files <- NULL
  p <- ggplot(data, aes(x = Month, y = Files, fill = Month)) +
    geom_col() +
    scale_fill_manual(values = palette) +
    theme_light()
  return(p)
}

#' Bar plot of downloads by data attributes
#'
#' This expects summary breakdown for core annotation attributes, e.g. a table with cols
#' `resourceType`, `proportion` and a table with cols `assay`, `proportion`.
#'
#' @inheritParams plot_sankey_status
#' @param rdata Resource type annotation data.
#' @param adata Assay type annotation data.
#' @param assay_palette Color palette for assays,
#' which might need more customization since assay annotations can be somewhat project-specific.
#' @param resource_palette Color palette for resources -- default uses `resource_type_palette()`,
#' but provide a custom palette if annotations are project-specific.
#' @param donut Display as donut/sunburst-like chart.
#' @export
#' @import ggplot2
plot_data_segment <- function(rdata,
                              adata,
                              assay_palette,
                              resource_palette = resource_type_palette(),
                              donut = FALSE) {

  proportion <- assay <- resourceType <- type <- NULL
  adata$type <- "assay"
  rdata$type <- "resourceType"
  p <- ggplot() +
    geom_bar(data = rdata, aes(x = type, y = proportion, fill = resourceType),
             stat = "identity", position = "stack", color = "white") +
    scale_fill_manual(values = resource_palette, name = "Type") +
    ggnewscale::new_scale_fill() +
    geom_bar(data = adata, aes(x = type, y = proportion, fill = assay),
             stat = "identity", position = "stack", color = "white") +
    scale_fill_manual(values = assay_palette, name = "Assay") +
    scale_x_discrete(labels = c("Assay", "Type")) # limits = c("resourceType", "assay"))

  if(donut) {
    p <- p + theme_void() +
      coord_polar("y")
  } else {
    p <- p +
      theme_classic() +
      xlab("") +
      ylab("") +
      theme(axis.text.y = element_text(size = 12),
            axis.ticks.y = element_blank()) +
      coord_flip()
  }
  p <- p + ggtitle("Characterization of data requested") +
    theme(legend.position = "bottom", axis.line.y = element_blank(),
          plot.title = element_text(size = 16, margin = margin(0,0,30,0)),
          plot.title.position = "plot",
          legend.background = element_rect(color = "gray"),
          legend.text = element_text(size = 5),
          legend.box = "vertical",
          legend.margin = margin(10,10,10,10))
  return(p)
}


#' Lollipop plot of downloads by project
#'
#' Expects a `data.frame` with `project` and `downloads`.
#'
#' @inheritParams plot_sankey_status
#' @export
#' @import ggplot2
plot_lollipop_download_by_project <- function(data, palette) {
  # Horizontal

  project <- downloads <- NULL
  p <- ggplot(data, aes(x = stats::reorder(project, downloads), y = downloads)) +
      geom_segment(aes(x = stats::reorder(project, downloads),
                       xend = stats::reorder(project, downloads),
                       y = 0,
                       yend = downloads),
                   color = palette$secondary) +
      geom_point(color = palette$highlight, size = 5) +
      theme_light() +
      labs(x = NULL) +
      ggtitle("Download requests by project") +
      coord_flip() +
      theme(
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        axis.ticks.y = element_blank(),
        plot.title = element_text(size = 23, margin = margin(0,0,30,0)),
        plot.title.position = "plot"
        )
  return(p)
}

#' Bar plot of downloads over time
#'
#' Bar of downloads over time (day), grouped by project or Sage (NF-OSI) vs. regular users
#' Grouping by project becomes problematic when in the future there are 8+ projects, making this hard to read
#' @inheritParams plot_sankey_status
#' @param fill Variable to fill by, defaults to "project".
#' @export
#' @import ggplot2
plot_downloads_datetime <- function(data, fill = "project", palette) {

  data$date <- as.Date(data$date)
  p <- ggplot(data, aes_string(x = "date", fill = fill)) +
    geom_bar(stat = "count") +
    scale_fill_manual(values = palette) +
    theme_classic() +
    ylab("Count") +
    xlab("") +
    ggtitle("Downloads across projects over the report period") +
    scale_x_date(date_breaks = "2 weeks") +
    theme(legend.position = "bottom", axis.line.y = element_blank(),
          plot.title = element_text(size = 28, margin = margin(0,0,30,0)),
          plot.title.position = "plot")

  return(p)
}


#' Bipartite network connecting users and projects
#'
#' User ids are supposed to be random numbers (e.g. 6, 19, 40) and not actual user ids,
#' but to keep the display cleaner when there is potentially *a lot* of users, the ids are hidden by default.
#' Also, having numbers can be confusing (apparent by questions like: "Does '19' mean the number of users?" -- no, that's just the id).
#'
#' @inheritParams plot_sankey_status
#' @param hide_user_id Don't label user nodes with their ids. See details.
#' @import igraph
#' @export
plot_bipartite <- function(data, hide_user_id = TRUE) {

  project_node_color <- "#6fbeb8"
  user_node_color <- "#af316c"
  g <- graph.data.frame(data, directed = TRUE)
  V(g)$type <- igraph::bipartite.mapping(g)$type
  V(g)$color <- ifelse(V(g)$type,  project_node_color, user_node_color)
  user_node_label <- if(hide_user_id) user_node_color else "white" # obfuscate by using same color as bg
  V(g)$label.color <-  ifelse(V(g)$type, "black", user_node_label)
  V(g)$label.family <- "sans"
  V(g)$size <- ifelse(V(g)$type, 30,  20)
  plot(g, layout = layout_with_fr)
  # return(g)
}


#' Donut of file tiers
#'
#' Plot the restricted files as a proportion of total public files.
#' Original data can come from `query_file_snapshot`.
#' The tiers are `Public - Unrestricted` and `Public - Restricted`.
#'
#' @param data Table with columns `Tier` and `Count`.
#' @param palette Needs two colors for tiers shown by default. See details.
#' @export
plot_donut_file_tiers <- function(data, palette) {
  data$ymax <- cumsum(data$proportion)
  data$ymin <- c(0, head(data$ymax, n = -1))
  data$label <- glue::glue("{data$tier}\n{data$count} files")
  data$labelpos <- (data$ymax + data$ymin) / 2
  p <- ggplot(data, aes(ymax = ymax, ymin = ymin, xmax=4, xmin=3, fill = tier)) +
    geom_rect() +
    geom_text(x = 4.5, aes(y = labelpos, label = label, color = tier), size = 5, show.legend = F) +
    coord_polar(theta = "y") +
    scale_fill_manual(values = palette, name = "Data Tier") +
    xlim(c(1,4)) +
    theme_void()

  return(p)
}


