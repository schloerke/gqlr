#' @include R6z-from-json.R

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

#' @import graphql
graphql2list <- function(txt) {
  # ct <- javascript_context()
  # ct$call("stringify", str) %>%
  graphql::graphql2json(txt) %>%
    from_json() %>%
    clean_json()
}

#' @export
graphql2obj <- function(txt, ...) {
  info_list <- list(...)
  if (length(info_list) > 0) {
    info_names <- names(info_list)
    if (
      is.null(info_names) ||
      length(unique(info_names)) != length(info_list) ||
      any(nchar(info_names) == 0)
    ) {
      stop("graphql2obj() extra arguments must be uniquely named arguments")
    }
  }
  graphql2list(txt) %>%
    r6_from_list(fn_list = info_list)
}
