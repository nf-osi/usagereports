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


#' Pie chart
#'
#' A very generic pie chart for 'status'. See also `plot_donut_file_tiers`.
#'
#' @param data Data, expects a column 'status'.
#'
plot_pie <- function(data) {

  ggplot(data, aes(x="", y=status, fill=status)) +
    geom_bar(stat="identity", width=1, color="white") +
    coord_polar("y", start=0) +
    theme_void()
}


#' Hierarchical circle packing
#'
#' This is similar to a treemap and is useful for representing proportions of hierarchical entities (ontology classes and subclasses).
#'
#' @param nodes Nodes data. See `simd_class_count` to get example.
#' @param edges Edges data. See `simd_class_count` to get example.
#' @param seed Optional, seed for layout.
#' @param background Optional, background color.
#' @export
fig_class_count <- function(nodes,
                            edges,
                            seed = 42,
                            background = "black") {

  set.seed(seed)

  # Graph obj and graph
  graph <- tidygraph::tbl_graph(nodes, edges)

  # Layering manually because https://github.com/thomasp85/ggraph/issues/230
  ggraph::ggraph(graph, 'circlepack', weight = size) +
    ggraph::geom_node_circle(aes(filter = level==1, fill = I(fill)), color = "black", size = 0.25) +
    ggraph::geom_node_circle(aes(filter = level==2, fill = I(fill)), color = background, size = 0.25) +
    ggplot2::coord_fixed() +
    ggplot2::theme(legend.position = "FALSE") +
    ggplot2::theme_void() +
    ggraph::geom_node_text(aes(label = label), repel = TRUE, max.overlaps = 15) +
    ggraph::geom_node_label(aes(label = group_label), repel = TRUE, max.overlaps = Inf)

}

