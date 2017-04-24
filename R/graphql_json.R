#' @include R6z-from-json.R

#' @export
to_json <- function(..., pretty = TRUE) {
  jsonlite::toJSON(
    ...,
    pretty = pretty,
    auto_unbox = TRUE,
    null = "null"
  )
}
#' @export
from_json <- function(..., simplifyDataFrame = FALSE, simplifyVector = FALSE) {
  jsonlite::fromJSON(..., simplifyDataFrame = simplifyDataFrame, simplifyVector = simplifyVector)
}

clean_json <- function(obj, ...) {
  UseMethod("clean_json")
}

clean_json.list <- function(obj, ...) {
  ## remove all "loc" variables.  take up space
  # obj$loc <- NULL

  if (!is.null(obj$loc)) {
    obj$loc$kind <- "Location"
    # class(obj$loc) <- "Location"
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

#' @import graphql rjson
graphql2list <- function(txt = test_string()) {
  # ct <- javascript_context()
  # ct$call("stringify", str) %>%
  graphql::graphql2json(txt) %>%
    from_json() %>%
    clean_json()
}

#' @export
graphql2obj <- function(txt = test_string(), ...) {
  graphql2list(txt) %>%
    r6_from_list(...)
}
