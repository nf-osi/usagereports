library(data.table)

data_status <- query_data_status_snapshots(vRange = c(14,41)) 
# View
data_status 
fwrite(data_status, "data_status_2022-03-01_2022-08-29.csv")

# Explore
sum_data_status_changes(data_status)

# Output selected
sankey_data_status_selected <- to_sankey_data(status_data, "2022-07-04")
fwrite(sankey_data_status_selected, "sankey_data_status_selected.csv")
