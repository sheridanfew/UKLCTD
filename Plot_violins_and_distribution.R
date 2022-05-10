# Libraries
library(ggplot2)
library(dplyr)

### PATH DEFINITION

root_path <- '/Users/Shez/Google Drive/Grantham/JUICE/UKLCTD/'
input_path <- paste(root_path,'Input_data/',sep='')
intermediate_path <- paste(root_path,'Intermediate_data/',sep='') # This is where UKLCTD is kept
output_path <- paste(root_path,'Output_data/',sep='') # NB. These are the same here - output here is intermediate
plot_path <- paste(root_path,'Plots/',sep='') # NB. These are the same here - output here is intermediate


### INPUT DATA

# UKLCTD containing recent LSOA-level data on spatial area, population, rurality, meter data, PV deployment, and substation density. Generated from raw data sources using 'Generate_UKLCTD.R', and substation data added using 'Add_substations_to_UKLCTD.R'
UKLCTD_input <- 'UKLCTD_w_substations_Oct2020.csv'

### PRE_DEFINED VARIABLES - COLOUR

myColors<-c('#696766',
'#B9B7B9',
'#994808',
'#C9D46F',
'white')

names(myColors) <-c('Urban',
'Cities',
'Towns',
'Villages',
NA)

### DO STUFF


### 1. IMPORT UKLCTD
#############################################################################################################

# Import data
UKLCTD_df<-read.csv(paste(intermediate_path,UKLCTD_input, sep=''), header=TRUE)

UKLCTD_df<-UKLCTD_df[!is.na(UKLCTD_df$Rurality_code),]

UKLCTD_df_2020<-read.csv(paste(output_path,'dFES/UKLCTD_Scenarios_DFES_base_2020.csv',sep=''))
UKLCTD_df_2030<-read.csv(paste(output_path,'dFES/UKLCTD_Scenarios_DFES_base_2030.csv',sep=''))
UKLCTD_df_2040<-read.csv(paste(output_path,'dFES/UKLCTD_Scenarios_DFES_base_2040.csv',sep=''))
UKLCTD_df_2050<-read.csv(paste(output_path,'dFES/UKLCTD_Scenarios_DFES_base_2050.csv',sep=''))

UKLCTD_df_2020$Year<-2020
UKLCTD_df_2030$Year<-2030
UKLCTD_df_2040$Year<-2040
UKLCTD_df_2050$Year<-2050

# Combine years into one df

UKLCTD_by_year_df<-rbind(UKLCTD_df_2030,UKLCTD_df_2040,UKLCTD_df_2050)
UKLCTD_by_year_df<-UKLCTD_by_year_df[!is.na(UKLCTD_by_year_df$Rurality_code),]

# Make aggregated rurality category, make factor so that these stay in the right order

UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality_code, pattern = "A1", replacement = "Urban")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "B1", replacement = "Urban")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C1", replacement = "Cities")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C2", replacement = "Cities")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D1", replacement = "Towns")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D2", replacement = "Towns")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E1", replacement = "Villages")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E2", replacement = "Villages")

UKLCTD_df$Rurality <- factor(UKLCTD_df$Rurality, levels = c("Urban","Cities","Towns","Villages"))


UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality_code, pattern = "A1", replacement = "Urban")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "B1", replacement = "Urban")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "C1", replacement = "Cities")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "C2", replacement = "Cities")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "D1", replacement = "Towns")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "D2", replacement = "Towns")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "E1", replacement = "Villages")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "E2", replacement = "Villages")


# Combine year and ruirality nto one variable

UKLCTD_by_year_df$Year_Rurality<-as.character(paste(UKLCTD_by_year_df$Year,UKLCTD_by_year_df$Rurality,sep=',   '))

# Mess to ensure years are separated in plot (this will generate extra columns to be removed from the png later - bit clunky, but subcategories in ggplot are quite fiddly to implement)
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2030,               '
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2040,               '
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2050,               '

# Make factor of specific order for plotting purposes
UKLCTD_by_year_df$Year_Rurality <- factor(UKLCTD_by_year_df$Year_Rurality, levels = c("2030,   Urban","2030,   Cities","2030,   Towns","2030,   Villages",
                                                                               "2040,               ",
                                                                               "2040,   Urban","2040,   Cities","2040,   Towns","2040,   Villages",
                                                                               "2050,               ",
                                                                               "2050,   Urban","2050,   Cities","2050,   Towns","2050,   Villages"
                                                                               ))

### 2. MAKE VIOLIN PLOTS
#############################################################################################################

# Current PV deployment violin

p<-ggplot(UKLCTD_df, aes(x=Rurality, y=PV_domestic_sum_kW, fill=Rurality)) +
    ylim(0,500) +
    geom_violin(width=1.4) +
    geom_boxplot(width=0.1, color="black", alpha=0.2) +
    scale_fill_manual(name = "Rurality",values = myColors) +
    coord_cartesian(expand=FALSE) +
    theme_bw() +
    theme(axis.text.x = element_text(angle=90, hjust=1)) +
    theme(text = element_text(size=20),panel.grid = element_blank(), panel.border = element_blank(), axis.line = element_line()) +
    # theme_ipsum() +
    theme(
      legend.position="none",
      plot.title = element_text(size=11)
    ) +
    xlab("") +
    ylab("Domestic PV (kW/LSOA)")

    ggsave(paste(plot_path,'Violins/Dom_PV_By_Rurality_Violin.png',sep=''),plot=p,width=8,height=6)


# Future PV deployment violin

# Plot
p<-ggplot(UKLCTD_by_year_df, aes(x=Year_Rurality, y=PV_domestic_sum_kW, fill=Rurality)) +
    ylim(0,2000) +
    geom_violin(width=1.4) +
    geom_boxplot(width=0.1, color="black", alpha=0.2) +
    scale_fill_manual(name = "Rurality",values = myColors) +
    coord_cartesian(expand=FALSE) +
    theme_bw() +
    theme(axis.text.x = element_text(angle=90, hjust=1)) +
    theme(text = element_text(size=15),panel.grid = element_blank(), panel.border = element_blank(), axis.line = element_line()) +
    # theme_ipsum() +
    theme(
      legend.position="none",
      plot.title = element_text(size=11)
    ) +
    xlab("") +
    ylab("Domestic PV (kW/LSOA)")

    ggsave(paste(plot_path,'Violins/Dom_PV_By_Rurality_by_Year_Violin.png',sep=''),plot=p,width=8,height=4)




### 3. MAKE FILLED DISTRIBUTION LINE PLOTS
#############################################################################################################

# Plot to indicate dominant rurality at each stage of savings for flexibility per LSOA graph

# Example here for solar deployment - figures for savings made separately by Predrag based on code adapted slightly from this

# This code inspired by https://stackoverflow.com/questions/63289154/colour-segments-of-density-plot-by-bin

  # Function to define most common rurality per band
  most_common <- function(x) {
    uniqx <- unique(na.omit(x))
    uniqx[which.max(tabulate(match(x, uniqx)))]
  }


  # Make plot with 3 different bin sizes
lapply(c(100,50,25),function(bin_size){
  dens<-subset(UKLCTD_df, select=c("Rurality", "PV_domestic_sum_kW"))
  names(dens)[names(dens) == 'PV_domestic_sum_kW'] <- 'y'
  dens<-dens[order(-dens$y),]
  dens$x<-c(1:nrow(dens))
 
  # Split into bands of (binsize) LSOAs
  dens$band <- dens$x %/% bin_size

  # This us the complex bit. For each band we want to add a point on
  # the x axis at the upper and lower ltime imits:
  dens <- do.call("rbind", lapply(split(dens, dens$band), function(df) {
    df <- rbind(df[1,], df, df[nrow(df),])
    df$y[c(1, nrow(df))] <- 0
    df
  }))

  aggdata <-aggregate(dens, by=list(dens$band),
    FUN=most_common)

  colors<-myColors[aggdata$Rurality]
  names(colors)<-c(1:length(colors))

  # Plot

  p<-ggplot(dens, aes(x, y)) + 
    ylim(0,500) +
    geom_polygon(aes(fill = factor(band), color = factor(band))) +
    theme_minimal() +
    theme(
        legend.position="none",
        plot.title = element_text(size=11)
      ) +
    scale_fill_manual(values = c(colors), name = "Rurality") +
    scale_colour_manual(values = c(colors), name = "Rurality") +
    xlab("LSOA") +
    ylab("Domestic PV (kW/LSOA)") 


    ggsave(paste(plot_path,'Distributions/Dom_PV_By_Rurality_Distn_',bin_size,'.png',sep=''),plot=p,width=8,height=4)
})


### 4. EXPORT EXAMPLE DATA FOR PREDRAG
######################################

# In order to do similar for cost and savings

PD_UKLCTD_df<-subset(UKLCTD_df, select=c("LSOA","Rurality","PV_domestic_sum_kW","PV_nondom_sum_kW"))
names(PD_UKLCTD_df)[names(PD_UKLCTD_df) == 'PV_domestic_sum_kW'] <- 'LV_flexibility_savings'
names(PD_UKLCTD_df)[names(PD_UKLCTD_df) == 'PV_nondom_sum_kW'] <- 'Total_flexibility_savings'
write.table(PD_UKLCTD_df, paste(output_path,'Predrag_example_data/PD_UKLCTD_df.csv',sep=''), sep=",", row.names=FALSE)


PD_UKLCTD_by_year_df<-subset(UKLCTD_by_year_df, select=c("LSOA","Rurality","Year","PV_domestic_sum_kW","PV_nondom_sum_kW"))
names(PD_UKLCTD_by_year_df)[names(PD_UKLCTD_by_year_df) == 'PV_domestic_sum_kW'] <- 'LV_upgrade_cost'
names(PD_UKLCTD_by_year_df)[names(PD_UKLCTD_by_year_df) == 'PV_nondom_sum_kW'] <- 'Total_upgrade_cost'
write.table(PD_UKLCTD_by_year_df, paste(output_path,'Predrag_example_data/PD_UKLCTD_by_year_df.csv',sep=''), sep=",", row.names=FALSE)


### ALTERNATIVE VERSIONS OF STAGES 2 & 3
######################################


# ALTERNATIVE VERSION OF STEP 2 & 3 INCLUDING 2020 BUT EXCLUDING 2040


UKLCTD_by_year_df<-rbind(UKLCTD_df_2020,UKLCTD_df_2030,UKLCTD_df_2050)
UKLCTD_by_year_df<-UKLCTD_by_year_df[!is.na(UKLCTD_by_year_df$Rurality_code),]

# Make aggregated rurality category, make factor so that these stay in the right order

UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality_code, pattern = "A1", replacement = "Urban")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "B1", replacement = "Urban")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C1", replacement = "Cities")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C2", replacement = "Cities")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D1", replacement = "Towns")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D2", replacement = "Towns")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E1", replacement = "Villages")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E2", replacement = "Villages")

UKLCTD_df$Rurality <- factor(UKLCTD_df$Rurality, levels = c("Urban","Cities","Towns","Villages"))


UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality_code, pattern = "A1", replacement = "Urban")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "B1", replacement = "Urban")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "C1", replacement = "Cities")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "C2", replacement = "Cities")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "D1", replacement = "Towns")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "D2", replacement = "Towns")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "E1", replacement = "Villages")
UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "E2", replacement = "Villages")


# Combine year and ruirality into one variable

UKLCTD_by_year_df$Year_Rurality<-as.character(paste(UKLCTD_by_year_df$Year,UKLCTD_by_year_df$Rurality,sep=',   '))

# Mess to ensure years are separated in plot (this will generate extra columns to be removed from the png later - bit clunky, but subcategories in ggplot are quite fiddly to implement)
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2030,               '
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2050,               '

# Make factor of specific order for plotting purposes
UKLCTD_by_year_df$Year_Rurality <- factor(UKLCTD_by_year_df$Year_Rurality, levels = c("2020,   Urban","2020,   Cities","2020,   Towns","2020,   Villages",
                                                                               "2030,               ",
                                                                               "2030,   Urban","2030,   Cities","2030,   Towns","2030,   Villages",
                                                                               "2050,               ",
                                                                               "2050,   Urban","2050,   Cities","2050,   Towns","2050,   Villages"
                                                                               ))



# Future PV deployment violin

# Plot
p<-ggplot(UKLCTD_by_year_df, aes(x=Year_Rurality, y=PV_domestic_sum_kW, fill=Rurality)) +
    ylim(0,2000) +
    geom_violin(width=1.4) +
    geom_boxplot(width=0.1, color="black", alpha=0.2) +
    scale_fill_manual(name = "Rurality",values = myColors) +
    coord_cartesian(expand=FALSE) +
    theme_bw() +
    theme(axis.text.x = element_text(angle=90, hjust=1)) +
    theme(text = element_text(size=15),panel.grid = element_blank(), panel.border = element_blank(), axis.line = element_line()) +
    # theme_ipsum() +
    theme(
      legend.position="none",
      plot.title = element_text(size=11)
    ) +
    xlab("") +
    ylab("Domestic PV (kW/LSOA)")

    ggsave(paste(plot_path,'Violins/Dom_PV_By_Rurality_by_Year_w_2020_Violin.png',sep=''),plot=p,width=8,height=4)


# ALTERNATIVE VERSION OF STEP 2 INCLUDING 2020 (excluded because it makes the plot busy)


# UKLCTD_by_year_df<-rbind(UKLCTD_df_2020,UKLCTD_df_2030,UKLCTD_df_2040,UKLCTD_df_2050)
# UKLCTD_by_year_df<-UKLCTD_by_year_df[!is.na(UKLCTD_by_year_df$Rurality_code),]

# # Make aggregated rurality category, make factor so that these stay in the right order

# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality_code, pattern = "A1", replacement = "Urban")
# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "B1", replacement = "Urban")
# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C1", replacement = "Cities")
# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C2", replacement = "Cities")
# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D1", replacement = "Towns")
# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D2", replacement = "Towns")
# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E1", replacement = "Villages")
# UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E2", replacement = "Villages")

# UKLCTD_df$Rurality <- factor(UKLCTD_df$Rurality, levels = c("Urban","Cities","Towns","Villages"))


# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality_code, pattern = "A1", replacement = "Urban")
# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "B1", replacement = "Urban")
# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "C1", replacement = "Cities")
# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "C2", replacement = "Cities")
# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "D1", replacement = "Towns")
# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "D2", replacement = "Towns")
# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "E1", replacement = "Villages")
# UKLCTD_by_year_df$Rurality<-gsub(UKLCTD_by_year_df$Rurality, pattern = "E2", replacement = "Villages")


# # Combine year and ruirality nto one variable

# UKLCTD_by_year_df$Year_Rurality<-as.character(paste(UKLCTD_by_year_df$Year,UKLCTD_by_year_df$Rurality,sep=',   '))

# # Mess to ensure years are separated in plot
# UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
# UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2030,               '
# UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
# UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2040,               '
# UKLCTD_by_year_df[nrow(UKLCTD_by_year_df)+1,] <- 0
# UKLCTD_by_year_df[nrow(UKLCTD_by_year_df),]$Year_Rurality <- '2050,               '

# # Make factor of specific order for plotting purposes
# UKLCTD_by_year_df$Year_Rurality <- factor(UKLCTD_by_year_df$Year_Rurality, levels = c("2020,   Urban","2020,   Cities","2020,   Towns","2020,   Villages",
#                                                                                "2030,               ",
#                                                                                "2030,   Urban","2030,   Cities","2030,   Towns","2030,   Villages",
#                                                                                "2040,               ",
#                                                                                "2040,   Urban","2040,   Cities","2040,   Towns","2040,   Villages",
#                                                                                "2050,               ",
#                                                                                "2050,   Urban","2050,   Cities","2050,   Towns","2050,   Villages"
#                                                                                ))
