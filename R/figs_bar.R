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

#' Bar plot of downloads by data attribute
#'
#' Convenience proportion plot for annotation attribute.
#' See either `simd_resourcetype_breakdown` or `simd_assay_breakdown` for example data.
#' See also `plot_status` for very nearly the same plot method with different data.
#'
#' @param data Data in long format for plot. Expects cols `attribute` with name of attribute,
#' `value` for the attribute value, and `proportion` for the share of that value in the overall data. See details.
#' @param palette Optional, manual color palette for customized or consistent fill of the attribute values.
#' The default palette handles up to
#' @export
#' @import ggplot2
plot_data_segment <- function(data,
                              palette = NULL) {

  # Auto-generate palette if custom palette not given
  if(is.null(palette)) {
    palette <- usagereports::syn_palette()
  }
  p <- ggplot(data, aes(x = attribute, y = proportion, fill = value)) +
    geom_col(color = "white") +
    geom_text(aes(label = proportion), col = "white", size = 5, position = position_stack(vjust = 0.5)) +
    theme_minimal() +
    theme(axis.title = element_blank(),
          axis.text.y= element_text(size = 10, face = "bold")) +
    scale_fill_manual(values = palette, name = "") +
    scale_y_discrete() +
    xlab("") +
    ylab("Proportion")

  p
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


#' Project and data status grouped bar plot
#'
#' @param data Data table, expects `studyStatus` and `dataStatus` columns.
#' @param palette Palette for fill colors by `dataStatus`. Defaults are provided.
#' @export
plot_status <- function(data,
                        palette = data_status_palette()) {

  ggplot(data, aes(x = studyStatus, y = N, fill = dataStatus)) +
    geom_col(color = "white") +
    geom_text(aes(label = N), col = "white", size = 5, position = position_stack(vjust = 0.5)) +
    scale_fill_manual(values = palette, name = "Data Status") +
    theme_minimal() +
    theme(axis.title = element_blank(),
          axis.text.y= element_text(size = 10, face="bold")) +
    scale_y_discrete() +
    xlab("Study Status") +
    ylab("Data Status") +
    coord_flip()
}

