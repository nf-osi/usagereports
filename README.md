# usagereports

This contains scripts and an Rmarkdown template to generate data usage reports for a funder.
**No real data** lives here. 
To propose a new plot figure, you *should* add a corresponding function to create example data so it's clear what the data looks like.

The collection of functions in `R` are:
- `query_*` : Query and compile data from data warehouse, portal assets, Google Analytics, etc.
- `to_*` : Take data output from `query_*` and massage to the structure needed for specific plots or other forms. 
- `plot_*` : Generate plots that go into the report.
- `simd_*` : Simulate example data for the corresponding plots.

## Workflow

Overall, the functions can be put together in the manner represented below to generate the desired figures.
Figures are approximately numbered by the order in which they appear in the "suggested" report format.
However, the package should make it easy to just use for 1-2 figures or mix and match for another report format.

**Please contribute back if you have additional or alternative figures that would be useful!**

```mermaid

flowchart TD
    
    classDef fig fill:orange,stroke:#333,stroke-width:0px;
    class fig1,fig2,fig3,fig4,fig5,fig6,fig7,fig8,fig9,fig10 fig;
    style datawarehouse fill:#625191,stroke-width:0px
    style synapse fill:#125e81,stroke-width:0px
    style google fill:#e9b4ce,stroke-width:0px
    style datawarehouse color:white
    style synapse color:white


    subgraph datawarehouse
        dw[(db warehouse)] -- query_data_by_funding_agency --> files[[files]] 
        dw -- query_file_snapshot --> file_summary_data(file_summary_data)
        file_summary_data -- plot_bar_available_files --> fig2:::fig
        files -- to_deidentified_export --> data(data) 
        data -- plot_lollipop_download_by_project --> fig4:::fig
        data -- plot_downloads_datetime --> fig5:::fig
        data -- filter --> filtered_data(filtered_data)
        filtered_data -- plot_lollipop_download_by_project --> fig6:::fig
        filtered_data -- plot_downloads_datetime --> fig7:::fig
    end
    
    subgraph synapse
        studies(Portal - Studies) -- query_data_status_snapshots --> data_status(data_status)
        data_status -- to_sankey_data --> sankey_data(sankey_data)
        sankey_data(sankey_data) -- plot_sankey_status --> fig1:::fig

        filemeta(File meta) --> data_type_breakdown(data_type_breakdown)
        filemeta(File meta) --> data_assay_breakdown(data_assay_breakdown)
        filtered_data -- annotation_join --> filemeta
        data_assay_breakdown -- plot_bar_data_segment --> fig8:::fig
        data_type_breakdown -- plot_bar_data_segment --> fig9:::fig
        filtered_data -- to_summary_users --> data_user_summary(data_user_summary)
        data_user_summary -- plot_user_summary --> fig10:::fig
    end

    subgraph google
        studies --> project_stats
        GA[(Google Analytics)] -- query_ga --> project_stats(project_stats)
        project_stats -- plot_pageviews --> fig3:::fig
    end
    
```

### Templates

Helper templates are provided for the data prep:
- For legacy datawarehouse data (purple workflow domain): `rmarkdown::draft(file = "Data-prep-DW-YYYY-MM", template = "prepare-data-legacy", package = "usagereports")`
- (Comming soon) For Synapse and Google Analytics data (teal and pink workflow domains): `rmarkdown::draft(file = "Data-prep-Syn-GA-YYYY-MM", template = "prepare-data-synapse-ga", package = "usagereports")`

Once data prep is done, the report template can be used:
- (Comming soon) `rmarkdown::draft(file = "Funder-Report-Issue-x", template = "report", package = "usagereports")`

## Installation

### OS dependencies installation

SQL db or client:
- deb: `libmysqlclient-dev` (Debian, Ubuntu, etc)
- brew: `mysql` (OSX)

This needs `libsodium` for encrypting/de-encrypting some data.
- deb: `libsodium-dev` (Debian, Ubuntu, etc)
- brew: `libsodium-dev` (OSX)

### R dev package dependencies

This relies on two non-CRAN packages that can be installed via `devtools`:

- `devtools::install_github("Sage-Bionetworks/synapseusagereports")`
- `devtools::install_github("davidsjoberg/ggsankey")`

Then: 
`devtools::install_github("nf-osi/usagereports")`

(Or for contributors) Clone this repo and install locally with:
`devtools::install()`



