% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_synapse.R
\name{query_annotation}
\alias{query_annotation}
\title{Query annotations}
\usage{
query_annotation(
  file_ids,
  fileview = "syn16858331",
  attributes = c("resourceType", "assay", "dataType")
)
}
\arguments{
\item{file_ids}{Vector of numeric file ids (without "syn" prefix).}

\item{fileview}{Fileview id, which may vary for the portal. Defaults to NF's \code{Portal - Files}.
If \code{NULL}, for when the fileview does not exist or contain the files in scope,
this will use alternative method of \code{get_annotations}, which will be slower but retrieves most up-to-date data,
which is not guaranteed with a fileview.}

\item{attributes}{Vector of relevant metadata attributes for breakdown, which may vary for the portal.
Defaults to NF core attributes.}
}
\description{
Query annotations for files to faciliate assay, etc. breakdown
}
