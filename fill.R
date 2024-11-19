#Load functions
source("functions.R")
path <- "data/Mean_estimate.csv"
data <- read.csv(path)

#Add 00:00:00 to the timestamps which don´t have hour minute (it only happens miodnight)
data$timestamp <- ifelse(grepl(" ", data$timestamp), data$timestamp, paste(data$timestamp, "00:00:00"))

data <- data %>%
  mutate(timestamp = ymd_hms(timestamp, tz = "Europe/Madrid"))

#Add column with week_minute
data <- data %>%
  mutate(
    week_minute = as.numeric(difftime(timestamp, floor_date(timestamp, "week", week_start = 1), units = "mins"))
  )

#Df with the mean of ecah week_minute
mean_by_minute <- data %>%
  group_by(week_minute) %>%
  summarise(across(ends_with(".People__amount"), 
                   ~ mean(.x, na.rm = TRUE), 
                   .names = "mean_{.col}_estimation")) 

#Add occupation mean, to the data
data <- data %>%
  left_join(mean_by_minute, by = "week_minute")

#Fill the NA from the data columns with the mean estimation
df_fill_week_mean <- data %>%
  mutate(across(ends_with(".People__amount"),
                ~ coalesce(.x, get(paste0("mean_", cur_column(),"_estimation")))))

# Delete columns with _estimation no longer neccesary
df_fill_week_mean <- df_fill_week_mean %>% #Method 1 finished (fill with mean)
  select(-ends_with("_estimation"))

#Method 2 multipy room activity singal and the fill in data 
df_fill_week_mean_multiply_basic <- df_fill_week_mean %>%
  mutate(across(starts_with("Room"), 
                ~ {
                  if (grepl(".People__amount$", cur_column())) {
                    # Get room activity column name
                    active_col_name <- sub("^(.+)\\.People__amount$", "\\1.Room__active", cur_column())
                    active_col <- get(active_col_name)
                    
                    message("Multiplicando: ", cur_column(), " por ", active_col_name)
                    
                    return(.x * active_col)
                  } else {
                    return(.x)  
                  }
                },
                .names = "{.col}_act_estimation"))  


#Method 3, calculate the maximum of activity colum to avoid oscilations
time_aggregation <- 360 #Maximum of 6 hours

df_fill_week_mean_multiply_max <- df_fill_week_mean %>%
  arrange(timestamp) %>%
  mutate(across(matches("^Room.*Room__active$"), 
                ~ {
                  room_active_col <- cur_column()
                  purrr::map_dbl(timestamp, 
                                 ~ {
                                   valores <- get(room_active_col)[timestamp >= (.x - minutes(floor(time_aggregation / 2))) & 
                                                                     timestamp < (.x + minutes(floor(time_aggregation / 2)))]
                                   
                                   #Rerturns max of NA if there are no values
                                   if (length(valores) > 0 && any(!is.na(valores))) {
                                     return(max(valores, na.rm = TRUE))
                                   } else {
                                     return(NA) 
                                   }
                                 })
                },
                .names = "{.col}_max_period"))  

#Multiply the new signal by the week_minute
#Remove original activity colum
columns_to_remove <- colnames(df_fill_week_mean_multiply_max)[grepl(
  "^Room[A-F]\\.Room__active$", colnames(df_fill_week_mean_multiply_max))]             
df_fill_week_mean_multiply_max <- df_fill_week_mean_multiply_max %>%
  select(-all_of(columns_to_remove))
#Replace activity colum with the max in the period 
df_fill_week_mean_multiply_max <- df_fill_week_mean_multiply_max %>%
  rename_with(~ sub("_max_period$", "", .), ends_with("_max_period"))  

#Multiply both signals
df_fill_week_mean_multiply_max <- df_fill_week_mean_multiply_max %>%
  mutate(across(starts_with("Room"), 
                ~ {

                  if (grepl(".People__amount$", cur_column())) {

                    active_col_name <- sub("^(.+)\\.People__amount$", "\\1.Room__active", cur_column())
                    active_col <- get(active_col_name)
                    
                    # Imprimir información de depuración
                    message("Multiplicando: ", cur_column(), " por ", active_col_name)
                    
                    # Realizar la multiplicación
                    return(.x * active_col)
                  } else {
                    return(.x)  
                  }
                },
                .names = "{.col}_act_estimation"))  



#Method 4 Calculate a percentil of the mean
percentil <- 0.2 #Value the mean has to be bigger than 
df_fill_week_mean_multiply_percentil <- df_fill_week_mean %>%
  arrange(timestamp) %>%
  mutate(across(matches("^Room.*Room__active$"), 
                ~ {
                  room_active_col <- cur_column()
                  # Calculate mean in specify time
                  purrr::map_dbl(timestamp, 
                                 ~ {

                                   valores <- get(room_active_col)[timestamp >= (.x - minutes(floor(time_aggregation / 2))) & 
                                                                     timestamp < (.x + minutes(floor(time_aggregation / 2)))]
                                   # Mean cal
                                   if (length(valores) > 0 && any(!is.na(valores))) {
                                     media_valores <- mean(valores, na.rm = TRUE)
                                     # Returns 1 if the mean is bigger than the percentil
                                     return(ifelse(media_valores > percentil, 1, 0))
                                   } else {
                                     return(NA)  
                                   }
                                 })
                },
                .names = "{.col}_percentil"))  

#Multiply the new signal by the week_minute
#Remove original activity colum
columns_to_remove <- colnames(df_fill_week_mean_multiply_percentil)[grepl(
  "^Room[A-F]\\.Room__active$", colnames(df_fill_week_mean_multiply_percentil))]             
df_fill_week_mean_multiply_percentil <- df_fill_week_mean_multiply_percentil %>%
  select(-all_of(columns_to_remove))
#Replace activity colum with the max in the period 
df_fill_week_mean_multiply_percentil <- df_fill_week_mean_multiply_percentil %>%
  rename_with(~ sub("_percentil$", "", .), ends_with("_percentil"))  

#Multiply both signals
df_fill_week_mean_multiply_percentil <- df_fill_week_mean_multiply_percentil %>%
  mutate(across(starts_with("Room"), 
                ~ {
                  if (grepl(".People__amount$", cur_column())) {
                    active_col_name <- sub("^(.+)\\.People__amount$", "\\1.Room__active", cur_column())
                    active_col <- get(active_col_name)
                    
                    
                    message("Multiplicando: ", cur_column(), " por ", active_col_name)
                    

                    return(.x * active_col)
                  } else {
                    return(.x) 
                  }
                },
                .names = "{.col}_act_estimation"))  



#Plot 
start_date <- "2023-04-23"
end_date <- "2023-04-29"

#All methods graph
data_filt<- data %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_fill_week_mean_filt <- df_fill_week_mean %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_fill_week_mean_multiply_basic_filt <- df_fill_week_mean_multiply_basic %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_fill_week_mean_multiply_max_filt <- df_fill_week_mean_multiply_max %>%
  filter(timestamp >= start_date & timestamp <= end_date)
df_fill_week_mean_multiply_percentil_filt <- df_fill_week_mean_multiply_percentil %>%
  filter(timestamp >= start_date & timestamp <= end_date)




p <- ggplot() +
  geom_point(data = data_filt, aes(x = timestamp, y = RoomA.People__amount, color = "Actual Occupation")) + 
  geom_line(data = df_fill_week_mean_filt, aes(x = timestamp, y = RoomA.People__amount, color = "Week minute mean")) +
  geom_line(data = df_fill_week_mean_multiply_basic_filt, aes(x = timestamp, y = RoomA.People__amount_act_estimation, color = "Mean * activity"),
            linewidth = 1) + 
  geom_line(data = df_fill_week_mean_multiply_max_filt, aes(x = timestamp, y = RoomA.People__amount_act_estimation, color = "Mean * max(activity)"),
            linewidth = 1) + 
  geom_line(data = df_fill_week_mean_multiply_percentil_filt, aes(x = timestamp, y = RoomA.People__amount_act_estimation, color = "Mean * per(activity)")) +
  scale_color_manual(
    values = c(
      "Actual Occupation" = "blue",
      "Week minute mean" = "red",
      "Mean * activity" = "pink",
      "Mean * max(activity)" = "purple",
      "Mean * per(activity)" = "green"
    )
  ) +
  labs(
    title = "Comparación de Estimaciones de RoomA.People__amount",
    x = "Timestamp",
    y = "RoomA.People__amount",
    color = "Método de Estimación"
  ) +
  theme_minimal()
p
