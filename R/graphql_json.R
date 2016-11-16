

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
  ret <- lapply(obj, clean_json)
  if (! is.null(kind)) {
    class(ret) <- kind
  }
  ret
}
clean_json.default <- function(obj, ...) {
  obj
}

eval_json <- function(str = test_string()) {
  # ct <- javascript_context()
  # ct$call("stringify", str) %>%
  graphql::graphql2json(str) %>%
    rjson::fromJSON() %>%
    clean_json()
}
