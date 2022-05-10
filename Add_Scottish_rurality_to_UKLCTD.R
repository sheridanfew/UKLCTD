# Script to assign rurality type to Scottish datazones based upon meter density
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
# ONS Table to convert between LA and LSOA, source: https://geoportal.statistics.gov.uk/datasets/output-area-to-lsoa-to-msoa-to-local-authority-district-december-2017-lookup-with-area-classifications-in-great-britain/data date accessed: 8 Oct 2020
ONS_OA_LSOA_MSOA_LA_conversion_input <- "ONS/Output_Area_to_LSOA_to_MSOA_to_Local_Authority_District__December_2017__Lookup_with_Area_Classifications_in_Great_Britain.csv" 

# UKLCTD containing recent LSOA-level data on spatial area, population, rurality, meter data, PV deployment, and substation density. Generated from raw data sources using 'Generate_UKLCTD.R', and substation data added using 'Add_substations_to_UKLCTD.R'
UKLCTD_input <- 'UKLCTD_w_substations_Oct2020.csv'


### DO STUFF

### 1. IMPORT UKLCTD
#############################################################################################################

UKLCTD_df<-read.csv(paste(intermediate_path,UKLCTD_input, sep=''), header=TRUE)


### 2. GET STATS FOR METER DENSITY PER RURALITY CONTEXT
#############################################################################################################

UKLCTD_df$Meter_density_dom<-UKLCTD_df$Meters_domestic/UKLCTD_df$Area_km2

#Rurality_Meter_Density_df <-UKLCTD_df[Rurality_code,Meter_density_dom]
Rurality_Meter_Density_df <- subset(UKLCTD_df,select=c('Rurality_code','Meter_density_dom'))

# Get rurality codes (but only those ending in 1)
Rurality_types<-as.character(unique(UKLCTD_df$Rurality_code)[1:5])

Rurality_types<-Rurality_types[order(Rurality_types)]

median_densities_by_rurality<-sapply(Rurality_types,function(rurality)
{
	median(UKLCTD_df[which(UKLCTD_df$Rurality_code==rurality),]$Meter_density_dom)
})

mean_densities_by_rurality<-sapply(Rurality_types,function(rurality)
{
	mean(UKLCTD_df[which(UKLCTD_df$Rurality_code==rurality),]$Meter_density_dom)
})

sd_densities_by_rurality<-sapply(Rurality_types,function(rurality)
{
	sd(UKLCTD_df[which(UKLCTD_df$Rurality_code==rurality),]$Meter_density_dom)
})

density_stats_by_rurality<-rbind(median=median_densities_by_rurality,mean=mean_densities_by_rurality,sd=sd_densities_by_rurality)

rownames(density_stats_by_rurality)<-Rurality_types

### 3. USE THE ABOVE TO IDENTIFY BEST FIT FOR RURALITY CONTEXT OF SCOTTISH LSOAS (smallest number of SDs from median meter densities of a given rurality type in data from English and Welsh LSOAs)
#############################################################################################################

# These values define limits at which meter density is at the edge of the window to be considered in each rurality category A-D

maxima<-sapply(c(1:(length(Rurality_types)-1)),function(rurality_id){
	rurality_type<-Rurality_types[rurality_id]
	next_rurality_type<-Rurality_types[rurality_id+1]
	maximum<-density_stats_by_rurality['median',rurality_type]+(density_stats_by_rurality['median',next_rurality_type]-density_stats_by_rurality['median',rurality_type])*density_stats_by_rurality['sd',rurality_type]/(density_stats_by_rurality['sd',rurality_type]+density_stats_by_rurality['sd',next_rurality_type])
	return(maximum)
})

# Make array to compare Scottish LSOA meter densities to, containing windows to make sure LSOAs fall in correct categories

max_min_array<-c(maxima[1]+0.01,maxima[1]-0.01,maxima[2]+0.01,maxima[2]-0.01,maxima[3]+0.01,maxima[3]-0.01,maxima[4]+0.01,maxima[4]-0.01)
names(max_min_array)<-c('A1','B1','B1','C1','C1','D1','D1','E1')

# Compare Scottish LSOAs and assign rurality code

UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_code<-sapply(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Meter_density_dom,function(dom_meter_density){
	names(max_min_array)[(which.min((max_min_array-dom_meter_density)^2))]
})

# Add rurality description

rurality_description_by_code<-unique(UKLCTD_df$Rurality_description)
names(rurality_description_by_code)<-unique(UKLCTD_df$Rurality_code)

UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_description<-sapply(
UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_code,function(rurality_code){
	return(as.character(rurality_description_by_code[as.character(rurality_code)]))
})


# (Currently not implemented) Replace A1, B1 with C1 for Scottish LSOAs - A1, B1, C1 more based on wider surroundings than properties of the LSOA itself

# UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA) & grepl("[A-B]1" , UKLCTD_df$Rurality_code)),]$Rurality_code<-'C1'

# Export dataframe:

write.csv(UKLCTD_df, paste(intermediate_path,'UKLCTD_w_substations_w_Scot_Rurality_Oct2020.csv', sep=''), row.names=FALSE)


# 4  Look at some stats comparing distribution of ruralities in Scottish LSOAs to the UK as a whole -> similar proportion in cities, more in villages, fewer in towns 
#############################################################################################################


table(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_code)

table(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_code)/table(UKLCTD_df$Rurality_code)*nrow(UKLCTD_df)/nrow(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),])


UKLCTD_df$Rurality_class<-NA
UKLCTD_df[which(grepl("[A-C][1-2]" , UKLCTD_df$Rurality_code)),]$Rurality_class<-"City"
UKLCTD_df[which(grepl("D[1-2]" , UKLCTD_df$Rurality_code)),]$Rurality_class<-"Town"
UKLCTD_df[which(grepl("E[1-2]" , UKLCTD_df$Rurality_code)),]$Rurality_class<-"Village"

table(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_class)/table(UKLCTD_df$Rurality_class)*nrow(UKLCTD_df)/nrow(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),])

table(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_class)/table(UKLCTD_df[which(grepl("[E,W][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),]$Rurality_class)*nrow(UKLCTD_df[which(grepl("[E,W][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),])/nrow(UKLCTD_df[which(grepl("S[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , UKLCTD_df$LSOA)),])
