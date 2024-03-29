# load_all(); testthat::test_file(file.path("tests", "testthat", "test-validation-object.R")); # nolint



expect_validate_err <- function(schema, ..., txt = schema) {
  schema %>%
    gqlr:::ObjectHelpers$new(source = txt, error_list = ErrorList$new(verbose = FALSE)) ->
  oh

  validate_schema(oh = oh)

  testthat::expect_true(oh$error_list$has_any_errors())

  expect_error({
      stop(format(oh$error_list))
    },
    ...
  )
}

test_that("validate schema", {
  oh <- ObjectHelpers$new(dog_cat_schema)
  validate_schema(oh = oh)

  expect_true(oh$error_list$has_no_errors())




  # double field name
  "
  interface BarretInterface {
    A: String
    A: String
  }
  " %>%
    expect_validate_err("3.1.3.1")

  "
  # bad field name
  type Barret {
    __A: String
  }
  " %>%
    expect_validate_err("'__'")

  # incomplete implementation
  "interface BarretInterface {
    A: String
    B: String
  }
  type Barret implements BarretInterface {
    A: String
    C: Float
  }
  " %>%
    expect_validate_err("must implement all fields of interface")

  # different arg implementation
  "
  interface BarretInterface {
    A(arg1: Int): String
  }
  type Barret implements BarretInterface {
    A(arg2: Int): String
  }
  " %>%
    expect_validate_err("must have at least the same argument names")

  # extra arg implementation
  "
  interface BarretInterface {
    A(arg1: Int): String
  }
  type Barret implements BarretInterface {
    A(arg1: Int, arg2: Float!): String
  }
  " %>%
    expect_validate_err("all additional arguments")

  # extra arg implementation
  "
  interface BarretInterface {
    A(arg1: Int): String
  }
  type Barret implements BarretInterface {
    A(arg1: Float): String
  }
  " %>%
    expect_validate_err("must input the same type")


  "
  scalar MyScalar
  type MyObject {
    fieldA: Int
  }
  union MyUnion = MyObject | MyScalar
  schema {
    query: MyObject
  }
  " %>%
    expect_validate_err("may not be member types of a Union")

  "
  type MyObject {
    fieldA: Int
  }
  schema {
    query: MyObject
  }
  " -> schema_txt

  schema <- gqlr_schema(schema_txt)
  my_obj <- schema$get_object("MyObject")
  my_obj$fields <- list()

  schema %>%
    expect_validate_err(txt = schema_txt, "must have at least one field")


})
