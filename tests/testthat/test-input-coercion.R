# testthat::test_file(file.path("tests", "testthat", "test-input-coercion.R"))


context("input-coercion")

source("validate_helper.R")

# type Arguments {
#   multipleReqs(x: Int!, y: Int!): Int!
#   booleanArgField(booleanArg: Boolean): Boolean
#   floatArgField(floatArg: Float): Float
#   intArgField(intArg: Int): Int
#   stringArgField(stringArg: String): String
#   nonNullBooleanArgField(nonNullBooleanArg: Boolean!): Boolean!
#   booleanListArgField(booleanListArg: [Boolean]): [Boolean]
# }
#

test_that("input-coercion - Int", {
  "{ arguments { intArgField(intArg: 5) } }" %>% expect_r6()
  "{ arguments { intArgField(intArg: null) } }" %>% expect_r6()

  "{ arguments { intArgField(intArg: 5.0) } }" %>% expect_err("Expected type ")
  "{ arguments { intArgField(intArg: \"5\") } }" %>% expect_err("Expected type ")
  "{ arguments { intArgField(intArg: true) } }" %>% expect_err("Expected type ")
})


test_that("input-coercion - Float", {
  "{ arguments { floatArgField(floatArg: 5) } }" %>% expect_r6()
  "{ arguments { floatArgField(floatArg: 5.0) } }" %>% expect_r6()
  "{ arguments { floatArgField(floatArg: null) } }" %>% expect_r6()

  "{ arguments { floatArgField(floatArg: true) } }" %>% expect_err("Expected type ")
  "{ arguments { floatArgField(floatArg: \"5.0\") } }" %>% expect_err("Expected type ")
})


test_that("input-coercion - String", {
  "{ arguments { stringArgField(stringArg: \"5\") } }" %>% expect_r6()
  "{ arguments { stringArgField(stringArg: null) } }" %>% expect_r6()

  "{ arguments { stringArgField(stringArg: 5) } }" %>% expect_err("Expected type ")
  "{ arguments { stringArgField(stringArg: 5.0) } }" %>% expect_err("Expected type ")
  "{ arguments { stringArgField(stringArg: true) } }" %>% expect_err("Expected type ")
})

test_that("input-coercion - Boolean", {
  "{ arguments { booleanArgField(booleanArg: true) } }" %>% expect_r6()
  "{ arguments { booleanArgField(booleanArg: null) } }" %>% expect_r6()

  "{ arguments { booleanArgField(booleanArg: \"5\") } }" %>% expect_err("Expected type ")
  "{ arguments { booleanArgField(booleanArg: 5) } }" %>% expect_err("Expected type ")
  "{ arguments { booleanArgField(booleanArg: 5.0) } }" %>% expect_err("Expected type ")
})
