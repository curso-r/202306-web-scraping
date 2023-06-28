u_cdg <- "https://www.chancedegol.com.br/br22.htm"
r_cdg <- httr::GET(u_cdg)

# httr::content(r_cdg)

# alternativa xml2
da_cdg <- r_cdg |>
  xml2::read_html() |>
  xml2::xml_find_first("//table[@bgcolor='#C0C0C0']") |>
  rvest::html_table(header = TRUE)

# alternativa rvest
da_cdg_rvest <- r_cdg |>
  rvest::read_html() |>
  rvest::html_element(xpath = "//table") |>
  rvest::html_table(header = TRUE)

# arrumar a base

## pegar as cores
cores <- r_cdg |>
  xml2::read_html() |>
  xml2::xml_find_all("//table//font[@color='#FF0000']") |>
  xml2::xml_text()

da_acertos <- da_cdg |>
  janitor::clean_names() |>
  dplyr::mutate(vermelho = cores) |>
  dplyr::mutate(
    dplyr::across(vitoria_do_mandante:vermelho, readr::parse_number),
    prob_maxima = pmax(vitoria_do_mandante, vitoria_do_visitante, empate),
    acertou = prob_maxima == vermelho
  )

da_acertos |>
  dplyr::count(acertou) |>
  dplyr::mutate(prob = formattable::percent(n/sum(n)))

da_acertos |>
  dplyr::filter(vermelho != empate) |>
  dplyr::count(acertou) |>
  dplyr::mutate(prob = formattable::percent(n/sum(n)))



