

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
