# Script to analyse elexon data
# Sheridan Few, Oct 2020
# See also readme file

### Packages

library(data.table) # For fread to import subset of data (saving memory) - not currently implememnted
library(plyr) # For renaming data frame columns
library(stringr)
library(readxl)


### PATH DEFINITION

root_path <- '/Users/Shez/Google Drive/Grantham/JUICE/UKPVD/'
input_path <- paste(root_path,'Input_data/',sep='')
output_path <- paste(root_path,'Intermediate_data/',sep='') # UKPVD is considered intermediate data as it is an output of sorts, but will be used for future processing

### INPUT DATA

# Elexon profiles, from Paul Westacott's old data
Elexon_profiles_input <- "Elexon/Elexon_DemandData_PC1238.csv" 

### DO STUFF 

# Import data
Elexon_profiles_df<-read.csv(paste(input_path,Elexon_profiles_input, sep=''), header=TRUE)


# List of profile names
Profile_names<-c("Domestic Unrestricted Customers","Domestic Economy 7 Customers","Non-Domestic Unrestricted Customers","Non-Domestic Maximum Demand Customers with a Peak Load Factor over 40%")

names(Elexon_profiles_df)<-c("Date","Time",Profile_names)


# Get info about load profiles at midday on days of lowest midday demand in the year - trying to see if nondom might be more concentrated in the middle of the day and therefore be better at balancing PV (turns out nindom slightly worse than dom on these days)
# Each normalised relative to average load

midday_Elexon_profiles_df <- Elexon_profiles_df[ which(Elexon_profiles_df$Time=='12:00'),]

PC_stats_midday<-sapply(Profile_names, function(pc){
	Mean_midday_load_norm<-mean(midday_Elexon_profiles_df[[pc]])*24*365
	Min_midday_load_norm<-min(midday_Elexon_profiles_df[[pc]])*24*365

	Fifth_Percentile_midday_load_norm<-quantile(midday_Elexon_profiles_df[[pc]], 0.05)[[1]]*24*365
	Min_Over_Mean_midday<-Min_midday_load_norm/Mean_midday_load_norm
	Fifth_Percentile_Over_Mean_midday<-Fifth_Percentile_midday_load_norm/Mean_midday_load_norm
	return(c(pc,Mean_midday_load_norm,Min_midday_load_norm,Fifth_Percentile_midday_load_norm,Min_Over_Mean_midday,Fifth_Percentile_Over_Mean_midday))
})

# Combine into one df
PC_stats_midday_df<-transpose(as.data.frame(PC_stats))
names(PC_stats_hour_df)<-c('pc','Mean_midday_load_norm','Min_midday_load_norm','Fifth_Percentile_midday_load_norm','Min_Over_Mean_midday','Fifth_Percentile_Over_Mean_midday')


# Similar to the above for each hour of the day -> similar story for 10am - 2pm at least
Stats_by_hour<-lapply(unique(Elexon_profiles_df$Time), function(hour_of_interest){
	hour_Elexon_profiles_df<-Elexon_profiles_df[ which(Elexon_profiles_df$Time==hour_of_interest), ]

	PC_stats_hour_df<-sapply(Profile_names, function(pc){
		Mean_hour_load_norm<-mean(hour_Elexon_profiles_df[[pc]])*24*365
		Min_hour_load_norm<-min(hour_Elexon_profiles_df[[pc]])*24*365
		Fifth_Percentile_hour_load_norm<-quantile(hour_Elexon_profiles_df[[pc]], 0.05)[[1]]*24*365

		Min_Over_Mean_hour<-Min_hour_load_norm/Mean_hour_load_norm
		Fifth_Percentile_Over_Mean_hour<-Fifth_Percentile_hour_load_norm/Mean_hour_load_norm
		return(c(pc,Mean_hour_load_norm,Min_hour_load_norm,Fifth_Percentile_hour_load_norm,Min_Over_Mean_hour,Fifth_Percentile_Over_Mean_hour))
	})

	PC_stats_hour_df<-transpose(as.data.frame(PC_stats_hour_df))
	names(PC_stats_hour_df)<-c('pc','Mean_hour_load_norm','Min_hour_load_norm','Fifth_Percentile_hour_load_norm','Min_Over_Mean_hour','Fifth_Percentile_Over_Mean_hour')
	return(PC_stats_hour_df)
})

names(Stats_by_hour)<-unique(Elexon_profiles_df$Time)

# Look at days when midday load is lowest (to check if these are summer days of high PV output)
lowest_midday_Elexon_profiles_nondom_df <- midday_Elexon_profiles_df[ which(midday_Elexon_profiles_df[["Non-Domestic Unrestricted Customers"]]<= 0.75/24/365),]

# Elexon Profile class descriptions:
# Profile Class 1 – Domestic Unrestricted Customers
# Profile Class 2 – Domestic Economy 7 Customers
# Profile Class 3 – Non-Domestic Unrestricted Customers
# Profile Class 4 – Non-Domestic Economy 7 Customers
# Profile Class 5 – Non-Domestic Maximum Demand (MD) Customers with a Peak Load Factor (LF) of less than 20%
# Profile Class 6 – Non-Domestic Maximum Demand Customers with a Peak Load Factor between 20% and 30%
# Profile Class 7 – Non-Domestic Maximum Demand Customers with a Peak Load Factor between 30% and 40%
# Profile Class 8 – Non-Domestic Maximum Demand Customers with a Peak Load Factor over 40%