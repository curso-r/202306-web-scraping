u_jobs <- "https://realpython.github.io/fake-jobs/"

links <- u_jobs |>
  httr::GET() |>
  xml2::read_html() |>
  xml2::xml_find_all("//a[@class='card-footer-item']") |>
  xml2::xml_attr("href") |>
  # só para não ter tantos links
  stringr::str_subset("software")

# future::plan(future::sequential)

fs::dir_create("output/jobs")

purrr::iwalk(
  links,
  \(x, id) httr::GET(
    x,
    httr::write_disk(glue::glue("output/jobs/{id}.html"))
  )
)

arqs <- fs::dir_ls("output/jobs")

library(purrr)
library(xml2)

x <- arqs[1]
parser <- function(x) {

  box <- x |>
    read_html() |>
    xml_find_first("//div[@class='box']")

  xpaths <- c(
    "./h1", "./h2", "./div/p",
    "./div/p[@id='location']",
    "./div/p[@id='date']"
  )

  xpaths |>
    map(\(xp) xml_find_first(box, xp)) |>
    map(xml_text) |>
    set_names("cargo", "empresa", "descricao", "local", "data") |>
    tibble::as_tibble()

}

parser(arqs[1])
parser(arqs[2])
parser(arqs[3])

map(arqs, possibly(parser, tibble::tibble(erro = "erro"))) |>
  dplyr::bind_rows(.id = "file")

resultados <- map(arqs, parser) |>
  purrr::list_rbind(names_to = "file")
