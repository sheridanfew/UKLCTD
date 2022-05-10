# Script to generate NG scenarios from UKLCTD database directly from data sources
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
plot_path <- paste(root_path,'Plots/',sep='') # NB. These are the same here - output here is intermediate


### INPUT DATA
# ONS Table to convert between LA and LSOA, source: https://geoportal.statistics.gov.uk/datasets/output-area-to-lsoa-to-msoa-to-local-authority-district-december-2017-lookup-with-area-classifications-in-great-britain/data date accessed: 8 Oct 2020
ONS_OA_LSOA_MSOA_LA_conversion_input <- "ONS/Output_Area_to_LSOA_to_MSOA_to_Local_Authority_District__December_2017__Lookup_with_Area_Classifications_in_Great_Britain.csv" 

# UKLCTD containing recent LSOA-level data on spatial area, population, rurality, meter data, PV deployment, and substation density. Generated from raw data sources using 'Generate_UKLCTD.R', and substation data added using 'Add_substations_to_UKLCTD.R'
UKLCTD_input <- 'UKLCTD_w_substations_Oct2020.csv'

# National Grid Future Energy Scenarios 2019 data workbook source: https://www.nationalgrideso.com/future-energy/future-energy-scenarios/fes-2019-documents date accessed: 9 Oct 2020
NG_FES_input <- 'FES/UKLCTD_Scenarios_FES2019_'

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
DFES_base_output <- 'UKLCTD_Scenarios_DFES_base_'

# VARIABLES (USED GLOBALLY)

# Definition of years of interest
years_of_interest_list<-c('2020','2030','2040','2050')

### FUNCTIONS

# Define function to plot box&whisker plots by rurality

boxplot_by_rurality<-function(df, variable, variable_short, title, name){

png(paste(plot_path,'BoxAndWhisker/',name,'.png',sep=''),width = 550, height = 210, unit = "px")

data<-df

x1 <- data[[variable]][data$Rurality_code=="A1"]
x2 <- data[[variable]][data$Rurality_code=="B1"]
x3 <- data[[variable]][data$Rurality_code=="C1" | data$Rurality_code=="C2" ]
x4 <- data[[variable]][data$Rurality_code=="D1" | data$Rurality_code=="D2" ]
x5 <- data[[variable]][data$Rurality_code=="E1" | data$Rurality_code=="E2" ]

par(mar =  c(5.1, 4.1, 4.1, 2.1) + c(0, 5, 0, 0)) 
par(ps = 18, cex = 1, cex.main = 1)

boxplot(x1, x2, x3, x4,x5,
	names=c("Maj Con","Min Con", "City & Town", "Town & Fringe","Village"),
    col=c("grey40","grey60","grey80","chocolate4","green4"),
    main=title,
    horizontal=TRUE,outline=FALSE,las=1,frame=FALSE)
	#ylim=c(0,1200),

 title(xlab = variable_short)

dev.off()
}



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


### 2. IMPORT UKLCTD
#############################################################################################################

# Import data
UKLCTD_df<-read.csv(paste(intermediate_path,UKLCTD_input, sep=''), header=TRUE)

### 3. IMPORT NG FES SCENARIOS
#############################################################################################################

# Import data by year

UKLCTD_FES_df <- lapply(years_of_interest_list,function(year)
{
	 UKLCTD_year_df<-read.csv(paste(intermediate_path,NG_FES_input,year,'.csv', sep=''), header=TRUE)
	return(UKLCTD_year_df)
}
)

names(UKLCTD_FES_df) <- years_of_interest_list


### 4. IMPORT dFES SCENARIOS AND REPLACE VALUES WITH THESE IN UKLCTD SCENARIOS
#############################################################################################################

### 4a. WPD Scenarios

#Import data

WPD_EM_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_EM_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_EM_DFES_Stor_Dom_input, sep=''),header=TRUE,skip=6))

WPD_SW_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_SW_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_SW_DFES_Stor_Dom_input, sep=''),header=TRUE,skip=6))

WPD_WA_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_WA_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WA_DFES_Stor_Dom_input, sep=''),header=TRUE,skip=6))

WPD_WM_DFES_DomPV_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_PV_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_EV_autonomous_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_EV_autonomous_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_EV_nonauto_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_EV_nonauto_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_HPs_hybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_HPs_hybrid_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_HPs_nonhybrid_number_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_HPs_nonhybrid_input, sep=''),header=TRUE,skip=6))
WPD_WM_DFES_Stor_MW_df <- as.data.frame(read.csv(paste(input_path,WPD_WM_DFES_Stor_Dom_input, sep=''),header=TRUE,skip=6))


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
 	df_out <- df[c('LA',years_of_interest_list)]
 	return(df_out)
})

# Differences in names found using the commands below:

#setdiff(rownames(WPD_combined_data_list[[1]]),unique(LSOA_LA_df$LA))
#unique(LSOA_LA_df$LA)[order(unique(LSOA_LA_df$LA))]
#rownames(WPD_combined_data_list[[1]])[order(rownames(WPD_combined_data_list[[1]]))]


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
	# Rename rows by LA, select years of interest, & export
 	rownames(df)<-df$LA
 	df_out <- df[c('LA',years_of_interest_list)]
 	return(df_out)
}
)

names(NPG_combined_data_list)<-c('DomPV_MW_df','EVs_number_df','HPs_number_df','Stor_MW_df')

### 4c. Combine WPD and NPG SCENARIOS (As some LAs span both network regions, this combination is reqired before attributing quantities to LSOAs)
#############################################################################################################



WPD_NPG_combined_data_list<-lapply(c('DomPV_MW_df','EVs_number_df','HPs_number_df','Stor_MW_df'),function(name){
	# Sum data for LAs spanning both WPD and NPG regions
	df  <- rbind(WPD_combined_data_list[[name]],NPG_combined_data_list[[name]])
	df  <- as.data.frame(aggregate(df[-1], list(df$LA), sum))
	df  <- rename(df, c("Group.1"="LA"))

	# Exclude LAs which lie partly outside of the region we have data for (avoids these quantities being erronously divided between all LSOAs in the whole LA)
	df <- df[ !(df$LA %in% c('South Holland', 'Huntingdonshire', 'Fenland', 'Peterborough', 'Bedford', 'Aylesbury Vale', 'West Oxfordshire', 'Cherwell', 'Cotswold', 'Wiltshire', 'Dorset', 'Ceredigion', 'Powys', 'High Peak', 'Cheshire East', 'Pendle', 'Craven',"King's Lynn and West Norfolk",'Central Bedfordshire')), ]

	# Order by LA name
	df<-df[order(df$LA),]

	# Rename rows by LA, select years of interest, & export
	rownames(df)<-df$LA
	df_out <- df[c(years_of_interest_list)]
	return(df_out)
})

names(WPD_NPG_combined_data_list)<-c('DomPV_MW_df','EVs_number_df','HPs_number_df','Stor_MW_df')

# This step using WPD and NPG data combined
# Convert to LSOA level (by dividing equally between LSOAs in the LA - several steps following the same thinking as converting MSOA level data for nondom demand in creating the UKLCTD)

## Get list of WPD_NPG LAs
WPD_NPG_LAs<-rownames(WPD_NPG_combined_data_list[[1]])

## Make df ready for LSOA level data containing every LSOA in LAs covered by WPD_NPG
WPD_NPG_combined_data_LSOA_df <- LSOA_LA_lookup_df[is.element(LSOA_LA_lookup_df$LA, WPD_NPG_LAs),]

# Add columns for LSOA level variables (to be filled in subsequent 'lapply' routine)
WPD_NPG_combined_data_LSOA_df$PV_domestic_sum_kW<-NA
WPD_NPG_combined_data_LSOA_df$EVs_number<-NA
WPD_NPG_combined_data_LSOA_df$Heatpumps_LSOA_number<-NA
WPD_NPG_combined_data_LSOA_df$Storage_sum_kW<-NA

# Add number of meters (used in allocating techs across LSOA)
WPD_NPG_combined_data_LSOA_df <- merge(WPD_NPG_combined_data_LSOA_df,UKLCTD_df[c('LSOA','Meters_domestic')],by='LSOA')


# Routine to divide between constituent LSOAs - I wrote this a while ago and it's a bit slow and clunky, but it works

# Make df containing DFES values for each year of interest:
UKLCTD_WPD_NPG_DFES_df<-lapply(years_of_interest_list, function(year) {
	print(paste('Running for year: ', year,sep=''))
	# Duplicate df with all LSOAs to process here ( needs redoing each time because it's a global variable - bit messy)
	WPD_NPG_combined_data_LSOA_year_df<<-WPD_NPG_combined_data_LSOA_df
	# Run across LAs of interest list
	# Function to divide LA level data between LSOAs and put into WPD_NPG_combined_data_LSOA_df frame. Lapply across list of LAs in WPD_NPG region.
	lapply(WPD_NPG_LAs,function(LA){
		# Get LA level data for the LA currently being processed
		DomPV_LA_kW <- WPD_NPG_combined_data_list[['DomPV_MW_df']][LA,year]*1000
		EVs_LA_number <- WPD_NPG_combined_data_list[['EVs_number_df']][LA,year]
		HPs_LA_number <- WPD_NPG_combined_data_list[['HPs_number_df']][LA,year]
		Stor_LA_kW <- WPD_NPG_combined_data_list[['Stor_MW_df']][LA,year]*1000

		# Which LSOAs are in this LA? How many of them are there?
		LSOAs=as.vector(LSOA_LA_lookup_df$LSOA[which(LSOA_LA_lookup_df$LA==LA)])
		N_LSOAs <- length(LSOAs)

		# How many domestic meters are in this LA?
		N_meters <- sum(WPD_NPG_combined_data_LSOA_df$Meters_domestic[which(WPD_NPG_combined_data_LSOA_df$LA==LA)])

		# Divide LA level data by number of LSOAs in that LA
		PV_domestic_sum_kW_per_meter <- DomPV_LA_kW/N_meters
		EVs_LSOA_number_per_meter <- EVs_LA_number/N_meters
		HPs_LSOA_number_per_meter <- HPs_LA_number/N_meters
		Stor_LSOA_kW_per_meter <- Stor_LA_kW/N_meters

		# Put newly calculated data into global WPD_NPG_combined_data_LSOA_df dataframe by LSOA
		lapply (LSOAs, function(LSOA) {
			index = which(WPD_NPG_combined_data_LSOA_df$LSOA==LSOA)
			WPD_NPG_combined_data_LSOA_year_df$PV_domestic_sum_kW[index] <<- WPD_NPG_combined_data_LSOA_year_df$Meters_domestic[index] * PV_domestic_sum_kW_per_meter
			WPD_NPG_combined_data_LSOA_year_df$EVs_number[index] <<- WPD_NPG_combined_data_LSOA_year_df$Meters_domestic[index] * EVs_LSOA_number_per_meter
			WPD_NPG_combined_data_LSOA_year_df$Heatpumps_LSOA_number[index] <<- WPD_NPG_combined_data_LSOA_year_df$Meters_domestic[index] * HPs_LSOA_number_per_meter
			WPD_NPG_combined_data_LSOA_year_df$Storage_sum_kW[index] <<- WPD_NPG_combined_data_LSOA_year_df$Meters_domestic[index] * Stor_LSOA_kW_per_meter
		})
	})
	return(WPD_NPG_combined_data_LSOA_year_df)
})

names(UKLCTD_WPD_NPG_DFES_df)<-years_of_interest_list


### 4d  UKPN SCENARIOS
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

UKLCTD_UKPN_DFES_df <- lapply(years_of_interest_list, function(year) {
	year_df <- cbind(UKPN_combined_data_list[['PV_Domestic_kW_df']][c('LSOA',year)],
		UKPN_combined_data_list[['PV_Nondom_kW_df']][year],
		UKPN_combined_data_list[['BEVs_number_df']][year]+UKPN_combined_data_list[['BEV_vans_number_df']][year],
		UKPN_combined_data_list[['PHEVs_number_df']][year]+UKPN_combined_data_list[['PHEV_vans_number_df']][year],
		UKPN_combined_data_list[['Pure_HPs_number_df']][year],
		UKPN_combined_data_list[['Hybrid_HPs_number_df']][year],
		UKPN_combined_data_list[['Stor_Dom_kW_df']][year],
		UKPN_combined_data_list[['Stor_Nondom_kW_df']][year])

	names(year_df) <- c('LSOA','PV_domestic_sum_kW','PV_Nondom_kW','EVs_number','PHEVs_number','Heatpumps_LSOA_number','Hybrid_HPs_number','Stor_Dom_kW_df','Stor_Nondom_kW_df')
	return(year_df)
	})

names(UKLCTD_UKPN_DFES_df)<-years_of_interest_list


### 5. CONVERSIONS/COMPARISONS
#############################################################################################################


# UKLCTD_UKPN_union <- lapply(years_of_interest_list,function(year){
# 	UKLCTD_UKPN_DFES_year_relabelled_df<-UKLCTD_UKPN_DFES_df[[year]]
# 	colnames(UKLCTD_UKPN_DFES_year_relabelled_df) <- c('LSOA',paste("UKPN", colnames(UKLCTD_UKPN_DFES_year_relabelled_df)[-1], sep = "_"))
# 	df <- merge(UKLCTD_FES_df[[year]],UKLCTD_UKPN_DFES_year_relabelled_df,by='LSOA')
# })
# names(UKLCTD_UKPN_union)<-years_of_interest_list

# UKLCTD_NPG_union <- lapply(years_of_interest_list,function(year){
# 	UKLCTD_NPG_DFES_year_relabelled_df<-UKLCTD_NPG_DFES_df[[year]]
# 	colnames(UKLCTD_NPG_DFES_year_relabelled_df) <- c('LSOA',paste("NPG", colnames(UKLCTD_NPG_DFES_year_relabelled_df)[-1], sep = "_"))
# 	df <- merge(UKLCTD_FES_df[[year]],UKLCTD_NPG_DFES_year_relabelled_df,by='LSOA')
# })

# names(UKLCTD_NPG_union)<-years_of_interest_list

# # PV per household

# NG_PV_dom_per_household <- sum(UKLCTD_FES_df[['2050']]$PV_domestic_sum_kW)/sum(UKLCTD_FES_df[['2050']]$Meters_domestic)
# NG_PV_nondom_per_household <- sum(UKLCTD_FES_df[['2050']]$PV_nondom_sum_kW)/sum(UKLCTD_FES_df[['2050']]$Meters_domestic)

# UKPN_PV_dom_per_household_2020 <- sum(UKLCTD_UKPN_union[['2020']]$UKPN_PV_domestic_sum_kW)/sum(UKLCTD_UKPN_union[['2020']]$Meters_domestic)
# UKPN_PV_dom_per_household_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_PV_domestic_sum_kW)/sum(UKLCTD_UKPN_union[['2050']]$Meters_domestic)
# UKPN_PV_nondom_per_household_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_PV_Nondom_kW)/sum(UKLCTD_UKPN_union[['2050']]$Meters_domestic)

# NPG_PV_per_household_2020 <- sum(UKLCTD_NPG_union[['2020']]$NPG_PV_domestic_sum_kW)/sum(UKLCTD_NPG_union[['2020']]$Meters_domestic)
# NPG_PV_per_household_2050 <- sum(UKLCTD_NPG_union[['2050']]$NPG_PV_domestic_sum_kW)/sum(UKLCTD_NPG_union[['2050']]$Meters_domestic)

# # Dom/nondom PV per demand

# NG_PV_dom_per_dem_2050 <- sum(UKLCTD_FES_df[['2050']]$PV_domestic_sum_kW)/sum(UKLCTD_FES_df[['2050']]$Demand_domestic_sum_kWh)
# NG_PV_nondom_per_dem_2050 <- sum(UKLCTD_FES_df[['2050']]$PV_nondom_sum_kW)/sum(UKLCTD_FES_df[['2050']]$Demand_nondom_sum_kWh)

# UKPN_PV_dom_per_dem_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_PV_domestic_sum_kW)/sum(UKLCTD_UKPN_union[['2050']]$Demand_domestic_sum_kWh)
# UKPN_PV_nondom_per_dem_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_PV_Nondom_kW)/sum(UKLCTD_UKPN_union[['2050']]$Demand_nondom_sum_kWh)

# # EVs per household

# NG_EVs_per_household_2020 <- sum(UKLCTD_FES_df[['2020']]$EV_number)/sum(UKLCTD_FES_df[['2020']]$Meters_domestic)
# NG_EVs_per_household_2050 <- sum(UKLCTD_FES_df[['2050']]$EV_number)/sum(UKLCTD_FES_df[['2050']]$Meters_domestic)

# UKPN_EVs_per_household_2020 <- sum(UKLCTD_UKPN_union[['2020']]$UKPN_BEVs_number)/sum(UKLCTD_UKPN_union[['2020']]$Meters_domestic)
# UKPN_EVs_per_household_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_BEVs_number)/sum(UKLCTD_UKPN_union[['2050']]$Meters_domestic)

# NPG_EVs_per_household_2020 <- sum(UKLCTD_NPG_union[['2020']]$NPG_EVs_number)/sum(UKLCTD_NPG_union[['2020']]$Meters_domestic)
# NPG_EVs_per_household_2050 <- sum(UKLCTD_NPG_union[['2050']]$NPG_EVs_number)/sum(UKLCTD_NPG_union[['2050']]$Meters_domestic)

# # Growth Factors for EVs

# NG_EV_Growth_Factor_2020_2050_NoSmart <- sum(UKLCTD_FES_df[['2050']]$EV_peak_NoSmart_kW)/sum(UKLCTD_FES_df[['2020']]$EV_peak_NoSmart_kW)
# NG_EV_Growth_Factor_2020_2050_Smart <- sum(UKLCTD_FES_df[['2050']]$EV_peak_Smart_kW)/sum(UKLCTD_FES_df[['2020']]$EV_peak_Smart_kW)

# UKPN_EV_Growth_Factor_2020_2050 <- sum(UKLCTD_UKPN_DFES_df[['2050']]$BEVs_number)/sum(UKLCTD_UKPN_DFES_df[['2020']]$BEVs_number)
# NPG_EV_Growth_Factor_2020_2050 <- sum(UKLCTD_NPG_DFES_df[['2050']]$EVs_number)/sum(UKLCTD_NPG_DFES_df[['2020']]$EVs_number)

# # HPs per household

# NG_HPs_per_household <- sum(UKLCTD_FES_df[['2050']]$Heatpumps_nonhybrid_installations)/sum(UKLCTD_FES_df[['2050']]$Meters_domestic)
# NG_HybridHPs_per_household <- sum(UKLCTD_FES_df[['2050']]$Heatpumps_hybrid_installations)/sum(UKLCTD_FES_df[['2050']]$Meters_domestic)

# UKPN_HPs_per_household <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_Pure_HPs_number)/sum(UKLCTD_UKPN_union[['2050']]$Meters_domestic)
# NPG_HPs_per_household <- sum(UKLCTD_NPG_union[['2050']]$NPG_Heatpumps_LSOA_number)/sum(UKLCTD_NPG_union[['2050']]$Meters_domestic)

# UKPN_proportion_NG_HPs_per_household_2050 <- UKPN_HPs_per_household/NG_HPs_per_household
# NPG_proportion_NG_HPs_per_household_2050 <- NPG_HPs_per_household/NG_HPs_per_household

# UKPN_proportion_NG_HPs_Total_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_Pure_HPs_number)/sum(UKLCTD_FES_df[['2050']]$Heatpumps_nonhybrid_installations)
# NPG_proportion_NG_HPs_Total_2050 <- sum(UKLCTD_NPG_union[['2050']]$NPG_Heatpumps_LSOA_number)/sum(UKLCTD_FES_df[['2050']]$Heatpumps_nonhybrid_installations)

# # Storage - comparison between NG and DFES:


# NG_Stor_per_household_2050 <- sum(UKLCTD_FES_df[['2050']]$Stor_kW)/sum(UKLCTD_FES_df[['2050']]$Meters_domestic)

# UKPN_Stor_per_household_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_Stor_Dom_kW_df + UKLCTD_UKPN_union[['2050']]$UKPN_Stor_Nonom_kW_df)/sum(UKLCTD_UKPN_union[['2050']]$Meters_domestic)
# NPG_Stor_per_household_2050 <- sum(UKLCTD_NPG_union[['2050']]$NPG_Storage_sum_kW)/sum(UKLCTD_NPG_union[['2050']]$Meters_domestic)

# UKPN_over_NG_Stor_2050 <- sum(UKLCTD_UKPN_union[['2050']]$UKPN_Stor_Dom_kW_df + UKLCTD_UKPN_union[['2050']]$UKPN_Stor_Nonom_kW_df)/sum(UKLCTD_UKPN_union[['2050']]$Stor_kW)
# NPG_over_NG_Stor_2050 <- sum(UKLCTD_NPG_union[['2050']]$NPG_Storage_sum_kW)/sum(UKLCTD_NPG_union[['2050']]$Stor_kW)


# Calibrate NG EV demand to dFES number of vehicles -> get aggregate demand per vehicle -> get nukber of vehicles & aggregate demand for each LSOA

# A sense check - if every car becomes an EV (same as current number of cars, ~40 million), what would NG demand be per vehicle?

NG_EV_Demand_kWperVehicle_NoSmart <- sum(UKLCTD_FES_df[['2050']]$EV_peak_NoSmart_kW) / sum(UKLCTD_FES_df[['2050']]$EV_number)
NG_EV_Demand_kWperVehicle_Smart <- sum(UKLCTD_FES_df[['2050']]$EV_peak_Smart_kW) / sum(UKLCTD_FES_df[['2050']]$EV_number)

# # This number (and that below for NPG, which is similar) seem surprisingly low to me (approx 0.6/0.3kW per vehicle depending on smart/non smart charging), but scenarios are broadly similar and results similar to the above for NG - NG say no ICEs on the road by 2050, and UKPN/NPG scenarios have the same.

# UKPN_Aggregate_EV_Demand_kWperVehicle_NoSmart <- sum(UKLCTD_UKPN_union[['2050']]$EV_peak_NoSmart_kW)/sum(UKLCTD_UKPN_union[['2050']]$UKPN_BEVs_number)
# UKPN_Aggregate_EV_Demand_kWperVehicle_Smart <- sum(UKLCTD_UKPN_union[['2050']]$EV_peak_Smart_kW)/sum(UKLCTD_UKPN_union[['2050']]$UKPN_BEVs_number)

# NPG_Aggregate_EV_Demand_kWperVehicle_NoSmart <- sum(UKLCTD_NPG_union[['2050']]$EV_peak_NoSmart_kW)/sum(UKLCTD_NPG_union[['2050']]$NPG_EVs_number)
# NPG_Aggregate_EV_Demand_kWperVehicle_Smart <- sum(UKLCTD_NPG_union[['2050']]$EV_peak_Smart_kW)/sum(UKLCTD_NPG_union[['2050']]$NPG_EVs_number)



### 6. MAKE ND EXPORT LSOA LEVEL BASE SCENARIO COMBINING ELEMENTS OF NG FES, and UKPN and NPG DFES
#############################################################################

# Combine scenarios by year in lapply loop

UKLCTD_base_scenarios_df_list <- lapply(years_of_interest_list,function(year){
	# Add UKPN data
	UKLCTD_UKPN_DFES_year_relabelled_df<-UKLCTD_UKPN_DFES_df[[year]]
	colnames(UKLCTD_UKPN_DFES_year_relabelled_df) <- c('LSOA',paste("UKPN", colnames(UKLCTD_UKPN_DFES_year_relabelled_df)[-1], sep = "_"))
	df <- merge(UKLCTD_FES_df[[year]],UKLCTD_UKPN_DFES_year_relabelled_df,by='LSOA',all=TRUE)

	# Add WPD_NPG data
	UKLCTD_WPD_NPG_DFES_year_relabelled_df<-UKLCTD_WPD_NPG_DFES_df[[year]]
	colnames(UKLCTD_WPD_NPG_DFES_year_relabelled_df) <- c('LSOA',paste("WPD_NPG", colnames(UKLCTD_WPD_NPG_DFES_year_relabelled_df)[-1], sep = "_"))
	df <- merge(df,UKLCTD_WPD_NPG_DFES_year_relabelled_df,by='LSOA',all=TRUE)

	# Replace generic data with UKPN, WPD_NPG, and WPD data for regions where this is available

	UKPN_indices <- which(! is.na(df$UKPN_PV_domestic_sum_kW), arr.ind=TRUE)
	df[UKPN_indices,][['PV_domestic_sum_kW']]<-df[UKPN_indices,][['UKPN_PV_domestic_sum_kW']]
	df[UKPN_indices,][['PV_domestic_installations']]<-df[UKPN_indices,][['UKPN_PV_domestic_sum_kW']]/4 # Assumed 4kW capacity of residential installations as per UKPN DFES datasheet. Close to mean of 3.5 from Ofgem data.
	df[UKPN_indices,][['PV_nondom_sum_kW']]<-df[UKPN_indices,][['UKPN_PV_Nondom_kW']]
	df[UKPN_indices,][['PV_nondom_installations']]<-df[UKPN_indices,][['UKPN_PV_domestic_sum_kW']]/63.6 # Mean nondom PV capacity based on Ofgem data (within 4 - 150kW range specified in UKPN DFES datasheet)

	df[UKPN_indices,][['EV_number']]<-df[UKPN_indices,][['UKPN_EVs_number']]
	df[UKPN_indices,][['EV_peak_Smart_kW']]<-df[UKPN_indices,][['UKPN_EVs_number']] * NG_EV_Demand_kWperVehicle_Smart
	df[UKPN_indices,][['EV_peak_NoSmart_kW']]<-df[UKPN_indices,][['UKPN_EVs_number']] * NG_EV_Demand_kWperVehicle_NoSmart
	df[UKPN_indices,][['Heatpumps_nonhybrid_installations']]<-df[UKPN_indices,][['UKPN_Heatpumps_LSOA_number']]
	df[UKPN_indices,][['Heatpumps_hybrid_installations']]<-df[UKPN_indices,][['UKPN_Hybrid_HPs_number']]

	df[UKPN_indices,][['Stor_kW']]<-df[UKPN_indices,][['UKPN_Stor_Dom_kW_df']] + df[UKPN_indices,][['UKPN_Stor_Nondom_kW_df']]


	WPD_NPG_indices <- which(! is.na(df$WPD_NPG_PV_domestic_sum_kW), arr.ind=TRUE)
	df[WPD_NPG_indices,][['PV_domestic_sum_kW']]<-df[WPD_NPG_indices,][['WPD_NPG_PV_domestic_sum_kW']]
	df[WPD_NPG_indices,][['PV_domestic_installations']]<-df[WPD_NPG_indices,][['WPD_NPG_PV_domestic_sum_kW']]/4 # Assumed 4kW capacity of residential installations as per UKPN DFES datasheet
	df[WPD_NPG_indices,][['EV_number']]<-df[WPD_NPG_indices,][['WPD_NPG_EVs_number']]
	df[WPD_NPG_indices,][['EV_peak_Smart_kW']]<-df[WPD_NPG_indices,][['WPD_NPG_EVs_number']] * NG_EV_Demand_kWperVehicle_Smart
	df[WPD_NPG_indices,][['EV_peak_NoSmart_kW']]<-df[WPD_NPG_indices,][['WPD_NPG_EVs_number']] * NG_EV_Demand_kWperVehicle_NoSmart
	df[WPD_NPG_indices,][['Heatpumps_nonhybrid_installations']]<-df[WPD_NPG_indices,][['WPD_NPG_Heatpumps_LSOA_number']]

	df[WPD_NPG_indices,][['Stor_kW']]<-df[WPD_NPG_indices,][['WPD_NPG_Storage_sum_kW']]


	df <- df[c("LSOA","Area_km2","Rurality_code","Meters_domestic","Demand_domestic_sum_kWh","Meters_nondom","Demand_nondom_sum_kWh",
		"N_Substations","GMT_Substation_Proportion",
		"PV_domestic_sum_kW","PV_domestic_installations", "PV_nondom_sum_kW", "PV_nondom_installations",
		"EV_peak_Smart_kW", "EV_number", "Heatpumps_nonhybrid_installations", "Stor_kW")]

	write.table(df, paste(output_path,'DFES/',DFES_base_output,year,'.csv', sep=''), sep=",", row.names=FALSE)

	return(df)
})

names(UKLCTD_base_scenarios_df_list) <- years_of_interest_list


# 7. Plot distributions for whole GB and for smaller regions
#############################################################


lapply(c('2020','2050'),function(year){
	dfs_by_region <- list(UKLCTD_FES_df[[year]],
						  UKLCTD_base_scenarios_df_list[[year]],
						  subset(UKLCTD_base_scenarios_df_list[[year]], LSOA %in% UKLCTD_WPD_NPG_DFES_df[[year]]$LSOA),
						  subset(UKLCTD_base_scenarios_df_list[[year]], LSOA %in% UKLCTD_UKPN_DFES_df[[year]]$LSOA))

	names(dfs_by_region)<-c('allGB_FES', 'allGB_DFES', 'WPD_NPG', 'UKPN')

	lapply(names(dfs_by_region),function(region){
		boxplot_by_rurality(df=dfs_by_region[[region]], variable="Heatpumps_nonhybrid_installations",variable_short="Number of Heatpumps",title=paste(region, ', ',year,sep=''),name=paste("HPs_",region,"_",year,sep=''))
		boxplot_by_rurality(df=dfs_by_region[[region]], variable="EV_number",variable_short="Number of EVs",title=paste(region, ', ',year,sep=''),name=paste("EVs_",region,"_",year,sep=''))
		boxplot_by_rurality(df=dfs_by_region[[region]], variable="PV_domestic_sum_kW",variable_short="Domestic PV (kW)",title=paste(region, ', ',year,sep=''),name=paste("PVdom_",region,"_",year,sep=''))
		boxplot_by_rurality(df=dfs_by_region[[region]], variable="PV_nondom_sum_kW",variable_short="Nondom PV (kW)",title=paste(region, ', ',year,sep=''),name=paste("PVnondom_",region,"_",year,sep=''))
		boxplot_by_rurality(df=dfs_by_region[[region]], variable="Stor_kW",variable_short="Storage (kW)",title=paste(region, ', ',year,sep=''),name=paste("Stor_",region,"_",year,sep=''))

		boxplot_by_rurality(df=dfs_by_region[[region]], variable="Area_km2",variable_short="Area (km2)",title=paste(region, ', ',year,sep=''),name=paste("Area_",region,"_",year,sep=''))
		boxplot_by_rurality(df=dfs_by_region[[region]], variable="N_Substations",variable_short="Number of substations",title=paste(region, ', ',year,sep=''),name=paste("NSubs_",region,"_",year,sep=''))
		boxplot_by_rurality(df=dfs_by_region[[region]], variable="Meters_domestic",variable_short="Number of domestic meters",title=paste(region, ', ',year,sep=''),name=paste("MetDom_",region,"_",year,sep=''))
	})
})


# Get some aggregrate properties
# UKPN_domestic_growth<-sum(UKPN_combined_data_list[[1]][which(UKPN_combined_data_list[[1]]$Parameter=='Domestic PV capacity'),][['2050']])/sum(UKPN_combined_data_list[[1]][which(UKPN_combined_data_list[[1]]$Parameter=='Domestic PV capacity'),][['2020']])




