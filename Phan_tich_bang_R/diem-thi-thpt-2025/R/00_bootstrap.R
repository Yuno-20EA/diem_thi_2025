
source_utf8 <- function(path, envir = globalenv()) {
  exprs <- parse(text = readLines(path, encoding = "UTF-8", warn = FALSE),
                 keep.source = FALSE)
  for (e in exprs) eval(e, envir = envir)
  invisible(path)
}

load_modules <- function(dir = here::here("R")) {
  files <- sort(list.files(dir, pattern = "\\.R$", full.names = TRUE))
  files <- files[basename(files) != "00_bootstrap.R"]
  for (f in files) source_utf8(f)
  invisible(files)
}
