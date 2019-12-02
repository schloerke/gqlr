

.onLoad <- function(...) {

  # message("running onload")
  # lazy eval all definitions to avoid storing all R6 objs in pkg at build time
  lapply(onload_queue, function(fn) {
    eval(body(fn), envir = gqlr_env)
  })
}
