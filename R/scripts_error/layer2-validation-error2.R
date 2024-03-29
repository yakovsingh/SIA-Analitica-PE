#' Funciones principales
#' layer2(agente, eb)

layer2 <- function(agente, eb){
eb <- validarOperacionesVacias(agente, eb)
eb <- validarOperacionesDuplicadas(agente, eb)
eb <- validarCruceInterno(agente, eb)
eb <- validarCampos(agente, eb)
return(eb)
}

#' Funciones secundarias: nivel I
#' validarCuadreContable
#' validarOperacionesDUVA
#' validarCruceInterno
#' validarCampos

 
validarOperacionesVacias     <- function(agente, eb){
  carpeta   <- getCarpetaFromAgent(agente)
  exigibles <- getArchivosNoObservadosByCols(agente, eb, c("CCR", "CCR_C", "CODGR"))
  
  vacios <- tibble(NombreArchivo = exigibles) %>% rowwise() %>% 
    mutate(ruta    = getRuta(carpeta, NombreArchivo),
           Vacios = getoperacionesVacias(ruta)) %>%
    filter(Vacios != 0)

  if (nrow(vacios) > 0) {
    chunk_311 <- vacios %>% rowwise() %>% 
      mutate(CodCoopac = getCoopacFromAgent(agente),
             IdProceso = getIdProcesoFromAgent(agente),
             Cod = 311,
             Periodo = getAnoMesFromRuta(toString(ruta)),
             BD      = getBDFromRuta(toString(ruta)),
             num1 = Vacios) %>%  
      select(CodCoopac, IdProceso, Cod, Periodo, BD, num1)
    
    eb <- addErrorMasivo(eb, chunk_311)
  }
  
  n <- eb %>% filter(Cod %in% c(311)) %>% nrow()
  
  if (n == 0) {  
    addEventLog(agente, paste0("La validaci�n de operaciones vac�as concluy� sin observaciones. (~ly2)"), "I", "B") 
  }
  else{
    addEventLog(agente, paste0("La validaci�n de operaciones vac�as concluy� con ", n, " observaciones. (~ly2)"), "I", "B")
  }
  
  return(eb)
}
validarOperacionesDuplicadas <- function(agente, eb){
  carpeta   <- getCarpetaFromAgent(agente)
  exigibles <- getArchivosNoObservadosByCols(agente, eb, c("CCR", "CCR_C", "CODGR"))
  
  dups <- tibble(NombreArchivo = exigibles) %>% rowwise() %>% 
    mutate(ruta       = getRuta(carpeta, NombreArchivo),
           Duplicados = getoperacionesDuplicadas(ruta)) %>%
    filter(Duplicados != "")
  
  if (nrow(dups) > 0) {
    chunk_312 <- dups %>% rowwise() %>%
      mutate(CodCoopac = getCoopacFromAgent(agente),
             IdProceso = getIdProcesoFromAgent(agente),
             Cod = 312,
             Periodo = getAnoMesFromRuta(toString(ruta)),
             BD      = getBDFromRuta(toString(ruta)),
             txt1 = Duplicados,
             num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
      select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)

    eb <- addErrorMasivo(eb, chunk_312)
  }
  
  n <- eb %>% filter(Cod %in% c(312)) %>% nrow()
  
  if (n == 0) {
    addEventLog(agente, paste0("La validaci�n de operaciones duplicadas concluy� sin observaciones. (~ly2) "), "I", "B")
  }
  else{
    
    addEventLog(agente, paste0("La validaci�n de operaciones duplicadas concluy� con ", n, " observaci�n. (~ly2) "), "I", "B")
  }
  
  return(eb)
}
validarCruceInterno          <- function(agente, eb){
  
  if (length(getPeriodosNoObservados(agente, eb, "CCR")) >0){
    
    cruce1 <- tibble(Periodo   = getPeriodosNoObservados(agente, eb, "CCR")) %>% rowwise() %>%
      mutate(OpFaltantes_BD01  = realizarCruce(agente, Periodo, "BD02A", "BD01"),
             OpFaltantes_BD02A = realizarCruce(agente, Periodo, "BD01", "BD02A"))
    
    f_bd01  <- cruce1 %>% filter(OpFaltantes_BD01 != "") %>% select(Periodo, OpFaltantes_BD01)
    f_bd02A <- cruce1 %>% filter(OpFaltantes_BD02A != "") %>% select(Periodo, OpFaltantes_BD02A)
    
    if (nrow(f_bd01) >0) {
      chunk_321 <- f_bd01 %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Cod = 312,
               BD  = "BD01",
               txt1 = OpFaltantes_BD01,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)
      
      eb <- addErrorMasivo(eb, chunk_321)
    }
    if (nrow(f_bd02A) >0) {
      chunk_322 <- f_bd02A %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Cod = 322,
               BD  = "BD02A",
               txt1 = OpFaltantes_BD02A,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)
      
      eb <- addErrorMasivo(eb, chunk_322)
    }
  }
  
  if (length(getPeriodosNoObservados(agente, eb, "CODGR")) >0){
    
    cruce2 <- tibble(Periodo = getPeriodosNoObservados(agente, eb, "CODGR")) %>% rowwise() %>%
      mutate(GaranFaltantes_BD03A = realizarCruce(agente, Periodo, "BD03B", "BD03A"))
    
    f_bd03A <- cruce2 %>% filter(GaranFaltantes_BD03A != "") %>% select(Periodo, GaranFaltantes_BD03A)
    
    if (nrow(f_bd03A) >0) {
      chunk_323 <- f_bd03A %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Cod = 323,
               BD  = "BD03A",
               txt1 = GaranFaltantes_BD03A,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)
      
      eb <- addErrorMasivo(eb, chunk_323)
    }
  }

  n <- eb %>% filter(Cod %in% c(321, 322, 323)) %>% nrow()
  
  if (n == 0) {
    addEventLog(agente, paste0("La validaci�n cruce interno concluy� sin observaciones. (~ly2) "), "I", "B")
  }
  else{
    
    addEventLog(agente, paste0("La validaci�n cruce interno concluy� con ", n, " observaci�n. (~ly2) "), "I", "B")
  }
  
  return(eb)
}
validarCampos                <- function(agente, eb){
  carpeta   <- getCarpetaFromAgent(agente)
  exigibles <- getArchivosNoObservadosByCols(agente, eb, c("CCR","CCR_C","CODGR"))
  
  # i. Errores tipo1 ----
  for (x in 1:length(exigibles)){
    ruta_x <- getRuta(carpeta, exigibles[x])
    eb     <- procesarErroresT1(agente, ruta_x, eb)
  }
  
  n <- eb %>% filter(Cod %in% c(401:457)) %>% nrow()
  if (n == 0) {
    addEventLog(agente, paste0("La validaci�n de los campos concluy� sin observaciones tipo1. (~ly2) "), "I", "B")
  }
  else{
    
    addEventLog(agente, paste0("La validaci�n de los campos concluy� con ",n," observaciones tipo1. (~ly2) "), "I", "B")
  }
  
  
  # ii. Errores tipo2 ----
  for (y in 1:length(exigibles[str_detect(exigibles, "BD01")])){
    ruta_y <- getRuta(carpeta, exigibles[str_detect(exigibles, "BD01")][y])
    eb     <- procesarErrorSaldosNegativos(agente, ruta_y, eb)
  }
  
  cod <- 462
  for (z in 462:467){
    eb <- procesarErroresT2(agente, eb, exigibles, cod)
    cod <- cod +1
  }
  
  n <- eb %>% filter(Cod %in% c(461:467)) %>% nrow()
  if (n == 0) {
    addEventLog(agente, paste0("La validaci�n de los campos concluy� sin observaciones tipo2. (~ly2) "), "I", "B")
  }
  else{
    
    addEventLog(agente, paste0("La validaci�n de los campos concluy� con ",n," observaciones tipo2. (~ly2) "), "I", "B")
  }
  
  
  # iii. Errores tipo2 ----
  exigibles <- exigibles[str_detect(exigibles, paste(c("BD01","BD02A","BD02B","BD04"), collapse = '|'))]

  for (m in 1:length(exigibles)) {
    ruta_m <- getRuta(carpeta, exigibles[m])
    eb     <- procesarErroresT3(agente, ruta_m, eb)
  }
  
  exigibles <- intersect(exigibles[str_detect(exigibles, "BD01")], getArchivosNoObservadosByCols(agent, eb, "FOT"))
  error479 <- tibble(Archivo = exigibles) %>% rowwise() %>%
    mutate(ruta      = getRuta(getCarpetaFromAgent(agente), Archivo),
           verificar = procesarErrorFechaDesembolso(ruta) %>%
                          unique() %>% toString(),
           Cod       = 479) %>%
    filter(verificar != "")
  
  if (nrow(error479) >0) {
      chunk479 <- error479 %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Periodo = getAnoMesFromRuta(toString(ruta)),
               BD      = getBDFromRuta(toString(ruta)),
               txt1 = verificar,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)

      eb <- addErrorMasivo(eb, chunk479)
  }
  
  
  n <- eb %>% filter(Cod %in% c(471:479)) %>% nrow()
  if (n == 0) {
    addEventLog(agente, paste0("La validaci�n de los campos concluy� sin observaciones tipo3. (~ly2) "), "I", "B")
  }
  else{
    
    addEventLog(agente, paste0("La validaci�n de los campos concluy� con ",n," observaci�n(es) tipo3. (~ly2) "), "I", "B")
  }
  
  
  ####
  n <- eb %>% filter(Cod %in% c(401:479)) %>% nrow()
  
  if (n == 0) {
    addEventLog(agente, paste0("La validaci�n de los campos concluy� sin observaciones. (~ly2) "), "I", "B")
  }
  else{
    
    addEventLog(agente, paste0("La validaci�n de los campos concluy� con un total de ", n, " observaci�n(es). (~ly2) "), "I", "B")
  }
  
  return(eb)
}


getCodigoBD <- function(bd){
  campo <- case_when(bd == "BD01"  ~ "CCR",
                     bd == "BD02A" ~ "CCR",
                     bd == "BD02B" ~ "CCR_C",
                     bd == "BD03A" ~ "CODGR",
                     bd == "BD03B" ~ "CODGR",
                     bd == "BD04"  ~ "CCR_C")
  return(campo)
}
#validarOperacionesVacias #cambiar nombre
getoperacionesVacias <- function(ruta){
  BD <- evaluarFile(ruta)
  
  BD %>% 
    select(getCodigoBD(getBDFromRuta(ruta))[1]) %>%
    sapply(function(x) sum(is.na(x))) %>% return()
}

#validarOperacionesDuplicadas  #cambiar nombre
getoperacionesDuplicadas <- function(ruta){
  if (getBDFromRuta(ruta) == "BD01" | getBDFromRuta(ruta) == "BD03A") {
    operaciones <- evaluarFile(ruta) %>% select(getCodigoBD(getBDFromRuta(ruta))[1]) 
    duplicados  <- operaciones[duplicated(operaciones), ] %>% 
      unique() %>%
      pull(getCodigoBD(getBDFromRuta(ruta))[1]) %>%
      toString()
    return(duplicados)
    }
  else {
    return("")
    }  
}

#validarCruceInterno
realizarCruce <- function(agente, periodo, data1, data2){
  
  archivo1 <- getRuta(getCarpetaFromAgent(agente), 
                      paste0(paste(getCoopacFromAgent(agente), data1, periodo, sep  = "_"), ".txt"))
  archivo2 <- getRuta(getCarpetaFromAgent(agente), 
                      paste0(paste(getCoopacFromAgent(agente), data2, periodo, sep  = "_"), ".txt"))
  
  setdiff(evaluarFile(getRuta(getCarpetaFromAgent(agente), archivo1)) %>% pull(getCodigoBD(data1)),
          evaluarFile(getRuta(getCarpetaFromAgent(agente), archivo2)) %>% pull(getCodigoBD(data2))) %>%
    unique() %>%
    toString() %>% return()
}

#Validar campos
# Tipo1 ----
getDigitosBD01  <- function(campo){
  digitos <- switch (campo,
                     TID = {c(1,2,3,4,5,6,7)},
                     TCR = {c(6,7,8,9,10,11,12,13,20)},
                     CAL = {c(0,1,2,3,4)},
                     ESAM = {c(1,2,3,4,5)},
                     SEC = {c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,99)},
                     MDCR ={c(1,2,3,4,5,9)},
                     OSD = {c(1,2,3,4,5,6,7,8,9,10,99)})
  return(digitos)
}
getDigitosBD02A <- function(campo){
  digitos <- switch (campo,
                     MON = {c(1,2,3)},
                     FOCAN = {c(1,2,3,4,5)})
  return(digitos)
}
getDigitosBD02B <- function(campo){
  digitos <- switch (campo,
                     MON_C = {c(1,2,3)},
                     FOCAN_C = {c(1,2,3,4)})
  return(digitos)
}
getDigitosBD03A <- function(campo){
  digitos <- switch (campo,
                     CGR = {c(1,2,3,4,5)},
                     COBGR = {c(1,2)},
                     MONGR = {c(1,2,3)})
  return(digitos)
}
getDigitosBD03B <- function(campo){
  digitos <- switch (campo,
                     CGR = {c(1,2,3,4,5)})
  return(digitos)
}
getDigitosBD04  <- function(campo){
  digitos <- switch (campo,
                     TID_C = {c(1,2,3,4,5,6,7)},
                     TCR_C = {c(6,7,8,9,10,11,12,13,20)},
                     MON_C = {c(1,2,3)},
                     CAL_C = {c(0,1,2,3,4)},
                     ESAM_C = {c(1,2,3,4,5)},
                     FOCAN_C = {c(1,2,3,4,5)},
                     MDCR_C = {c(1,2,3,4,5,9)})
  return(digitos)
}

getDigitosBD   <- function(ruta,campo){
  digitos <- switch (getBDFromRuta(ruta),
                     BD01  = {getDigitosBD01(campo)},
                     BD02A = {getDigitosBD02A(campo)},
                     BD02B = {getDigitosBD02B(campo)},
                     BD03A = {getDigitosBD03A(campo)},
                     BD03B = {getDigitosBD03B(campo)},
                     BD04  = {getDigitosBD04(campo)})
  return(digitos)
}
getColsErrorT1 <- function(ruta){
  cols <- switch(getBDFromRuta(ruta),
                 BD01  = {c("TID","TCR","CAL","ESAM","SEC","MDCR","OSD")},
                 BD02A = {c("MON","FOCAN")},
                 BD02B = {c("MON_C","FOCAN_C")},
                 BD03A = {c("CGR","COBGR")},
                 BD03B = {c("CGR")},
                 BD04  = {c("TID_C","TCR_C","MON_C","CAL_C","ESAM_C","FOCAN_C","MDCR_C")}) 
  return(cols)
}
getCodErrorT1  <- function(ruta, campo){
  codError <- switch (getBDFromRuta(ruta),
                      BD01  = {c(401,402,403,404,405,406,407)},
                      BD02A = {c(411,412)},
                      BD02B = {c(421,422)},
                      BD03A = {c(431,432)},
                      BD03B = {c(441)},
                      BD04  = {c(451,452,453,454,455,456,457)})
  
  cod <- tibble(col       = getColsErrorT1(ruta),
                cod_error = codError) %>% 
    filter(col == campo) %>% 
    pull(cod_error)
  return(cod)
}

procesarErroresT1 <- function(agente, ruta, eb){
  BD <- evaluarFile(ruta)
  
  if (length(getColsNoObservadas(ruta, eb, "T1")) >0) {
    erroresTipo1 <- tibble(Columna = getColsNoObservadas(ruta, eb, "T1")) %>%
      rowwise() %>%
      mutate(verificar = BD %>% 
                          filter((as.numeric(cgrep(BD, Columna)[[1]]) %in% getDigitosBD(ruta, Columna)) == FALSE) %>%
                          pull(getCodigoBD(getBDFromRuta(ruta))) %>%
                          unique() %>% toString(),
             Cod       = getCodErrorT1(ruta, Columna)) %>% 
      filter(verificar != "")
    
    if (nrow(erroresTipo1) >0) {
      chunkT1 <- erroresTipo1 %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Periodo = getAnoMesFromRuta(toString(ruta)),
               BD      = getBDFromRuta(toString(ruta)),
               txt1 = verificar,
               txt2 = Columna,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, txt2, num1)
      
      eb <- addErrorMasivo(eb, chunkT1)
      }
    return(eb)
    }
  return(eb)
}

# Tipo2----
procesarErroresT2 <- function(agente, eb, exigibles, codigoError){
  #filter files:
  archivos <- switch (toString(codigoError),
                      "462"= getArchivosNoObservadosByCols(agente, eb, c("ESAM","NCPR", "PCUO")) %>% intersect(exigibles[str_detect(exigibles, "BD01")]),
                      "463"= getArchivosNoObservadosByCols(agente, eb, c("MORG", "SKCR")) %>% intersect(exigibles[str_detect(exigibles, "BD01")]),
                      "464"= getArchivosNoObservadosByCols(agente, eb, c("KVE", "DAK", "KJU")) %>% intersect(exigibles[str_detect(exigibles, "BD01")]),
                      "465"= getArchivosNoObservadosByCols(agente, eb, c("TID", "NID", "TID_C", "NID_C")) %>% intersect(exigibles[str_detect(exigibles, paste(c("BD01","BD04"), collapse = '|'))]),
                      "466"= getArchivosNoObservadosByCols(agente, eb, c("NCR", "NRCL")) %>% intersect(exigibles[str_detect(exigibles, "BD03A")]))

  # errores t2:
  if (codigoError < 467 & length(archivos) >0){
    
    erroresTipo2 <- tibble(Archivo = archivos) %>% rowwise() %>%
      mutate(ruta    = getRuta(getCarpetaFromAgent(agente), Archivo),
             verificar = switch (toString(codigoError),
                                 "462"= procesarErrorModalidadCouta(ruta),
                                 "463"= procesarErrorMontoOtorgado(ruta),
                                 "464"= procesarErrorVencRetraso(ruta),
                                 "465"= procesarErrorDocumentoIdent(ruta),
                                 "466"= procesarErrorNumCredCobertura(ruta)) %>%
                 unique() %>% toString(),
             Cod       = codigoError) %>% 
      filter(verificar != "")
    
    if (nrow(erroresTipo2) >0) {
      chunkT2 <- erroresTipo2 %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Periodo = getAnoMesFromRuta(toString(ruta)),
               BD      = getBDFromRuta(toString(ruta)),
               txt1 = verificar,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)
        
        eb <- addErrorMasivo(eb, chunkT2)
      }
    return(eb)
    }
  if (codigoError == 467 & length(getPeriodosNoObservados(agente, eb, "CIS")) > 0) {
    
    erroresTipo2 <- tibble(Periodo = getPeriodosNoObservados(agente, eb, "CIS")) %>% rowwise() %>%
      mutate(error467 = procesarErrorcodDeudor(agente, Periodo),
             Cod = codigoError)%>% 
      filter(error467 != "")
    
    if (nrow(erroresTipo2) >0) {
      chunkT2 <- erroresTipo2 %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               BD   = "BD03A",
               txt1 = error467,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, num1)
      
      eb <- addErrorMasivo(eb, chunkT2)
      }
    return(eb)
    }
}

#BD01
procesarErrorSaldosNegativos <- function(agente, ruta, eb){
  BD         <- evaluarFile(ruta)
  saldosCols <- getColsNoObservadas(ruta, eb, "saldos")
  
  if (length(saldosCols) >0) {
    errorSaldos <- tibble(Columna = saldosCols) %>%
      rowwise() %>%
      mutate(verificarSaldos = BD %>% filter(as.numeric(cgrep(BD, Columna)[[1]]) <0) %>%
               pull(getCodigoBD("BD01")) %>% toString(),
             Cod             = 461) %>%
      filter(verificarSaldos != "")
    
    if (nrow(errorSaldos) >0) {
      chunkSaldos <- errorSaldos %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Periodo = getAnoMesFromRuta(toString(ruta)),
               BD      = getBDFromRuta(toString(ruta)),
               txt1 = verificarSaldos,
               txt2 = Columna,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, txt2, num1)
      
      eb <- addErrorMasivo(eb, chunkSaldos)
    }
    return(eb)
  }
  return(eb)
}
procesarErrorModalidadCouta  <- function(ruta){
  BD <- evaluarFile(ruta)
  
  BD %>%
    filter(((as.numeric(ESAM) < 5) & (as.numeric(NCPR) == 0 | as.numeric(PCUO)  == 0)) == TRUE) %>%
    pull(CCR) %>% return()
}
procesarErrorMontoOtorgado   <- function(ruta){
  BD <- evaluarFile(ruta)
  
  BD %>% filter(as.numeric(MORG) < as.numeric(SKCR)) %>%
    pull(CCR) %>%
    return()
}
procesarErrorVencRetraso     <- function(ruta){
  BD <- evaluarFile(ruta)
  
  BD %>% 
    filter((as.numeric(KVE) > 0 & as.numeric(DAK) == 0)) %>% 
    pull (CCR) %>% return()
}

#BD01 y BD04
detectarVacios              <- function(ruta,campo){
  BD    <- evaluarFile(ruta)
  
  vacios <- BD %>% 
    filter(is.na(cgrep(BD, campo))) %>% 
    pull(getCodigoBD(getBDFromRuta(ruta)))
  
  return(vacios)
}
getnumCaracteresDoc         <- function(documento){
  n_caracteres <- switch (documento,
                          "1" = "8",
                          "2" = "9",
                          "3" = "13",
                          "4" = "13",
                          "5" = "12",
                          "6" = "11")
  return(n_caracteres)
}
procesarErrorDocumentoIdent <- function(ruta){
  BD <- evaluarFile(ruta)
  
  if (getBDFromRuta(ruta) =="BD01"){
    verificar_documento <- BD %>%
      filter((CCR %in% detectarVacios(ruta, "TID")) == FALSE) %>% 
      rowwise() %>%
      mutate(detectarError = if_else(getnumCaracteresDoc(TID) == (nchar(NID) %>% toString()), "TRUE", "FALSE")) %>%
      filter(detectarError == "FALSE") %>%
      pull(getCodigoBD(getBDFromRuta(ruta))) %>%
      union(detectarVacios(ruta, "TID")) %>% toString()
    
    return(verificar_documento)
  }
  
  if (getBDFromRuta(ruta) =="BD04"){
    verificar_documento <- BD %>%
      filter((CCR_C %in% detectarVacios(ruta, "TID_C")) == FALSE) %>% 
      rowwise() %>%
      mutate(detectarError = if_else(getnumCaracteresDoc(TID_C) == (nchar(NID_C) %>% toString()), "TRUE", "FALSE")) %>%
      filter(detectarError == "FALSE") %>%
      pull(getCodigoBD(getBDFromRuta(ruta))) %>%
      union(detectarVacios(ruta, "TID_C")) %>% toString()
    
    return(verificar_documento)
  }
}

#BD03A
procesarErrorNumCredCobertura <- function(ruta){
  BD <- evaluarFile(ruta)
  
  BD %>% 
    filter(as.numeric(NCR) > 0, as.numeric(NRCL) == 0) %>%
    pull(getCodigoBD("BD03A")) %>%
    unique() %>% return()
}

#BD3A y BD01
procesarErrorcodDeudor <- function(agente, periodo){
  
  archivo1 <- getRuta(getCarpetaFromAgent(agente), 
                      paste0(paste(getCoopacFromAgent(agente), "BD03A", periodo, sep  = "_"), ".txt"))
  archivo2 <- getRuta(getCarpetaFromAgent(agente), 
                      paste0(paste(getCoopacFromAgent(agente), "BD01", periodo, sep  = "_"), ".txt"))
  
  setdiff(evaluarFile(getRuta(getCarpetaFromAgent(agente), archivo1)) %>% pull(getCodigoBD("BD03A")),
          evaluarFile(getRuta(getCarpetaFromAgent(agente), archivo2)) %>% pull(getCodigoBD("BD01"))) %>%
    unique() %>%
    toString() %>% return()
}


# Tipo3----
#BD01, BD02A, BD02B, BD04 
getColsErrorT3 <- function(ruta){
  cols <- switch (getBDFromRuta(ruta),
                  BD01  = {c("FOT", "FVEG", "FVEP")},
                  BD02A = {c("FVEP")},
                  BD02B = {c("FVEP_C")},
                  BD04  = {c("FOT_C", "FCAN_C")}) 
  return(cols)
}
getCodErrorT3  <- function(ruta, campo){
  codError <- switch (getBDFromRuta(ruta),
                      BD01  = {c(471,472,473)},
                      BD02A = {c(474)},
                      BD02B = {c(475)},
                      BD04  = {c(476, 477)})
  
  cod <- tibble(col       = getColsErrorT3(ruta),
                cod_error = codError) %>% 
    filter(col == campo) %>% 
    pull(cod_error)
  return(cod)
}

procesarErroresT3 <- function(agente, ruta, eb){
  BD <- evaluarFile(ruta)
  
  if (length(getColsNoObservadas(ruta, eb, "T3")) >0) {
    erroresTipo3 <- tibble(Columna = getColsNoObservadas(ruta, eb, "T3")) %>%
      rowwise() %>%
      mutate(verificar = BD %>% 
                            filter(dmy(cgrep(BD, Columna)[[1]]) %>% is.na() == TRUE) %>% 
                            pull(getCodigoBD(getBDFromRuta(ruta))) %>%
                            unique() %>% toString(),
             Cod       = getCodErrorT3(ruta, Columna)) %>% 
      filter(verificar != "")
    
    if (nrow(erroresTipo3) >0) {
      chunkT3 <- erroresTipo3 %>% rowwise() %>%
        mutate(CodCoopac = getCoopacFromAgent(agente),
               IdProceso = getIdProcesoFromAgent(agente),
               Periodo = getAnoMesFromRuta(toString(ruta)),
               BD      = getBDFromRuta(toString(ruta)),
               txt1 = verificar,
               txt2 = Columna,
               num1 = length(str_split(string=txt1 ,pattern = ",")[[1]])) %>%
        select(CodCoopac, IdProceso, Cod, Periodo, BD, txt1, txt2, num1)
      
      eb <- addErrorMasivo(eb, chunkT3)
    }
    return(eb)
  }
  return(eb)
}

#BD01
getFechaCorte                <- function(ruta){
  fecha_corte <- seq(as.Date(paste(getAnoFromRuta(ruta),getMesFromRuta(ruta),"01", sep = "-")),
                     length=1, by="months") %>%
    ceiling_date("month") - days(1)
  return(fecha_corte)
}
procesarErrorFechaDesembolso <- function(ruta){
  BD <- evaluarFile(ruta)
  
  BD %>% filter((dmy(BD %>% pull(FOT)) > getFechaCorte(ruta)) == TRUE) %>% 
    pull(getCodigoBD("BD01")) %>% return()
}

####

# Filter files, periods, cols from bucket----
getArchivosObservadosFromBucket <- function(eb) {
  eb %>% 
    mutate(filename = paste0(CodCoopac,"_",BD, "_",Periodo,".txt")) %>% 
    pull(filename) %>% unique() %>% return()
}
getArchivosNoObservados         <- function(agente, eb) {
  setdiff(getArchivosExigiblesFromAgent(agente),
          getArchivosObservadosFromBucket(eb)) %>%  return()
}
getArchivosNoObservadosByErrors <- function(agente, eb, cods) {
  v <- eb %>% 
    filter(Cod %in% cods) %>% 
    mutate(filename = paste0(CodCoopac,"_",BD, "_",Periodo,".txt")) %>% 
    pull(filename) %>% unique()
  
  setdiff(getArchivosExigiblesFromAgent(agente),
          v) %>%  return()
}
getArchivosNoObservadosByCols   <- function(agente, eb, cols) {
  v <- eb %>%
    filter(Cod %in% c(201, 202, 203)) %>% 
    rowwise() %>% 
    filter_at(.vars = vars(txt1),
              .vars_predicate = any_vars(str_detect(., paste0(paste(cols, collapse = "|"))))) %>% 
    mutate(filename = paste0(CodCoopac,"_",BD, "_",Periodo,".txt")) %>% 
    pull(filename) %>% unique()
  
  setdiff(getArchivosExigiblesFromAgent(agente),
          v) %>%  return()
}
getPeriodosNoObservados         <- function(agente, eb, colCruce){
  archivos  <- getArchivosNoObservadosByCols(agente, eb, colCruce)
  archCruce <- switch (colCruce,
                       CCR   = archivos[str_detect(archivos, paste(c("BD01","BD02A"), collapse = '|'))],
                       CODGR = archivos[str_detect(archivos, paste(c("BD03A","BD03B"), collapse = '|'))],
                       CIS   = archivos[str_detect(archivos, paste(c("BD03A","BD01"), collapse = '|'))])
  
  getPeriodos <- tibble(Periodos =  str_extract(archCruce, paste(as.character(global.alcance),collapse = '|'))) %>%
    group_by(Periodos) %>%
    filter(n() ==2) %>%
    pull(Periodos) %>% 
    unique() 
  
  return(getPeriodos)
}
getColsNoObservadas             <- function(ruta, eb, tipoError){
  colsError <- eb %>%
    filter(BD == getBDFromRuta(ruta) & Periodo == getAnoMesFromRuta(ruta) & Cod == 203) %>% 
    pull(txt1) %>%
    str_split(",") %>% 
    unlist() %>% unique()
  
  
  cols <- switch (tipoError,
                  T1 = setdiff(getColsErrorT1(ruta), colsError),
                  T3 = setdiff(getColsErrorT3(ruta), colsError),
                  saldos = setdiff(c("SKCR", "PCI", "KVI", "KRF", "KVE", "KJU", "SIN", "SID", "SIS", "DGR", "NCPR", "NCPA", "TPINT", "NRPRG"),
                                   colsError))
  
  return(cols)
}
