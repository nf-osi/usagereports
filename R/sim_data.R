
simd_sankey_project_status <- function() {
  status_data <- data.frame(Jan = c(rep("Intake", 10), rep("Active", 40), rep("Completed", 15)),
                            June = c(rep("Active", 50), rep("Completed", 15)),
                            Nov = c(rep("Active", 40), rep("Completed", 25))
  )
  status_data <- status_data %>%
    ggsankey::make_long(Jan, June, Nov)
  return(status_data)
}


simd_sankey_data_status <- function() {
  status_data <- data.frame(Jan = c(rep("Pre-Synapse", 10), rep("None", 40), rep("Under Embargo", 15)),
                            June = c(rep("Under Embargo", 50), rep("Available", 15)),
                            Nov = c(rep("Under Embargo", 40), rep("Available", 25))
  )
  sankey_data <- status_data %>%
    ggsankey::make_long(Jan, June, Nov)
  return(sankey_data)
}

simd_download_by_project <- function() {
  data <- data.frame(
    project = paste0("syn", 1:10),
    downloads = abs(stats::rnorm(10, mean = 60, sd = 20))
  )
  return(data)
}

simd_guage <- function() {
  data <- data.frame(
    variable = c("Project Usage", "Satisfaction", "Blah"),
    percentage = c(0.61,0.35,0.80)
  )

  data <- data %>%
    dplyr::mutate(group = ifelse(percentage <0.6, "danger", ifelse(percentage>=0.6 & percentage<0.8, "warning","success")),
           label = paste0(percentage*100, "%"))
  return(data)
}

simd_project_download_date <- function() {

  date_range <- seq(as.Date("2022-01-01"), by = "day", length.out = 180)
  data <- data.frame(
    project = paste0("syn", ceiling(stats::rnorm(100, mean = 3))),
    date = sample(date_range, size = 100, replace = T)
  )
  return(data)
}


simd_project_pageview_date <- function() {

  date_range <- seq(as.Date("2022-01-01"), by = "day", length.out = 180)
  data <- data.frame(
    project = c(rep("released", 100), rep("non-released", 400)),
    date = sample(date_range, size = 500, replace = T)
  )
  return(data)
}

#' @import data.table
simd_assay_breakdown <- function() {

  data <- data.table(attribute = "Assay",
                     value = c("whole exome sequencing", "RNA-seq", "immunohistochemistry"),
                     count = c(200, 500, 100))
  total <- sum(data$count)
  data[, proportion := count/total]
  return(data)

}

#' @import data.table
simd_resourcetype_breakdown <- function() {
  data <- data.table(attribute = "Resource Type",
                     value = c("experimentalData", "metadata", "report"),
                     count = c(700, 60, 40))
  total <- sum(data$count)
  data[, proportion := count/total]
  return(data)
}

#' Simulate data for fig_class_count
#'
simd_class_count <- function() {

  # Nodes
  class <- data.frame(
    name = c("cereal", "coffee", "sandwich", "cookie", "pasta", "wine", "cheesecake"),
    class = c("Breakfast", "Breakfast", "Lunch", "Lunch", "Dinner", "Dinner", "Dinner"),
    size = c(300, 5, 550, 100, 800, 150, 300),
    fill = c("yellow", "yellow", "lightblue", "lightblue", "lavender", "lavender", "lavender"),
    level = 2L) # calories

  # Upper-level classes, or level 1
  class_sum <- class %>%
    dplyr::group_by(class) %>%
    dplyr::summarize(size = sum(`size`)) %>% # when plotting, ggraph will ignore pre-calc size anyway ('Non-leaf weights ignored')
    # dplyr::summarize(size = 0) %>%
    dplyr::mutate(name = class, fill = c("orange", "purple", "dodgerblue"), level = 1L)

  nodes <- class %>%
    dplyr::bind_rows(class_sum) %>%
    dplyr::mutate(size = log2(size) + 0.1)

  # Edges
  edges <- class %>%
    dplyr::select(from = `class`, to = `name`)

  list(nodes = nodes, edges = edges)
}

