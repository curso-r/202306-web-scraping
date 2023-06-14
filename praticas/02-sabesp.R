
u_base_sabesp <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
endpoint_sabesp <- "2023-06-08"
u_sabesp <- paste0(u_base_sabesp, endpoint_sabesp)

r_sabesp <- httr::GET(u_sabesp)

r_sabesp |>
  httr::content(simplifyDataFrame = TRUE) |>
  purrr::pluck("ReturnObj", "sistemas") |>
  tibble::as_tibble() |>
  janitor::clean_names()

# x <- r_sabesp |>
#   httr::content(simplifyDataFrame = TRUE)
#
# x$ReturnObj$sistemas

pegar_sabesp_dia <- function(dia = Sys.Date()-1) {
  u_base_sabesp <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  u_sabesp <- paste0(u_base_sabesp, dia)
  r_sabesp <- httr::GET(u_sabesp)
  r_sabesp |>
    httr::content(simplifyDataFrame = TRUE) |>
    purrr::pluck("ReturnObj", "sistemas") |>
    tibble::as_tibble() |>
    janitor::clean_names()
}

pegar_sabesp_dia("2022-05-03")
