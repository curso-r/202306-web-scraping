u_anatel <- "https://anatel.gov.br/biblioteca/asp/resultadoFrame.asp"

q_anatel <- list(
  `modo_busca` = "legislacao",
  `content` = "resultado",
  `iBanner` = "0",
  `iEscondeMenu` = "0",
  `iSomenteLegislacao` = "0",
  `iIdioma` = "0",
  `BuscaSrv` = "1"
)

termo_busca <- "roaming"

b_anatel <- list(
  `leg_campo1` = termo_busca,
  `leg_ordenacao` = "publicacaoDESC",
  `leg_normas` = "12",
  `leg_numero` = "",
  `ano_ass` = "",
  `leg_orgao_origem` = "-1",
  `sel_data_ass` = "0",
  `data_ass_inicio` = "",
  `data_ass_fim` = "",
  `leg_campo5` = "",
  `sel_data_pub` = "0",
  `data_pub_inicio` = "",
  `data_pub_fim` = "",
  `leg_campo6` = "",
  `processo` = "",
  `leg_campo4` = "",
  `leg_autoria` = "",
  `leg_numero_projeto` = "",
  `leg_campo2` = "",
  `leg_bib` = "",
  `submeteu` = "legislacao"
)

r_anatel <- httr::POST(
  u_anatel,
  query = q_anatel,
  body = b_anatel
)

# não rolou
r_anatel |>
  httr::content("text") |>
  cat()

r_anatel <- httr::POST(
  u_anatel,
  query = q_anatel,
  body = b_anatel,
  encode = "form",
  httr::write_disk("output/anatel.html", overwrite = TRUE)
)

# agora foi! :)
r_anatel |>
  httr::content("text") |>
  cat()

## paginação
## TODO: Descobrir como fazer a paginação nesse caso.

lista_itens <- r_anatel |>
  xml2::read_html() |>
  xml2::xml_find_first("//script") |>
  xml2::xml_text() |>
  stringr::str_extract("(?<=vetor_codigos\\[1\\] = \\[)[^\\]]+") |>
  stringr::str_split(",") |>
  purrr::pluck(1)

pagina <- 2
itens_pag <- lista_itens[(((pagina-1)*20)+1):(min(pagina*20, length(lista_itens)))] |>
  paste(collapse = ", ")


u_paginacao <- "https://anatel.gov.br/biblioteca/index.asp"
q_paginacao <- list(
  "modo_busca" = "legislacao",
  "veio_de" = "paginacao",
  "pagina" = glue::glue("|{pagina}"),
  "indice" = "|1",
  "submeteu" = "legislacao",
  "content" = "resultado",
  "vetor_pag" = glue::glue("'|[{pagina}]{itens_pag}'"),
  "Servidor" = "1",
  "iSrvCombo" = "",
  "iBanner" = "0",
  "iEscondeMenu" = "0",
  "iSomenteLegislacao" = "0",
  "iIdioma" = "0",
  "campo1" = "palavra_chave",
  "valor1" = termo_busca,
  "campo8" = "14",
  "valor8" = "12"
)

r_paginacao <- httr::GET(
  u_paginacao,
  query = q_paginacao,
  httr::write_disk("output/pag.html", overwrite = TRUE)
)

## parse da página de resultados

tabela <- xml2::read_html("output/anatel.html", encoding = "UTF-8") |>
  xml2::xml_find_all("//table[@class='max_width' and contains(@style,'border-spacing: 1px')]")

da_anatel_html_table <- tabela |>
  rvest::html_table(header = FALSE)

da_anatel_tidy <- da_anatel_html_table |>
  dplyr::select(1,2) |>
  dplyr::mutate(
    numero = ifelse(stringr::str_detect(X1, "^[0-9]+$"), X1, NA)
  ) |>
  tidyr::fill(numero) |>
  ## retirar os números e valores vazios
  dplyr::filter(
    !stringr::str_detect(X1, "^[0-9]+$"),
    !is.na(X2),
    !X2 %in% c("")
  ) |>
  ## tinha um valor com "Texto Integral" com "I"
  dplyr::mutate(X1 = tolower(X1)) |>
  ## pivota a base
  tidyr::pivot_wider(names_from = X1, values_from = X2) |>
  janitor::clean_names()

## pag

tabela <- xml2::read_html("output/pag.html", encoding = "UTF-8") |>
  xml2::xml_find_first("//table[@class='max_width' and contains(@style,'border-spacing: 1px')]")

da_anatel_html_table <- tabela |>
  rvest::html_table(header = FALSE)

da_anatel_tidy <- da_anatel_html_table |>
  dplyr::select(1,2) |>
  dplyr::mutate(
    numero = ifelse(stringr::str_detect(X1, "^[0-9]+$"), X1, NA)
  ) |>
  tidyr::fill(numero) |>
  ## retirar os números e valores vazios
  dplyr::filter(
    !stringr::str_detect(X1, "^[0-9]+$"),
    !is.na(X2),
    !X2 %in% c("")
  ) |>
  ## tinha um valor com "Texto Integral" com "I"
  dplyr::mutate(X1 = tolower(X1)) |>
  ## pivota a base
  tidyr::pivot_wider(names_from = X1, values_from = X2) |>
  janitor::clean_names()



