#' Test Hello
#' @export
test_hello <- function() {
  queryString <- "query FragmentTyping {\n  profiles(handles: [\"zuck\", \"cocacola\"]) {\n    handle\n    ...userFragment\n    ...pageFragment\n  }\n}\n\nfragment userFragment on User {\n  friends {\n    count\n  }\n}\n\nfragment pageFragment on Page {\n  likers {\n    count\n  }\n}"

  result <- .Call("graphqlr_make_json_ast_fn", PACKAGE = "graphqlr", queryString)
  result <- from_json(result)
  return(result)
}

#' @export
test_string <- function() {
  "query FragmentTyping {\n  profiles(handles: [\"zuck\", \"cocacola\"]) {\n    handle\n    ...userFragment\n    ...pageFragment\n  }\n}\n\nfragment userFragment on User {\n  friends {\n    count\n  }\n}\n\nfragment pageFragment on Page {\n  likers {\n    count\n  }\n}"
}

#' Make graphql AST
#'
#' @param queryString string to be directly parsed by libgraphqlparser
#' @export
make_ast <- function(queryString) {
  queryString %>%
    make_json_ast() %>%
    from_json()
}


from_json <- function(...) {
  rjson::fromJSON(...)
}

to_json <- function(...) {
  rjson::toJSON(...)
}
