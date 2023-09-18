#' Store deidentified snapshot data in Synapse
#' 
#' Convenience function to store the compiled snapshot after `to_identified_export`.
#' At some point this may not be needed.
#' 
#' @param name Name of the table.
#' @param data Table data.
#' @param project Synapse project in which to store; a default location is used.
#' @export
store_snapshot_data <- function(name, data, project = "syn39770191") {
  
  columns <- c(
    synapser::Column(name = "project", columnType = "STRING", maximumSize = 15L), # Cannot use ENTITY, change manually in UI
    synapser::Column(name = "userId", columnType = "DOUBLE"),
    synapser::Column(name = "id", columnType = "DOUBLE"), # file id
    synapser::Column(name = "DATE", columnType = "STRING"),
    synapser::Column(name = "TIMESTAMP", columnType = "DATE"),
    synapser::Column(name = "NODE_TYPE", columnType = "STRING"),
    synapser::Column(name = "NAME", columnType = "STRING", maximumSize = 256L),
    synapser::Column(name = "recordType", columnType = "STRING"),
    synapser::Column(name = "date", columnType = "STRING"),
    synapser::Column(name = "dateGrouping", columnType = "STRING"),
    synapser::Column(name = "monthYear", columnType = "STRING"),
    synapser::Column(name = "userGroup", columnType = "STRING"))
  
  schema <- synapser::Schema(
    name = name,
    columns = columns,
    parent = project
  )
  
  t <- synapser::Table(schema, data)
  t <- synapser::synStore(t)
  return(t)
}
