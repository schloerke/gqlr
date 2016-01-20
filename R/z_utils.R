


str_replace <- function(x, val, replacement) {
  gsub(val, replacement, x)
}


stop0 <- function(...) {
  stop(paste0(...))
}
