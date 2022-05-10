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
'#C9D46F')

names(myColors) <-c('Urban',
'Cities',
'Towns',
'Villages')

### DO STUFF


### 1. IMPORT UKLCTD
#############################################################################################################

# Import data
UKLCTD_df<-read.csv(paste(intermediate_path,UKLCTD_input, sep=''), header=TRUE)

UKLCTD_df<-UKLCTD_df[!is.na(UKLCTD_df$Rurality_code),]

# Make aggregated rurality category
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality_code, pattern = "A1", replacement = "Urban")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "B1", replacement = "Urban")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C1", replacement = "Cities")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "C2", replacement = "Cities")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D1", replacement = "Towns")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "D2", replacement = "Towns")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E1", replacement = "Villages")
UKLCTD_df$Rurality<-gsub(UKLCTD_df$Rurality, pattern = "E2", replacement = "Villages")

UKLCTD_df$Rurality <- factor(UKLCTD_df$Rurality, levels = c("Urban","Cities","Towns","Villages"))


### 2. MAKE PLOTS
#############################################################################################################

# sample size
sample_size = UKLCTD_df %>% group_by(Rurality) %>% summarize(num=n())


# Plot
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



# Plot


# Commented out possible version which includes number of points, but messes up ordering of ruralities
#
# UKLCTD_df %>%
#   left_join(sample_size) %>%
#   mutate(myaxis = paste(Rurality, "\n", "n=", num)) %>%
#   ggplot(aes(x=myaxis, y=PV_domestic_sum_kW, fill=Rurality)) +
#     ylim(0,500) +
#     geom_violin(width=1.4) +
#     geom_boxplot(width=0.1, color="black", alpha=0.2) +
#     scale_fill_manual(name = "Rurality",values = myColors) +
#     coord_cartesian(expand=FALSE) +
#     theme_bw() +
#     theme(axis.text.x = element_text(angle=90, hjust=1)) +
#     theme(text = element_text(size=20),panel.grid = element_blank(), panel.border = element_blank(), axis.line = element_line()) +
#     # theme_ipsum() +
#     theme(
#       legend.position="none",
#       plot.title = element_text(size=11)
#     ) +
#     xlab("")









values_of_interest<-c('LV_cost','Total_cost')


    p<-ggplot(melted_data, aes(fill=Device, y=Load, x=Month)) + 
      geom_bar(position="stack", stat="identity") +   
      coord_cartesian(expand=FALSE) +
      theme_bw() +
      theme(text = element_text(size=20),panel.grid = element_blank(), panel.border = element_blank(), axis.line = element_line()) +
      ggtitle(paste('Tier ',tier,', ',climate,' climate', sep='')) +
      ylab('Mean Load (W)') +
      scale_x_continuous(breaks = seq(1, 12, 1)) +
      scale_fill_manual(name = "Device",values = myColors)

    ggsave(paste(plot_path,'Load_By_Tier/mean_monthly_load_tier_',tier,'_',village,'.png',sep=''),plot=p,width=8,height=4)
