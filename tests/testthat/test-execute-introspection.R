# load_all(); testthat::test_file(file.path("tests", "testthat", "test-execute-introspection.R"))


context("execute-introspection")

source("validate_helper.R")

read_kitchen <- function(file_name) {
  collapse(readLines(file.path("kitchen", file_name)), collapse = "\n")
}

test_that("empty introspection", {

  "
  schema {
    query: QueryRoot
  }
  type QueryRoot {
    onlyField: String
  }
  " %>%
    ObjectHelpers$new() ->
  oh

  introspection_query <-
    read_kitchen("execution-introspection.graphql") %>%
    graphql2obj() %>%
    validate_query(vh = oh)

  ans <- execute_request(
    introspection_query,
    operation_name = "IntrospectionQuery",
    initial_value = list(),
    oh = oh
  )

  warning("update introspection response check")
  expect_true(TRUE)

  cat("\n\nans:\n")
  str(ans)

  if (is.null(ans)) {
    cat("\n\n")
    str(oh$error_list)
  }

})





test_that("kitchen introspection", {


  oh <- ObjectHelpers$new(dog_cat_schema)

  introspection_query <-
    read_kitchen("execution-introspection.graphql") %>%
    graphql2obj() %>%
    validate_query(vh = oh)

  ans <- execute_request(
    introspection_query,
    operation_name = "IntrospectionQuery",
    initial_value = list(),
    oh = oh
  )

  warning("update introspection response check")
  expect_true(TRUE)

  cat("\n\nans:\n")
  str(ans)

  if (is.null(ans)) {
    cat("\n\n")
    str(oh$error_list)
  }


# expect(
#   await execute(schema, ast, data, null, { size: 100 }, "Example")
# ).to.deep.equal(expected);

})
