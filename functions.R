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


max_estimation <- function(df, temporal_window, columns_of_interest){
  #Function that calculates the maximum value of the given temporal_window
  #a new column is create for each colum un columns of interest, the new columns have
  #the samen name + _estimation
  
  df_w <- data %>%
    arrange(timestamp) %>%
    mutate(across(all_of(columns_of_interest), 
                  .fns = list(estimation = ~ map_dbl(timestamp, 
                                                         ~ {
                                                           # Filtra los valores dentro de la ventana de tiempo
                                                           relevant_values <- data[[cur_column()]][
                                                             timestamp >= (.x - minutes(floor(temporal_window / 2))) & 
                                                               timestamp < (.x + minutes(floor(temporal_window / 2)))
                                                           ]
                                                           
                                                           # Asegúrate de que solo consideramos valores numéricos y no NA
                                                           relevant_values <- relevant_values[!is.na(relevant_values)]
                                                           
                                                           # Calcula el máximo si hay valores válidos
                                                           if (length(relevant_values) == 0) {
                                                             return(NA_real_)  # Devuelve NA si no hay valores válidos
                                                           } else {
                                                             return(max(relevant_values, na.rm = TRUE))
                                                           }
                                                         }))))
  
  return (df_w)
  
}


rounded_mean_estimation <- function(df, temporal_window, columns_of_interest){
  #Function that calculates the rounded mean value of the given temporal_window
  #a new column is create for each colum un columns of interest, the new columns have
  #the samen name + _estimation
  
  df_w <- data %>%
    arrange(timestamp) %>%
    mutate(across(all_of(columns_of_interest), 
                  .fns = list(estimation = ~ map_dbl(timestamp, 
                                                     ~ {
                                                       # Filtra los valores dentro de la ventana de tiempo
                                                       relevant_values <- data[[cur_column()]][
                                                         timestamp >= (.x - minutes(floor(temporal_window / 2))) & 
                                                           timestamp < (.x + minutes(floor(temporal_window / 2)))
                                                       ]
                                                       
                                                       # Asegúrate de que solo consideramos valores numéricos y no NA
                                                       relevant_values <- relevant_values[!is.na(relevant_values)]
                                                       
                                                       # Calcula el máximo si hay valores válidos
                                                       if (length(relevant_values) == 0) {
                                                         return(NA_real_)  # Devuelve NA si no hay valores válidos
                                                       } else {
                                                         return(round(mean(relevant_values, na.rm = TRUE)))
                                                       }
                                                     }))))
  
  return (df_w)
  
}


mean_estimation <- function(df, temporal_window, columns_of_interest){
  #Function that calculates the mean value of the given temporal_window
  #a new column is create for each colum un columns of interest, the new columns have
  #the samen name + _estimation
  
  df_w <- data %>%
    arrange(timestamp) %>%
    mutate(across(all_of(columns_of_interest), 
                  .fns = list(estimation = ~ map_dbl(timestamp, 
                                              ~ {
                                                # Filtra los valores dentro de la ventana de tiempo
                                                relevant_values <- data[[cur_column()]][
                                                  timestamp >= (.x - minutes(floor(temporal_window / 2))) & 
                                                    timestamp < (.x + minutes(floor(temporal_window / 2)))
                                                ]
                                                
                                                # Asegúrate de que solo consideramos valores numéricos y no NA
                                                relevant_values <- relevant_values[!is.na(relevant_values)]
                                                
                                                # Calcula el máximo si hay valores válidos
                                                if (length(relevant_values) == 0) {
                                                  return(NA_real_)  # Devuelve NA si no hay valores válidos
                                                } else {
                                                  return(mean(relevant_values, na.rm = TRUE))
                                                }
                                              }))))
  
  return (df_w)
  
}


weighted_mean_estimation <- function(df, temporal_window, columns_of_interest, weights_list, unique_values_list) {
  # Function that calculates the weighted mean value of the given temporal_window
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
                                                       # Filtra los valores dentro de la ventana de tiempo
                                                       relevant_values <- df[[cur_column()]][
                                                         timestamp >= (.x - minutes(floor(temporal_window / 2))) & 
                                                           timestamp < (.x + minutes(floor(temporal_window / 2)))
                                                       ]
                                                       
                                                       # Obtener el índice de la columna actual
                                                       col_index <- which(columns_of_interest == cur_column())
                                                       unique_values <- unique_values_list[[col_index]]
                                                       weights <- weights_list[[col_index]]
                                                       
                                                       # Asignar pesos a los valores relevantes
                                                       w <- weights[match(relevant_values, unique_values)]
                                                       w[is.na(w)] <- 0
                                                       
                                                       # Calcular la media ponderada
                                                       if (length(relevant_values) > 0 && all(!is.na(w))) {
                                                         return(weighted.mean(relevant_values, w, na.rm = TRUE))  
                                                       } else {
                                                         return(NA)
                                                       }
                                                     }))))
  return (df_w)
  
}
