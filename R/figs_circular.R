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
