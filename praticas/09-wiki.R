

u_wiki <- "https://en.wikipedia.org/wiki/R_language"
r_wiki <- httr::GET(u_wiki)

links <- r_wiki |>
  xml2::read_html() |>
  xml2::xml_find_all("//table[@class='infobox vevent']//a")

urls <- links |>
  xml2::xml_attr("href")

urls <- paste0("https://en.wikipedia.org", urls)

# uso hipster
links |>
  xml2::xml_attr("href") |>
  paste0("https://en.wikipedia.org/", ... = _)

fs::dir_create("output/wiki")

paths <- paste0("output/wiki/", seq_along(links), ".html")

purrr::walk2(
  urls, paths,
  \(url, path) httr::GET(url, httr::write_disk(path, TRUE))
)

# purrr::map(1:10, \(x) x+1)
# purrr::walk(1:10, \(x) x+1)

## tratando erros

library(purrr)
library(httr)
walk2(
  urls, paths,
  \(url, path) possibly(GET)(url, write_disk(path, TRUE))
)

safe_get <- possibly(GET)
walk2(
  urls, paths,
  \(url, path) safe_get(url, write_disk(path, TRUE))
)

walk2(
  urls, paths,
  \(url, path) safe_get(url, write_disk(path, TRUE)),
  .progress = TRUE
)

library(future)
plan(multisession, workers = 4)

safe_get <- function(x, y, prog = NULL) {
  if (!is.null(prog)) prog()
  possibly(GET)(x, write_disk(y, TRUE))
}

progressr::with_progress({
  p <- progressr::progressor(length(urls))
  furrr::future_walk2(urls, paths, safe_get, prog = p)
})


