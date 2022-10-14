#' Column plot comparing pageviews for projects with released vs unreleased data
#'
#' @inheritParams plot_sankey_status
plot_col_pageview_ <- function(data) {
  
  project <- sum_pageviews <- data_released <- NULL
  ggplot(data, aes(x = stats::reorder(project, sum_pageviews), y = sum_pageviews, fill = data_released)) +
    geom_col() +
    facet_wrap(~ data_released, scales = "free_x") +
    scale_fill_manual(values = c("#af316c", "#376b8b")) +
    theme_light()
}


#' Dot plot comparing pageviews for projects with released vs unreleased data
#'
#' @inheritParams plot_sankey_status
#' @export
plot_dot_pageviews <- function(data) {
  
  status <- sum_pageviews <- NULL
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
#' Plot unique visitors by project, meant to complement `plot_dot_pageviews`.
#'
#' @param data Data from Google Analytics, something like `ga_data`.
#' @param pictogram Does additional fun stuff with user pictograms, defaults to `FALSE`.
#' @export
plot_bar_visitors <- function(data, pictogram = FALSE) {
  
  x <- project <- max_users <- NULL
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
#' separately in `plot_dot_pageviews` and `plot_bar_visitors`.
#'
#' @inheritParams plot_bar_visitors
#' @param cutoff Cutoff based on visitor number; projects above this have labels that help highlight them as more popular.
#' @export
plot_scatter_pageviews_visitors <- function(data, cutoff = 10) {
  
  project <- max_users <- data_release_group <- sum_pageviews <- NULL
  p <- ggplot(data, aes(x = max_users, y = sum_pageviews, size = max_users, color = data_release_group, label = project)) +
    geom_point() +
    geom_text(data = subset(data, max_users > cutoff),  hjust = "right", vjust = "bottom", nudge_x = -0.6) +
    theme_minimal() +
    xlab("Visitors") +
    ylab("Pageviews") +
    scale_color_manual(labels = c(unreleased = "Unreleased",
                                  start = "Released before report period",
                                  end = "Released during report period"),
                       values = c(unreleased = default_palette()$gray2,
                                  start = default_palette()$primary,
                                  end = default_palette()$highlight),
                       name = "Data Release Group") +
    scale_size_continuous(name = "Visitor Population Size")
  
  return(p)
}
