# testthat::test_file(file.path("tests", "testthat", "test-validation-query.R"))


context("validation-query")


source("validate_helper.R")


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
  {
    dog {
      ...interfaceFieldSelection
    }
  }
  fragment interfaceFieldSelection on Pet {
    name
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ... on Dog {
        name
      }
      ...interfaceFieldSelection
    }
  }
  fragment interfaceFieldSelection on Pet {
    name
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      ...fieldNotDefined
    }
  }
  fragment fieldNotDefined on Dog {
    meowVolume
  }
  " %>%
  expect_err("not all requested names are found")

})
