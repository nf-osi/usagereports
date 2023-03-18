# usagereports

This contains scripts and an Rmarkdown template to generate data usage reports for a funder.
**No real data** lives here. 
To propose a new plot figure, you *should* add a corresponding function to create example data so it's clear what the data looks like.

The collection of functions in `R` are:
- `query_*` : Query and compile data from data warehouse, portal assets, Google Analytics, etc.
- `to_*` : Take data output from `query_*` and massage to the structure needed for specific plots or other forms. 
- `plot_*` : Generate plots that go into the report.
- `simd_*` : Simulate example data for the corresponding plots.

## Diagram

Overall, the functions can be put together in the manner represented below to generate the desired figures.
Figures are approximately numbered by the order in which they appear in the "suggested" report format.
However, the package should make it easy to just use for 1-2 figures or mix and match for another report format.

**Please contribute back if you have additional or alternative figures that would be useful!**

```mermaid
flowchart TD
    
    classDef fig fill:orange,stroke:#333,stroke-width:3px;
    class fig1,fig2,fig3,fig4,fig5,fig6,fig7,fig8,fig9,fig10 fig;
    
    dw[(db warehouse)] -- query_data_by_funding_agency --> files[[files]] 
    dw -- query_file_snapshot --> file_summary_data(file_summary_data)
    file_summary_data -- plot_bar_available_files --> fig2:::fig
    files -- to_deidentified_export --> data(data) 
    data -- plot_lollipop_download_by_project --> fig4:::fig
    data -- plot_downloads_datetime --> fig5:::fig
    
    data -- filter --> filtered_data(filtered_data)
    filtered_data -- plot_lollipop_download_by_project --> fig6:::fig
    filtered_data -- plot_downloads_datetime --> fig7:::fig
    
    studies(Portal - Studies) -- query_data_status_snapshots --> data_status(data_status)
    data_status -- to_sankey_data --> sankey_data(sankey_data)
    sankey_data(sankey_data) -- plot_sankey_status --> fig1:::fig
    
    GA[(Google Analytics)] -- query_ga --> pageview_data(pageview_data)
    pageview_data -- plot_pageviews --> fig3:::fig
    
    filtered_data -- annotation_join --> data_assay_breakdown(data_assay_breakdown)
    filtered_data -- to_parsed_format --> data_type_breakdown(data_type_breakdown)
    data_assay_breakdown -- plot_bar_data_segment --> fig8:::fig
    data_type_breakdown -- plot_bar_data_segment --> fig9:::fig
    filtered_data -- to_summary_users --> data_user_summary(data_user_summary)
    data_user_summary -- plot_user_summary --> fig10:::fig
    
    
```

## Installation

This relies on two non-CRAN packages that should be installed via `devtools`:

- `devtools::install_github("Sage-Bionetworks/synapseusagereports")`
- `devtools::install_github("davidsjoberg/ggsankey")`
