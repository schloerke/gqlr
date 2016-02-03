


str_c <- function (..., sep = "", collapse = NULL) {
  paste(..., sep = sep, collapse = collapse)
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
