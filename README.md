# usagereports

## Intro

This is an R package with functions and templates to generate data usage reports for a funder.
**No real data** lives here. 

The collection of functions in `R` are prefixed with their intent:
- `query_*` : Query and compile data from data warehouse, portal assets, Google Analytics, etc.
- `to_*` : Take data output from `query_*` and massage to the structure needed for specific plots or other forms. 
- `plot_*` : Generate plots that go into the report.
- `simd_*` : Simulate example data for the corresponding plots.

## Usage 
There are several ways in which you can view and engage with this package:

1. For heavily guided usage and workflow to put together a full biannual or annual PDF report deliverable for a sponsor funder. 
See the supporting flowchart and templates below; figures are approximately numbered by the order in which they appear in the "suggested" report format.

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

2. For *a la carte* generation of just 1-2 figures that you like, e.g to include independently in some slides instead of an entire report. 

3. As a good starting place and conceptual catalog of interesting metrics/data products, even if you don't ultimately use any of the queries/plotting utils here. 
Consider contributing if you come up with something that others might also find useful.

4. As a playground and learning resource for R analytics.

### Templates

**Data warehouse (purple domain)**
- Snowflake template is WIP.

**Synapse (teal domain) and Google Analytics (pink domain)**
- Set up with `rmarkdown::draft(file = "Data-prep-Syn-GA-YYYY-MM", template = "prepare-data-synapse-ga", package = "usagereports")`

**Reporting template**  
Once data prep is done, the report template can be used. Note that not all reporting features may apply or are covered for other DCCs, so treat this as a starting point for customization:
- (Coming soon) `rmarkdown::draft(file = "Funder-Report-Issue-x", template = "report", package = "usagereports")`

## Installation

### OS dependencies

This needs `libsodium` for encrypting/de-encrypting some data.
- deb: `libsodium-dev` (Debian, Ubuntu, etc)
- brew: `libsodium-dev` (OSX)

### R dev package dependencies

This relies on a non-CRAN packages that can be installed via `devtools`:
- `devtools::install_github("davidsjoberg/ggsankey")`

Then: 
- `devtools::install_github("nf-osi/usagereports")`
- (Or for potential contributors) Clone this repo and install locally with: `devtools::install()`

### Snowflake dependencies (optional / WIP)

Snowflake data can be obtained via Worksheets UI, and it's not absolutely required to configure programmatic connection (though it can be somewhat more convenient). 
If you are interested, install drivers and follow docs here:
https://developers.snowflake.com/odbc/

There are docs on other options for Snowflake connections here as well: https://github.com/Sage-Bionetworks/snowflake

### Older versions (legacy warehouse)

- If for some reason legacy-specific code needs to be referenced, the best option is to install package at [this commit](https://github.com/nf-osi/usagereports/commit/441ff039f923bb1b780a56e3b32d16c073caf45e).
- For this package version you'll also need the SQL db or client on your OS:
    - deb: `libmysqlclient-dev` (Debian, Ubuntu, etc)
    - brew: `mysql` (OSX)
- And also install the R dependency `devtools::install_github("Sage-Bionetworks/synapseusagereports")`.

## Development notes

This package is in development and will depend on a new backend (itself also in development) being stabilized. 
Version 1.0 is possible some time in 2024, and current developments are focused on:

- Deprecation of legacy warehouse functions and templates and replacing everything as applicable with new backend.
- Split Google Analytics and Synapse data prep, aiming for greater modularity and greater generalization.
- Setting up more overall package checks and tests.

### Contributing guide

- Create a branch for changes and make a pull request against `main`.
- To propose a new figure, it is *recommended* that you add a corresponding function to create example data to help users see what data is expected/what shape they need to get their data into.
