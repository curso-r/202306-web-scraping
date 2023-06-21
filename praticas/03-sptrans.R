library(tidyverse)
library(httr)

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
endpoint <- "/Posicao"

u_sptrans_busca <- paste0(u_sptrans, endpoint)
(r_sptrans <- httr::GET(u_sptrans_busca))
httr::content(r_sptrans)

# caso voce nao queira/nao tenha conseguido fazer uma conta
api_key <- "4af5e3112da870ac5708c48b7a237b30206806f296e1d302e4cb611660e2e03f"

# Obtenha a API key e coloque no seu ambiente
## Dica: usar usethis::edit_r_environ("project")

u_sptrans_login <- paste0(u_sptrans, "/Login/Autenticar")
q_sptrans_login <- list(token = Sys.getenv("API_OLHO_VIVO"))
# q_sptrans_login <- list(token = api_key)
r_sptrans_login <- POST(u_sptrans_login, query = q_sptrans_login)

# precisa ser TRUE!
content(r_sptrans_login)

# agora sim, estamos autenticados :)

(r_sptrans <- httr::GET(u_sptrans_busca))
httr::content(r_sptrans)


# alternativa httr2 -------------------------------------------------------

library(httr2)

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
req_base <- u_sptrans |> 
  httr2::request()

req_login <- req_base |> 
  httr2::req_url_path_append("/Login/Autenticar") |> 
  httr2::req_url_query(token = Sys.getenv("API_OLHO_VIVO")) |> 
  httr2::req_body_form(x = NULL)

resp_login <- req_login |> 
  httr2::req_verbose() |> 
  httr2::req_perform()

# ok!
resp_login |> 
  httr2::resp_body_string()

req_busca <- req_base |> 
  httr2::req_url_path_append("Posicao") 

resp_busca <- req_busca |> 
  httr2::req_perform()

# mesmo assim nao deu!
# isso acontece porque as chamadas sao independentes.
# https://github.com/r-lib/httr2/issues/223

# adicionando cookies na mao

req_busca <- req_base |> 
  httr2::req_url_path_append("Posicao") |> 
  httr2::req_headers(
    Cookie = resp_login$headers[["Set-Cookie"]]
  )

resp_busca <- req_busca |> 
  httr2::req_perform()

resp_busca |> 
  httr2::resp_body_json()

# base de dados de posicoes (live)

# base desaninhada (live)

# visualizacao! (live)

