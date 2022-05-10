# Script to generate UKLCTD database directly from data sources
# Sheridan Few, Oct 2020
# See also readme file

### Packages

library(data.table) # For fread to import subset of data (saving memory) - not currently implememnted
library(plyr) # For renaming data frame columns
library(stringr)
library(readxl)


### PATH DEFINITION

root_path <- '/Users/Shez/Google Drive/Grantham/JUICE/UKLCTD/'
input_path <- paste(root_path,'Input_data/',sep='')
output_path <- paste(root_path,'Intermediate_data/',sep='') # UKLCTD is considered intermediate data as it is an output of sorts, but will be used for future processing

### INPUT DATA
# Note that while LSOA data for all aspects is available for England and Wales, only some is available for Scotland (elec demand & PV deployment), and Northern Ireland doesn't use LSOAs, so is excluded

# ONS Table to convert between OA, LSOA, and MSOA, source: https://geoportal.statistics.gov.uk/datasets/output-area-to-lsoa-to-msoa-to-local-authority-district-december-2017-lookup-with-area-classifications-in-great-britain/data date accessed: 8 Oct 2020
ONS_OA_LSOA_MSOA_conversion_input <- "ONS/Output_Area_to_LSOA_to_MSOA_to_Local_Authority_District__December_2017__Lookup_with_Area_Classifications_in_Great_Britain.csv" 

# ONS Population & Area by LSOA, source: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareapopulationdensity (Mid-2019: SAPE22DT11 edition) date accessed: 8 Oct 2020
ONS_Pop_Area_input <- "ONS/SAPE22DT11-mid-2019-lsoa-population-density.xlsx"

# ONS Table of rurality classifications by LSOA, source: https://data.gov.uk/dataset/b1165cea-2655-4cf7-bf22-dfbd3cdeb242/rural-urban-classification-2011-of-lower-layer-super-output-areas-in-england-and-wales date accessed: 8 Oct 2020
ONS_Rurality_input <- "ONS/Rural_Urban_Classification__2011__of_Lower_Layer_Super_Output_Areas_in_England_and_Wales.csv"

# Scottish Government Population & Area by LSOA, derived from GIS data, source: https://data.gov.uk/dataset/ab9f1f20-3b7f-4efa-9bd2-239acf63b540/data-zone-boundaries-2011
SG_Pop_Area_input <- "Scottish_Government/SG_DataZone_Bdry_2011.csv"

# BEIS Meter data, source: https://www.gov.uk/government/statistics/lower-and-middle-super-output-areas-electricity-consumption date accessed: 6 Oct 2020
BEIS_DomDem_input <- 'BEIS/LSOA_ELEC_2018.csv'
BEIS_NonDomDem_input <- 'BEIS/MSOA_NONDOM_ELEC_2018.csv'

# Ofgem FiT PV data, source: https://www.ofgem.gov.uk/publications-and-updates/feed-tariff-installation-report-30-september-2020 date accessed: 6 Oct 2020
Ofgem_FiT_data_1_input <- 'Ofgem/installation_report_oct2020_part_1.xlsx'
Ofgem_FiT_data_2_input <- 'Ofgem/installation_report_oct2020_part_2.xlsx'
Ofgem_FiT_data_3_input <- 'Ofgem/installation_report_oct2020_part_3.xlsx'

### OUTPUT DATA

UKLCTD_output <- 'UKLCTD_Oct2020.csv'

### DO STUFF (STEPS 1 - 7 TO GENERATE UKLCTD FROM INPUT DATA)

### 1. IMPORT ONS DATA WITH CORRESPONDENCE BETWEEN OAs, LSOAs, AND MSOAs (later used in processing BEIS data)
#############################################################################################################

# Import data
OA_LSOA_MSOA_df<-read.csv(paste(input_path,ONS_OA_LSOA_MSOA_conversion_input, sep=''), header=TRUE)

# Rename columns
OA_LSOA_MSOA_df  <- rename(OA_LSOA_MSOA_df, c("OA11CD"="OA"))
OA_LSOA_MSOA_df  <- rename(OA_LSOA_MSOA_df, c("LSOA11CD"="LSOA"))
OA_LSOA_MSOA_df  <- rename(OA_LSOA_MSOA_df, c("MSOA11CD"="MSOA"))

# Select only relevant colummns
OA_LSOA_MSOA_df<-OA_LSOA_MSOA_df[c('OA','LSOA','MSOA')]

# # Extract unique identifiers and generate lookup tables for which (1) MSOA an LSOA is in, (2) which LSOAs are in an MSOA, and similar for OAs/LSOAs
# OA_LSOA_df=subset(OA_LSOA_MSOA_df, select=c("OA", "LSOA"))
# OA_LSOA_lookup_df=unique(OA_LSOA_df)

LSOA_MSOA_df=subset(OA_LSOA_MSOA_df, select=c("LSOA", "MSOA"))
LSOA_MSOA_lookup_df=unique(LSOA_MSOA_df)


### 2. IMPORT ONS DATA FOR AREA & POPULATION (only for England and Wales)
############################################

# Import data
ONS_Pop_Area_LSOA_df <- as.data.frame(read_excel(paste(input_path,ONS_Pop_Area_input, sep=''),sheet="Mid-2019 Population Density", skip=4))

# Rename columns
ONS_Pop_Area_LSOA_df <- rename(ONS_Pop_Area_LSOA_df, c("LSOA Code"="LSOA"))
ONS_Pop_Area_LSOA_df <- rename(ONS_Pop_Area_LSOA_df, c("Area Sq Km"="Area_km2"))
ONS_Pop_Area_LSOA_df <- rename(ONS_Pop_Area_LSOA_df, c("Mid-2019 population"="Population"))
ONS_Pop_Area_LSOA_df <- rename(ONS_Pop_Area_LSOA_df, c("People per Sq Km"="Population_density"))

# Select only relevant colummns
ONS_Pop_Area_LSOA_df<-ONS_Pop_Area_LSOA_df[c('LSOA','Population','Area_km2','Population_density')]

### 2b. IMPORT SCOTTISH GOVERNMENT DATA FOR AREA & POPULATION IN SCOTLAND
#########################################################################

# Import data
SG_Pop_Area_LSOA_df <- read.csv(paste(input_path,SG_Pop_Area_input, sep=''), header=TRUE)

# Rename columns 
# NB. Technically Scottish Datazones are different from LSOAs - a bit smaller, but other data (eg. BEIS, OfGem) include Scottish data at a datazone level
SG_Pop_Area_LSOA_df <- rename(SG_Pop_Area_LSOA_df, c("DataZone"="LSOA")) 
SG_Pop_Area_LSOA_df <- rename(SG_Pop_Area_LSOA_df, c("StdAreaKm2"="Area_km2"))
SG_Pop_Area_LSOA_df <- rename(SG_Pop_Area_LSOA_df, c("TotPop2011"="Population"))

# Select only relevant colummns
SG_Pop_Area_LSOA_df<-SG_Pop_Area_LSOA_df[c('LSOA','Population','Area_km2')]

# Generate population density column
SG_Pop_Area_LSOA_df$Population_density <- SG_Pop_Area_LSOA_df$Population / SG_Pop_Area_LSOA_df$Area_km2


### 2c. COMBINE ENGLISH, WELSH, & SCOTTISH DATA FOR AREA & POPULATION
#############################################################

Combined_Pop_Area_LSOA_df <- rbind(ONS_Pop_Area_LSOA_df,SG_Pop_Area_LSOA_df)


### 3. IMPORT ONS DATA FOR RURALITY BY LSOA (Data available only for England and Wales)
############################################

# Import data
ONS_Rurality_LSOA_df<-read.csv(paste(input_path,ONS_Rurality_input, sep=''), header=TRUE)

# Rename columns
ONS_Rurality_LSOA_df  <- rename(ONS_Rurality_LSOA_df, c("LSOA11CD"="LSOA"))
ONS_Rurality_LSOA_df  <- rename(ONS_Rurality_LSOA_df, c("RUC11CD"="Rurality_code"))
ONS_Rurality_LSOA_df  <- rename(ONS_Rurality_LSOA_df, c("RUC11"="Rurality_description"))

# Select only relevant colummns
ONS_Rurality_LSOA_df<-ONS_Rurality_LSOA_df[c('LSOA','Rurality_code','Rurality_description')]

### 4. IMPORT BEIS DATA, DIVIDE MSOA DATA AMONG LSOAs AND TRIM TO ONLY DATA OF INTEREST (Data available for England, Wales, and Scotland)
#############################################################################################################

# Import data
BEIS_DomMeters_LSOA_df<-read.csv(paste(input_path,BEIS_DomDem_input, sep=''), header=TRUE)
BEIS_NonDomMeters_MSOA_df<-read.csv(paste(input_path,BEIS_NonDomDem_input, sep=''), header=TRUE)

# Rename columns
BEIS_DomMeters_LSOA_df  <- rename(BEIS_DomMeters_LSOA_df, c("LSOACode"="LSOA"))
BEIS_DomMeters_LSOA_df  <- rename(BEIS_DomMeters_LSOA_df, c("METERS"="Meters_domestic"))
BEIS_DomMeters_LSOA_df  <- rename(BEIS_DomMeters_LSOA_df, c("KWH"="Demand_domestic_sum_kWh"))
BEIS_DomMeters_LSOA_df  <- rename(BEIS_DomMeters_LSOA_df, c("MEDIAN"="Demand_domestic_median_kWh"))

BEIS_NonDomMeters_MSOA_df  <- rename(BEIS_NonDomMeters_MSOA_df, c("MSOACode"="MSOA"))
BEIS_NonDomMeters_MSOA_df  <- rename(BEIS_NonDomMeters_MSOA_df, c("METERS"="Meters_nondom"))
BEIS_NonDomMeters_MSOA_df  <- rename(BEIS_NonDomMeters_MSOA_df, c("KWH"="Demand_nondom_sum_kWh"))
BEIS_NonDomMeters_MSOA_df  <- rename(BEIS_NonDomMeters_MSOA_df, c("MEDIAN"="Demand_nondom_median_kWh"))

# Exclude lines which don't refer to an LSOA/MSOA (rows at the end include 'unallocated' data)
BEIS_DomMeters_LSOA_df <- subset(BEIS_DomMeters_LSOA,  grepl("[A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , BEIS_DomMeters_LSOA_df$LSOA) )
BEIS_NonDomMeters_MSOA_df <- subset(BEIS_NonDomMeters_MSOA,  grepl("[A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" , BEIS_NonDomMeters_MSOA_df$MSOA) )

# Select only relevant colummns
BEIS_DomMeters_LSOA_df<-BEIS_DomMeters_LSOA_df[c('LSOA','Meters_domestic','Demand_domestic_sum_kWh','Demand_domestic_median_kWh')]
BEIS_NonDomMeters_MSOA_df<-BEIS_NonDomMeters_MSOA_df[c('MSOA','Meters_nondom','Demand_nondom_sum_kWh','Demand_nondom_median_kWh')]

# Initiate dataframe to convert nondom data to LSOA level (from original MSOA level)
BEIS_NonDomMeters_LSOA_df <- subset(LSOA_MSOA_lookup_df, select=c("LSOA"))

# Add columns for nondomestic demand (to be filled in subsequent 'apply' routine)
BEIS_NonDomMeters_LSOA_df$Demand_nondom_sum_kWh<-NA
BEIS_NonDomMeters_LSOA_df$Meters_nondom<-NA
BEIS_NonDomMeters_LSOA_df$Demand_nondom_median_kWh<-NA


# Routine to divide nondom MSOA meters and demand between constituent LSOAs - I wrote this a while ago and it's a bit slow and clunky, but it works
# NB. This step may take more than ten mins, make a cup of tea or have lunch?
length=length(t(subset(BEIS_NonDomMeters_MSOA_df,select=c("MSOA"))))
#progress<-0
print ('Beginning MSOA processing...')
apply(BEIS_NonDomMeters_MSOA_df, 1, function(x) {
	# Function to divide demand between LSOAs and put into BEIS_NonDomMeters_LSOA_df frame - to apply to each row of BEIS_NonDomMeters_MSOA_df
	MSOA <- x[1]
	NonDomDem_MSOA_kWh <- as.numeric(x[3])
	NonDomMeters_MSOA <- as.numeric(x[2])
	NonDomDemMedian_kWh <- as.numeric(x[4])
	LSOAs=as.vector(LSOA_MSOA_lookup_df$LSOA[which(LSOA_MSOA_lookup_df$MSOA==x[1])])
	N_LSOAs <- length(LSOAs)
	NonDomDem_LSOA_kWh <- NonDomDem_MSOA_kWh/N_LSOAs
	NonDomMeters_LSOA <- NonDomMeters_MSOA/N_LSOAs
	lapply (LSOAs, function(y) {
		index = which(BEIS_NonDomMeters_LSOA_df$LSOA==y)
		BEIS_NonDomMeters_LSOA_df$Demand_nondom_sum_kWh[index] <<- NonDomDem_LSOA_kWh
		BEIS_NonDomMeters_LSOA_df$Meters_nondom[index] <<- NonDomMeters_LSOA
		BEIS_NonDomMeters_LSOA_df$Demand_nondom_median_kWh[index] <<- NonDomDemMedian_kWh
	})
	#progress <<- progress + 1 
	#progress(progress, length)
})

BEIS_Meter_data_processed_df <- merge(BEIS_DomMeters_LSOA_df,BEIS_NonDomMeters_LSOA_df,by='LSOA',all=TRUE)

# Final data cleaning (removes 25 LSOAs with NA or nonsensical negative demand values)
BEIS_Meter_data_processed_df$Demand_nondom_sum_kWh[BEIS_Meter_data_processed_df$Demand_nondom_sum_kWh < 0] <- NA
BEIS_Meter_data_processed_df <- na.omit(BEIS_Meter_data_processed_df)

# Remove these to save memory
rm(BEIS_NonDomMeters_MSOA_df,OA_LSOA_MSOA_df,LSOA_MSOA_df,LSOA_MSOA_lookup_df)
gc()

### 5. IMPORT OFGEM DATA AND TRIM TO ONLY PV DATA OF INTEREST
##############################################################


# Import data and merge to one df - ranges specified in a cumbersome manner because certain columns were causing input errors when importing the entire sheet

Ofgem_FiT_data_1 <- as.data.frame(cbind(read_excel(paste(input_path,Ofgem_FiT_data_1_input, sep=''),sheet='Part 1',cell_limits(c(5, 3), c(NA, 12))),
										read_excel(paste(input_path,Ofgem_FiT_data_1_input, sep=''),sheet='Part 1',cell_limits(c(5, 20), c(NA, 20)))))

Ofgem_FiT_data_2 <- as.data.frame(cbind(read_excel(paste(input_path,Ofgem_FiT_data_2_input, sep=''),sheet='Part 2',cell_limits(c(5, 3), c(NA, 12))),
										read_excel(paste(input_path,Ofgem_FiT_data_2_input, sep=''),sheet='Part 2',cell_limits(c(5, 20), c(NA, 20)))))

Ofgem_FiT_data_3 <- as.data.frame(cbind(read_excel(paste(input_path,Ofgem_FiT_data_3_input, sep=''),sheet='Part 3',cell_limits(c(5, 3), c(NA, 12))),
										read_excel(paste(input_path,Ofgem_FiT_data_3_input, sep=''),sheet='Part 3',cell_limits(c(5, 20), c(NA, 20)))))


Ofgem_FiT_data_combined <- rbind(Ofgem_FiT_data_1,Ofgem_FiT_data_2,Ofgem_FiT_data_3)

# Rename colummns
Ofgem_FiT_data_combined  <- rename(Ofgem_FiT_data_combined, c("Installed capacity"="cap_kW"))
Ofgem_FiT_data_combined  <- rename(Ofgem_FiT_data_combined, c("LLSOA Code"="LSOA"))
Ofgem_FiT_data_combined  <- rename(Ofgem_FiT_data_combined, c("Installation Type"="InstallationType"))


# Select only PV
Ofgem_FiT_data_PV <- Ofgem_FiT_data_combined[ which(Ofgem_FiT_data_combined$Technology=='Photovoltaic'), ]

# Get total capacity, median size, and number of dom PV installations by LSOA
FiT_LSOA_PV_dom_data = subset(Ofgem_FiT_data_PV, InstallationType=='Domestic',select=c("LSOA","cap_kW"))
FiT_LSOA_PV_dom_sum_data = aggregate(.~LSOA, FiT_LSOA_PV_dom_data, sum)
FiT_LSOA_PV_dom_sum_data  <- rename(FiT_LSOA_PV_dom_sum_data, c("cap_kW"="PV_domestic_sum_kW"))
FiT_LSOA_PV_dom_med_data = aggregate(.~LSOA, FiT_LSOA_PV_dom_data, median)
FiT_LSOA_PV_dom_med_data  <- rename(FiT_LSOA_PV_dom_med_data, c("cap_kW"="PV_domestic_median_kW"))
FiT_LSOA_PV_dom_count_data = count(FiT_LSOA_PV_dom_data, vars = "LSOA")
FiT_LSOA_PV_dom_count_data  <- rename(FiT_LSOA_PV_dom_count_data, c("freq"="PV_domestic_installations"))

# Get total capacity, median size, and number of nondom PV installations by LSOA
FiT_LSOA_PV_nondom_data = subset(Ofgem_FiT_data_PV, InstallationType!='Domestic',select=c("LSOA","cap_kW"))
FiT_LSOA_PV_nondom_sum_data = aggregate(.~LSOA, FiT_LSOA_PV_nondom_data, sum)
FiT_LSOA_PV_nondom_sum_data  <- rename(FiT_LSOA_PV_nondom_sum_data, c("cap_kW"="PV_nondom_sum_kW"))
FiT_LSOA_PV_nondom_med_data = aggregate(.~LSOA, FiT_LSOA_PV_nondom_data, median)
FiT_LSOA_PV_nondom_med_data  <- rename(FiT_LSOA_PV_nondom_med_data, c("cap_kW"="PV_nondom_median_kW"))
FiT_LSOA_PV_nondom_count_data = count(FiT_LSOA_PV_nondom_data, vars = "LSOA")
FiT_LSOA_PV_nondom_count_data  <- rename(FiT_LSOA_PV_nondom_count_data, c("freq"="PV_nondom_installations"))


# Merge Ofgem data (for explanation of merging technique see https://www.musgraveanalytics.com/blog/2018/2/12/how-to-merge-multiple-data-frames-using-base-r )
# The above command maintains all LSOAs in the merge (ie. including those where there is dom but no nondom PV deployment) and puts NAs where there is no data for a given colume
Ofgem_FiT_data_processed_df <- Reduce(function(x, y){merge(x, y, by= "LSOA", all.x= TRUE, all.y= TRUE)}, 
	list(FiT_LSOA_PV_dom_sum_data, FiT_LSOA_PV_dom_med_data, FiT_LSOA_PV_dom_count_data, FiT_LSOA_PV_nondom_sum_data, FiT_LSOA_PV_nondom_med_data, FiT_LSOA_PV_nondom_count_data))

# Where appropriate, replace NAs with zeroes (sum capacity and number of installations, but not median cap)
Ofgem_FiT_data_processed_df$PV_domestic_sum_kW[is.na(Ofgem_FiT_data_processed_df$PV_domestic_sum_kW)] <- 0
Ofgem_FiT_data_processed_df$PV_domestic_installations[is.na(Ofgem_FiT_data_processed_df$PV_domestic_installations)] <- 0
Ofgem_FiT_data_processed_df$PV_nondom_sum_kW[is.na(Ofgem_FiT_data_processed_df$PV_nondom_sum_kW)] <- 0
Ofgem_FiT_data_processed_df$PV_nondom_installations[is.na(Ofgem_FiT_data_processed_df$PV_nondom_installations)] <- 0

### 6. COMBINE DATA INTO ONE DATABASE
##############################################################
UKLCTD_df <- Reduce(function(x, y){merge(x, y, by= "LSOA", all.x= TRUE, all.y= TRUE)}, 
	list(Combined_Pop_Area_LSOA_df, ONS_Rurality_LSOA_df, BEIS_Meter_data_processed_df, Ofgem_FiT_data_processed_df))

# Where appropriate, replace NAs with zeroes in PV data (sum capacity and number of installations per LSOA leading to zero where none installed, but retain NA for median cap)
UKLCTD_df$PV_domestic_sum_kW[is.na(UKLCTD_df$PV_domestic_sum_kW)] <- 0
UKLCTD_df$PV_domestic_installations[is.na(UKLCTD_df$PV_domestic_installations)] <- 0
UKLCTD_df$PV_nondom_sum_kW[is.na(UKLCTD_df$PV_nondom_sum_kW)] <- 0
UKLCTD_df$PV_nondom_installations[is.na(UKLCTD_df$PV_nondom_installations)] <- 0

# Remove LSOAs with missing values for number of meters (general cleanup of data)
UKLCTD_df <- UKLCTD_df[rowSums(is.na(UKLCTD_df[7:12])) == 0,]

### 7. EXPORT UKLCTD
##############################################################

write.table(UKLCTD_df, paste(output_path,UKLCTD_output, sep=''), sep=",", row.names=FALSE)

