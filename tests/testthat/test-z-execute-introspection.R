# load_all(); testthat::test_file(file.path("tests", "testthat", "test-execute-introspection.R"))


context("execute-introspection")

source("validate_helper.R")

read_intro <- function(file_name) {
  collapse(readLines(file.path("introspection", file_name)), collapse = "\n")
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
    read_intro("execution-introspection.graphql") %>%
    graphql2obj() %>%
    validate_query(oh = oh)

  ans <- execute_request(
    introspection_query,
    operation_name = "IntrospectionQuery",
    initial_value = list(),
    oh = oh
  )

  ans_subset <- read_intro("introspection-empty-output.json") %>% from_json()
  expect_subset(ans$data, ans_subset)

  if (is.null(ans)) {
    cat("\n\n")
    str(oh$error_list)
  }

})





test_that("kitchen introspection", {


  oh <- ObjectHelpers$new(dog_cat_schema)

  introspection_query <-
    read_intro("execution-introspection.graphql") %>%
    graphql2obj() %>%
    validate_query(oh = oh)

  ans <- execute_request(
    introspection_query,
    operation_name = "IntrospectionQuery",
    initial_value = list(),
    oh = oh
  )

  # cat("\n\nans:\n")
  # str(ans)

  ans_subset <- read_intro("introspection-dogcat.json") %>% from_json()
  expect_subset(ans$data, ans_subset)

  if (is.null(ans)) {
    cat("\n\n")
    str(oh$error_list)
  }
})
