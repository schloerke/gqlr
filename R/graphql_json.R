#' @include R6z-from-json.R
#' @include R6-Schema.R

#' @import jsonlite
to_json <- function(..., pretty = TRUE) {
  jsonlite::toJSON(
    ...,
    pretty = pretty,
    auto_unbox = TRUE,
    null = "null"
  )
}
from_json <- function(..., simplifyDataFrame = FALSE, simplifyVector = FALSE) {
  jsonlite::fromJSON(..., simplifyDataFrame = simplifyDataFrame, simplifyVector = simplifyVector)
}

clean_json <- function(obj, ...) {
  UseMethod("clean_json")
}

clean_json.list <- function(obj, ...) {
  if (!is.null(obj$loc)) {
    obj$loc$kind <- "Location"
    class(obj$loc) <- "Location"

    obj$loc$start$kind <- "Position"
    obj$loc$end$kind <- "Position"
    class(obj$loc$start) <- "Position"
    class(obj$loc$end) <- "Position"
    obj$loc$start$line <- as.numeric(obj$loc$start$line)
    obj$loc$start$column <- as.numeric(obj$loc$start$column)
    obj$loc$end$line <- as.numeric(obj$loc$end$line)
    obj$loc$end$column <- as.numeric(obj$loc$end$column)
  }
  kind <- obj$kind
  ret <- lapply(obj, function(x) clean_json(x))
  if (! is.null(kind)) {
    class(ret) <- kind
  }
  ret
}
clean_json.default <- function(obj, ...) {
  obj
}



is_named_list <- function(obj, err) {
  if (length(obj) > 0) {
    obj_names <- names(obj)
    if (
      is.null(obj_names) ||
      length(unique(obj_names)) != length(obj) ||
      any(nchar(obj_names) == 0)
    ) {
      stop(err)
    }
  }
}

#' @import graphql
graphql2obj <- function(txt) {
  graphql::graphql2json(txt) %>%
    from_json() %>%
    clean_json() %>%
    r6_from_list()
}
