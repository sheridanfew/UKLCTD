# UKLCTD

### Overview ###


This repository contains:

(1) The United Kingdom Low Carbon Technology Database (UKLCTD), a collection of real geographically disaggregated data on current deployment of small scale photovoltaics (PV), heat pumps (HPs), electric vehicles (EVs), network inrastructure, domestic and nondomestic meter density, electricity demand, and rurality at an LSOA level.

(2) Scenarios for future deployment of PV, HPs, EVs, and battery storage upto 2050 at an LSOA level based upon current data, National Grid's Future Energy Scenarios (FES) and UKPN, NPG, and WPD's Distribution Future Energy Scenarios (DFES).

(3) Raw data from which each of the above are generated, and R scripts used to generate the above databases from raw data. Links to sources of raw data are included in scripts to facilitate upadates to this framework as new data becomes available.


### Usage ###


The data may be explored using the following script:

- Import_UKLCTD.R

To generate the UKLCTD and scenarios from scratch, scripts are intended to be run in this order (names mostly self explanatory)

- Generate_UKLCTD.R
- Add_substations_to_UKLCTD.R
- Add_Scottish_rurality_to_UKLCTD.R
- Generate_NG_scenarios.R
- Add_DFES_scenarios_w_plot.R
- Cap_Deployment.R

(Note: before running these, 'root_path' variable will need to be updated in each script to reflect the path these files are kept in on your local repository)

Each of these scripts generates data used by subsequent scripts. These are broken down into stages and commented as far as possible.

Additional scripts produce violin plots and distribution plots based upon this data.

### Data Structure ###

Data: All raw data is in "Input_Data". This data can be updated as new information becomes available (input data files, sheets, and cells referred to in the above scripts will likely need to be updated accordingly). Data produced by these scripts in "Intermediate Data" and "Output Data" folders depending on whether it is used by subsequent scripts.

Plots are generated in the "Plots" folder

"Complementary_Analysis" contains scripts which support, but are not central to this analysis. This includes an initial attempt to attribute LSOAs to grid supply points, an analysis of Elexon data to indicate differences in temporal distribution of electricity usage (aggregated) across user types, an attribution of ruralities to Scottish LSOAs based on population density (replaced by attribution of rurality type performed by Scottish government in the final analysis) and an "Analysis" script which condusts some basic analysis of rurality in UKLCTD.


### Convention ###

These scripts were written with the following naming/processing convention in mind:

Databases: Source_Datatype_Resolution_Format (Ofgem_FiT_PV_LSOA_df)

Variables: Variable_Sector_Aggregation_Unit (eg. PV_dom_med_kW)

Processing: (1) Import/merge data, (2) Rename columns, (3) Subset data, (4) Process data, (5) export data

### Attribution ###

If this framework has been useful, please cite the following papers outlining our methodology:

Sheridan Few, Predrag Djapic, Goran Strbac, Jenny Nelson, and Chiara Candelise. ‘Assessing Local Costs and Impacts of Distributed Solar PV Using High Resolution Data from across Great Britain’. Renewable Energy 162 (December 2020): 1140–50. https://doi.org/10.1016/j.renene.2020.08.025.

Sheridan Few, Predrag Djapic, Goran Strbac, Jenny Nelson, and Chiara Candelise. 'Geographically disaggregated approach to integrate low carbon technologies across local electricity networks'. (Manuscript in preparation)
