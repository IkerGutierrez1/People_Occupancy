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
columns_of_interest <- c("RoomA.People__amount","RoomA.Room__active") 

#Parameteres for weighted mean estimation
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

plot_estimation(df_max, original_column = original_column, filename = "Test2")







#-----------------------------------------------------------------------------
#Para hacer la grafica con mas de una estimacion

# Renombrar las columnas de df2 para evitar conflictos
df2_renamed <- df_mean %>%
  rename(estimacion_df2 = estimation_column)


df_combined <- df_weighted_mean %>%
  left_join(df_mean, by = "timestamp")

# Suponiendo que ya tienes df_combined con las columnas renombradas
p <- ggplot(df_combined, aes(x = timestamp)) +
  geom_point(aes(y = !!sym("RoomA.People__amount.x")), color = "blue", size = 2, alpha = 0.5, shape = 16) +  # Puntos originales
  geom_line(aes(y = !!sym("RoomA.People__amount_estimation.x")), color = "green", size = 1) +  # Línea de la primera estimación
  geom_line(aes(y = !!sym("RoomA.People__amount_estimation.y")), color = "orange", size = 1) +  # Línea de la segunda estimación
  
  labs(title = "Comparación de Datos Originales y Estimaciones",
       x = "Fecha",
       y = "Valores") +
  theme_minimal(base_size = 15) +
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "grey90"),
        panel.grid.minor = element_line(color = "grey95"),
        legend.position = "none") +
  scale_y_continuous(limits = c(0, 8))

# Guardar la gráfica como un archivo PNG
ggsave("grafica_estimaciones.png", plot = p, width = 10, height = 6, dpi = 300)
