#' Test Hello
#' @export
test_hello <- function() {
  queryString <- "query FragmentTyping {\n  profiles(handles: [\"zuck\", \"cocacola\"]) {\n    handle\n    ...userFragment\n    ...pageFragment\n  }\n}\n\nfragment userFragment on User {\n  friends {\n    count\n  }\n}\n\nfragment pageFragment on Page {\n  likers {\n    count\n  }\n}"

  result <- .Call("graphqlr_make_json_ast_fn", PACKAGE = "graphqlr", queryString)
  result <- from_json(result)
  return(result)
}

#' @export
# load_all(); test_string() %>% make_ast() -> a
test_string <- function(pos = 0) {
  switch(as.character(pos),
    "1" = "{\n    name\n    relationship {\n      name\n    }\n  }",
    "2" = "fragment userFragment on User {\n  friends {\n    count\n  }\n}\n\nquery FragmentTyping {\n  profiles(handles: [\"zuck\", \"cocacola\"]) {\n    handle\n    ...userFragment\n    ...pageFragment\n  }\n}\n\nfragment pageFragment on Page {\n  likers {\n    count\n  }\n}",
    "4" =   "query HeroNameAndFriendsQuery {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  }",
    "5" = "{\n  firstSearchResult {\n    ... on Person {\n      name\n    }\n    ... on\nPhoto {\n      height\n    }\n  }\n}",
    "6" = "mutation StoryLikeMutation($input: StoryLikeInput) {\n  storyLike(input: $input) {\n    story {\n      likers { count }\n      likeSentence { text }\n    }\n  }\n}",
    "7" =   "query HeroNameAndFriendsQuery {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  } query HeroNameAndFriendsQuery2 {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  }",

    # has error. (expected)
    "8" =   " {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  } query HeroNameAndFriendsQuery2 {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  }",

    "{\n    name\n    relationship {\n      name\n    }\n  }"
  )
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
