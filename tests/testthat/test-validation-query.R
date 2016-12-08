# testthat::test_file(file.path("tests", "testthat", "test-validation-query.R"))



context("validation-query")


source("dog_cat_schema.R")


expect_r6 <- function(query, ...) {

  query %>%
    eval_json() %>%
    r6_from_list() %>%
    validate_query(dog_cat_schema) %>%
    expect_true(...)

}



expect_err <- function(query, ...) {
  expect_error(
    {
      query %>%
        eval_json() %>%
        r6_from_list() %>%
        validate_query(dog_cat_schema)
    },
    ...
  )
}


test_that('5.1.1.1 - Operation Name Uniqueness', {

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
  expect_r6(query)

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
  expect_err("has duplicate return name: getName")

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
  expect_err("has duplicate return name: dogOperation")


  "
  query HeroNameQuery1 {
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
  " %>%
  expect_err("has duplicate return name")


});




test_that('5.1.2.1 - Lone Anonymous Operation', {

  "
  {
    dog {
      name
    }
  }
  " %>%
  expect_r6(query)

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
  expect_err("syntax error")

});




test_that("5.2.1 - Field Selections On Objects, Interfaces, and Union Types", {

  "
  fragment interfaceFieldSelection on Pet {
    name
  }
  " %>%
  expect_r6()

  "
  fragment fieldNotDefined on Dog {
    meowVolume
  }
  " %>%
  expect_err("not all requested names are found")

})




test_that("5.4.1.1 - Fragment Name Uniqueness", {

  "
  {
    dog {
      ...fragmentOne
      ...fragmentTwo
    }
  }
  fragment fragmentOne on Dog {
    name
  }
  fragment fragmentTwo on Dog {
    owner {
      name
    }
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ...fragmentOne
    }
  }
  fragment fragmentOne on Dog {
    name
  }
  fragment fragmentOne on Dog {
    owner {
      name
    }
  }
  " %>%
  expect_err("has duplicate return name")


  })


test_that("5.4.1.2 - Fragment Spread Type Existence", {


  "
  fragment correctType on Dog {
    name
  }

  fragment inlineFragment on Dog {
    ... on Dog {
      name
    }
  }

  fragment inlineFragment2 on Dog {
    ... @include(if: true) {
      name
    }
  }
  " %>%
  expect_r6()


  "
  fragment notOnExistingType on NotInSchema {
    name
  }
  " %>%
  expect_err()

})
