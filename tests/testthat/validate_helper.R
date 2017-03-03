source("dog_cat_schema.R")


expect_r6 <- function(query, ..., schema_obj = dog_cat_schema) {

  vh <- ValidatorHelpers$new(schema_obj, ErrorList$new())

  ans <- query %>%
    graphql2obj() %>%
    validate_query(vh = vh)

  expect_true(vh$error_list$has_no_errors())

  expect_true(R6::is.R6(ans), ...)
}

expect_err <- function(query, ..., schema_obj = dog_cat_schema) {

  vh <- ValidatorHelpers$new(schema_obj, ErrorList$new())

  ans <- query %>%
    graphql2obj() %>%
    validate_query(vh = vh)

  expect_true(vh$error_list$has_any_errors())

  expect_error(
    {
      stop(vh$error_list$present())
    },
    ...
  )
}
