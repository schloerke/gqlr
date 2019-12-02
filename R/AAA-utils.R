

str_trim <- function(x) {
  x <- str_replace(x, "^\\s*", "")
  x <- str_replace(x, "\\s*$", "")
  x
}

str_c <- function(..., sep = "", collapse = NULL) {
  paste(..., sep = sep, collapse = collapse)
}

collapse <- function(..., sep = "", collapse = "") {
  paste(..., sep = sep, collapse = collapse)
}

str_replace <- function(x, val, replacement) {
  gsub(val, replacement, x)
}

str_detect <- function(string, pattern, ...) {
  grepl(pattern, string, ...)
}

ifnull <- function(a, b) {
  if (is.null(a)) {
    b
  } else {
    a
  }
}





pryr_unenclose <- function(f) {
  stopifnot(is.function(f))
  env <- environment(f)
  body <- pryr::modify_lang(body(f), unenclose_a_to_b(env))
  make_function(formals(f), body, parent.env(env))
}

unenclose_a_to_b <- function(env, ls_env = ls(envir = env)) {
  function(x) {
    if (is.name(x)) {
      dep_x <- deparse(x)
      if (dep_x %in% ls_env) {
        return(get(dep_x, envir = env))
      }
    }
    x
  }
}

# lazy eval all definitions to avoid storing all R6 objs in pkg at build time
# message("init queue")
gqlr_env <- environment()
gqlr_env$onload_queue <- list()
for_onload <- function(fn) {
  # message("adding fn to queue")
  gqlr_env$onload_queue <<- c(gqlr_env$onload_queue, fn)
}


for_onload_eval <- function() {
  # message("running onload")
  # lazy eval all definitions to avoid storing all R6 objs in pkg at build time
  lapply(gqlr_env$onload_queue, function(fn) {
    eval(body(fn), envir = gqlr_env)
  })
}
