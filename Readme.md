# People Occupation data smoothing

This repository contains a R project used for smoothing the data of room occupation. It includes the R scripts and the plots created to visualize the data.

## Data sources

[METE ALGO DE INFORMACIÓN SOBRE EL DATASET, UN PÁRRAFO DE 3-4 LÍNEAS CON LA INFO BÁSICA: Tipo de edificio, ubicación geográfica, número de habitaciones, frecuencia de muestreo]

The data was collected from six office in Aalborg University in Denmark from February 2023 to December 2023. It has a frecuency of five minutes and contains measurments of occupany, ventilation, heating, lighting and general enviromental factors. The dataset contains data from six office rooms

[añade la referencia completa]

The dataset was obtained from:
Melgaard, S. P., Johra, H., Nyborg, V. Ø., Marszal-Pomianowska, A., Jensen, R. L., Kantas, C., Larsen, O. K., Hu, Y., Frandsen, K. M., Larsen, T. S., Svidt, K., Andersen, K. H., Leiria, D., Schaffer, M., Frandsen, M., Veit, M., Ussing, L. F., Lindhard, S. M., Pomianowski, M. Z., … Heiselberg, P. K. (2024). 
A Danish high-resolution dataset for six office rooms with occupancy, indoor environment , heating, ventilation, lighting and room control monitoring [Data set]. 
En Data in Brief (Versión v3, Vol. 54, p. 110326). 
Zenodo. https://doi.org/10.5281/zenodo.10673763

The data is documented in: 
Simon Pommerencke Melgaard, Hicham Johra, Victor Ørsøe Nyborg, Anna Marszal-Pomianowska, Rasmus Lund Jensen, Christos Kantas, Olena Kalyanova Larsen, Yue Hu, Kirstine Meyer Frandsen, Tine Steen Larsen, Kjeld Svidt, Kamilla Heimar Andersen, Daniel Leiria, Markus Schaffer, Martin Frandsen, Martin Veit, Lene Faber Ussing, Søren Munch Lindhard, Michal Zbigniew Pomianowski, Lasse Rohde, Anders Rhiger Hansen, Per Kvols Heiselberg,
Detailed operational building data for six office rooms in Denmark: Occupancy, indoor environment, heating, ventilation, lighting and room control monitoring with sub-hourly temporal resolution,
Data in Brief,
Volume 54,
2024,
110326,
ISSN 2352-3409,
https://doi.org/10.1016/j.dib.2024.110326.


## [smoothing approach]

[Añadir una sección en la que presentas las distintas fórmulas, idem que en el paper, pero añadiendo el nombre exacto de las funciones y sus datos de entrada y salida]

In the script there are functions to perform four different smoothing methods, all of them perform some operation with the values inside a time interval around the point:

- **max_estimation <- function(df, aggregation_period, columns_of_interest)**. The point is smoothed out to the maximum value of the interval. df is the dataframe with data, aggregation_period is the length of the interval (It is centered around the point, it spans from t-aggregation_period/2 to t+aggregation_period/2). columns_of_interest is a list with the names of the columns to be smoothed. It returns a dataframe with the original columns and new columns ending in _estimation for all the columns in columns_of_interest.

- **rounded_mean_estimation <- function(df, aggregation_period, columns_of_interest)**. The mean value of the interval is calculated rounded. It has the same arguments as max_estimation and returns the same.

- **mean_estimation <- function(df, aggregation_period, columns_of_interest)**. The mean value is calculated. It has the same arguments as max_estimation and rounded_mean_estimation and returns the same. _estimation columns have non integer values.

- **weighted_mean_estimation <- function(df, temporal_window, columns_of_interest, weights_list, unique_values_list)**. The weighted mean of the interval is calculated with the weights from weights_list. df, aggregation_period and columns_of_interest function like the ones in the other methods. weights_list is a list of weight_lists, it needs as many lists as columns are in columns_of_interest and the corresponding weight_list of each column needs to be in the same order as columns_of_interest, each weight_list has a weight for each unique value in that column. The unique value of the column are specified in unique_values_list, which like weights_list is a list of lists and needs to be in the same order as weights_list and columns_of_interest.
## Repository structure

[INDICARLO DE FORMA MÁS ORDENADA

FOLDERS:

- data containing .csv file with the occupany data

- output default route to save plots and resulting dataframes.

FILES IN THE REPOSITORY ROOT:

- data.csv contains data from November 6th to 12th, it only has three columns timestamp, RoomA.People__amount with the measured occupnay for RoomA during that week and RoomA.Room__active which indicates room occupation of at leats 1 with a 1 and 0 if empty.

- functions.R with all the functions used for the project

- occupation.R with an example of usage of the functions

INDICA QUE HABITACIÓN, QUE SEÑAL CONCRETA, Y QUE PERÍODO TEMPORAL COGES

The example analysis from occupation.R was donde for data from November 6th to 12th and the signal RoomA.People__amount, this signal measures the occupany of office roomA.

]

[COMENTARIOS A LAS FUNCINONES Y AL CÓDIGO DE EJEMPLO

The exmaple analysis from occupation.R starts by laoding the data and cleaning it using load_data which has a path to the data as an arugument. It defines the variables needed for the different methods and using those variables uses the four methods creates four dataframes with the results from the different methods. 

After that plot_estimation functions is called, **plot_estimation <- function(df, original_column = "RoomA.People__amount", save_dir = "output/graphs", filename, start_time = NULL, end_time = NULL)**. df is one of the four df obtained with the different methods, original_column is the column name with the original data that was smoothed, save_dir the directory to save plot and filename its filename. Start and end times are used to only plot betwwen those bounds, if they are not specified it plots all the data in the df. It plots one at a time and the variables and dataframe should be changed accordingly each time to obtained the desire plot.

**save_df <- function(df, save_dir = "output/", df_name)**. Its called last and it is used for saving the df as a .csv, df is the dataframe to be saved and df_name the name you want to save it as. The function replaces the orignal data with the smoothed one in _estimation columns. The saved dataframe will have the same amount of columns with the same names as the original data from data folder. The order or the columns will be different from the orginal one.


EXPLICA EN CADA FUNCIÓN PARA QUÉ SIRVE, CUALES SON SUS DATOS Y FORMATOS DE ENTRADA Y DE SALIDA

EL NOMBRE DE LAS VARIABLES, IGUAL HABRÍA QUE REVISARLO UN POCO:

-   temporal window – aggregation period?

-   valores_unicos_RoomA - pasar a inglés

-   valores_unicos_RoomA_active - pasar a inglés

-   etc.

]

[

PREGUNTA. Los gráficos se generan todos de golpe, o hay que particularizar la línea 45 del código.

Sea lo que sea, mete una explicación.

]
