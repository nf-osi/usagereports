#' Guage graph
#'
#' @inheritParams plot_sankey_status
plot_gauge_3x <- function(data, palette) {

  group <- percentage <- label <- variable <- NULL
  p <- ggplot(data, aes(fill = group, ymax = percentage, ymin = 0, xmax = 2, xmin = 1)) +
    geom_rect(aes(ymax=1, ymin=0, xmax=2, xmin=1), fill = palette$gray1 ) +
    geom_rect() +
    coord_polar(theta = "y",start=-pi/2) + xlim(c(0, 2)) + ylim(c(0,2)) +
    geom_text(aes(x = 0, y = 0, label = label, colour=group), size = 6.5, family = "Arial SemiBold") +
    geom_text(aes(x=1.5, y=1.5, label = variable), family = "Arial", size=4.2) +
    facet_wrap(~variable, ncol = 3) +
    theme_void() +
    scale_fill_manual(values = palette) +
    scale_colour_manual(values = palette) +
    theme(strip.background = element_blank(),
          strip.text.x = element_blank()) +
    guides(fill=FALSE) +
    guides(colour=FALSE)
  return(p)
}
