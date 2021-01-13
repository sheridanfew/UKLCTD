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
# ONS Table to convert between LA and LSOA, source: https://geoportal.statistics.gov.uk/datasets/output-area-to-lsoa-to-msoa-to-local-authority-district-december-2017-lookup-with-area-classifications-in-great-britain/data date accessed: 8 Oct 2020
ONS_OA_LSOA_MSOA_LA_conversion_input <- "ONS/Output_Area_to_LSOA_to_MSOA_to_Local_Authority_District__December_2017__Lookup_with_Area_Classifications_in_Great_Britain.csv" 

# UKPVD containing recent LSOA-level data on spatial area, population, rurality, meter data, PV deployment, and substation density. Generated from raw data sources using 'Generate_UKPVD.R', and substation data added using 'Add_substations_to_UKPVD.R'
UKPVD_input <- 'UKPVD_w_substations_Oct2020.csv'

# National Grid Future Energy Scenarios 2019 data workbook source: https://www.nationalgrideso.com/future-energy/future-energy-scenarios/fes-2019-documents date accessed: 9 Oct 2020
NG_FES_input <- 'FES/UKPVD_Scenarios_FES2019_'

# DFES Inputs:
# WPD 2020 data workbook source: https://www.westernpower.co.uk/distribution-future-energy-scenarios-application date accessed: 8 Jan 2021
WPD_EM_DFES_PV_input <- "DFES/WPD/EM_Consumer_Transformation_Solar_Generation_Domestic_rooftop_(_10kW)_LA.csv" # NB. Larger commercial units (10kW - 1MW not included on the basis that most of this capacity will likely be commencted at higher voltage levels) - differentiation in voltage level at which techs connected coul be useful
WPD_EM_DFES_EV_autonomous_input <- "DFES/WPD/EM_Consumer_Transformation_EV_Pure_electric_car_(autonomous)_LA.csv"
WPD_EM_DFES_EV_nonauto_input <- "DFES/WPD/EM_Consumer_Transformation_EV_Pure_electric_car_(non_autonomous)_LA.csv"
WPD_EM_DFES_HPs_hybrid_input <- "DFES/WPD/EM_Consumer_Transformation_Heat_pumps_Domestic_-_Hybrid_LA.csv"
WPD_EM_DFES_HPs_nonhybrid_input <- "DFES/WPD/EM_Consumer_Transformation_Heat_pumps_Domestic_-_Non-hybrid_LA.csv"
WPD_EM_DFES_Stor_Dom_input <- "DFES/WPD/EM_Consumer_Transformation_Storage_Domestic_Batteries_(G98)_LA.csv"

WPD_SW_DFES_PV_input <- "DFES/WPD/SW_Consumer_Transformation_Solar_Generation_Domestic_rooftop_(_10kW)_LA.csv"
WPD_SW_DFES_EV_autonomous_input <- "DFES/WPD/SW_Consumer_Transformation_EV_Pure_electric_car_(autonomous)_LA.csv"
WPD_SW_DFES_EV_nonauto_input <- "DFES/WPD/SW_Consumer_Transformation_EV_Pure_electric_car_(non_autonomous)_LA.csv"
WPD_SW_DFES_HPs_hybrid_input <- "DFES/WPD/SW_Consumer_Transformation_Heat_pumps_Domestic_-_Hybrid_LA.csv"
WPD_SW_DFES_HPs_nonhybrid_input <- "DFES/WPD/SW_Consumer_Transformation_Heat_pumps_Domestic_-_Non-hybrid_LA.csv"
WPD_SW_DFES_Stor_Dom_input <- "DFES/WPD/SW_Consumer_Transformation_Storage_Domestic_Batteries_(G98)_LA.csv"

WPD_WA_DFES_PV_input <- "DFES/WPD/WA_Consumer_Transformation_Solar_Generation_Domestic_rooftop_(_10kW)_LA.csv"
WPD_WA_DFES_EV_autonomous_input <- "DFES/WPD/WA_Consumer_Transformation_EV_Pure_electric_car_(autonomous)_LA.csv"
WPD_WA_DFES_EV_nonauto_input <- "DFES/WPD/WA_Consumer_Transformation_EV_Pure_electric_car_(non_autonomous)_LA.csv"
WPD_WA_DFES_HPs_hybrid_input <- "DFES/WPD/WA_Consumer_Transformation_Heat_pumps_Domestic_-_Hybrid_LA.csv"
WPD_WA_DFES_HPs_nonhybrid_input <- "DFES/WPD/WA_Consumer_Transformation_Heat_pumps_Domestic_-_Non-hybrid_LA.csv"
WPD_WA_DFES_Stor_Dom_input <- "DFES/WPD/WA_Consumer_Transformation_Storage_Domestic_Batteries_(G98)_LA.csv"

WPD_WM_DFES_PV_input <- "DFES/WPD/WM_Consumer_Transformation_Solar_Generation_Domestic_rooftop_(_10kW)_LA.csv"
WPD_WM_DFES_EV_autonomous_input <- "DFES/WPD/WM_Consumer_Transformation_EV_Pure_electric_car_(autonomous)_LA.csv"
WPD_WM_DFES_EV_nonauto_input <- "DFES/WPD/WM_Consumer_Transformation_EV_Pure_electric_car_(non_autonomous)_LA.csv"
WPD_WM_DFES_HPs_hybrid_input <- "DFES/WPD/WM_Consumer_Transformation_Heat_pumps_Domestic_-_Hybrid_LA.csv"
WPD_WM_DFES_HPs_nonhybrid_input <- "DFES/WPD/WM_Consumer_Transformation_Heat_pumps_Domestic_-_Non-hybrid_LA.csv"
WPD_WM_DFES_Stor_Dom_input <- "DFES/WPD/WM_Consumer_Transformation_Storage_Domestic_Batteries_(G98)_LA.csv"

# Northern Powergrid 2019 data workbook source: https://odileeds.org/projects/northernpowergrid/dfes/ date accessed: 1 Oct 2020
NPG_DFES_input <- "DFES/NPG/Local Authority View - All Data for Northern Powergrid DFES 2019.xlsx"

# UKPN 2019 data workbook source: https://innovation.ukpowernetworks.co.uk/2020/02/06/distribution-future-energy-scenarios/ date accessed: 1 Oct 2020
UKPN_DFES_PV_input <- "DFES/UKPN/UKPN-small-scale-PV-scenarios-LSOA-1.xlsx"
UKPN_DFES_EV_input <- "DFES/UKPN/UKPN-electric-car-scenarios-LSOA.xlsx"
UKPN_DFES_EV_vans_input <- "DFES/UKPN/UKPN-electric-van-scenarios-LSOA.xlsx"
UKPN_DFES_HP_input <- 'DFES/UKPN/UKPN-domestic-heating-technologies-scenarios_renewable-LSOA.xlsx' 
UKPN_DFES_Stor_Dom_input <- 'DFES/UKPN/UKPN-domestic-battery-scenarios-LSOA.xlsx' 
UKPN_DFES_Stor_Nondom_input <- 'DFES/UKPN/UKPN-industrial-and-commercial-battery-storage-scenarios-LSOA.xlsx' 

### OUTPUT DATA
DFES_base_output <- 'UKPVD_Scenarios_DFES_base_'

# VARIABLES (USED GLOBALLY)

# Definition of years of interest
years_of_interest_list<-c('2020','2030','2040','2050')

### DO STUFF

### 1. IMPORT ONS DATA WITH CORRESPONDENCE BETWEEN OAs, LSOAs, MSOAs, and LAs (later used in processing NPG data which is at an LA level)
#############################################################################################################

# Import data
OA_LSOA_MSOA_LA_df<-read.csv(paste(input_path,ONS_OA_LSOA_MSOA_LA_conversion_input, sep=''), header=TRUE)

# Rename columns
OA_LSOA_MSOA_LA_df  <- rename(OA_LSOA_MSOA_LA_df, c("OA11CD"="OA"))
OA_LSOA_MSOA_LA_df  <- rename(OA_LSOA_MSOA_LA_df, c("LSOA11CD"="LSOA"))
OA_LSOA_MSOA_LA_df  <- rename(OA_LSOA_MSOA_LA_df, c("MSOA11CD"="MSOA"))
OA_LSOA_MSOA_LA_df  <- rename(OA_LSOA_MSOA_LA_df, c("LAD17NM"="LA"))

# Select only relevant colummns
OA_LSOA_MSOA_LA_df<-OA_LSOA_MSOA_LA_df[c('OA','LSOA','MSOA','LA')]

# Extract unique identifiers and generate lookup tables for which which LSOAs are in an LA
LSOA_LA_df=subset(OA_LSOA_MSOA_LA_df, select=c("LSOA", "LA"))
LSOA_LA_lookup_df=unique(LSOA_LA_df)


### 2. IMPORT UKPVD
#############################################################################################################

# Import data
UKPVD_df<-read.csv(paste(intermediate_path,UKPVD_input, sep=''), header=TRUE)

### 3. IMPORT NG FES SCENARIOS
#############################################################################################################

# Import data by year

UKPVD_FES_df <- lapply(years_of_interest_list,function(year)
{
	 UKPVD_year_df<-read.csv(paste(intermediate_path,NG_FES_input,year,'.csv', sep=''), header=TRUE)
	return(UKPVD_year_df)
}
)

names(UKPVD_FES_df) <- years_of_interest_list


### 4. IMPORT dFES SCENARIOS AND REPLACE VALUES WITH THESE IN UKPVD SCENARIOS
#############################################################################################################

### 4a. WPD Scenarios

#Import data

WPD_EM_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_Storm_Dom_input, sep=''),header=TRUE,skip=6))

WPD_SW_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_Storm_Dom_input, sep=''),header=TRUE,skip=6))

WPD_WA_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_Storm_Dom_input, sep=''),header=TRUE,skip=6))

WPD_WM_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_Storm_Dom_input, sep=''),header=TRUE,skip=6))

#Combine data where appropriate (sum auto and nonauto EVs to gettoal number)

#Combine regions

WPD_DomPV_MW_df<-rbind(WPD_EM_DFES_DomPV_MW_df,
					WPD_SW_DFES_DomPV_MW_df,
					WPD_WA_DFES_DomPV_MW_df,
					WPD_WM_DFES_DomPV_MW_df)

WPD_EVs_number_df<-rbind(WPD_EM_DFES_EV_autonomous_number_df+WPD_EM_DFES_EV_nonauto_number_df,
						WPD_SW_DFES_EV_autonomous_number_df+WPD_SW_DFES_EV_nonauto_number_df,
						WPD_WA_DFES_EV_autonomous_number_df+WPD_WA_DFES_EV_nonauto_number_df,
						WPD_WM_DFES_EV_autonomous_number_df+WPD_WM_DFES_EV_nonauto_number_df)

WPD_EVs_number_df$Local.Authority.Name<-c(as.character(WPD_EM_DFES_EV_autonomous_number_df$Local.Authority.Name),
										as.character(WPD_SW_DFES_EV_autonomous_number_df$Local.Authority.Name),
										as.character(WPD_WA_DFES_EV_autonomous_number_df$Local.Authority.Name),
										as.character(WPD_WM_DFES_EV_autonomous_number_df$Local.Authority.Name))

WPD_HPs_number_df <- rbind(WPD_EM_DFES_HPs_nonhybrid_number_df,
					WPD_SW_DFES_HPs_nonhybrid_number_df,
					WPD_WA_DFES_HPs_nonhybrid_number_df,
					WPD_WM_DFES_HPs_nonhybrid_number_df)

WPD_Stor_MW_df <- rbind(WPD_EM_DFES_Stor_MW_df,
					WPD_SW_DFES_Stor_MW_df,
					WPD_WA_DFES_Stor_MW_df,
					WPD_WM_DFES_Stor_MW_df)


# Combine into list

WPD_combined_data_list <- list(WPD_DomPV_MW_df,
						WPD_EVs_number_df,
						WPD_HPs_number_df,
						WPD_Stor_MW_df)

names(WPD_combined_data_list)<-c('DomPV_MW_df','EVs_number_df','HPs_number_df','Stor_MW_df')


# Select only relevant rows and columns (and rename LAs where naming is not consistent with other data sources)

WPD_combined_data_list<-lapply(WPD_combined_data_list,function(df){
	# Data for some LAs divided between different DNO regions - sum values associated with LA in these cases (eg. south Gloucestershire on border of SW, WM, and WA)
	df  <- as.data.frame(aggregate(df[-1], list(df$Local.Authority.Name), sum))
	df  <- rename(df, c("Group.1"="LA"))
	# Sort row names, and make LAs character not factor (facilitates latter processing)
	names(df) <- gsub(x = names(df), pattern = "X", replacement = "")
	df$LA<-as.character(df$LA)

	# Generalisable inconsistencies
	df$LA <- gsub(x = df$LA, pattern = ' District', replacement = "")
	df$LA <- gsub(x = df$LA, pattern = ' [(]B[])]', replacement = "")
	df$LA <- gsub(x = df$LA, pattern = 'City of ', replacement = "")

	# All Welsh LSOAs have Welsh then English names in WPD data (separated by ' - '), whereas other data sources have only English, removing Welsh names fo this analysis :(
	df$LA <- gsub(".* - ", "", df$LA)

	# More specific inconsistencies
	df$LA <- gsub(x = df$LA, pattern = 'the Vale of Glamorgan', replacement = "The Vale of Glamorgan")
	df$LA <- gsub(x = df$LA, pattern = "County of Herefordshire", replacement = "Herefordshire, County of")
	df$LA <- gsub(x = df$LA, pattern = 'Bristol', replacement = 'Bristol, City of')

	# Order by LA name
	df<-df[order(df$LA),]

	# "Dorset" and "Somerset West and Taunton" excluded. These are new LAs created in 2020 by merging others - these are excluded as a clear mapping to LSOAs not yet available
	df<-subset(df, LA!="Dorset")
	df<-subset(df, LA!="Somerset West and Taunton")

	# Rename rows by LA, select years of interest, & export
	rownames(df)<-df$LA
	df_out <- df[c(years_of_interest_list)]
	return(df_out)
})

# Differences in names found using the commands below:

#setdiff(rownames(WPD_combined_data_list[[1]]),unique(LSOA_LA_df$LA))
#unique(LSOA_LA_df$LA)[order(unique(LSOA_LA_df$LA))]
#rownames(WPD_combined_data_list[[1]])[order(rownames(WPD_combined_data_list[[1]]))]


### NB. From this point forward, the process for WPD exactly mirrors that for NPG 

# Convert to LSOA level (by dividing equally between LSOAs in the LA - several steps following the same thinking as converting MSOA level data for nondom demand in creating the UKPVD)

## Get list of WPD LAs
WPD_LAs<-rownames(WPD_combined_data_list[[1]])

## Make df ready for LSOA level data containing every LSOA in LAs covered by WPD
WPD_combined_data_LSOA_df <- LSOA_LA_lookup_df[is.element(LSOA_LA_lookup_df$LA, WPD_LAs),]

# Add columns for LSOA level variables (to be filled in subsequent 'lapply' routine)
WPD_combined_data_LSOA_df$PV_domestic_sum_kW<-NA
WPD_combined_data_LSOA_df$EVs_number<-NA
WPD_combined_data_LSOA_df$Heatpumps_LSOA_number<-NA
WPD_combined_data_LSOA_df$Storage_sum_kW<-NA

# Add number of meters (used in allocating techs across LSOA)
WPD_combined_data_LSOA_df <- merge(WPD_combined_data_LSOA_df,UKPVD_df[c('LSOA','Meters_domestic')],by='LSOA')

# Routine to divide between constituent LSOAs - I wrote this a while ago and it's a bit slow and clunky, but it works

# Make df containing DFES values for each year of interest:
UKPVD_WPD_DFES_df<-lapply(years_of_interest_list, function(year) {
	print(paste('Running for year: ', year,sep=''))
	# Duplicate df with all LSOAs to process here ( needs redoing each time because it's a global variable - bit messy)
	WPD_combined_data_LSOA_year_df<<-WPD_combined_data_LSOA_df
	# Run across LAs of interest list
	# Function to divide LA level data between LSOAs and put into WPD_combined_data_LSOA_df frame. Lapply across list of LAs in WPD region.
	lapply(WPD_LAs,function(LA){
		# Get LA level data for the LA currently being processed
		DomPV_LA_kW <- WPD_combined_data_list[['DomPV_MW_df']][LA,year]*1000
		EVs_LA_number <- WPD_combined_data_list[['EVs_number_df']][LA,year]
		HPs_LA_number <- WPD_combined_data_list[['HPs_number_df']][LA,year]
		Stor_LA_kW <- WPD_combined_data_list[['Stor_MW_df']][LA,year]*1000

		# Which LSOAs are in this LA? How many of them are there?
		LSOAs=as.vector(LSOA_LA_lookup_df$LSOA[which(LSOA_LA_lookup_df$LA==LA)])
		N_LSOAs <- length(LSOAs)

		# How many domestic meters are in this LA?
		N_meters <- sum(WPD_combined_data_LSOA_df$Meters_domestic[which(WPD_combined_data_LSOA_df$LA==LA)])

		# Divide LA level data by number of LSOAs in that LA
		PV_domestic_sum_kW_per_meter <- DomPV_LA_kW/N_meters
		EVs_LSOA_number_per_meter <- EVs_LA_number/N_meters
		HPs_LSOA_number_per_meter <- HPs_LA_number/N_meters
		Stor_LSOA_kW_per_meter <- Stor_LA_kW/N_meters

		# Put newly calculated data into global WPD_combined_data_LSOA_df dataframe by LSOA
		lapply (LSOAs, function(LSOA) {
			index = which(WPD_combined_data_LSOA_df$LSOA==LSOA)
			WPD_combined_data_LSOA_year_df$PV_domestic_sum_kW[index] <<- WPD_combined_data_LSOA_year_df$Meters_domestic[index] * PV_domestic_sum_kW_per_meter
			WPD_combined_data_LSOA_year_df$EVs_number[index] <<- WPD_combined_data_LSOA_year_df$Meters_domestic[index] * EVs_LSOA_number_per_meter
			WPD_combined_data_LSOA_year_df$Heatpumps_LSOA_number[index] <<- WPD_combined_data_LSOA_year_df$Meters_domestic[index] * HPs_LSOA_number_per_meter
			WPD_combined_data_LSOA_year_df$Storage_sum_kW[index] <<- WPD_combined_data_LSOA_year_df$Meters_domestic[index] * Stor_LSOA_kW_per_meter
		})
	})
	return(WPD_combined_data_LSOA_year_df)
})

names(UKPVD_WPD_DFES_df)<-years_of_interest_list


### 4b. NPG SCENARIOS
#############################################################################################################

# Import NPG scenario data (only 'Community Renewables' scenario)

NPG_DFES_DomPV_MW_df<-as.data.frame(read_excel(paste(input_path,NPG_DFES_input, sep=''),sheet='DomPV_MW-CR',range="A1:AI40"))
NPG_DFES_EVs_number_df<-as.data.frame(read_excel(paste(input_path,NPG_DFES_input, sep=''),sheet='EVs-CR',range="A1:AI40"))
NPG_DFES_HPs_number_df<-as.data.frame(read_excel(paste(input_path,NPG_DFES_input, sep=''),sheet='HeatPumps-CR',range="A1:AI40"))
NPG_DFES_Stor_MW_df<-as.data.frame(read_excel(paste(input_path,NPG_DFES_input, sep=''),sheet='Storage_MW-CR',range="A1:AI40")) # Storage not currently used

# Combine into list

NPG_combined_data_list<-list(NPG_DFES_DomPV_MW_df,NPG_DFES_EVs_number_df,NPG_DFES_HPs_number_df,NPG_DFES_Stor_MW_df)

# Select only relevant rows and columns (and rename)

NPG_combined_data_list<-lapply(NPG_combined_data_list,function(df){
	df  <- rename(df, c("Local Authority"="LA"))
	rownames(df)<-df$LA
	df_out <- df[c(years_of_interest_list)]
	return(df_out)
}
)

names(NPG_combined_data_list)<-c('DomPV_MW_df','EVs_number_df','HPs_number_df','Stor_MW_df')

# Convert to LSOA level (by dividing equally between LSOAs in the LA - several steps following the same thinking as converting MSOA level data for nondom demand in creating the UKPVD)

## Get list of NPG LAs
NPG_LAs<-rownames(NPG_combined_data_list[[1]])

## Make df ready for LSOA level data containing every LSOA in LAs covered by NPG
NPG_combined_data_LSOA_df <- LSOA_LA_lookup_df[is.element(LSOA_LA_lookup_df$LA, NPG_LAs),]

# Add columns for LSOA level variables (to be filled in subsequent 'lapply' routine)
NPG_combined_data_LSOA_df$PV_domestic_sum_kW<-NA
NPG_combined_data_LSOA_df$EVs_number<-NA
NPG_combined_data_LSOA_df$Heatpumps_LSOA_number<-NA
NPG_combined_data_LSOA_df$Storage_sum_kW<-NA

# Add number of meters (used in allocating techs across LSOA)
NPG_combined_data_LSOA_df <- merge(NPG_combined_data_LSOA_df,UKPVD_df[c('LSOA','Meters_domestic')],by='LSOA')


# Routine to divide between constituent LSOAs - I wrote this a while ago and it's a bit slow and clunky, but it works

# Make df containing DFES values for each year of interest:
UKPVD_NPG_DFES_df<-lapply(years_of_interest_list, function(year) {
	print(paste('Running for year: ', year,sep=''))
	# Duplicate df with all LSOAs to process here ( needs redoing each time because it's a global variable - bit messy)
	NPG_combined_data_LSOA_year_df<<-NPG_combined_data_LSOA_df
	# Run across LAs of interest list
	# Function to divide LA level data between LSOAs and put into NPG_combined_data_LSOA_df frame. Lapply across list of LAs in NPG region.
	lapply(NPG_LAs,function(LA){
		# Get LA level data for the LA currently being processed
		DomPV_LA_kW <- NPG_combined_data_list[['DomPV_MW_df']][LA,year]*1000
		EVs_LA_number <- NPG_combined_data_list[['EVs_number_df']][LA,year]
		HPs_LA_number <- NPG_combined_data_list[['HPs_number_df']][LA,year]
		Stor_LA_kW <- NPG_combined_data_list[['Stor_MW_df']][LA,year]*1000

		# Which LSOAs are in this LA? How many of them are there?
		LSOAs=as.vector(LSOA_LA_lookup_df$LSOA[which(LSOA_LA_lookup_df$LA==LA)])
		N_LSOAs <- length(LSOAs)

		# How many domestic meters are in this LA?
		N_meters <- sum(NPG_combined_data_LSOA_df$Meters_domestic[which(NPG_combined_data_LSOA_df$LA==LA)])

		# Divide LA level data by number of LSOAs in that LA
		PV_domestic_sum_kW_per_meter <- DomPV_LA_kW/N_meters
		EVs_LSOA_number_per_meter <- EVs_LA_number/N_meters
		HPs_LSOA_number_per_meter <- HPs_LA_number/N_meters
		Stor_LSOA_kW_per_meter <- Stor_LA_kW/N_meters

		# Put newly calculated data into global NPG_combined_data_LSOA_df dataframe by LSOA
		lapply (LSOAs, function(LSOA) {
			index = which(NPG_combined_data_LSOA_df$LSOA==LSOA)
			NPG_combined_data_LSOA_year_df$PV_domestic_sum_kW[index] <<- NPG_combined_data_LSOA_year_df$Meters_domestic[index] * PV_domestic_sum_kW_per_meter
			NPG_combined_data_LSOA_year_df$EVs_number[index] <<- NPG_combined_data_LSOA_year_df$Meters_domestic[index] * EVs_LSOA_number_per_meter
			NPG_combined_data_LSOA_year_df$Heatpumps_LSOA_number[index] <<- NPG_combined_data_LSOA_year_df$Meters_domestic[index] * HPs_LSOA_number_per_meter
			NPG_combined_data_LSOA_year_df$Storage_sum_kW[index] <<- NPG_combined_data_LSOA_year_df$Meters_domestic[index] * Stor_LSOA_kW_per_meter
		})
	})
	return(NPG_combined_data_LSOA_year_df)
})

names(UKPVD_NPG_DFES_df)<-years_of_interest_list


### 4c  UKPN SCENARIOS
#############################################################################################################

# Import Data

UKPN_DFES_SmallScalePV_kW_df<-as.data.frame(read_excel(paste(input_path,UKPN_DFES_PV_input, sep=''),sheet='Small Scale PV',range="A1:AT63925"))
UKPN_DFES_EVs_number_df<-as.data.frame(read_excel(paste(input_path,UKPN_DFES_EV_input, sep=''),sheet='Cars',range="A1:AS31963"))
UKPN_DFES_EV_vans_number_df<-as.data.frame(read_excel(paste(input_path,UKPN_DFES_EV_vans_input, sep=''),sheet='Vans',range="A1:AS31963"))
UKPN_DFES_HPs_number_df<-as.data.frame(read_excel(paste(input_path,UKPN_DFES_HP_input, sep=''),sheet='Domestic Heating Technologies',range="A1:AS63925"))
UKPN_DFES_Stor_Dom_kW_df<-as.data.frame(read_excel(paste(input_path,UKPN_DFES_Stor_Dom_input, sep=''),sheet='Domestic Batteries',range="A1:AS31963")) # Storage not currently used
UKPN_DFES_Stor_Nondom_kW_df<-as.data.frame(read_excel(paste(input_path,UKPN_DFES_Stor_Nondom_input, sep=''),sheet='Rounded',range="A1:AS31963")) # Storage not currently used

# Split data where relevant (PV and HP)

UKPN_DFES_PV_Domestic_kW_df<-UKPN_DFES_SmallScalePV_kW_df[which(UKPN_DFES_SmallScalePV_kW_df$Parameter=='Domestic PV capacity'),]
UKPN_DFES_PV_Nondom_kW_df<-UKPN_DFES_SmallScalePV_kW_df[which(UKPN_DFES_SmallScalePV_kW_df$Parameter=='I&C PV capacity'),]

UKPN_DFES_PureHPs_number_df<-UKPN_DFES_HPs_number_df[which(UKPN_DFES_HPs_number_df$Parameter=='Heat Pump'),]
UKPN_DFES_HybridHPs_number_df<-UKPN_DFES_HPs_number_df[which(UKPN_DFES_HPs_number_df$Parameter=='Hybrid Heat Pump'),]

UKPN_DFES_BEVs_number_df<-UKPN_DFES_EVs_number_df[which(UKPN_DFES_EVs_number_df$Parameter=='BEV'),]
UKPN_DFES_PHEVs_number_df<-UKPN_DFES_EVs_number_df[which(UKPN_DFES_EVs_number_df$Parameter=='PHEV'),]

UKPN_DFES_BEV_vans_number_df<-UKPN_DFES_EV_vans_number_df[which(UKPN_DFES_EVs_number_df$Parameter=='BEV'),]
UKPN_DFES_PHEV_vans_number_df<-UKPN_DFES_EV_vans_number_df[which(UKPN_DFES_EVs_number_df$Parameter=='BEV'),]

# Combine into list
UKPN_combined_data_list<-list(UKPN_DFES_PV_Domestic_kW_df,UKPN_DFES_PV_Nondom_kW_df,UKPN_DFES_BEVs_number_df,UKPN_DFES_PHEVs_number_df,UKPN_DFES_BEV_vans_number_df,UKPN_DFES_PHEV_vans_number_df,UKPN_DFES_PureHPs_number_df,UKPN_DFES_HybridHPs_number_df,UKPN_DFES_Stor_Dom_kW_df,UKPN_DFES_Stor_Nondom_kW_df)

# Select only relevant rows and columns (and rename)
UKPN_combined_data_list<-lapply(UKPN_combined_data_list,function(df){
	df  <- rename(df, c("LSOA11CD"="LSOA"))
	df <- df[which(df$Scenario=='High' | df$Scenario=='Engaged Society' ),]
	df_out <- df[c('LSOA',years_of_interest_list)]
	return(df_out)
}
)
names(UKPN_combined_data_list)<-c('PV_Domestic_kW_df','PV_Nondom_kW_df','BEVs_number_df','PHEVs_number_df','BEV_vans_number_df','PHEV_vans_number_df','Pure_HPs_number_df','Hybrid_HPs_number_df','Stor_Dom_kW_df','Stor_Nondom_kW_df')


# Combine into single df arranged by year (as per NPG data) Vans and cars added together as for NG FES

UKPVD_UKPN_DFES_df <- lapply(years_of_interest_list, function(year) {
	year_df <- cbind(UKPN_combined_data_list[['PV_Domestic_kW_df']][c('LSOA',year)],
		UKPN_combined_data_list[['PV_Nondom_kW_df']][year],
		UKPN_combined_data_list[['BEVs_number_df']][year]+UKPN_combined_data_list[['BEV_vans_number_df']][year],
		UKPN_combined_data_list[['PHEVs_number_df']][year]+UKPN_combined_data_list[['PHEV_vans_number_df']][year],
		UKPN_combined_data_list[['Pure_HPs_number_df']][year],
		UKPN_combined_data_list[['Hybrid_HPs_number_df']][year],
		UKPN_combined_data_list[['Stor_Dom_kW_df']][year],
		UKPN_combined_data_list[['Stor_Nondom_kW_df']][year])

	names(year_df) <- c('LSOA','PV_domestic_sum_kW','PV_Nondom_kW','BEVs_number','PHEVs_number','Pure_HPs_number','Hybrid_HPs_number','Stor_Dom_kW_df','Stor_Nondom_kW_df')
	return(year_df)
	})

names(UKPVD_UKPN_DFES_df)<-years_of_interest_list


### 5. CONVERSIONS/COMPARISONS
#############################################################################################################


# UKPVD_UKPN_union <- lapply(years_of_interest_list,function(year){
# 	UKPVD_UKPN_DFES_year_relabelled_df<-UKPVD_UKPN_DFES_df[[year]]
# 	colnames(UKPVD_UKPN_DFES_year_relabelled_df) <- c('LSOA',paste("UKPN", colnames(UKPVD_UKPN_DFES_year_relabelled_df)[-1], sep = "_"))
# 	df <- merge(UKPVD_FES_df[[year]],UKPVD_UKPN_DFES_year_relabelled_df,by='LSOA')
# })
# names(UKPVD_UKPN_union)<-years_of_interest_list

# UKPVD_NPG_union <- lapply(years_of_interest_list,function(year){
# 	UKPVD_NPG_DFES_year_relabelled_df<-UKPVD_NPG_DFES_df[[year]]
# 	colnames(UKPVD_NPG_DFES_year_relabelled_df) <- c('LSOA',paste("NPG", colnames(UKPVD_NPG_DFES_year_relabelled_df)[-1], sep = "_"))
# 	df <- merge(UKPVD_FES_df[[year]],UKPVD_NPG_DFES_year_relabelled_df,by='LSOA')
# })

# names(UKPVD_NPG_union)<-years_of_interest_list

# # PV per household

# NG_PV_dom_per_household <- sum(UKPVD_FES_df[['2050']]$PV_domestic_sum_kW)/sum(UKPVD_FES_df[['2050']]$Meters_domestic)
# NG_PV_nondom_per_household <- sum(UKPVD_FES_df[['2050']]$PV_nondom_sum_kW)/sum(UKPVD_FES_df[['2050']]$Meters_domestic)

# UKPN_PV_dom_per_household_2020 <- sum(UKPVD_UKPN_union[['2020']]$UKPN_PV_domestic_sum_kW)/sum(UKPVD_UKPN_union[['2020']]$Meters_domestic)
# UKPN_PV_dom_per_household_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_PV_domestic_sum_kW)/sum(UKPVD_UKPN_union[['2050']]$Meters_domestic)
# UKPN_PV_nondom_per_household_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_PV_Nondom_kW)/sum(UKPVD_UKPN_union[['2050']]$Meters_domestic)

# NPG_PV_per_household_2020 <- sum(UKPVD_NPG_union[['2020']]$NPG_PV_domestic_sum_kW)/sum(UKPVD_NPG_union[['2020']]$Meters_domestic)
# NPG_PV_per_household_2050 <- sum(UKPVD_NPG_union[['2050']]$NPG_PV_domestic_sum_kW)/sum(UKPVD_NPG_union[['2050']]$Meters_domestic)

# # Dom/nondom PV per demand

# NG_PV_dom_per_dem_2050 <- sum(UKPVD_FES_df[['2050']]$PV_domestic_sum_kW)/sum(UKPVD_FES_df[['2050']]$Demand_domestic_sum_kWh)
# NG_PV_nondom_per_dem_2050 <- sum(UKPVD_FES_df[['2050']]$PV_nondom_sum_kW)/sum(UKPVD_FES_df[['2050']]$Demand_nondom_sum_kWh)

# UKPN_PV_dom_per_dem_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_PV_domestic_sum_kW)/sum(UKPVD_UKPN_union[['2050']]$Demand_domestic_sum_kWh)
# UKPN_PV_nondom_per_dem_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_PV_Nondom_kW)/sum(UKPVD_UKPN_union[['2050']]$Demand_nondom_sum_kWh)

# # EVs per household

# NG_EVs_per_household_2020 <- sum(UKPVD_FES_df[['2020']]$EV_number)/sum(UKPVD_FES_df[['2020']]$Meters_domestic)
# NG_EVs_per_household_2050 <- sum(UKPVD_FES_df[['2050']]$EV_number)/sum(UKPVD_FES_df[['2050']]$Meters_domestic)

# UKPN_EVs_per_household_2020 <- sum(UKPVD_UKPN_union[['2020']]$UKPN_BEVs_number)/sum(UKPVD_UKPN_union[['2020']]$Meters_domestic)
# UKPN_EVs_per_household_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_BEVs_number)/sum(UKPVD_UKPN_union[['2050']]$Meters_domestic)

# NPG_EVs_per_household_2020 <- sum(UKPVD_NPG_union[['2020']]$NPG_EVs_number)/sum(UKPVD_NPG_union[['2020']]$Meters_domestic)
# NPG_EVs_per_household_2050 <- sum(UKPVD_NPG_union[['2050']]$NPG_EVs_number)/sum(UKPVD_NPG_union[['2050']]$Meters_domestic)

# # Growth Factors for EVs

# NG_EV_Growth_Factor_2020_2050_NoSmart <- sum(UKPVD_FES_df[['2050']]$EV_peak_NoSmart_kW)/sum(UKPVD_FES_df[['2020']]$EV_peak_NoSmart_kW)
# NG_EV_Growth_Factor_2020_2050_Smart <- sum(UKPVD_FES_df[['2050']]$EV_peak_Smart_kW)/sum(UKPVD_FES_df[['2020']]$EV_peak_Smart_kW)

# UKPN_EV_Growth_Factor_2020_2050 <- sum(UKPVD_UKPN_DFES_df[['2050']]$BEVs_number)/sum(UKPVD_UKPN_DFES_df[['2020']]$BEVs_number)
# NPG_EV_Growth_Factor_2020_2050 <- sum(UKPVD_NPG_DFES_df[['2050']]$EVs_number)/sum(UKPVD_NPG_DFES_df[['2020']]$EVs_number)

# # HPs per household

# NG_HPs_per_household <- sum(UKPVD_FES_df[['2050']]$Heatpumps_nonhybrid_installations)/sum(UKPVD_FES_df[['2050']]$Meters_domestic)
# NG_HybridHPs_per_household <- sum(UKPVD_FES_df[['2050']]$Heatpumps_hybrid_installations)/sum(UKPVD_FES_df[['2050']]$Meters_domestic)

# UKPN_HPs_per_household <- sum(UKPVD_UKPN_union[['2050']]$UKPN_Pure_HPs_number)/sum(UKPVD_UKPN_union[['2050']]$Meters_domestic)
# NPG_HPs_per_household <- sum(UKPVD_NPG_union[['2050']]$NPG_Heatpumps_LSOA_number)/sum(UKPVD_NPG_union[['2050']]$Meters_domestic)

# UKPN_proportion_NG_HPs_per_household_2050 <- UKPN_HPs_per_household/NG_HPs_per_household
# NPG_proportion_NG_HPs_per_household_2050 <- NPG_HPs_per_household/NG_HPs_per_household

# UKPN_proportion_NG_HPs_Total_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_Pure_HPs_number)/sum(UKPVD_FES_df[['2050']]$Heatpumps_nonhybrid_installations)
# NPG_proportion_NG_HPs_Total_2050 <- sum(UKPVD_NPG_union[['2050']]$NPG_Heatpumps_LSOA_number)/sum(UKPVD_FES_df[['2050']]$Heatpumps_nonhybrid_installations)

# # Storage - comparison between NG and DFES:


# NG_Stor_per_household_2050 <- sum(UKPVD_FES_df[['2050']]$Stor_kW)/sum(UKPVD_FES_df[['2050']]$Meters_domestic)

# UKPN_Stor_per_household_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_Stor_Dom_kW_df + UKPVD_UKPN_union[['2050']]$UKPN_Stor_Nonom_kW_df)/sum(UKPVD_UKPN_union[['2050']]$Meters_domestic)
# NPG_Stor_per_household_2050 <- sum(UKPVD_NPG_union[['2050']]$NPG_Storage_sum_kW)/sum(UKPVD_NPG_union[['2050']]$Meters_domestic)

# UKPN_over_NG_Stor_2050 <- sum(UKPVD_UKPN_union[['2050']]$UKPN_Stor_Dom_kW_df + UKPVD_UKPN_union[['2050']]$UKPN_Stor_Nonom_kW_df)/sum(UKPVD_UKPN_union[['2050']]$Stor_kW)
# NPG_over_NG_Stor_2050 <- sum(UKPVD_NPG_union[['2050']]$NPG_Storage_sum_kW)/sum(UKPVD_NPG_union[['2050']]$Stor_kW)


# Calibrate NG EV demand to dFES number of vehicles -> get aggregate demand per vehicle -> get nukber of vehicles & aggregate demand for each LSOA

# A sense check - if every car becomes an EV (same as current number of cars, ~40 million), what would NG demand be per vehicle?

NG_EV_Demand_kWperVehicle_NoSmart <- sum(UKPVD_FES_df[['2050']]$EV_peak_NoSmart_kW) / sum(UKPVD_FES_df[['2050']]$EV_number)
NG_EV_Demand_kWperVehicle_Smart <- sum(UKPVD_FES_df[['2050']]$EV_peak_Smart_kW) / sum(UKPVD_FES_df[['2050']]$EV_number)

# # This number (and that below for NPG, which is similar) seem surprisingly low to me (approx 0.6/0.3kW per vehicle depending on smart/non smart charging), but scenarios are broadly similar and results similar to the above for NG - NG say no ICEs on the road by 2050, and UKPN/NPG scenarios have the same.

# UKPN_Aggregate_EV_Demand_kWperVehicle_NoSmart <- sum(UKPVD_UKPN_union[['2050']]$EV_peak_NoSmart_kW)/sum(UKPVD_UKPN_union[['2050']]$UKPN_BEVs_number)
# UKPN_Aggregate_EV_Demand_kWperVehicle_Smart <- sum(UKPVD_UKPN_union[['2050']]$EV_peak_Smart_kW)/sum(UKPVD_UKPN_union[['2050']]$UKPN_BEVs_number)

# NPG_Aggregate_EV_Demand_kWperVehicle_NoSmart <- sum(UKPVD_NPG_union[['2050']]$EV_peak_NoSmart_kW)/sum(UKPVD_NPG_union[['2050']]$NPG_EVs_number)
# NPG_Aggregate_EV_Demand_kWperVehicle_Smart <- sum(UKPVD_NPG_union[['2050']]$EV_peak_Smart_kW)/sum(UKPVD_NPG_union[['2050']]$NPG_EVs_number)



### 6. MAKE ND EXPORT LSOA LEVEL BASE SCENARIO COMBINING ELEMENTS OF NG FES, and UKPN and NPG DFES
#############################################################################

# Combine scenarios by year in lapply loop

UKPVD_base_scenarios_df_list <- lapply(years_of_interest_list,function(year){
	# Add UKPN data
	UKPVD_UKPN_DFES_year_relabelled_df<-UKPVD_UKPN_DFES_df[[year]]
	colnames(UKPVD_UKPN_DFES_year_relabelled_df) <- c('LSOA',paste("UKPN", colnames(UKPVD_UKPN_DFES_year_relabelled_df)[-1], sep = "_"))
	df <- merge(UKPVD_FES_df[[year]],UKPVD_UKPN_DFES_year_relabelled_df,by='LSOA',all=TRUE)

	# Add NPG data
	UKPVD_NPG_DFES_year_relabelled_df<-UKPVD_NPG_DFES_df[[year]]
	colnames(UKPVD_NPG_DFES_year_relabelled_df) <- c('LSOA',paste("NPG", colnames(UKPVD_NPG_DFES_year_relabelled_df)[-1], sep = "_"))
	df <- merge(df,UKPVD_NPG_DFES_year_relabelled_df,by='LSOA',all=TRUE)

	# Add WPD data
	UKPVD_WPD_DFES_year_relabelled_df<-UKPVD_WPD_DFES_df[[year]]
	colnames(UKPVD_WPD_DFES_year_relabelled_df) <- c('LSOA',paste("WPD", colnames(UKPVD_WPD_DFES_year_relabelled_df)[-1], sep = "_"))
	df <- merge(df,UKPVD_WPD_DFES_year_relabelled_df,by='LSOA',all=TRUE)

	# Replace generic data with UKPN, NPG, and WPD data for regions where this is available

	UKPN_indices <- which(! is.na(df$UKPN_PV_domestic_sum_kW), arr.ind=TRUE)
	df[UKPN_indices,][['PV_domestic_sum_kW']]<-df[UKPN_indices,][['UKPN_PV_domestic_sum_kW']]
	df[UKPN_indices,][['PV_domestic_installations']]<-df[UKPN_indices,][['UKPN_PV_domestic_sum_kW']]/4 # Assumed 4kW capacity of residential installations as per UKPN DFES datasheet. Close to mean of 3.5 from Ofgem data.
	df[UKPN_indices,][['PV_nondom_sum_kW']]<-df[UKPN_indices,][['UKPN_PV_Nondom_kW']]
	df[UKPN_indices,][['PV_nondom_installations']]<-df[UKPN_indices,][['UKPN_PV_domestic_sum_kW']]/63.6 # Mean nondom PV capacity based on Ofgem data (within 4 - 150kW range specified in UKPN DFES datasheet)

	df[UKPN_indices,][['EV_number']]<-df[UKPN_indices,][['UKPN_BEVs_number']]
	df[UKPN_indices,][['EV_peak_Smart_kW']]<-df[UKPN_indices,][['UKPN_BEVs_number']] * NG_EV_Demand_kWperVehicle_Smart
	df[UKPN_indices,][['EV_peak_NoSmart_kW']]<-df[UKPN_indices,][['UKPN_BEVs_number']] * NG_EV_Demand_kWperVehicle_NoSmart
	df[UKPN_indices,][['Heatpumps_nonhybrid_installations']]<-df[UKPN_indices,][['UKPN_Pure_HPs_number']]
	df[UKPN_indices,][['Heatpumps_hybrid_installations']]<-df[UKPN_indices,][['UKPN_Hybrid_HPs_number']]

	df[UKPN_indices,][['Stor_kW']]<-df[UKPN_indices,][['UKPN_Stor_Dom_kW_df']] + df[UKPN_indices,][['UKPN_Stor_Nondom_kW_df']]


	NPG_indices <- which(! is.na(df$NPG_PV_domestic_sum_kW), arr.ind=TRUE)
	df[NPG_indices,][['PV_domestic_sum_kW']]<-df[NPG_indices,][['NPG_PV_domestic_sum_kW']]
	df[NPG_indices,][['PV_domestic_installations']]<-df[NPG_indices,][['NPG_PV_domestic_sum_kW']]/4 # Assumed 4kW capacity of residential installations as per UKPN DFES datasheet
	df[NPG_indices,][['EV_number']]<-df[NPG_indices,][['NPG_EVs_number']]
	df[NPG_indices,][['EV_peak_Smart_kW']]<-df[NPG_indices,][['NPG_EVs_number']] * NG_EV_Demand_kWperVehicle_Smart
	df[NPG_indices,][['EV_peak_NoSmart_kW']]<-df[NPG_indices,][['NPG_EVs_number']] * NG_EV_Demand_kWperVehicle_NoSmart
	df[NPG_indices,][['Heatpumps_nonhybrid_installations']]<-df[NPG_indices,][['NPG_Heatpumps_LSOA_number']]

	df[NPG_indices,][['Stor_kW']]<-df[NPG_indices,][['NPG_Storage_sum_kW']]


	WPD_indices <- which(! is.na(df$WPD_PV_domestic_sum_kW), arr.ind=TRUE)
	df[WPD_indices,][['PV_domestic_sum_kW']]<-df[WPD_indices,][['WPD_PV_domestic_sum_kW']]
	df[WPD_indices,][['PV_domestic_installations']]<-df[WPD_indices,][['WPD_PV_domestic_sum_kW']]/4 # Assumed 4kW capacity of residential installations as per UKPN DFES datasheet
	df[WPD_indices,][['EV_number']]<-df[WPD_indices,][['WPD_EVs_number']]
	df[WPD_indices,][['EV_peak_Smart_kW']]<-df[WPD_indices,][['WPD_EVs_number']] * NG_EV_Demand_kWperVehicle_Smart
	df[WPD_indices,][['EV_peak_NoSmart_kW']]<-df[WPD_indices,][['WPD_EVs_number']] * NG_EV_Demand_kWperVehicle_NoSmart
	df[WPD_indices,][['Heatpumps_nonhybrid_installations']]<-df[WPD_indices,][['WPD_Heatpumps_LSOA_number']]

	df[WPD_indices,][['Stor_kW']]<-df[WPD_indices,][['WPD_Storage_sum_kW']]

	df <- df[c("LSOA","Area_km2","Rurality_code","Meters_domestic","Demand_domestic_sum_kWh","Meters_nondom","Demand_nondom_sum_kWh",
		"N_Substations","GMT_Substation_Proportion",
		"PV_domestic_sum_kW","PV_domestic_installations", "PV_nondom_sum_kW", "PV_nondom_installations",
		"EV_peak_Smart_kW", "EV_number", "Heatpumps_nonhybrid_installations", "Stor_kW")]

	write.table(df, paste(output_path,'DFES/',DFES_base_output,year,'.csv', sep=''), sep=",", row.names=FALSE)

	return(df)
})

names(UKPVD_base_scenarios_df_list) <- years_of_interest_list



# Get some aggregrate properties
# UKPN_domestic_growth<-sum(UKPN_combined_data_list[[1]][which(UKPN_combined_data_list[[1]]$Parameter=='Domestic PV capacity'),][['2050']])/sum(UKPN_combined_data_list[[1]][which(UKPN_combined_data_list[[1]]$Parameter=='Domestic PV capacity'),][['2020']])




