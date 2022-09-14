sim_data_sankey_status <- function() {
  status_data <- data.frame(Jan = c(rep("Intake", 10), rep("Active", 40), rep("Completed", 15)),
                            June = c(rep("Active", 50), rep("Completed", 15)),
                            Nov = c(rep("Active", 40), rep("Completed", 25))
  )
  status_data <- status_data %>%
    ggsankey::make_long(Jan, June, Nov)
  return(status_data)
}

sim_data_download_by_project <- function() {
  data <- data.frame(
    project = paste0("syn", 1:10),
    downloads = abs(rnorm(10, mean = 60, sd = 20))
  )
  return(data)
}

sim_data_guage <- function() {
  data <- data.frame(
    variable = c("Project Usage", "Satisfaction", "Blah"),
    percentage = c(0.61,0.35,0.80)
  )
  
  data <- data %>% 
    mutate(group = ifelse(percentage <0.6, "danger", ifelse(percentage>=0.6 & percentage<0.8, "warning","success")),
           label = paste0(percentage*100, "%"))
  return(data)
}

sim_data_project_download_date <- function() {
  
  date_range <- seq(as.Date("2022-01-01"), by = "day", length.out = 180)
  data <- data.frame(
    project = paste0("syn", ceiling(rnorm(100, mean = 3))),
    date = sample(date_range, size = 100, replace = T)
  )
  return(data)
}

sim_data_project_pageview_date <- function() {
  
  date_range <- seq(as.Date("2022-01-01"), by = "day", length.out = 180)
  data <- data.frame(
    project = c(rep("released", 100), rep("non-released", 400)),
    date = sample(date_range, size = 500, replace = T)
  )
  return(data)
}