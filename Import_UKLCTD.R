# Script to import UKLCTD (current situation, not future scenarios)
# Sheridan Few, Oct 2020
# See also readme file

### PACKAGES

library(data.table)
library(plyr) 

### PATH DEFINITION

root_path <- '/Users/Shez/Google Drive/Grantham/JUICE/UKLCTD/'
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
