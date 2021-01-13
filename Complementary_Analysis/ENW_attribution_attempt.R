# ### START OF WORK ON CODE TRANSLATING ENW DFES DATA (at primary substation level) TO LSOA LEVEL (Based on defining closest primary substation to each LSOA, and dividing primary subs level numbers amongst these))
# Decided attribution & defining limits of edge of ENW network is too complicated given different units so not finally implemented

# ENW  Primary substation locations: https://www.enwl.co.uk/get-connected/network-information/heatmap-tool/ date accessed: 13 Oct 2020
ENW_PrimarySubs_Location_input <- "DFES/ENW/heatmap-tool.xlsx"

# ENW DFES 2019 data by primary substation https://www.enwl.co.uk/get-connected/network-information/dfes/ date accessed: 1 Oct 2020
ENW_PDFES_input <- "DFES/ENW/dfes-2019-workbook_updated_version_20jul20.xlsx"


# ONS Table with centroids of LSOAs, units Eating and Northing (meters) used in finding nearest primary substation in ENW data source: https://geoportal.statistics.gov.uk/datasets/lower-layer-super-output-areas-december-2011-population-weighted-centroids date accessed: 13 Oct 2020
ONS_LSOA_coords_input <-"ONS/Lower_Layer_Super_Output_Areas__December_2011__Population_Weighted_Centroids.csv"


# ### 5c. ENW SCENARIOS
# #############################################################################################################

# ## First stage is mapping LSOAs to BSPs

# # Import data
# ONS_LSOA_coords_df<-read.csv(paste(input_path,ONS_LSOA_coords_input, sep=''), header=TRUE)
# ENW_PrimarySubs_Location_df<-as.data.frame(read_excel(paste(input_path,ENW_PrimarySubs_Location_input, sep=''),sheet='4) Primary Headroom Data',range="B5:H376"))

# # Rename columns
# ONS_LSOA_coords_df  <- rename(ONS_LSOA_coords_df, c("lsoa11cd"="LSOA"))

# ENW_PrimarySubs_Location_df  <- rename(ENW_PrimarySubs_Location_df, c("Primary Substation Location"="X"))
# ENW_PrimarySubs_Location_df  <- rename(ENW_PrimarySubs_Location_df, c("X__2"="Y"))

# # Exclude mess in first line
# ENW_PrimarySubs_Location_df  <- ENW_PrimarySubs_Location_df[-1,]

# # Select only relevant colummns
# ONS_LSOA_coords_df<-ONS_LSOA_coords_df[c('X','Y','LSOA')]
# ENW_PrimarySubs_Location_df<-ENW_PrimarySubs_Location_df[c('Primary Substation','X','Y')]

# # Make R recognise numbers in coordinates
# ENW_PrimarySubs_Location_df$X <- as.numeric(ENW_PrimarySubs_Location_df$X)
# ENW_PrimarySubs_Location_df$Y <- as.numeric(ENW_PrimarySubs_Location_df$Y)

# max_X = max(ENW_PrimarySubs_Location_df$X )
# min_X = min(ENW_PrimarySubs_Location_df$X )
# max_Y = max(ENW_PrimarySubs_Location_df$Y )
# min_Y = min(ENW_PrimarySubs_Location_df$Y )


# # Distance function 
# distance <- function(a, b){
#                 dt <- data.table((ENW_PrimarySubs_Location_df$X-a)^2+(ENW_PrimarySubs_Location_df$Y-b)^2)
#                 if (min(dt) >= 10000 & ){
#                 	return('NA')
#                 } else {
#                 return(ENW_PrimarySubs_Location_df[['Primary Substation']][which.min(dt$V1)])
#             	}
#             }


# ONS_LSOA_coords_dt<-data.table(ONS_LSOA_coords_df)

# results <- ONS_LSOA_coords_dt[, j = list(Closest =  distance(X, Y)), by = 1:nrow(ONS_LSOA_coords_dt)]



# read.csv(paste(input_path,ONS_LSOA_coords_input, sep=''), header=TRUE)


# # ENW  Primary substation locations: https://www.enwl.co.uk/get-connected/network-information/heatmap-tool/ date accessed: 13 Oct 2020
# ENW_PrimarySubs_Location_input <- "DFES/ENW/heatmap-tool.xlsx"

# # ENW DFES 2019 data by primary substation https://www.enwl.co.uk/get-connected/network-information/dfes/ date accessed: 1 Oct 2020
# ENW_PDFES_input <- "DFES/ENW/dfes-2019-workbook_updated_version_20jul20.xlsx"

