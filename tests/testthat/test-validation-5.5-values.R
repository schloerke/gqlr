# load_all(); testthat::test_file(file.path("tests", "testthat", "test-validation-5.5-values.R")); # nolint




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
  expect_r6(schema = schema_txt)

  "
  {
    field(arg: { arg: true, arg: false })
  }
  " %>%
  expect_err("must have unique field names", schema = schema_txt)

})
