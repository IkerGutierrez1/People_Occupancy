#Usage example of code



#Load functions
source("functions.R")

path <- "data/data.csv"
df_data <- load_data(path = path)


#Parameters for all estimations
aggregation_period <- 60
columns_of_interest <- c("RoomA.People__amount") 

#Parameters for weighted mean estimation
unique_values_RoomA <- 0:8 
w_A <- c(0.04,0.15,0.15,0.15,0.15,0.09,0.09,0.09,0.09)

unique_values_RoomA_active <- 0:1 
w_A_active <- c(0.5,0.5)

unique_value_list <- list(unique_values_RoomA)
w_list <- list(w_A)

#Use of estimators
df_max <- max_estimation(df_data, aggregation_period, columns_of_interest)
df_rounded_mean <- rounded_mean_estimation(df_data, aggregation_period, columns_of_interest)
df_mean <- mean_estimation(df_data, aggregation_period, columns_of_interest)
df_weighted_mean <- weighted_mean_estimation(df_data, aggregation_period, columns_of_interest,
                                             w_list,unique_value_list)
df_spline <- spline_mean_estimation(df_data,aggregation_period,columns_of_interest)


# Name of colum with data you want to plot
original_column <- "RoomA.People__amount"

start_time <- as.POSIXct("2023-11-06 05:00")
end_time <- as.POSIXct("2023-11-06 23:00")


plot_estimation(df_spline, original_column = original_column, filename = "Example_Plot",
                start_time = start_time, end_time = end_time)

#Save the dataframe replacing the data
save_df(df_max,df_name = "Example_DF")


start_date <- start_time
end_date <- end_time

#All methods graph
df_max_filt<- df_max %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_rounded_mean_filt <- df_rounded_mean %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_mean_filt <- df_mean %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_weighted_mean_filt <- df_weighted_mean %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_spline_filt <- df_spline %>%
  filter(timestamp >= start_date & timestamp <= end_date)




p <- ggplot() +
  geom_line(data = df_max_filt, aes(x = timestamp, y = RoomA.People__amount_estimation, color = "Max Estimation")) + 
  geom_line(data = df_rounded_mean_filt, aes(x = timestamp, y = RoomA.People__amount_estimation, color = "Rounded Mean Estimation")) +
  geom_line(data = df_mean_filt, aes(x = timestamp, y = RoomA.People__amount_estimation, color = "Mean Estimation")) + 
  geom_line(data = df_weighted_mean_filt, aes(x = timestamp, y = RoomA.People__amount_estimation, color = "Weighted Mean Estimation")) + 
  geom_line(data = df_spline_filt, aes(x = timestamp, y = RoomA.People__amount_estimation, color = "Spline Estimation")) + 
  geom_point(data = df_spline_filt, aes(x = timestamp, y = RoomA.People__amount, color = "Actual People Amount")) +
  scale_color_manual(
    values = c(
      "Max Estimation" = "green",
      "Rounded Mean Estimation" = "red",
      "Mean Estimation" = "orange",
      "Weighted Mean Estimation" = "pink",
      "Spline Estimation" = "purple",
      "Actual People Amount" = "blue"
    )
  ) +
  labs(
    title = "Comparación de Estimaciones de RoomA.People__amount",
    x = "Timestamp",
    y = "RoomA.People__amount",
    color = "Método de Estimación"
  ) +
  theme_minimal()