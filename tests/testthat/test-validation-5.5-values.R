# testthat::test_file(file.path("tests", "testthat", "test-validation-5.5-values.R"))

context("validation-5.5-values")


source("validate_helper.R")

test_that("5.5.1 - Input Object Field Uniqueness", {

  test_schema <- GQLRSchema$new()
  "
  schema {
    query: SearchRoot
  }
  input SingleArgInput {
    arg: Boolean
  }
  type SearchRoot {
    field(arg: SingleArgInput): Int
  }
  " %>%
    graphql2obj() %>%
    magrittr::extract2("definitions") %>%
    lapply(test_schema$add)


  "
  {
    field(arg: { arg: true })
  }
  " %>%
  expect_r6(schema_obj = test_schema)

  "
  {
    field(arg: { arg: true, arg: false })
  }
  " %>%
  expect_err("must have unique field names", schema_obj = test_schema)

})
