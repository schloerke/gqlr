


# str <- function(object, ...) {
#   UseMethod("str")
# }

# https://github.com/hadley/adv-r/blob/master/S3.Rmd
# If you're implementing more complicated print() methods, it's a better idea to implement format() methods that return a string, and then implement print.class <- function(x, ...) cat(format(x, ...), "\n". This makes for methods that are much easier to compose, because the side-effects are isolated to a single place.

#' @export
format_all <- function(x, ..., prompt = NULL, header = NULL, all_fields = TRUE) {
  format(x, ..., prompt = prompt, header = header, all_fields = all_fields)
}
#' @export
format.AST <- function(x, ..., prompt = NULL, header = NULL, all_fields = FALSE) {
  collapse(
    if (!is.null(header)) collapse(header, "\n", prompt),
    gsub("\n", collapse("\n", prompt), x$.format(..., all_fields = all_fields), fixed = TRUE)
  )
}
#' @export
print.AST <- function(x, ..., prompt = "  | ", header = "<graphql definition>") {
  cat(format(x, ..., prompt = prompt, header = header), "\n", sep = "")
}
#' @export
print_all <- function(x, ..., prompt = "  | ", header = "<graphql definition>") {
  cat(format_all(x, ..., prompt = prompt, header = header), "\n", sep = "")
}

#' @export
as_R6 <- function(x) {
  if (inherits(x, "R6")) {
    class(x) <- "R6"
  }
  x
}
