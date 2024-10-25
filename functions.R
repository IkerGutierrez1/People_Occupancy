load_data <- function(path){
  #Function for loading data from specified path 
  
  data <- read.csv(path,sep = ";")
  
  #Filter out rows with NA values in timestamp (this NA values only appear at the end after reading)
  data <- data %>%
    filter(!is.na(timestamp))
  
  #Add 00:00:00 to the timestamps which don´t have hour minute (it only happens miodnight)
  data$timestamp <- ifelse(grepl(" ", data$timestamp), data$timestamp, paste(data$timestamp, "00:00:00"))
  
  
  data <- data %>%
    mutate(timestamp = ymd_hms(timestamp, tz = "Europe/Madrid"))
  
  data <- data %>%
    mutate(across(-c(timestamp), as.character))
  
  # Replace "#N/A" with NA
  data <- data %>%
    mutate(across(-c(timestamp), ~ na_if(., "#N/A")))
  
  data <- data %>%
    mutate(across(-c(timestamp), ~ as.numeric(.)))
  
  
  return (data)
  
}


max_estimation <- function(df, aggregation_period, columns_of_interest){
  #Function that calculates the maximum value of the given aggregation_period
  #a new column is create for each colum un columns of interest, the new columns have
  #the samen name + _estimation
  
  df_w <- df %>%
    arrange(timestamp) %>%
    mutate(across(all_of(columns_of_interest), 
                  .fns = list(estimation = ~ map_dbl(timestamp, 
                                                         ~ {
                                                           
                                                           relevant_values <- df[[cur_column()]][
                                                             timestamp >= (.x - minutes(floor(aggregation_period / 2))) & 
                                                               timestamp < (.x + minutes(floor(aggregation_period / 2)))
                                                           ]
                                                           
                                                           
                                                           relevant_values <- relevant_values[!is.na(relevant_values)]
                                                           
                                                      
                                                           if (length(relevant_values) == 0) {
                                                             return(NA_real_)  
                                                           } else {
                                                             return(max(relevant_values, na.rm = TRUE))
                                                           }
                                                         }))))
  
  return (df_w)
  
}


rounded_mean_estimation <- function(df, aggregation_period, columns_of_interest){
  #Function that calculates the rounded mean value of the given aggregation_period
  #a new column is create for each colum un columns of interest, the new columns have
  #the samen name + _estimation
  
  df_w <- df %>%
    arrange(timestamp) %>%
    mutate(across(all_of(columns_of_interest), 
                  .fns = list(estimation = ~ map_dbl(timestamp, 
                                                     ~ {
                                                       
                                                       relevant_values <- df[[cur_column()]][
                                                         timestamp >= (.x - minutes(floor(aggregation_period / 2))) & 
                                                           timestamp < (.x + minutes(floor(aggregation_period / 2)))
                                                       ]
                                                       
                                                      
                                                       relevant_values <- relevant_values[!is.na(relevant_values)]
                                                       
                                                      
                                                       if (length(relevant_values) == 0) {
                                                         return(NA_real_)  
                                                       } else {
                                                         return(round(mean(relevant_values, na.rm = TRUE)))
                                                       }
                                                     }))))
  
  return (df_w)
  
}


mean_estimation <- function(df, aggregation_period, columns_of_interest){
  #Function that calculates the mean value of the given aggregation_period
  #a new column is create for each colum un columns of interest, the new columns have
  #the samen name + _estimation
  
  df_w <- df %>%
    arrange(timestamp) %>%
    mutate(across(all_of(columns_of_interest), 
                  .fns = list(estimation = ~ map_dbl(timestamp, 
                                              ~ {
                                                
                                                relevant_values <- df[[cur_column()]][
                                                  timestamp >= (.x - minutes(floor(aggregation_period / 2))) & 
                                                    timestamp < (.x + minutes(floor(aggregation_period / 2)))
                                                ]
                                                
                                                
                                                relevant_values <- relevant_values[!is.na(relevant_values)]
                                                
                                               
                                                if (length(relevant_values) == 0) {
                                                  return(NA_real_)  
                                                } else {
                                                  return(mean(relevant_values, na.rm = TRUE))
                                                }
                                              }))))
  
  return (df_w)
  
}


weighted_mean_estimation <- function(df, aggregation_period, columns_of_interest, weights_list, unique_values_list) {
  # Function that calculates the weighted mean value of the given aggregation_period
  # A new column is created for each column in columns_of_interest, 
  # the new columns have the same name + "_estimation"
  #The wights and unique values list need to be in the same order as columns of intrest, 
  #if column of interest has RoomA ocupaction as first element, its wights and unique values have to be the first element
  #of their respectives lists
  
  df_w <- df %>%
    arrange(timestamp) %>%
    mutate(across(all_of(columns_of_interest), 
                  .fns = list(estimation = ~ map_dbl(timestamp, 
                                                     ~ {
                                                       
                                                       relevant_values <- df[[cur_column()]][
                                                         timestamp >= (.x - minutes(floor(aggregation_period / 2))) & 
                                                           timestamp < (.x + minutes(floor(aggregation_period / 2)))
                                                       ]
                                                       
                                                       
                                                       col_index <- which(columns_of_interest == cur_column())
                                                       unique_values <- unique_values_list[[col_index]]
                                                       weights <- weights_list[[col_index]]
                                                       
                                                       
                                                       w <- weights[match(relevant_values, unique_values)]
                                                       w[is.na(w)] <- 0
                                                       
                                                       
                                                       if (length(relevant_values) > 0 && all(!is.na(w))) {
                                                         return(weighted.mean(relevant_values, w, na.rm = TRUE))  
                                                       } else {
                                                         return(NA)
                                                       }
                                                     }))))
  return (df_w)
  
}


plot_estimation <- function(df, original_column = "RoomA.People__amount", save_dir = "output/graphs",
                            filename, start_time = NULL, end_time = NULL){
  #Function for ploting the estimation and original observations vs time, original column is the original observations
  #start and end times are optional and the function will take all the range in dateframe if not specified
  estimation_column = paste0(original_column,"_estimation")
  filepath = paste0(save_dir,"/",filename,".png")
  print(filepath)
  
  if (is.null(start_time)) {
    start_time <- as.POSIXct(min(df$timestamp, na.rm = TRUE))
  }
  if (is.null(end_time)) {
    end_time <- as.POSIXct(max(df$timestamp, na.rm = TRUE))
  }
  
  df <- df %>%
    filter(timestamp >= as.POSIXct(start_time) & 
             timestamp <= as.POSIXct(end_time))
  
  p <- ggplot(df, aes(x = timestamp)) +
    geom_point(aes(y = !!sym(original_column)), color = "blue", size = 2, alpha = 0.5, shape = 16) +  
    geom_line(aes(y = !!sym(estimation_column)), color = "green", linewidth = 1) +  
    
    labs(title = "Original data vs estimation",
         x = "Date",
         y = "Occupation") +
    theme_minimal(base_size = 15) +  
    theme(panel.background = element_rect(fill = "white"),  
          plot.background = element_rect(fill = "white"),   
          panel.grid.major = element_line(color = "grey90"), 
          panel.grid.minor = element_line(color = "grey95"),
          legend.position = "none")+  
    scale_y_continuous(limits = c(0, 8))  
  
  ggsave(filepath, plot = p, width = 10, height = 6, dpi = 300)
}

save_df <- function(df, save_dir = "output/", df_name){
  #Function to save the dataframe, it replaces the data in the columns that have been estimated
  #with the estiamtion data, deleting the _estimation cols and replacing original data with estimte
  file_path = paste0(save_dir,df_name,".csv")
  
  #All cols with _estimation
  cols_estimation <- names(df_max)[grep("_estimation", names(df_max))]
  
  #Cols with original data to be replaced by cols_esimation
  cols_delete <- gsub("_estimation$", "", cols_estimation)
  
  print("Replacing data in:")
  print(cols_delete)
  print("with:")
  print(cols_estimation)
  
  # Replaced data that has been estimated
  df <- df %>%
    select(-all_of(cols_delete)) %>% 
    rename_with(~ gsub("_estimation$", "", .), cols_estimation) 
  write.csv(df, file_path, row.names = FALSE)
}
