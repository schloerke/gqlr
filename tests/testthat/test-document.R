


context("Document - Names")

check_if_valid <- function(query, expected, ...) {

  query %>%
    make_ast() %>%
    parse_document() ->
    ans

  expect_true(is.list(ans))
}

expect_err <- function(query, ...) {
  expect_error({
    query %>%
      make_ast() %>%
      parse_document()
  }, ...)
}


test_that('Allows for no name query', {
  query <- "{
      hero {
        name
      }
    }
  "
  check_if_valid(query)
});


test_that('Allows multiple name queries', {
  query <- "query HeroNameQuery1 {
      hero {
        name
      }
    }

    query HeroNameQuery2 {
        hero {
          name
        }
      }
  "
  check_if_valid(query)

  query <- "query HeroNameQuery1 {
      ...HeroNameFrag
    }

    query HeroNameQuery2 {
      ...HeroNameFrag
    }

    fragment HeroNameFrag on Query {
      hero {
        name
      }
    }
    fragment HeroNameFrag2 on Query {
      hero {
        name
      }
    }
  "
  check_if_valid(query)
});

test_that('Does not allow a missing name and a given named query', {
  query <- "query {
      hero {
        name
      }
    }

    query HeroNameQuery{
        hero {
          name
        }
      }
  "
  expect_err(query, "must have a name")

  # # Causes parser error
  # query <- "query HeroNameQuery1 {
  #     ...HeroNameFrag
  #   }
  #
  #   query HeroNameQuery2 {
  #     ...HeroNameFrag
  #   }
  #
  #   fragment on Query {
  #     hero {
  #       name
  #     }
  #   }
  #   fragment HeroNameFrag on Query {
  #     hero {
  #       name
  #     }
  #   }
  # "
  # expect_err(query, "must have a name")
});


test_that('Does not allow a duplicated name queries', {
  query <- "query HeroNameQuery {
      hero {
        name
      }
    }

    query HeroNameQuery {
        hero {
          name
        }
      }
  "
  expect_err(query, "must have a unique name")

  query <- "query HeroNameQuery1 {
      ...HeroNameFrag
    }

    query HeroNameQuery2 {
      ...HeroNameFrag
    }

    fragment HeroNameFrag on Query {
      hero {
        name
      }
    }
    fragment HeroNameFrag on Query {
      hero {
        name
      }
    }
  "
  expect_err(query, "must have a unique name")
});
