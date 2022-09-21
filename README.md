# usage-reports

This contains scripts and an Rmarkdown template to generate data usage reports for a funder.
**No real data** lives here. 
To propose a new plot figure, you *must* add a corresponding function to create example data so it's clear what the data looks like.

The collection of functions in `R` are:
- `query_*` : Query and compile data from either the data warehouse or portal assets.
- `to_*` : Take data output from `query_*` and massage to the structure needed for specific plots, other forms suitable for sharing. 
- `plot_*` : Generate plots that go into the report.
- `simd_*` : Simulate example data for the corresponding plots.


