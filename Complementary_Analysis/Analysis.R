# Conduct Analysis
# Sheridan Few, Oct 2020
# See also readme file

### PACKAGES

library(data.table) # For fread to import subset of data (saving memory) - not currently implememnted
library(plyr) # For renaming data frame columns
library(stringr)
library(readxl)


### PATH DEFINITION

root_path <- '/Users/Shez/Google Drive/Grantham/JUICE/UKLCTD/'
input_path <- paste(root_path,'Input_data/',sep='')
intermediate_path <- paste(root_path,'Intermediate_data/',sep='') # This is where UKLCTD is kept
output_path <- paste(root_path,'Output_data/',sep='') # NB. These are the same here - output here is intermediate

### INPUT DATA

# UKLCTD containing recent LSOA-level data on spatial area, population, rurality, meter data, and PV deployment. Generated from raw data sources using 'Generate_UKLCTD.R'
UKLCTD_input <- 'UKLCTD_Oct2020.csv'

### DO STUFF
##############################################################

# Import data
UKLCTD_df<-read.csv(paste(intermediate_path,UKLCTD_input, sep=''), header=TRUE)

### ANALYSE RURALITY PROPERTIES
##############################################################


# List of rurality types
Ruralities_list <- unique(UKLCTD_df$Rurality_description)

# Separate UKLCTD dfs by rurality in list
UKLCTD_dfs_by_rurality<-lapply(Ruralities_list, function(rurality){
	return(UKLCTD_df[ which(UKLCTD_df$Rurality_description==rurality), ])
})
names(UKLCTD_dfs_by_rurality)<-Ruralities_list


# Get stats on area and number of LSOAs by rurality
rurality_stats<-sapply(UKLCTD_dfs_by_rurality, function(df){
	mean_area<-mean(df$Area_km2)
	sd_area<-sd(df$Area_km2)
	N_LSOAs<-length(df$LSOA)
	return(c(mean_area,sd_area,N_LSOAs))
})

# Combine stats into one df
rurality_stats_df<-transpose(as.data.frame(rurality_stats))
names(rurality_stats_df)<-c('mean_area','sd_area','N_LSOAs')
rurality_stats_df<-cbind(Rurality=Ruralities_list,rurality_stats_df)[order(rurality_stats_df$mean_area),]

# See how many LSOAs in UKLCTD/NPG region are in a given rurality - could be useful in estimating ruralities and scenario application to Scottish LSOAs
intersect(UKLCTD_dfs_by_rurality[['Rural village and dispersed in a sparse setting']]$LSOA,UKLCTD_UKPN_DFES_df[['2020']]$LSOA)
intersect(UKLCTD_dfs_by_rurality[['Rural village and dispersed in a sparse setting']]$LSOA,UKLCTD_NPG_DFES_df[['2020']]$LSOA)

