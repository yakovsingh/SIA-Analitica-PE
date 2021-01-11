# Create log
getNombreCoopac  <- function(cod){
  initCuadreContable() %>% 
    filter(CODIGO_ENTIDAD == as.integer(cod)) %>%
    pull(ENTIDAD) %>% first()
}
getLogObject     <- function(path){
  read_delim(path, "\t", escape_double = FALSE,col_types = cols(Categoria = col_character(), 
                                                                Coopac = col_character(), Criticidad = col_character(), 
                                                                Descripcion = col_character(),  Carpeta = col_character(), Fecha = col_character(), 
                                                                Hora = col_character(), 
                                                                IdProceso = col_integer(),
                                                                Usuario = col_character()), trim_ws = TRUE) %>% return()
}
getNextIdProceso <- function(logObject){
  if (logObject %>% pull(IdProceso) %>% max(na.rm = T) > 0)
    (logObject %>% pull(IdProceso) %>% max(na.rm = T) + 1) %>% return()
  else 
    return(1) 
}
addEventLog      <- function(agent,
                             descripcion,
                             categoria, 
                             criticidad){
  
  myLog <- getLogObject("logging/log.txt")
  event <- tibble(IdProceso = getIdProcesoFromAgent(agent),
                  Fecha = toString(Sys.Date()),
                  Hora  = toString(Sys.time()),
                  Usuario = "DPACHECO", 
                  Coopac  = getNombreCoopacFromAgent(agent) ,
                  Carpeta = getCarpetaFromAgent(agent) , 
                  Descripcion = descripcion ,
                  Categoria  = ifelse(categoria == "I", "Informativo", "Advertencia"),
                  Criticidad = ifelse(criticidad == "B", "Baja", ifelse(criticidad == "M",Media, Alta)))
  
  write_delim(x = event,path = "logging/log.txt", delim = "\t", col_names = F, append = T)
  print(descripcion)
}