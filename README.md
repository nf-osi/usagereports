# usage-reports

This contains scripts and an Rmarkdown template to generate data usage reports for a funder.
**No real data** lives here. 
To propose a new plot figure, you *must* add a corresponding function to create example data so it's clear what the data looks like.

So far there are two families of functions in `R`:
- `plot_*` Generate plots for a variety of figures.
- `sim_data_*` - Simulate example data for the corresponding plots above.

Another family will be added:
- `to_*` - Functions that take output from `synaseusagereports` and transforms data to the structure needed. 

