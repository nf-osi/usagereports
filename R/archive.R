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
  
  if(!reticulate::py_module_available("synapseclient")) synapseclient <- reticulate::import("synapseclient")
  schema <- synapseclient$Schema(
    name = name,
    columns = list(
      synapseclient$Column(name = "project", columnType = "STRING", maximumSize = "11"), # Cannot use ENTITY
      synapseclient$Column(name = "userId", columnType = "DOUBLE"),
      synapseclient$Column(name = "id", columnType = "DOUBLE"), # file id
      synapseclient$Column(name = "DATE", columnType = "STRING"),
      synapseclient$Column(name = "TIMESTAMP", columnType = "DATE"),
      synapseclient$Column(name = "NODE_TYPE", columnType = "STRING"),
      synapseclient$Column(name = "NAME", columnType = "STRING", maximumSize = "256"),
      synapseclient$Column(name = "recordType", columnType = "STRING"),
      synapseclient$Column(name = "date", columnType = "STRING"),
      synapseclient$Column(name = "dateGrouping", columnType = "STRING"),
      synapseclient$Column(name = "monthYear", columnType = "STRING"),
      synapseclient$Column(name = "userGroup", columnType = "STRING")),
    parent = project
  )
  
  t <- synapseclient$Table(schema, data)
  t <- .syn$store(t)
  return(t)
}