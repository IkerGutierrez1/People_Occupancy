# People Occupation data smoothing

This repository contains a R project used for smoothing the data of room occupation. It includes the R scripts and the plots created to visualize the data.

## Data sources

[METE ALGO DE INFORMACIÓN SOBRE EL DATASET, UN PÁRRAFO DE 3-4 LÍNEAS CON LA INFO BÁSICA: Tipo de edificio, ubicación geográfica, número de habitaciones, frecuencia de muestreo]

The data was collected from six office in Aalborg University in Denmark from February 2023 to December 2023. It has a frecuency of five minutes and contains measurments of occupany, ventilation, heating, lighting and general enviromental factors.

[añade la referencia completa] ?

The dataset was obtained from: [Zenodo](https://zenodo.org/doi/10.5281/zenodo.10039896)

The data is documented in: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2352340924002956?via%3Dihub)

## [smoothing approach]

[Añadir una sección en la que presentas las distintas fórmulas, idem que en el paper, pero añadiendo el nombre exacto de las funciones y sus datos de entrada y salida]

In the script there are functions to perform four different smoothing methods, all of them perform some operation with the values inside a time interval around the point:

- max_estimation <- function(df, temporal_window, columns_of_interest), the point is smoothed out to the maximum value of the interval. df is the dataframe with data, temporal window is the length of the interval (It is centered around the point, it spans from t-temporal_window/2 to t+temporal_window/2). columns_of_interest is a list with the names of the columns to be smoothed. It returns a dataframe with the original columns and new columns ending in _estimation for all the columns in columns_of_interest.
## Repository structure

[INDICARLO DE FORMA MÁS ORDENADA

FOLDERS:

etc..

FILES IN THE REPOSITORY ROOT:

Etc...

data.csv

INDICA QUE HABITACIÓN, QUE SEÑAL CONCRETA, Y QUE PERÍODO TEMPORAL COGES

]

The repository has two .R files:

-   functions.R with all the functions used for the project
-   occupation.R with an example of usage of the functinos

data folder contains the .csv obtain from Zenodo, the data was processed to only have data from one week to create the plots.

output contains the resulting dataframe and plots of the data and different methods.

[COMENTARIOS A LAS FUNCINONES Y AL CÓDIGO DE EJEMPLO

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
