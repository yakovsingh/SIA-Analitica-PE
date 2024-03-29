#' funci�n principal 
#' layer1()
#' 
layer1 <- function(agente, eb){
  
  carpeta   <- getCarpetaFromAgent(agente)
  exigibles <- getArchivosExigiblesFromAgent(agente) 
  
  tbl1_ctrl1 <- tibble(NombreArchivo = exigibles) %>% rowwise() %>%
    mutate(ruta      = getRuta(carpeta, NombreArchivo),
           CodCoopac = getCoopacFromAgent(agente),
           IdProceso = getIdProcesoFromAgent(agente),
           BD        = getBDFromRuta(ruta),
           Columnas     = list(colnames(evaluarFile(ruta))),
           ColumnasOM   = getColumnasOM(BD),
           ColFaltantes = ifelse(length(setdiff(ColumnasOM, Columnas))>0,
                                 toString(setdiff(ColumnasOM, Columnas)),
                                 ""),
           ColSobrantes = ifelse(length(setdiff(Columnas, ColumnasOM))>0,
                                 toString(setdiff(Columnas, ColumnasOM)),
                                 ""),
           ColVacias    = toString(getColVacia(ruta)),
           is201        = ifelse(str_replace_all(ColFaltantes, pattern = " ", replacement = "") == "",0,1),
           is202        = ifelse(str_replace_all(ColSobrantes, pattern = " ", replacement = "") == "",0,1),
           is203        = ifelse(str_replace_all(ColVacias, pattern = " ", replacement = "") == "",0,1)) %>% 
    filter(is201 == 1 | is202 == 1 | is203 == 1)
  
  chunk_201 <- tbl1_ctrl1 %>% 
    filter(is201 == 1) %>% rowwise() %>% 
    mutate(Cod = 201,
           Periodo = getAnoMesFromRuta(toString(ruta)),
           BD          = getBDFromRuta(toString(ruta)),
           txt1 = str_replace_all(ColFaltantes, pattern = " ", replacement =""), 
           num1 = ifelse(!is.na(txt1),length(str_split(string=txt1 ,pattern = ",")[[1]]),0)) %>%  
    select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)
  
  eb <- addErrorMasivo(eb, chunk_201)
  
  chunk_202 <- tbl1_ctrl1 %>% 
    filter(is202 == 1) %>% rowwise() %>% 
    mutate(Cod = 202,
           Periodo = getAnoMesFromRuta(toString(ruta)),
           BD          = getBDFromRuta(toString(ruta)),
           txt1 = str_replace_all(ColSobrantes, pattern = " ", replacement =""),  
           num1 = ifelse(!is.na(txt1),length(str_split(string=txt1 ,pattern = ",")[[1]]),0)) %>% 
    select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)
  
  eb <- addErrorMasivo(eb, chunk_202)
  
  chunk_203 <- tbl1_ctrl1 %>%
    filter(is203 == 1) %>% rowwise() %>%
    mutate(Cod = 203,
           Periodo = getAnoMesFromRuta(toString(ruta)),
           BD          = getBDFromRuta(toString(ruta)),
           txt1 = str_replace_all(ColVacias, pattern = " ", replacement =""),  
           num1 = ifelse(!is.na(txt1),length(str_split(string=txt1 ,pattern = ",")[[1]]),0)) %>%
    select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1) 
  
  eb <- addErrorMasivo(eb, chunk_203)
  return(eb)
}

#' Funciones secundarias 
#' getColumnaOM()
#' getColVacia()
#' evaluarFile()
#' 
#' 
evaluarFile   <- function(ruta){
  read_delim(ruta,"\t",escape_double = FALSE, trim_ws = TRUE, col_names = TRUE,
             col_types = cols(.default = "c"), progress = F) %>%
    return()
  
}

getColumnasOM <- function(BD){ 
  cols_base <- switch (BD,
                       BD01  = {initEstructuraBase() %>% filter(BD == "BD01") %>% pull(CAMPO) %>% list()},
                       BD02A = {initEstructuraBase() %>% filter(BD == "BD02A") %>% pull(CAMPO) %>% list()},
                       BD02B = {initEstructuraBase() %>% filter(BD == "BD02B") %>% pull(CAMPO) %>% list()},
                       BD03A = {initEstructuraBase() %>% filter(BD == "BD03A") %>% pull(CAMPO) %>% list()},
                       BD03B = {initEstructuraBase() %>% filter(BD == "BD03B") %>% pull(CAMPO) %>% list()},
                       BD04  = {initEstructuraBase() %>% filter(BD == "BD04") %>% pull(CAMPO) %>% list()})
  return(cols_base)
}
getColVacia   <- function(ruta, BD = evaluarFile(ruta)){
  colsVacias <- intersect(BD[sapply(BD, function(x) all(is.na(x)))] %>% colnames(),
                          getColumnasOM(getBDFromRuta(ruta)) %>% unlist())

  return(colsVacias)
}