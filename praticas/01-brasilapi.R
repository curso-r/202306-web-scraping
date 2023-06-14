library(httr)
library(httr2)

# cep ---------------------------------------------------------------------

u_base <- "https://brasilapi.com.br/api"
endpoint_cep <- "/cep/v2/"
cep <- "35501410"

u_cep <- paste0(u_base, endpoint_cep, cep)

r_cep <- GET(u_cep)

# vamos entender diferentes formas de acessar os resultados

content(r_cep)
content(r_cep, as = "parsed")
content(r_cep, as = "text")

content(r_cep, as = "text") |> cat()

content(r_cep, as = "text") |>
  jsonlite::fromJSON(simplifyDataFrame = TRUE)

content(r_cep, as = "raw")

# e o httr2? Como faríamos??

req <- u_cep |>
  request()

req <- u_base |>
  request() |>
  req_url_path_append(endpoint_cep) |>
  req_url_path_append(cep)

resp <- req |>
  req_perform()

resp |>
  resp_body_json()

resp |>
  resp_body_string()

resp |>
  resp_body_raw()


# FIPE --------------------------------------------------------------------

endpoint_fipe <- "/fipe/marcas/v1/carros"
u_fipe <- paste0(u_base, endpoint_fipe)

r_fipe <- GET(
  u_fipe,
  write_disk("output/marcas.json", overwrite = TRUE)
)

content(r_fipe, simplifyDataFrame = TRUE) |>
  tibble::as_tibble()

jsonlite::read_json("output/marcas.json", simplifyDataFrame = TRUE)

endpoint_tabelas <- "/fipe/tabelas/v1"
u_fipe_tabelas <- paste0(u_base, endpoint_tabelas)

r_fipe_tabelas <- GET(
  u_fipe_tabelas
)

da_fipe_tabelas <- r_fipe_tabelas |>
  content(simplifyDataFrame = TRUE) |>
  tibble::as_tibble()

carro <- "004530-6"

endpoint_preco <- "/fipe/preco/v1/"
u_fipe_preco <- paste0(u_base, endpoint_preco, carro)
r_fipe_preco <- GET(u_fipe_preco)

r_fipe_preco |>
  content(simplifyDataFrame = TRUE) |>
  tibble::as_tibble()

# como estava em fevereiro/2023?
endpoint_preco <- "/fipe/preco/v1/"
u_fipe_preco <- paste0(u_base, endpoint_preco, carro)

q_tabela <- list(tabela_referencia = 285)

r_fipe_preco <- GET(u_fipe_preco, query = q_tabela)

r_fipe_preco |>
  content(simplifyDataFrame = TRUE) |>
  tibble::as_tibble()

r_fipe_preco$request

# httr2

req <- u_base |>
  request() |>
  req_url_path_append(endpoint_preco) |>
  req_url_path_append(carro) |>
  req_url_query(tabela_referencia = 285)

resp <- req |>
  req_perform()

resp |>
  resp_body_json(simplifyDataFrame = TRUE)
