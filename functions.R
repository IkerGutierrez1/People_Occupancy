get_df_dataset <- function(path){
  #Función para obtener un dataframe apartir de un .csv, convierte los valores #N/A en Na para facilitar el 
  #procesado tambien se asegura que timestamp este en POSIXct, tambien añade una columna week_day para mostrar el 
  #día de la semana que es
  
  data <- read.csv(path,sep = ";")
  
  
  df <- data %>%
    mutate(timestamp = ymd_hms(timestamp, tz = "Europe/Madrid"))
  
  #Añade una columna con el dia de la semana Lun = 1, Mar = 2...
  df$week_day <- wday(df$timestamp, week_start = 1)
  
  # Convertir todas las columnas excepto 'timestamp' a caracteres
  df <- df %>%
    mutate(across(-c(timestamp), as.character))
  
  # Reemplazar "#N/A" con NA
  df <- df %>%
    mutate(across(-c(timestamp), ~ na_if(., "#N/A")))
  
  # Convertir las columnas de nuevo a numéricas
  df <- df %>%
    mutate(across(-c(timestamp), ~ as.numeric(.)))
  
  # Filtra las filas donde timestamp no es NA
  df <- df[!is.na(df$X), ]
  
  
  return (df)
  
}