#Usage example of code

library(dplyr)
library(lubridate)
library(purrr)
library(ggplot2)

#Load functions
source("functions.R")

path <- "data/data.csv"
df_data <- load_data(path = path)


#Parameters for all estimations
temporal_window <- 60
columns_of_interest <- c("RoomA.People__amount") 

#Parameters for weighted mean estimation
valores_unicos_RoomA <- 0:8 
w_A <- c(0.04,0.15,0.15,0.15,0.15,0.09,0.09,0.09,0.09)

valores_unicos_RoomA_active <- 0:1 
w_A_active <- c(0.5,0.5)

unique_value_list <- list(valores_unicos_RoomA,valores_unicos_RoomA_active)
w_list <- list(w_A,w_A_active)

#Use of estimators
df_max <- max_estimation(df_data, temporal_window, columns_of_interest)
df_rounded_mean <- rounded_mean_estimation(df_data, temporal_window, columns_of_interest)
df_mean <- mean_estimation(df_data, temporal_window, columns_of_interest)
df_weighted_mean <- weighted_mean_estimation(df_data, temporal_window, columns_of_interest,
                                             w_list,unique_value_list)



# Name of colum with data you want to plot
original_column <- "RoomA.People__amount"

start_time <- as.POSIXct("2023-11-06 05:00")
end_time <- as.POSIXct("2023-11-06 23:00")


plot_estimation(df_max, original_column = original_column, filename = "Example_Plot",
                start_time = start_time, end_time = end_time)

#Save the dataframe replacing the data
save_df(df_max,df_name = "Example_DF")









