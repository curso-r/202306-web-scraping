library(httr)

api_key <- Sys.getenv("OPENAI_API_KEY")

u_base <- "https://api.openai.com/v1"
endpoint <- "/chat/completions"
u_gpt <- paste0(u_base, endpoint)

# body da requisição
b_gpt <- list(
  model = "gpt-3.5-turbo",
  temperature = 0.5,
  messages = list(
    list(
      role = "user",
      content = "Gere um código ggplot2 válido."
    )
  )
)
# TODO: como passar em texto?
b_gpt_json <- jsonlite::toJSON(b_gpt)

h_gpt <- httr::add_headers(
  Authorization = paste("Bearer", api_key)
)

r_gpt <- POST(
  u_gpt,
  body = b_gpt,
  encode = "json",
  h_gpt
)

httr::content(r_gpt, "text") |> cat()

resp <- httr::content(r_gpt)
resp$choices[[1]]$message$content |>
  cat()



library(ggplot2)

# Crie um conjunto de dados de exemplo
dados <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(2, 4, 6, 8, 10)
)

# Crie um gráfico de dispersão básico
ggplot(dados, aes(x, y)) +
  geom_point()

