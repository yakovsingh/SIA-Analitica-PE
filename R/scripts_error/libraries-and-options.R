##### 1. Librerias opciones ----- 
library(tidyverse)
library(stringr)
library(colr)
library(lubridate)

##### 2. Opciones ----- 

options(warn = -1)
options(scipen = 999)

#####3. Parametros de inicio ----- 
fileCuadreContable     = "config/config1.txt"
fileEstructuraBase     = "config/config2.txt"
fileRepositorioErrores = "config/config3.txt"
fileRepositorioAlertas = "config/config4.txt"
alcanceGeneral         = c(201901:201912, 202001:202012)
 

#####4. Inicializar archivos de configuracion

## Archivos precargados ----
initCuadreContable     <- function(){
  read_delim(fileCuadreContable, 
             "\t", escape_double = FALSE, col_types = cols(ANO = col_double(), 
                                                           CODIGO_ENTIDAD = col_double(), ENTIDAD = col_character(), 
                                                           KJU = col_double(), KRF = col_double(), 
                                                           KVE = col_double(), KVI = col_double(), 
                                                           PERIODO = col_double(), TIPOENTIDAD = col_character()), 
             trim_ws = TRUE, progress = T) %>% return()
}
initEstructuraBase     <- function(){ 
  read_delim(fileEstructuraBase, 
             "\t", escape_double = FALSE, col_types = cols(BD = col_character(), 
                                                           CAMPO = col_character(), 
                                                           DESCRIPCION = col_character(),  
                                                           NRO = col_double(), 
                                                           TIPO = col_character()), progress = T)  %>% return()
}
initRepositorioErrores <- function(){
  read_delim(fileRepositorioErrores, 
             "\t", escape_double = FALSE, col_types = cols(Cod = col_double(), 
                                                           Descripcion = col_character(), 
                                                           Tipo = col_character()),
             locale = locale(encoding = "ISO-8859-1"), trim_ws = TRUE, progress = T) %>% return()
}
 