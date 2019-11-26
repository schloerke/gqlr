# load_all(); testthat::test_file(file.path("tests", "testthat", "test-z-execute-mutation-simple.R")); # nolint


context("execute-mutation-simple")

source(testthat::test_path("validate_helper.R"))

test_that("small counter", {

  count_total <- 0
  "
  type Counter {
    value: Int
  }
  type AddCounter {
    value: Int
  }
  schema {
    query: Counter
    mutation: AddCounter
  }
  " %>%
    gqlr_schema(
      Counter = list(
        resolve = function(...) {
          list(value = count_total)
        }
      ),
      AddCounter = list(
        resolve = function(...) {
          list(
            value = function(z1, z2, schema) {
              count_total <<- count_total + 1
              count_total
            }
          )
        }
      )
    ) ->
  mutation_schema_doc


  do_query <- function(i) {
    ans <- execute_request(
      "{
        value
      }",
      mutation_schema_doc
    )
    expect_true(ans$error_list$has_no_errors())
    expect_equal(ans$data$value, i)
    expect_equal(format(ans, pretty = FALSE), str_c("{\"data\":{\"value\":", i, "}}"))
  }

  do_mutation <- function(i) {
    ans <- execute_request(
      "mutation add_value{
        value
      }",
      mutation_schema_doc
    )
    expect_true(ans$error_list$has_no_errors())
    expect_equal(ans$data$value, i)
    expect_output(print(ans, pretty = FALSE), as.character(i))
  }

  for (i in 0:10) {
    do_query(i)
    do_mutation(i + 1)
  }


})
