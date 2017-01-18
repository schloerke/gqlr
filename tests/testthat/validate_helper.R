source("dog_cat_schema.R")


expect_r6 <- function(query, ..., schema_obj = dog_cat_schema) {
  query %>%
    graphql2obj() %>%
    validate_query(schema_obj) %>%
    R6::is.R6() %>%
    expect_true(...)
}

expect_err <- function(query, ..., schema_obj = dog_cat_schema) {
  expect_error(
    {
      query %>%
        graphql2obj() %>%
        validate_query(schema_obj) %>%
        R6::is.R6()
    },
    ...
  )
}
