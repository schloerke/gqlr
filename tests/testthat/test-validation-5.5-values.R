# testthat::test_file(file.path("tests", "testthat", "test-validation-5.5-values.R"))

context("validation-5.5-values")


source("validate_helper.R")

test_that("5.5.1 - Input Object Field Uniqueness", {

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
  " ->
  schema_txt


  "
  {
    field(arg: { arg: true })
  }
  " %>%
  expect_r6(schema_obj = schema_txt)

  "
  {
    field(arg: { arg: true, arg: false })
  }
  " %>%
  expect_err("must have unique field names", schema_obj = schema_txt)

})
