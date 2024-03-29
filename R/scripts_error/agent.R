createAgent <- function(idCoopac,
                        periodoInicial, 
                        periodoFinal, 
                        usuarioSIA = default.usuario,
                        coopacCarpeta = default.carpeta, 
                        bds = default.bd){
  
  agente <- tibble(Coopac       = idCoopac,
                  NombreCoopac = getNombreCoopacFromIdCoopac(Coopac),
                  Carpeta      = coopacCarpeta,
                  IdProceso    = getNextIdProceso(getLogObject("logging/log.txt")),
                  Usuario      = usuarioSIA,
                  InicioProceso  = format(Sys.time(), "%a %b %d %X %Y"), 
                  PeriodoInicial = periodoInicial,
                  PeriodoFinal   = periodoFinal,
                  Alcance        = bds) 
  
  addEventLog(agente, paste0("Validador SIA 1.3.2021 --------------------------------------"), 
              "I", "B")
  
  addEventLog(agente, paste0("Agente creado. PID-", agente %>% pull(IdProceso) %>% first(),
                            ". [",idCoopac,"|", periodoInicial, "~", periodoFinal, "]"), 
              "I", "B")
  
  return(agente)
}


 
createBucket     <- function(agente){
  eb <- tibble(CodCoopac     = agente %>% pull(Coopac) %>% first(),
         IdProceso  = agente %>% pull(IdProceso) %>% first(), 
         Cod         = 100,
         Periodo = "",
         BD = "",
         txt1 = "",
         txt2 = "",
         txt3 = "",
         num1 = 0,
         num2 = 0,
         num3 = 0) 
  
  addEventLog(agente, paste0("Bucket de errores creado. PID-", agente %>% pull(IdProceso) %>% first(),"."), 
              "I", "B")
  
  return(eb)
}

interrogateAgent <- function(agente){
  eb <- createBucket(agente)
  
  addEventLog(agente, paste0("Inicio del interrogatorio. PID-", agente %>% pull(IdProceso) %>% first(),"."), 
              "I", "B")
  
  addEventLog(agente, paste0("Apertura de revisi�n de pre-requisitos."),  "I", "B")
  
    eb <- layer0(agente, eb) #pre-requisitos
  
    if (nrow(eb) > 0) {
      if ((eb %>% pull(Cod)) %in% c(101,102)) { 
      
        addEventLog(agente, paste0("Fin del proceso de revisi�n por errores cr�ticos 101-102."), "I", "B")
        return(eb)
    }
      else {
        addEventLog(agente, paste0("Revisi�n de pre-requisitos satisfactoria."), "I", "B")
    }
  }
    else {
    addEventLog(agente, paste0("Revisi�n de pre-requisitos satisfactoria."), "I", "B")
  }
  
  addEventLog(agente, paste0("Apertura de revisi�n de estructura de datos."),  "I", "B")
  
    eb <- layer1(agente, eb) #estructura de columnas
  
    if (nrow(eb) > 0) {
      
      if ((eb %>% pull(Cod)) %in% c(201,202)) { 
      
      n <- eb %>% filter(Cod %in% c(201,202)) %>% nrow()
      addEventLog(agente, paste0("La revisi�n de estructura de datos tiene observaciones. Continuar con discreci�n."), "I", "B")
        
      }
      else {
      addEventLog(agente, paste0("Revisi�n de estructura de datos satisfatoria."), "I", "B")
      }
      
    }
    else {
      addEventLog(agente, paste0("Revisi�n de estructura de datos satisfatoria."), "I", "B")
    }
  
  addEventLog(agente, paste0("Apertura de revisi�n de errores OM 22269-2020."),  "I", "B")
  
    eb <- layer2(agente, eb) #errores OM 22269-2020

    if (nrow(eb) > 0) {
      if (nrow(eb %>% filter(Cod %in% c(311:478)) >0)) {

        addEventLog(agente, paste0("La revisi�n errores OM 22269-2020 tiene observaciones."), "I", "B")
        }
      else {
        addEventLog(agente, paste0("Revisi�n de errores OM 22269-2020 fue satisfatoria."), "I", "B")
        }
      }
    else {
      addEventLog(agente, paste0("Revisi�n de errores OM 22269-2020 fue satisfatoria."), "I", "B")
      }

  # eb <- layer3(agent, eb) #alertas ad-hoc 11356
   
  return(eb)
}
closeAgent       <- function(agente, eb){
  agente <- agente %>% 
    mutate(
      FinProceso = format(Sys.time(), "%a %b %d %X %Y"),
      NroErrores = nrow(eb),
      Tramo      = paste0(PeriodoInicial, ":", PeriodoFinal)) %>% 
    select(Coopac, NombreCoopac, IdProceso, InicioProceso, FinProceso, Tramo, NroErrores, PeriodoInicial, PeriodoFinal) %>%
    return()
}