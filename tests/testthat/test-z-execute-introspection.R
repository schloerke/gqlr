# load_all(); testthat::test_file(file.path("tests", "testthat", "test-z-execute-introspection.R"))


context("execute-introspection")

source("validate_helper.R")

read_intro <- function(file_name) {
  collapse(readLines(file.path("introspection", file_name)), collapse = "\n")
}

compare_ans_and_expected <- function(ans, expected_file_name) {

  expect_true(ans$error_list$has_no_errors())
  expected <- strsplit(read_intro(expected_file_name), "\n")[[1]] # nolint

  ans_txt <- strsplit(to_json(ans$data), "\n")[[1]]
  expect_equal(ans_txt, expected)

  if (is.null(ans)) {
    cat("\n\n")
    str(ans$error_list)
  }

  if (length(ans_txt) != length(expected)) {
    e1 <- tempfile()
    e2 <- tempfile()
    cat(ans_txt, sep = "\n", file = e1)
    cat(expected, sep = "\n", file = e2)
    system(str_c("diff ", e1, " ", e2))

    cat(e1, "\n")
  }
}






test_that("empty introspection", {

  "
  schema {
    query: QueryRoot
  }
  type QueryRoot {
    onlyField: String
  }
  " ->
    schema_doc

  introspection_query <- read_intro("execution-introspection.graphql")

  ans <- execute_request(
    introspection_query,
    schema_doc
  )

  compare_ans_and_expected(ans, "introspection-empty-output.json")
})



test_that("kitchen introspection", {

  introspection_query <- read_intro("execution-introspection.graphql")

  ans <- execute_request(
    introspection_query,
    dog_cat_schema
  )

  compare_ans_and_expected(ans, "introspection-dogcat.json")
})
