


# str <- function(object, ...) {
#   UseMethod("str")
# }

# https://github.com/hadley/adv-r/blob/master/S3.Rmd
# If you're implementing more complicated print() methods, it's a better idea to implement format() methods that return a string, and then implement print.class <- function(x, ...) cat(format(x, ...), "\n". This makes for methods that are much easier to compose, because the side-effects are isolated to a single place.

raw_format <- function(x, ..., prompt = NULL, header = NULL) {
  format(x, ..., prompt = prompt, header = header)
}
format.AST <- function(x, ..., prompt = "| ", header = "<graphql definition>") {
  collapse(
    if (!is.null(header)) collapse(header, "\n", prompt),
    gsub("\n", collapse("\n", prompt), x$.format(), fixed = TRUE)
  )
}
print.AST <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
}

validate <- function(x, schema_obj, ...) {
  UseMethod("validate", x)
}

validate.default <- function(x, schema_obj, ...) {
  return(invisible(NULL))
}
