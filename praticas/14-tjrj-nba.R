# modo Docker -- avançado
library(RSelenium)
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4445L
)
remDr$open()

remDr$navigate("https://google.com")

remDr$screenshot(display = TRUE)
remDr$close()

# modo normal -- trava muito

drv <- rsDriver(
  browser = "firefox",
  verbose = TRUE,
  chromever = NULL
)

ses <- drv$client

ses$navigate("https://www.google.com")

busca <- ses$findElement(
  "xpath",
  "//*[@name='q']"
)

busca$sendKeysToElement(
  list("selenium é legal?")
)

busca$sendKeysToElement(
  list(RSelenium::selKeys$enter)
)


ses$close()


# exemplo david -----------------------------------------------------------


ses$open()

u_qlik_tjrj <- "https://dados.tjrj.jus.br/single/?appid=08ad01cb-8110-4654-a30b-ede1d1125263&sheet=190c3b4e-3f09-4570-aac2-c2d000064155&theme=tema_tjrj&opt=ctxmenu,currsel&select=Id.%20%C3%93rg%C3%A3o%20Julgador,604"

ses$navigate(u_qlik_tjrj)

item <- ses$findElement("xpath", "//span[@title='Lista de Processos']")
item$clickElement()

pegar_linhas <- function(ses) {
  html <- ses$getPageSource()
  html |>
    purrr::pluck(1) |>
    xml2::read_html() |>
    xml2::xml_find_first("//table[@dir='ltr' and @ng-style]") |>
    rvest::html_table() |>
    janitor::clean_names()
}

lista_final <- list()

tabela <- ses$findElement(
  "xpath",
  "//table[@dir='ltr' and @ng-style]"
)

tabela
tabela$click(buttonId = 2)

lista_final <- list()
lista_final <- c(lista_final, list(pegar_linhas(ses)))

scroll$sendKeysToElement(list(selKeys$down_arrow))

scroll$executeScript(
  "arguments[0].scrollBy(0,1000);",
  list(scroll)
)


# NBA ---------------------------------------------------------------------

u_nba <- "https://www.nba.com/stats/players/traditional?sort=PLAYER_NAME&dir=-1&Season=2021-22&SeasonType=Regular%20Season"
ses$navigate(u_nba)

pegar_linhas <- function(ses) {
  ses$getPageSource() |>
    purrr::pluck(1) |>
    xml2::read_html() |>
    xml2::xml_find_first("//table[contains(@class, 'Crom_table')]") |>
    rvest::html_table() |>
    janitor::clean_names()
}

paginas <- ses$getPageSource() |>
  purrr::pluck(1) |>
  xml2::read_html() |>
  xml2::xml_find_first("//div[contains(@class, 'Crom_cromSettings')]") |>
  xml2::xml_text() |>
  stringr::str_extract("(?<=of )[0-9]+") |>
  as.numeric()


lista_final <- list()
for (pagina in seq_len(paginas)) {
  dropdown <- ses$findElement(
    "xpath",
    "//div[contains(@class,'Pagination_pageDropdown')]"
  )
  dropdown$clickElement()
  element <- ses$findElements(
    "xpath",
    "//div[contains(@class,'Pagination_pageDropdown')]/div/label/div/select/option"
  )
  element[[pagina + 1]]$clickElement()
  Sys.sleep(1)
  lista_final <- c(lista_final, list(pegar_linhas(ses)))
}

dados_final_nba <- lista_final |>
  purrr::list_rbind(names_to = "pag")

dados_final_nba



tabela <- ses$findElement("xpath", "//table[contains(@class, 'Crom_table')]")
