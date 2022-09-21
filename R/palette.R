# Palette

palette <- list(primary = "#125E81",
                secondary = "#404B63",
                highlight = "#6fbeb8",
                gray1 = "#DCDCDC",
                gray2 = "#BBBBBC",
                gray3 = "gray",
                purple1 = "#6d5d98",
                danger = "#C9146C",
                warning = "#F7A700",
                success = "#2699A7")

generic_palette <-c("#376b8b", "#e9b4ce", "#392965", "#f2d7a6", "#0e8177", "#bc590b", "#748dcd", "#a15317")

project_status_palette <- c(`Pre-Synapse` = palette$gray2,
                            Active= palette$highlight, 
                            Completed= palette$purple1)

data_status_palette <- c(`Pre-Synapse` = palette$gray1, 
                         None = palette$purple1, 
                         `Under Embargo`= palette$danger,
                         `Partially Available`= palette$warning, 
                         Available = palette$success)
