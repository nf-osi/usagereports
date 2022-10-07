#-- Graphs ---------------------------------------------------------------------#

#' Sankey status transitions
#'
#' @param data The data.
#' @param palette Color palette.
#' @export
#' @import ggplot2
plot_sankey_status <- function(data, palette = data_status_palette) {
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
  p <- ggplot(data, aes(x = Month, y = Files, fill = Month)) +
    geom_col() +
    scale_fill_manual(values = palette) +
    theme_light()
  return(p)
}

#' Bar plot of downloads by data type
#'
#' @inheritParams plot_sankey_status
#' @param rdata
#' @param adata
#' @param donut Display as donut/sunburst-like chart.
#' @export
#' @import ggplot2
plot_data_segment <- function(rdata,
                              adata,
                              assay_palette,
                              resource_palette = resource_type_palette(),
                              donut = FALSE) {

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


#' Column plot comparing pageviews for projects with released vs unreleased data
#'
#' @inheritParams plot_sankey_status
plot_col_pageview_ <- function(data) {
  ggplot(data, aes(x = reorder(project, sum_pageviews), y = sum_pageviews, fill = data_released)) +
    geom_col() +
    facet_wrap(~ data_released, scales = "free_x") +
    scale_fill_manual(values = c("#af316c", "#376b8b")) +
    theme_light()
}


#' Dot plot comparing pageviews for projects with released vs unreleased data
#'
#' @inheritParams plot_sankey_status
plot_dot_pageviews <- function(data) {
  # Recode data_released
  data$status <- ifelse(data$data_released, "Released data", "No released data")
  p <- ggplot(data, aes(x = status, y = sum_pageviews, fill = status)) +
    geom_violin(alpha = 0.5) +
    geom_dotplot(binaxis = "y", stackdir = 'center') +
    scale_fill_manual(values = c("#af316c", "#376b8b"), name = NULL) +
    xlab("Project data status") +
    ylab("Number of pageviews") +
    theme_minimal()
  p
}


#' Plot visitors
#'
#' Plot unique visitors by project, meant to complement \link{`plot_dot_pageviews`}.
#'
#' @param data Data from Google Analytics, something like `ga_data`.
#' @param pictogram Does additional fun stuff with user pictograms, defaults to `FALSE`.
#' @export
plot_bar_visitors <- function(data, pictogram = FALSE) {

  p <- ggplot() +
    geom_bar(data = data, aes(x = max_users, y = factor(project)), stat = "identity", fill = default_palette()$primary) +
    theme_classic() +
    xlab("Visitors") +
    ylab("Project") +
    ggtitle("Unique visitors by project") +
    theme(legend.position = "bottom", axis.line.y = element_blank(),
          axis.ticks = element_blank(),
          plot.title = element_text(size = 26, margin = margin(0,0,30,0)),
          plot.title.position = "plot")

  if(pictogram) {
    u_pict <- data.frame(project = unlist(Map(rep, data$project, data$max_users)),
                         x = unlist(sapply(data$max_users, function(n) 1:n - 0.5) ))
    p <- p + geom_text(data = u_pict, aes(x = x, y = factor(project)), label = "\U1f468", size = 6)
  }

  return(p)
}


#' Plot scatter of pageviews x visitors
#'
#' This is an alternative that presents pagesviews and visitors together instead of
#' separately in \link{`plot_dot_pageviews`} and \link{plot_bar_visitors}


#' Bipartite network connecting users and projects
#'
#' @inheritParams plot_sankey_status
#' @import igraph
plot_bipartite <- function(data) {
  g <- graph.data.frame(user_project, directed = TRUE)
  V(g)$type <- igraph::bipartite.mapping(g)$type
  V(g)$color <- ifelse(V(g)$type,  "#6fbeb8",  "#af316c")
  V(g)$label.color <-  ifelse(V(g)$type, "black", "white")
  V(g)$label.family <- "sans"
  V(g)$size <- ifelse(V(g)$type, 30,  20)
  plot(g, layout = layout_with_fr)
  # return(g)
}
