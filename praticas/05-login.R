u_login <- "http://quotes.toscrape.com/login"

r_login_crfs_token <- httr::GET(u_login)

## Forma ROOTS
r_login_crfs_token |>
  httr::content("text") |>
  stringr::str_extract('csrf_token" value="[^"]+') |>
  stringr::str_remove('csrf_token" value="')

crfs_token <- r_login_crfs_token |>
  httr::content("text") |>
  stringr::str_extract('(?<=csrf_token" value=")[^"]+')

## Forma Nutella (spoiler da próxima aula)
crfs_token <- r_login_crfs_token |>
  xml2::read_html() |>
  xml2::xml_find_all("//input[@name='csrf_token']") |>
  xml2::xml_attr("value")

b_login <- list(
  username = "login",
  password = "cursowebscraping!!",
  csrf_token = crfs_token
)

r_login <- httr::POST(
  u_login, body = b_login,
  httr::write_disk("output/teste_login.html", overwrite = TRUE)
)

httr::content(r_login)
