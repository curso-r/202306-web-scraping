
u_dejt <- "https://dejt.jt.jus.br/dejt/f/n/diariocon"


r0_dejt <- httr::GET(u_dejt)
state <- r0_dejt |>
  xml2::read_html() |>
  xml2::xml_find_first("//input[@name='javax.faces.ViewState']") |>
  xml2::xml_attr("value")

b_dejt <-  list(
  `corpo:formulario:dataIni` = "04/07/2023",
  `corpo:formulario:dataFim` = "04/07/2023",
  `corpo:formulario:tipoCaderno` = "",
  `corpo:formulario:tribunal` = "",
  `corpo:formulario:ordenacaoPlc` = "",
  `navDe` = "1",
  `detCorrPlc` = "",
  `tabCorrPlc` = "",
  `detCorrPlcPaginado` = "",
  `exibeEdDocPlc` = "",
  `indExcDetPlc` = "",
  `org.apache.myfaces.trinidad.faces.FORM` = "corpo:formulario",
  `_noJavaScript` = "false",
  `javax.faces.ViewState` = state,
  `source` = "corpo:formulario:botaoAcaoPesquisar"
)

res <- httr::POST(
  u_dejt,
  body = b_dejt,
  encode = "form",
  httr::write_disk("output/dejt.html")
)

pdfs <- res |>
  xml2::read_html() |>
  xml2::xml_find_all("//*[contains(@onclick,'j_id131')]") |>
  xml2::xml_attr("onclick") |>
  stringr::str_extract("corpo:formulario:plcLogicaItens[^']+")

baixar_pdf <- function(pdf_id) {
  b_pdf <- b_dejt
  nome_pdf <- stringr::str_extract(pdf_id, "[0-9]+")
  arquivo <- glue::glue("output/dejt/{nome_pdf}.pdf")
  if (!file.exists(arquivo)) {
    b_pdf[["source"]] <- pdf_id
    httr::POST(
      u_dejt, body = b_pdf, encode = "form",
      httr::write_disk(arquivo, TRUE)
    )
  }
  arquivo
}

walk(pdfs, possibly(baixar_pdf), .progress = TRUE)

