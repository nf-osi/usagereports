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
