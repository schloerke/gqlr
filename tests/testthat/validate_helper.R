source("dog_cat_schema.R")


expect_r6 <- function(query, ...) {
  query %>%
    graphql2obj() %>%
    validate_query(dog_cat_schema) %>%
    R6::is.R6() %>%
    expect_true(...)
}

expect_err <- function(query, ...) {
  expect_error(
    {
      query %>%
        graphql2obj() %>%
        validate_query(dog_cat_schema) %>%
        R6::is.R6()
    },
    ...
  )
}
