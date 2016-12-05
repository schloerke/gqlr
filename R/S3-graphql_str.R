


graphql_string.Name = function(x, ...) {
  str_c("`", x$value, "`")
}


graphql_string.Type = function(x, ...) {
  parse_type <- function(obj) {
    switch(obj$.kind,
      "NamedType" = obj$name$value,
      "ListType" = str_c("[", parse_type(obj$type), "]"),
      "NonNullType" = str_c(parse_type(obj$type), "!"),
      stop("type: ", obj$.kind, " not known!")
    )
  }
  # cat("<Name - ", self$value, ">")
  str_c("`", parse_type(x), "`")
}
