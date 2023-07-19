u_copom <- "https://www.bcb.gov.br/publicacoes/atascopom/cronologicos"
u_copom_api <- "https://www.bcb.gov.br/api/servico/sitebcb/atascopom/ultimas"
r0 <- httr::GET(u_copom, httr::write_disk("output/copom.html"))

r0 <- httr::GET(
  u_copom_api,
  query = list(
    quantidade = 2000,
    filtro = ""
  ),
  httr::write_disk("output/copom.json", TRUE)
)

tab_conteudo <- r0 |>
  httr::content(simplifyDataFrame = TRUE) |>
  purrr::pluck("conteudo") |>
  tibble::as_tibble() |>
  janitor::clean_names()

dplyr::glimpse(tab_conteudo)

tab_conteudo$link_pagina[1]

url_base <- "https://www.bcb.gov.br/api/servico/sitebcb/atascopom/principal"

# urltools::url_decode("IdentificadorUrl%20eq%20%2721062023%27")

baixar_link_pagina <- function(link_pagina) {
  pag <- basename(link_pagina)
  link <- glue::glue("IdentificadorUrl eq '{pag}'")

  httr::GET(
    url_base,
    query = list(filtro = link),
    httr::write_disk(glue::glue("output/copom_pags/{pag}.json"))
  )
}

baixar_pdf <- function(link_pdf) {
  nm_pdf <- basename(link_pdf)

  httr::GET(
    paste0("https://www.bcb.gov.br", link_pdf),
    httr::write_disk(glue::glue("output/copom_pdf/{nm_pdf}"))
  )
}

fs::dir_create("output/copom_pags")

# baixa as páginas
tab_conteudo |>
  dplyr::filter(!is.na(link_pagina)) |>
  dplyr::distinct(link_pagina) |>
  with(link_pagina) |>
  purrr::walk(baixar_link_pagina, .progress = TRUE)

tab_conteudo |>
  dplyr::filter(!is.na(url)) |>
  with(url) |>
  purrr::walk(baixar_pdf, .progress = TRUE)
