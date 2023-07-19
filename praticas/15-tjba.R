u_tjba <- "http://esaj.tjba.jus.br/cpopg/search.do"

r0 <- httr::GET(u_tjba)

u_captcha <- "http://esaj.tjba.jus.br/cpopg/imagemCaptcha.do"
img_captcha <- httr::GET(
  u_captcha,
  httr::write_disk("output/captcha.png", overwrite = TRUE)
)

# remotes::install_github("decryptr/captcha")

cap <- captcha::read_captcha("output/captcha.png")
plot(cap)

model <- captcha::captcha_load_model("esaj")


vl_captcha <- captcha::decrypt("output/captcha.png", model)

params = list(
  `dadosConsulta.localPesquisa.cdLocal` = "-1",
  `cbPesquisa` = "NUMPROC",
  `dadosConsulta.tipoNuProcesso` = "UNIFICADO",
  `numeroDigitoAnoUnificado` = "0001351-58.2012",
  `foroNumeroUnificado` = "0006",
  `dadosConsulta.valorConsultaNuUnificado` = "0001351-58.2012.8.05.0006",
  `dadosConsulta.valorConsulta` = "",
  `vlCaptcha` = vl_captcha
)


httr::GET(
  u_tjba,
  query = params,
  httr::write_disk("output/tjba.html")
)
