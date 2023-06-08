# Script to import UKLCTD (current situation, not future scenarios)
# Sheridan Few, Oct 2020
# See also readme file

### PACKAGES

library(data.table)
library(plyr) 

### PATH DEFINITION

root_path <- '/Users/Shez/Library/CloudStorage/GoogleDrive-sheridan.few@gmail.com/My\ Drive/Grantham/JUICE/UKPVD/'
input_path <- paste(root_path,'Input_data/',sep='')
intermediate_path <- paste(root_path,'Intermediate_data/',sep='') # This is where UKLCTD is kept
output_path <- paste(root_path,'Output_data/',sep='')

### INPUT DATA

# UKLCTD containing recent LSOA-level data on spatial area, population, rurality, meter data, PV deployment, and substation density. Generated from raw data sources using 'Generate_UKLCTD.R', and substation data added using 'Add_substations_to_UKLCTD.R'
UKLCTD_input <- 'UKLCTD_w_substations_Oct2020.csv'

# VARIABLES (USED GLOBALLY)

# Definition of years of interest
years_of_interest_list<-c('2020','2030','2040','2050')

### DO STUFF

### 1. IMPORT UKLCTD
#############################################################################################################

# Import data
UKLCTD_df<-read.csv(paste(intermediate_path,UKLCTD_input, sep=''), header=TRUE)

Scot_UKLCTD_df <- subset(UKLCTD_df,  grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA) )

EW_UKLCTD_df <- subset(UKLCTD_df,  grepl("[E,W][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA) )


### 2. IMPORT UKLCTD future scenarios
#############################################################################################################

# Import data
UKLCTD_2030_df<-read.csv(paste(output_path,'dFES/UKLCTD_Scenarios_DFES_base_2030.csv', sep=''), header=TRUE)

UKLCTD_2040_df<-read.csv(paste(output_path,'dFES/UKLCTD_Scenarios_DFES_base_2040.csv', sep=''), header=TRUE)

UKLCTD_2050_df<-read.csv(paste(output_path,'dFES/UKLCTD_Scenarios_DFES_base_2050.csv', sep=''), header=TRUE)


### 3. Example commands for data analysis
#############################################################################################################

# PV installations per meter, 5th and 95th percentile

quantile(UKLCTD_2030_df$PV_domestic_installations/UKLCTD_2030_df$Meters_domestic,c(0.05,0.95))

quantile(UKLCTD_2030_df$Heatpumps_nonhybrid_installations/UKLCTD_2030_df$Meters_domestic,c(0.05,0.95))

# Cost estimates

PV_dom_cost_GBP =  2365 * 3.8  # UK Department for Energy Security and Net Zero 2023  https://www.gov.uk/government/statistics/solar-pv-cost-data

PV_nondom_cost_GBP =  1351 * 59  # UK Department for Energy Security and Net Zero 2023  https://www.gov.uk/government/statistics/solar-pv-cost-data

EV_dom_cost_GBP = 20000 # Lower end from Octopus Energy 2022 https://octopusev.com/ev-hub/how-much-does-an-electric-car-cost

HP_dom_cost_GBP = 10000 # Lower end from EDF 2023 (excluding Governmentgrant discount) https://www.edfenergy.com/heating/heat-pumps/air-source-heat-pump-guide


Total_cost = sum(UKLCTD_2050_df$PV_domestic_installations)*PV_dom_cost_GBP +
			 sum(UKLCTD_2050_df$PV_nondom_installations)*PV_dom_cost_GBP +
			 sum(UKLCTD_2050_df$EV_number)*EV_dom_cost_GBP +
			 sum(UKLCTD_2050_df$Heatpumps_nonhybrid_installations)*HP_dom_cost_GBP
