source("dog_cat_schema.R")


expect_r6 <- function(query, ...) {
  query %>%
    eval_json() %>%
    r6_from_list() %>%
    validate_query(dog_cat_schema) %>%
    R6::is.R6() %>%
    expect_true(...)
}

expect_err <- function(query, ...) {
  expect_error(
    {
      query %>%
        eval_json() %>%
        r6_from_list() %>%
        validate_query(dog_cat_schema) %>%
        R6::is.R6()
    },
    ...
  )
}
