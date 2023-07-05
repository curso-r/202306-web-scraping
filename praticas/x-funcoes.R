x <- try(log("a"))
2+2

library(purrr)


# - possibly(): é o nosso amigo de todo dia. Não estamos interessados em entender o erro
# - safely(): bazuka. Conseguimos controlar tudo
# - quietly(): NÃO É TRATAMENTO DE ERRO, lida com warnings e messages

safe_log <- possibly(log, tibble::tibble(erro = "erro"))
safe_log("a")

safe_log <- safely(log, tibble::tibble(erro = "erro"))
safe_log("a")
safe_log(1)

quiet_log <- quietly(log)
quiet_log(-1)
quiet_log("a")


# um uso que eu não gosto
f <- function(x) {
  map(x, log)
}

safe_f <- possibly(f)

safe_f(list(1, 2, 3, "a"))


# melhor uso
f <- function(x) {
  safe_log <- possibly(log, "ERRO!!!")
  map(x, safe_log)
}

safe_f <- f

safe_f(list(1, 2, 3, "a"))




library(parallel)
library(tictoc)
tic()
res <- map(1:4, \(x) Sys.sleep(1))
toc()

tic()
res <- pvec(1:4, \(x) Sys.sleep(1), mc.cores = 4L)
toc()

library(future)
library(furrr)
plan(multisession, workers = 8)

tic()
res <- future_map(1:4, \(x) Sys.sleep(1))
toc()

# paralelo
purrr::map(1:10, \(x) Sys.sleep(1), .progress = TRUE)
furrr::future_map(1:10, \(x) Sys.sleep(1), .progress = TRUE)

## para não precisar do with_progress()
# progressr::handlers(global = TRUE)

library(progressr)
handlers(handler_pbcol(enable_after = 3.0))

progressr::with_progress({

  p <- progressr::progressor(10)

  purrr::map(1:10, \(x) {
    p()
    Sys.sleep(1)
  })

})

progressr::with_progress({

  p <- progressr::progressor(30)

  furrr::future_map(1:30, \(x) {
    p()
    Sys.sleep(1)
  })

})
