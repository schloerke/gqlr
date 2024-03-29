# load_all(); testthat::test_file(file.path("tests", "testthat", "test-validation-5.1-operations.R")) # nolint






test_that("5.1.1.1 - Operation Name Uniqueness", {

  "
  query getDogName {
    dog {
      name
    }
  }
  query getOwnerName {
    dog {
      owner {
        name
      }
    }
  }
  " %>%
  expect_r6()

  "
  query getName {
    dog {
      name
    }
  }
  query getName {
    dog {
      owner {
        name
      }
    }
  }
  " %>%
  expect_err("has duplicate request name: getName")

  "
  query dogOperation {
    dog {
      name
    }
  }
  mutation dogOperation {
    mutateDog {
      id
    }
  }
  " %>%
  expect_err("has duplicate request name: dogOperation")


})




test_that("5.1.2.1 - Lone Anonymous Operation", {

  "
  {
    dog {
      name
    }
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      name
    }
  }
  query getName {
    dog {
      owner {
        name
      }
    }
  }
  " %>%
  expect_err("has an anonymous and defined definition")



  # Causes parser error
  # missing fragment name
  expect_graphql_error <- function(query, ...) {
    expect_error({
        graphql2obj(query)
      },
      class = "error",
      ...
    )
  }
  "
  query HeroNameQuery1 {
    ...HeroNameFrag
  }
  fragment on Query {
    hero {
      name
    }
  }
  " %>%
  expect_graphql_error("syntax error")

})
