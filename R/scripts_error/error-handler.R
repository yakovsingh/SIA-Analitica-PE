## Gestion de errores----
addErrorIndividual <- function(eb, agente, codcoopac, idproceso, cod, periodo, bd, 
                               arg_txt1, arg_txt2, arg_txt3,
                               arg_num1, arg_num2, arg_num3){
  t <- tibble(CodCoopac = codcoopac,
              IdProceso  = idproceso, 
              Cod         = cod, 
              Periodo     = periodo,
              BD          = bd,
              txt1     = arg_txt1,
              txt2    = arg_txt2,
              txt3    =  arg_txt3,
              num1    = arg_num1,
              num2    = arg_num2,
              num3    = arg_num3)
 

  return(bind_rows(eb, t))
} 

addErrorMasivo <- function(eb, parte1){
  bind_rows(eb, parte1) %>% return()
}



# Edwin reducir las dos funciones a esto: 

addError <- function(eb, 
                     obj = NULL) {
  
  eb <- bind_rows(eb, obj)
  return(eb)
  
}

# vamos a estandarizar las estructuras y resumir la mayor cantidad de codigo posible. 
# desde ahora, mala practica aplicar return() usando pipes.
