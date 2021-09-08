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

# VARIABLES (USED GLOBALLY)

# Definition of years of interest
years_of_interest_list<-c('2020','2030','2040','2050')

### DO STUFF

### 1. IMPORT UKPVD
#############################################################################################################

# Import data
UKPVD_df<-read.csv(paste(intermediate_path,UKPVD_input, sep=''), header=TRUE)

Scot_UKPVD_df <- subset(UKPVD_df,  grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKPVD_df$LSOA) )

EW_UKPVD_df <- subset(UKPVD_df,  grepl("[E,W][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKPVD_df$LSOA) )
