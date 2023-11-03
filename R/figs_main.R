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
    scale_fill_manual(values = resource_palette, name = "Resource Type") +
    ggnewscale::new_scale_fill() +
    geom_bar(data = adata, aes(x = type, y = proportion, fill = assay),
             stat = "identity", position = "stack", color = "white") +
    scale_fill_manual(values = assay_palette, name = "Assay") +
    scale_x_discrete(labels = c("Assay", "Resource Type")) # limits = c("resourceType", "assay"))

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
          legend.background = element_rect(color = "white"),
          legend.text = element_text(size = 5),
          legend.box = "vertical",
          legend.margin = margin(10,10,10,10))
  return(p)
}


#' Lollipop plot of downloads by project
#'
#' Expects a `data.frame` with `project` and `downloads`.
#'
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
#' Bar of downloads over time, grouped by project or Sage (NF-OSI) vs. regular users.
#'
#' Some tips:
#' 1. Scaling: `date` data is binned into "2 weeks" during plotting by default,
#' but the plot x-axis can easily be (re)scaled if needed after examining the result figure, e.g.:
#' `p <- plot_downloads_datetime(data)`
#' `p + ggplot2::scale_x_date(date_breaks = "2 months")`
#' ```
#' Depending on the download magnitude, y may preferably use log scaling:
#' `p + ggplot2::scale_y_continuous(trans='log2')`
#'
#' 2. Grouping by project can be problematic when there are 8+ projects, making this hard to read.
#'
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
#' Plot interactions between `user`s and `project`s.
#' User ids are supposed to be random numbers (e.g. 6, 19, 40) and not actual user ids,
#' but to keep the display cleaner when there is potentially *a lot* of users, the ids are hidden by default.
#' Numbers can be confusing (apparent by questions like: "Does '19' mean the number of users?" -- no, that's just the id).
#'
#' Some tips:
#' For scaling, depending on network size, it might be best with experimenting with other `*_node_size` numbers.
#'
#' @inheritParams plot_sankey_status
#' @param hide_user_id Don't label user nodes with their ids. See details.
#' @param project_node_size Node size of porject nodes.
#' @param user_node_size Node size of user nodes.
#' @import igraph
#' @export
plot_bipartite <- function(data,
                           project_node_size = 30,
                           user_node_size = 20,
                           hide_user_id = TRUE) {

  project_node_color <- "#6fbeb8"
  user_node_color <- "#af316c"
  g <- graph.data.frame(data, directed = TRUE)
  V(g)$type <- igraph::bipartite.mapping(g)$type
  V(g)$color <- ifelse(V(g)$type,  project_node_color, user_node_color)
  user_node_label <- if(hide_user_id) user_node_color else "white" # obfuscate by using same color as bg
  V(g)$label.color <-  ifelse(V(g)$type, "black", user_node_label)
  V(g)$label.family <- "sans"
  V(g)$size <- ifelse(V(g)$type, project_node_size, user_node_size)
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


#' Project breakdown flowchart template
#'
#' Generate a mermaid.js flowchart breaking down projects into groupings based on data status.
#' Can use as a starting template and substitute status labels depending on the DCC.
#'
#' @param total Total number.
#' @param available Number available from total.
#' @param reprocessable Number considered reprocessable, portion of available.
#' @param unreleased Number of unreleased from total.
#' @param under_embargo Number under embargo.
#' @param pending Number where data is still being generated.
#' @param not_expected Number where data not expected.
#' @export
#' @example
#' # p <- plot_project_flowchart(100, 40, 10, 50, 30, 20, 10)
#'
#'
plot_project_flowchart_template <- function(
                                   total,
                                   available,
                                   reprocessable,
                                   unreleased,
                                   under_embargo,
                                   pending,
                                   not_expected) {

  theme <- "%%{init: {'themeVariables': { 'primaryColor': '#125e81','edgeLabelBackground': 'white' }}}%%"

  glue::glue(
  'flowchart LR
    {theme}

    classDef Blue fill:#125e81,color:#fff,stroke-width:0px
    classDef Green fill:#00c87a,color:#fff,stroke-width:0px
    classDef Red fill:#af316c,color:#fff,stroke-width:0px
    classDef Pink fill:#e9b4ce,color:black,stroke-width:0px
    classDef Purple fill:#392965,color:#fff,stroke-width:0px
    classDef Yellow fill:#f2d7a6,color:black,stroke-width:0px
    classDef Gray fill:#636E83,color:white,stroke-width:0px

    Total:::Purple
    Available:::Blue
    Reprocessable:::Green
    DataNotReleased:::Red
    UnderEmbargo:::Pink
    DataPending:::Yellow
    DataNotExpected:::Gray

    Total["Total projects\n(n={total})"]-->Available["Data Partially Available\nor Available\n(n={available})"]-->Reprocessable["Data Reprocessed\n(n={reprocessable})"]
    Total-->DataNotReleased["Data Unreleased\n(n={unreleased})"]
    DataNotReleased-->UnderEmbargo["Data Under Embargo\n(n={under_embargo})"]
    DataNotReleased--->DataPending["Data Pending\n(n={pending})"]
    Total-->DataNotExpected["Data Not Expected\n(n={not_expected})"]
    ')
}

