# Script to import UKPVD (current situation, not future scenarios)
# Sheridan Few, Oct 2020
# See also readme file

### PACKAGES

library(data.table)
library(plyr) 

### PATH DEFINITION

root_path <- '/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/'
input_path <- paste(root_path,'Input_data/',sep='')
intermediate_path <- paste(root_path,'Intermediate_data/',sep='') # This is where UKPVD is kept
output_path <- paste(root_path,'Output_data/',sep='')

### INPUT DATA

# UKPVD containing recent LSOA-level data on spatial area, population, rurality, meter data, PV deployment, and substation density. Generated from raw data sources using 'Generate_UKPVD.R', and substation data added using 'Add_substations_to_UKPVD.R'
UKPVD_input <- 'UKPVD_w_substations_Oct2020.csv'


UKPVD_FES_2020 <- read.csv('/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/Intermediate_data/FES/UKPVD_Scenarios_FES2019_2020.csv', header=TRUE)

UKPVD_FES_2050 <- read.csv('/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/Intermediate_data/FES/UKPVD_Scenarios_FES2019_2050.csv', header=TRUE)


UKPVD_dFES_2030 <- read.csv('/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/Output_data/dFES/UKPVD_Scenarios_DFES_base_2030.csv', header=TRUE)
UKPVD_dFES_2040 <- read.csv('/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/Output_data/dFES/UKPVD_Scenarios_DFES_base_2040.csv', header=TRUE)
UKPVD_dFES_2050 <- read.csv('/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/Output_data/dFES/UKPVD_Scenarios_DFES_base_2050.csv', header=TRUE)



# Households 2050 (based on ONS population growth stats, assuming similar trends in GB and NI and same no. of ppl per household in 2050 as 2020)

# Based on https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationprojections/bulletins/nationalpopulationprojections/2018based 

UK_pop_2050 <- 73614759 
UK_pop_2035 <- 73200000
UK_pop_2020 <- 67195769
NI_pop_2020 <- 1890000
GB_pop_2050 <- (UK_pop_2020 - NI_pop_2020) * UK_pop_2050 / UK_pop_2020
GB_pop_2035 <- (UK_pop_2020 - NI_pop_2020) * UK_pop_2035 / UK_pop_2020
UK_ppl_per_house <- 2.39
GB_households_2050 <- GB_pop_2050 / UK_ppl_per_house
GB_households_2035 <- GB_pop_2035 / UK_ppl_per_house


UK_NetZero_HPs_Hi_2035 <- 11000000
UK_NetZero_HPs_Lo_2035 <- 7000000



# LCTs Deployment

PV_growth_factor <- sum(UKPVD_FES_2050$PV_domestic_sum_kW + UKPVD_FES_2050$PV_nondom_sum_kW)/sum(UKPVD_FES_2020$PV_domestic_sum_kW + UKPVD_FES_2020$PV_nondom_sum_kW)

PV_kW_per_household_2050 <- sum(UKPVD_FES_2050$PV_domestic_sum_kW + UKPVD_FES_2050$PV_nondom_sum_kW)/GB_households_2050

EVs_per_household_2050 <- sum(UKPVD_FES_2050$EV_number)/GB_households_2050

HPs_per_household_no_hybrid_FES_2050 <- sum(UKPVD_FES_2050$Heatpumps_nonhybrid_installations)/GB_households_2050

HPs_per_household_w_hybrid_FES_2050 <- sum(UKPVD_FES_2050$Heatpumps_nonhybrid_installations + UKPVD_FES_2050$Heatpumps_hybrid_installations)/GB_households_2035

HPs_per_household_no_hybrid_2050 <- sum(UKPVD_dFES_2050$Heatpumps_nonhybrid_installations)/GB_households_2050

HPs_per_household_w_hybrid_2050 <- sum(UKPVD_dFES_2050$Heatpumps_nonhybrid_installations + UKPVD_dFES_2050$Heatpumps_hybrid_installations)/GB_households_2035

HPs_per_household_2035 <- 0.5 * sum(UKPVD_dFES_2030$Heatpumps_nonhybrid_installations + UKPVD_dFES_2040$Heatpumps_nonhybrid_installations)/GB_households_2035

HPs_per_household_UK_NetZero_Hi_2035 <- UK_NetZero_HPs_Hi_2035/GB_households_2035

HPs_per_household_UK_NetZero_Lo_2035 <- UK_NetZero_HPs_Lo_2035/GB_households_2035
