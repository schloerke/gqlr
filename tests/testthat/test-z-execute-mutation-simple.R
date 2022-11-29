# load_all(); testthat::test_file(file.path("tests", "testthat", "test-z-execute-mutation-simple.R")); # nolint




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

# Altered from: https://github.com/schloerke/gqlr/issues/8
test_that("mutation works with names that are not query names", {

  votes <- 3

  "
  type Query {
    votes: Int!
  }

  type Mutation {
    castVote: Boolean!
  }

  schema {
    query: Query
    mutation: Mutation
  }
  " %>%
    gqlr_schema(
      Query = function(...) {
        list(votes = function(...) {
          votes
        })
      },
      Mutation = function(...) {
        list(castVote = function(...) {
          votes <<- 42
          # Return TRUE to indicate that the mutation was successful
          TRUE
        })
      }
    ) ->
  votes_schema

  expect_votes_request <- function(...) {
    expect_request(..., schema = votes_schema)
  }

  "{votes}" %>%
    expect_votes_request('{ "data": { "votes": 3 } }')
  "mutation Cast { castVote }" %>%
    expect_votes_request('{ "data": { "castVote": true } }')
  "{votes}" %>%
    expect_votes_request('{ "data": { "votes": 42 } }')

})
