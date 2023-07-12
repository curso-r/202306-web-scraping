

# intro pjs ---------------------------------------------------------------

library(webdriver)

# webdriver::install_phantomjs()
# webdriver:::phantom_paths()

pjs <- run_phantomjs()

ses <- Session$new(port = pjs$port)

ses$go("https://google.com")

ses$takeScreenshot()

busca <- ses$findElement(
  xpath = "//input[@name='q']"
)

class(ses)
class(busca)

busca$click()

busca$sendKeys("por que o phantomjs foi descontinuado?")
busca$sendKeys(key$enter)



# pesqele -----------------------------------------------------------------

u_pesqele <- "https://rseis.shinyapps.io/pesqEle/"

# o que acontece se tentarmos acessar o site com httr?

# httr::GET(u_pesqele, httr::write_disk("output/pesqele.html"))

ses$go(u_pesqele)
Sys.sleep(2)


caixas <- ses$findElements(xpath = "//div[contains(@class,'info-box-content')]")

caixas[[1]]$getText()
dados_caixas <- caixas |>
  purrr::map_chr(\(x) x$getText()) |>
  stringr::str_split("\n") |>
  purrr::map(tibble::as_tibble) |>
  purrr::list_rbind(names_to = "id") |>
  dplyr::group_by(id) |>
  dplyr::mutate(name = c("name", "value")) |>
  tidyr::pivot_wider() |>
  dplyr::ungroup()

ses$getSource()

radio <- ses$findElement(
  # xpath = '//*[@id="abrangencia"]/div/div[3]/label/input',
  xpath = "//div[@id='abrangencia']//input[@type='radio' and @value='nacionais']"
)

radio$click()


ses$takeScreenshot()

caixas <- ses$findElements(xpath = "//div[contains(@class,'info-box-content')]")

caixas[[1]]$getText()
dados_caixas <- caixas |>
  purrr::map_chr(\(x) x$getText()) |>
  stringr::str_split("\n") |>
  purrr::map(tibble::as_tibble) |>
  purrr::list_rbind(names_to = "id") |>
  dplyr::group_by(id) |>
  dplyr::mutate(name = c("name", "value")) |>
  tidyr::pivot_wider() |>
  dplyr::ungroup()

?Session
# sempre bom matar o webdriver/selenium após uso
ses$delete()
pjs$process$kill()
