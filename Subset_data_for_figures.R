# Script to add substation number and GMT proportion, based on dom meter density, calibrated WPD data
# Sheridan Few, Oct 2020
# See also readme file

### PACKAGES

library(data.table) # For fread to import subset of data (saving memory) - not currently implememnted
library(plyr) # For renaming data frame columns
library(stringr)
library(readxl)


### PATH DEFINITION

root_path <- '/Users/Shez/Library/CloudStorage/GoogleDrive-sheridan.few@gmail.com/My\ Drive/Grantham/JUICE/UKLCTD/'
input_path <- paste(root_path,'Input_data/',sep='')
intermediate_path <- paste(root_path,'Intermediate_data/',sep='') # This is where UKLCTD is kept
output_path <- paste(root_path,'Output_data/',sep='')

### INPUT DATA

# UKLCTD containing recent LSOA-level data on spatial area, population, rurality, meter data, and PV deployment. Generated from raw data sources using 'Generate_UKLCTD.R'
UKLCTD_input <- 'UKLCTD_Oct2020.csv'

# UKLCTD data with DFES data
UKLCTD_DFES_2050_input <- "dFES/UKLCTD_Scenarios_DFES_base_2050.csv" 

# ONS Table to convert between OA, LSOA, and MSOA, source: https://geoportal.statistics.gov.uk/datasets/output-area-to-lsoa-to-msoa-to-local-authority-district-december-2017-lookup-with-area-classifications-in-great-britain/data date accessed: 8 Oct 2020
ONS_OA_LSOA_MSOA_conversion_input <- "ONS/Output_Area_to_LSOA_to_MSOA_to_Local_Authority_District__December_2017__Lookup_with_Area_Classifications_in_Great_Britain.csv" 

# List of LAs in regions

County_Durham_LAs<-c('County Durham','Darlington','Hartlepool','Stockton-on-Tees')
County_Durham_LAs<-c('County Durham')
London_LAs<-c('City of London', 'Barking and Dagenham', 'Barnet', 'Bexley', 'Brent', 'Bromley', 'Camden', 'Croydon', 'Ealing', 'Enfield', 'Greenwich', 'Hackney', 'Hammersmith and Fulham', 'Haringey', 'Harrow', 'Havering', 'Hillingdon', 'Hounslow', 'Islington', 'Kensington and Chelsea', 'Kingston upon Thames', 'Lambeth', 'Lewisham', 'Merton', 'Newham', 'Redbridge', 'Richmond upon Thames', 'Southwark', 'Sutton', 'Tower Hamlets', 'Waltham Forest', 'Wandsworth', 'Westminster')
W_Yorks_LAs<-c('Bradford','Calderdale','Kirklees','Leeds','Wakefield')
Yorks_Humber_LAs<-c('Bradford','Calderdale','Kirklees','Leeds','Wakefield',
'Barnsley','Doncaster','Rotherham','Sheffield',
'East Riding of Yorkshire','Kingston upon Hull, City of',
'Craven','Harrogate', 'Hambleton','Richmondshire','Ryedale','Scarborough','Selby','York',
'North East Lincolnshire','North Lincolnshire')



### OUTPUT DATA

# LSOAs in London & Durham
County_Durham_output <- 'County_Durham_LSOAs.csv'
London_output <- 'London_LSOAs.csv'
W_Yorks_output <- 'W_Yorks_LSOAs.csv'
Yorks_Humber_output <- 'Yorks_Humber_LSOAs.csv'


# Thresholds for low/med/high/v. high in heatmaps
Heatmap_thresholds_output <- 'Heatmap_thresholds.csv'


### DO STUFF

### 1. IMPORT ONS DATA WITH CORRESPONDENCE BETWEEN OAs, LSOAs, AND MSOAs (later used in processing BEIS data)
#############################################################################################################

# Import data
LSOA_LA_df<-read.csv(paste(input_path,ONS_OA_LSOA_MSOA_conversion_input, sep=''), header=TRUE)

# Rename columns
LSOA_LA_df  <- rename(LSOA_LA_df, c("LAD17NM"="LA"))
LSOA_LA_df  <- rename(LSOA_LA_df, c("LSOA11CD"="LSOA"))

# Select only relevant colummns
LSOA_LA_df<-LSOA_LA_df[c('LA','LSOA')]

# # Extract unique identifiers and generate lookup tables for which (1) MSOA an LSOA is in, (2) which LSOAs are in an MSOA, and similar for OAs/LSOAs
# OA_LSOA_df=subset(OA_LSOA_MSOA_df, select=c("OA", "LSOA"))
# OA_LSOA_lookup_df=unique(OA_LSOA_df)

LSOA_LA_df=subset(LSOA_LA_df, select=c("LA", "LSOA"))
LSOA_LA_lookup_df=unique(LSOA_LA_df)


### 2. IMPORT UKLCTD DATA
#############################################################################################################

# Import data
UKLCTD_df<-read.csv(paste(intermediate_path,UKLCTD_input, sep=''), header=TRUE)

UKLCTD_DFES_2050_df<-read.csv(paste(output_path,UKLCTD_DFES_2050_input, sep=''), header=TRUE)

### 3. IDENTIFY LSOAs IN C DURHAM & LONDON & EXPORT
#############################################################################################################

County_Durham_LSOAs<-LSOA_LA_lookup_df[which(LSOA_LA_lookup_df$LA %in% County_Durham_LAs),]

London_LSOAs<-LSOA_LA_lookup_df[which(LSOA_LA_lookup_df$LA %in% London_LAs),]

W_Yorks_LSOAs<-LSOA_LA_lookup_df[which(LSOA_LA_lookup_df$LA %in% W_Yorks_LAs),]

Yorks_Humber_LSOAs<-LSOA_LA_lookup_df[which(LSOA_LA_lookup_df$LA %in% Yorks_Humber_LAs),]

#write.table(County_Durham_LSOAs$LSOA, paste(output_path,County_Durham_output, sep=''), sep=",", row.names=FALSE)

#write.table(London_LSOAs$LSOA, paste(output_path,London_output, sep=''), sep=",", row.names=FALSE)

write.table(W_Yorks_LSOAs$LSOA, paste(output_path,W_Yorks_output, sep=''), sep=",", row.names=FALSE)

write.table(Yorks_Humber_LSOAs$LSOA, paste(output_path,Yorks_Humber_output, sep=''), sep=",", row.names=FALSE)


### 4. Subset UKLCTD data in C Durham & London to check range of ruralities
#############################################################################################################

County_Durham_UKLCTD_df<-UKLCTD_df[which(UKLCTD_df$LSOA %in% County_Durham_LSOAs$LSOA),]

London_UKLCTD_df<-UKLCTD_df[which(UKLCTD_df$LSOA %in% London_LSOAs$LSOA),]


### 5. Determine limits for low/mid/high PV/HP/EV penetration and export
#########################################################################

thresholds<-c(0.25,0.75,0.9)

EV_quantiles<-quantile(UKLCTD_DFES_2050_df$EV_number/UKLCTD_DFES_2050_df$Meters_domestic,thresholds)
HP_quantiles<-quantile(UKLCTD_DFES_2050_df$Heatpumps_nonhybrid_installations/UKLCTD_DFES_2050_df$Meters_domestic,thresholds)
PV_quantiles<-quantile((UKLCTD_DFES_2050_df$PV_domestic_sum_kW+UKLCTD_DFES_2050_df$PV_nondom_sum_kW)/UKLCTD_DFES_2050_df$Meters_domestic,thresholds)

Major_UKLCTD_DFES_2050_df<-UKLCTD_DFES_2050_df[which(UKLCTD_DFES_2050_df$Rurality_code == 'A1' | UKLCTD_DFES_2050_df$Rurality_code == 'B1'),]
City_UKLCTD_DFES_2050_df<-UKLCTD_DFES_2050_df[which(UKLCTD_DFES_2050_df$Rurality_code == 'C1' | UKLCTD_DFES_2050_df$Rurality_code == 'C2'),]
Town_UKLCTD_DFES_2050_df<-UKLCTD_DFES_2050_df[which(UKLCTD_DFES_2050_df$Rurality_code == 'D1' | UKLCTD_DFES_2050_df$Rurality_code == 'D2'),]
Village_UKLCTD_DFES_2050_df<-UKLCTD_DFES_2050_df[which(UKLCTD_DFES_2050_df$Rurality_code == 'E1' | UKLCTD_DFES_2050_df$Rurality_code == 'E2'),]

Major_MetPerSubs_quantiles<-quantile(Major_UKLCTD_DFES_2050_df$Meters_domestic/Major_UKLCTD_DFES_2050_df$N_Substations,thresholds)
City_MetPerSubs_quantiles<-quantile(City_UKLCTD_DFES_2050_df$Meters_domestic/City_UKLCTD_DFES_2050_df$N_Substations,thresholds)
Town_MetPerSubs_quantiles<-quantile(Town_UKLCTD_DFES_2050_df$Meters_domestic/Town_UKLCTD_DFES_2050_df$N_Substations,thresholds)
Village_MetPerSubs_quantiles<-quantile(Village_UKLCTD_DFES_2050_df$Meters_domestic/Village_UKLCTD_DFES_2050_df$N_Substations,thresholds)

Heatmap_limits<-rbind(EV_quantiles,HP_quantiles,PV_quantiles,Major_MetPerSubs_quantiles,City_MetPerSubs_quantiles,Town_MetPerSubs_quantiles,Village_MetPerSubs_quantiles)

write.table(Heatmap_limits, paste(output_path,Heatmap_thresholds_output, sep=''), sep=",", row.names=TRUE)
