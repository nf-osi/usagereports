% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_dw.R
\name{query_filedownload_scoped}
\alias{query_filedownload_scoped}
\title{Generate query to get users and downloads parameterized by project ids and date range}
\usage{
query_filedownload_scoped(start_date, end_date, ids)
}
\arguments{
\item{start_date}{Start date for report window in format "YYYY-MM-DD".}

\item{end_date}{End date for report window in format "YYYY-MM-DD".}

\item{ids}{Character vector of project ids, e.g. \code{c("syn124", "syn999")}.}
}
\description{
This just helps generate a useful query, which can be submitted through whichever preferred interface,
e.g. Rstudio connection or the Snowflake Worksheets UI.
The result is a table with user and file download records for the projects specified.
It is a good precursor for deriving many other summaries of interest without making more calls,
e.g. from we can get total unique users, distribution of downloads (to identify "power users"),
the network of projects and users via downloads as edges, etc.
}
\details{
If you wish to go to just one of the summaries directly, then it's best to use a different query.
}
