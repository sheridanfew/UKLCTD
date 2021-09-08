# Script to cap deployment to 2
# Sheridan Few, Oct 2020
# See also readme file

### PACKAGES

library(data.table) # For fread to import subset of data (saving memory) - not currently implememnted
library(plyr) # For renaming data frame columns
library(stringr)
library(readxl)


### PATH DEFINITION

root_path <- '/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/'
input_path <- paste(root_path,'Input_data/',sep='')
intermediate_path <- paste(root_path,'Intermediate_data/',sep='') # This is where UKPVD is kept
output_path <- paste(root_path,'Output_data/',sep='')

### INPUT DATA

# UKPVD data with DFES data
UKPVD_DFES_2050_input <- "dFES/UKPVD_Scenarios_DFES_base_2050.csv" 

### OUTPUT DATA

# Capped LSOA level tech deployment
Capped_Deployment_output <- 'dFES/UKPVD_Scenarios_DFES_base_2050_capped.csv'

### DO STUFF

### 1. IMPORT UKPVD DATA
#############################################################################################################

# Import data
UKPVD_DFES_2050_df<-read.csv(paste(output_path,UKPVD_DFES_2050_input, sep=''), header=TRUE)


### 2. IMPOSE CAPS
#############################################################################################################

# Cap EVs at 2 per household

EV_cap<- 2 * UKPVD_DFES_2050_df$Meters_domestic

UKPVD_DFES_2050_df$EV_number[UKPVD_DFES_2050_df$EV_number > EV_cap] <- EV_cap[which(UKPVD_DFES_2050_df$EV_number > EV_cap)]

# Cap HPs at 2 per hopusehold

HP_cap<- 2 * UKPVD_DFES_2050_df$Meters_domestic

UKPVD_DFES_2050_df$Heatpumps_nonhybrid_installations[UKPVD_DFES_2050_df$Heatpumps_nonhybrid_installations > HP_cap] <- HP_cap[which(UKPVD_DFES_2050_df$Heatpumps_nonhybrid_installations > HP_cap)]

# Cap PV at 2 per hopusehold

Dom_PV_number_cap<- 2 * UKPVD_DFES_2050_df$Meters_domestic

Dom_PV_kw_cap<- 2 * 4 * UKPVD_DFES_2050_df$Meters_domestic

UKPVD_DFES_2050_df$PV_domestic_sum_kW[UKPVD_DFES_2050_df$PV_domestic_sum_kW > Dom_PV_kw_cap] <- Dom_PV_kw_cap[which(UKPVD_DFES_2050_df$PV_domestic_sum_kW > Dom_PV_kw_cap)]
UKPVD_DFES_2050_df$PV_domestic_installations[UKPVD_DFES_2050_df$PV_domestic_installations > Dom_PV_number_cap] <- Dom_PV_number_cap[which(UKPVD_DFES_2050_df$PV_domestic_installations > Dom_PV_number_cap)]


### 3. EXPORT CAPPED DATA
#############################################################################################################

write.table(UKPVD_DFES_2050_df, paste(output_path,Capped_Deployment_output, sep=''), sep=",", row.names=FALSE)
