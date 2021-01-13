# Script to generate NG scenarios from UKPVD database directly from data sources
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
output_path <- paste(root_path,'Output_data/',sep='') # NB. These are the same here - output here is intermediate

### INPUT DATA

# UKPVD containing recent LSOA-level data on spatial area, population, rurality, meter data, PV deployment, and substation density. Generated from raw data sources using 'Generate_UKPVD.R', and substation data added using 'Add_substations_to_UKPVD.R'
UKPVD_input <- 'UKPVD_w_substations_Oct2020.csv'

# National Grid Future Energy Scenarios 2019 data workbook source: https://www.nationalgrideso.com/future-energy/future-energy-scenarios/fes-2019-documents date accessed: 9 Oct 2020
NG_FES_input <- "National_Grid/fes-data-workbook-v30.xlsx" 

### OUTPUT DATA
FES_output <- 'UKPVD_Scenarios_FES2019_'

# VARIABLES (USED GLOBALLY)

# Definition of years of interest
years_of_interest_list<-c('2020','2030','2040','2050')

### DO STUFF

### 1. IMPORT UKPVD
#############################################################################################################

# Import data
UKPVD_df<-read.csv(paste(intermediate_path,UKPVD_input, sep=''), header=TRUE)

### 2. IMPORT NG FES SCENARIOS
#############################################################################################################

# Import data (Community Renewables scenario only)
NG_FES_Microgeneration_GW_df <- as.data.frame(read_excel(paste(input_path,NG_FES_input, sep=''),sheet='3.2',range="O8:AZ13"))
NG_FES_EVPeak_GW_df <- as.data.frame(read_excel(paste(input_path,NG_FES_input, sep=''),sheet='4.24',range="L7:AV10"))
NG_FES_EV_number_df <- as.data.frame(read_excel(paste(input_path,NG_FES_input, sep=''),sheet='ED5',range="G9:AP10",col_names=FALSE))
NG_FES_HeatPumps_Installations_df <- as.data.frame(read_excel(paste(input_path,NG_FES_input, sep=''),sheet='4.12',range="K8:S22"))
NG_FES_Stor_Decentralised_MW_df <- as.data.frame(read_excel(paste(input_path,NG_FES_input, sep=''),sheet='ES1',range="G38:AM38",col_names=FALSE))

# Rename columns where appropriate
names(NG_FES_Microgeneration_GW_df)<-c('Attribute',2014:2050)
names(NG_FES_EVPeak_GW_df)<-c('Charging_regime',2015:2050)
names(NG_FES_EV_number_df)<-c(2015:2050)
names(NG_FES_HeatPumps_Installations_df)[1]<-'Technology'
names(NG_FES_Stor_Decentralised_MW_df)<-c(2018:2050)

rownames(NG_FES_Microgeneration_GW_df)<-NG_FES_Microgeneration_GW_df$Attribute
rownames(NG_FES_EVPeak_GW_df)<-NG_FES_EVPeak_GW_df$Charging_regime
rownames(NG_FES_EV_number_df)<-c('Battery Electric Cars','Battery Electric Vans')
rownames(NG_FES_HeatPumps_Installations_df)<-NG_FES_HeatPumps_Installations_df$Technology


# Select only relevant rows & colums
NG_FES_Microgeneration_GW_df <- NG_FES_Microgeneration_GW_df[years_of_interest_list]
NG_FES_Microgeneration_GW_df <- NG_FES_Microgeneration_GW_df[c('Micro'),]

NG_FES_EVPeak_GW_df <- NG_FES_EVPeak_GW_df[years_of_interest_list]

NG_FES_HeatPumps_Installations_df <- NG_FES_HeatPumps_Installations_df[c('Technology',years_of_interest_list)]
NG_FES_HeatPumps_Installations_df <- NG_FES_HeatPumps_Installations_df[c("ASHP", "GSHP","Hybrid heat pump gas boiler"),]


### 3. APPLY NG FES SCENARIOS TO UKPVD AND EXPORT
#############################################################################################################

# Total number of domestic meters, used in allocating across LSOAs below

Total_N_dom_meters<-sum(UKPVD_df$Meters_domestic)

# Apply scenarios for each year in separate dataframes and export

UKPVD_FES_df <- lapply(years_of_interest_list,function(year)
{
	# Dataframe to use in loop, to fill with values for the year in question and then return as an output
	UKPVD_year_df<-UKPVD_df

	# Apply microgeneration growth factor to no. of PV installations and total capacity
	PV_growth_factor<-NG_FES_Microgeneration_GW_df['Micro',year]/NG_FES_Microgeneration_GW_df['Micro','2020']
	UKPVD_year_df[c('PV_domestic_sum_kW','PV_domestic_installations','PV_nondom_sum_kW','PV_nondom_installations')] <- PV_growth_factor * UKPVD_df[c('PV_domestic_sum_kW','PV_domestic_installations','PV_nondom_sum_kW','PV_nondom_installations')]

	# Add peak EV demand per LSOA (here just equal proportion of total UK demand per meter with no regard to whether the LSOA is urban or rural)
	UKPVD_year_df['EV_peak_NoSmart_kW']<-NG_FES_EVPeak_GW_df['No Smart Charging or V2G',year]*1000000 * UKPVD_df$Meters_domestic / Total_N_dom_meters
	UKPVD_year_df['EV_peak_Smart_kW']<-NG_FES_EVPeak_GW_df['With smart charging',year]*1000000 * UKPVD_df$Meters_domestic / Total_N_dom_meters

	# Add peak EV number per LSOA
	UKPVD_year_df['EV_number']<-(NG_FES_EV_number_df['Battery Electric Cars',year] + NG_FES_EV_number_df['Battery Electric Vans',year]) * UKPVD_df$Meters_domestic / Total_N_dom_meters

	# Add number of heat pumps demand per LSOA (equal proportion of total UK demand per meter with no regard to whether the LSOA is urban or rural, but separated into standard and hybrid)
	UKPVD_year_df['Heatpumps_nonhybrid_installations']<-(NG_FES_HeatPumps_Installations_df['ASHP',year]+NG_FES_HeatPumps_Installations_df['GSHP',year]) * UKPVD_df$Meters_domestic / Total_N_dom_meters
	UKPVD_year_df['Heatpumps_hybrid_installations']<-NG_FES_HeatPumps_Installations_df['Hybrid heat pump gas boiler',year] * UKPVD_df$Meters_domestic / Total_N_dom_meters

	# Add storage per LSOA (equal proportion of total UK demand per meter)
	UKPVD_year_df['Stor_kW']<-NG_FES_Stor_Decentralised_MW_df[1,year] * 1000 * UKPVD_df$Meters_domestic / Total_N_dom_meters

	write.table(UKPVD_year_df, paste(intermediate_path,'FES/',FES_output,year,'.csv', sep=''), sep=",", row.names=FALSE)

	return(UKPVD_year_df)
}
)

names(UKPVD_FES_df) <- years_of_interest_list