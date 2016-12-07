


# str <- function(object, ...) {
#   UseMethod("str")
# }

graphql_string <- function(x, ...) {
  UseMethod("graphql_string", x)
}

validate <- function(x, schema_obj, ...) {
  UseMethod("validate", x)
}

validate.default <- function(x, schema_obj, ...) {
  return(invisible(NULL))
}
