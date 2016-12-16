


context("validation-arguments")

source("validate_helper.R")

test_that("5.3.1 - Argument Names", {

  "
  {
    dog {
      ...argOnRequiredArg
      ...argOnOptional
    }
  }
  fragment argOnRequiredArg on Dog {
    doesKnowCommand(dogCommand: SIT)
  }
  fragment argOnOptional on Dog {
    isHousetrained(atOtherHomes: true) @include(if: true)
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ...invalidArgName
    }
  }
  fragment invalidArgName on Dog {
    doesKnowCommand(command: CLEAN_UP_HOUSE)
  }
  " %>%
  expect_err("could not find matching arg value")

  # "
  # {
  #   dog {
  #     ...invalidArgName
  #   }
  # }
  # fragment invalidArgName on Dog {
  #   isHousetrained(atOtherHomes: true) @include(unless: false)
  # }
  # " %>%
  # expect_err()


  # order doesn't matter
  "
  {
    arguments {
      ...multipleArgs
      ...multipleArgsReverseOrder
    }
  }
  fragment multipleArgs on Arguments {
    multipleReqs(x: 1, y: 2)
  }
  fragment multipleArgsReverseOrder on Arguments {
    multipleReqs(y: 1, x: 2)
  }
  " %>%
  expect_r6()

})


test_that("5.3.2 - Argument Uniqueness", {

  "
  {
    arguments {
      ...multipleArgs
    }
  }
  fragment multipleArgs on Arguments {
    multipleReqs(x: 1, y: 2, x: 3)
  }
  " %>%
  expect_err("duplicate arguments with same name")

})


test_that("5.3.3.1 - Compatible Values", {

  "
  {
    arguments {
      ...goodBooleanArg
      ...coercedIntIntoFloatArg
    }
  }
  fragment goodBooleanArg on Arguments {
    booleanArgField(booleanArg: true)
  }
  fragment coercedIntIntoFloatArg on Arguments {
    floatArgField(floatArg: 1)
  }
  " %>%
  expect_r6()

  # "
  # {
  #   arguments {
  #     ...stringIntoInt
  #   }
  # }
  # fragment stringIntoInt on Arguments {
  #   intArgField(intArg: \"3\")
  # }
  # " %>%
  # expect_err()



})



test_that("5.3.3.2 - Require Non-Null Arguments", {

  "
  {
    arguments {
      ...goodBooleanArg
      ...goodNonNullArg
      ...goodBooleanArgDefault
    }
  }
  fragment goodBooleanArg on Arguments {
    booleanArgField(booleanArg: true)
  }
  fragment goodNonNullArg on Arguments {
    nonNullBooleanArgField(nonNullBooleanArg: true)
  }
  fragment goodBooleanArgDefault on Arguments {
    booleanArgField
  }
  " %>%
  expect_r6()

  "
  {
    arguments {
      ...missingRequiredArg
    }
  }
  fragment missingRequiredArg on Arguments {
    nonNullBooleanArgField
  }
  " %>%
  expect_err("null or missing argument not allowed")

  # TODO remove when libgraphqlparser is updated in graphql R library
  # "
  # {
  #   arguments {
  #     ...missingRequiredArg
  #   }
  # }
  # fragment missingRequiredArg on Arguments {
  #   notNullBooleanArgField(nonNullBooleanArg: null)
  # }
  # " %>%
  # expect_err("null or missing argument not allowed")



})
