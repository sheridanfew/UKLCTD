# UKPVD

### Overview ###


This repository contains:

(1) The United Kingdom Photovoltaics Database (UKPVD), a collection of geographically disaggregated data on PV deployment, network inrastructure, domestic and nondomestic meter density, electricity demand, and rurality at an LSOA level.

(2) Scenarios for deployment of photovoltaics (PV), heat pumps (HPs), electric vehicles (EVs), and battery storage upto 2050 at an LSOA level based upon National Grid's Future Energy Scenarios (FES) and UKPN, NPG, and WPD's Distribution Future Energy Scenarios (DFES)

(3) Raw data from which each of the above are generated, and R scripts used to generate the above databases from raw data. Links to sources of raw data are included in scripts where possiblem to facilitate


Data on PV deployment and other relevant quantities at an LSOA level. R scripts to generate and process this data.

### Usage ###


To generate the UKPVD and scenarios based upon this, scripts are intended to be run in this order (names mostly self explanatory)

- Generate_UKPVD.R
- Add_substations_to_UKPVD.R
- Generate_NG_scenarios.R
- Add_DFES_scenarios.R

(Note: before running these, 'root_path' variable will need to be updated in each script to reflect the path these files are kept in on your local repository)

Each of these scripts generates data used by subsequent scripts. These are broken down into stages and commented as far as possible.

### Directory Structure ###

Data: All raw data is in "Input_Data". This data can be updated as new information becomes available (input data files, sheets, and cells referred to in the above scripts will likely need to be updated accordingly). Data produced by these scripts in "Intermediate Data" and "Output Data" folders depending on whether it is used by subsequent scripts.

Plots are generated in the "Plots" folder

"Complementary_Analysis" contains scripts which support, but are not central to this analysis. This includes an initial attempt to attribute LSOAs to grid supply points, an analysis of Elexon data to indicate differences in temporal distribution of electricity usage (aggregated) across user types, an attribution of ruralities to Scottish LSOAs based on population density (replaced by attribution of rurality type performed by Scottish government in the final analysis) and an "Analysis" script which condusts some basic analysis of rurality in UKPVD.


### Convention ###

These scripts were written with the following naming/processing convention in mind (not perfectly followed):

Databases: Source_Datatype_Resolution_Format (Ofgem_FiT_PV_LSOA_df)

Variables: Variable_Sector_Aggregation_Unit (eg. PV_dom_med_kW)

Processing: (1) Import/merge data, (2) Rename columns, (3) Subset data, (4) Process data, (5) export data
