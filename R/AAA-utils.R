

str_trim <- function(x) {
  x <- str_replace(x, "^\\s*", "")
  x <- str_replace(x, "\\s*$", "")
  x
}

str_c <- function (..., sep = "", collapse = NULL) {
  paste(..., sep = sep, collapse = collapse)
}

collapse <- function(..., collapse = "") {
  str_c(..., collapse = collapse)
}

str_replace <- function(x, val, replacement) {
  gsub(val, replacement, x)
}

str_detect <- function(string, pattern, ...) {
  grepl(pattern, string, ...)
}

stop0 <- function(...) {
  stop(paste0(...))
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
