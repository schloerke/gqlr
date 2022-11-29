expect_r6 <- function(query, ..., schema = dog_cat_schema) {

  oh <- ObjectHelpers$new(schema, source = query)
  oh$error_list$source <- query
  ans <- validate_document(query, oh = oh)

  testthat::expect_equal(format.ErrorList(oh$error_list), "<ErrorList> No errors")

  testthat::expect_true(R6::is.R6(ans), ...)
}

expect_err <- function(query, ..., schema = dog_cat_schema) {

  oh <- ObjectHelpers$new(schema, source = query, error_list = ErrorList$new(verbose = FALSE))
  ans <- validate_document(query, oh = oh) # nolint

  testthat::expect_true(oh$error_list$has_any_errors())

  testthat::expect_error({
      stop(format.ErrorList(oh$error_list))
    },
    ...
  )
}


expect_request <- function(
  query_txt,
  expected_json,
  variables = list(),
  operation_name = NULL,
  schema
) {
  expected_result <- to_json(from_json(expected_json))

  ans <- execute_request(
    query_txt,
    schema,
    operation_name = operation_name,
    variables = variables
  )

  testthat::expect_true(ans$error_list$has_no_errors())

  ans_json <- ans$as_json()

  ans_txt <- strsplit(ans_json, "\n")[[1]]
  expected_txt <- strsplit(expected_result, "\n")[[1]]

  if (length(ans_txt) != length(expected_txt)) {
    cat("\n\nans: \n")
    cat(ans_txt, sep = "\n")
    cat("\n\nexpected: \n")
    cat(expected_txt, sep = "\n")
    #  browser() # nolint
  }

  testthat::expect_equal(ans_txt, expected_txt)
}



expect_request_err <- function(
  query_txt,
  expected_json,
  variables = list(),
  operation_name = NULL,
  schema
) {
  expected_result <- to_json(from_json(expected_json))

  ans <- execute_request(
    query_txt,
    schema,
    operation_name = operation_name,
    variables = variables,
    verbose_errors = FALSE
  )

  testthat::expect_true(ans$error_list$has_any_errors())

  ans_json <- ans$as_json()

  ans_txt <- strsplit(ans_json, "\n")[[1]]
  expected_txt <- strsplit(expected_result, "\n")[[1]]

  if (length(ans_txt) != length(expected_txt)) {
    cat("\n\nans: \n")
    cat(ans_txt, sep = "\n")
    cat("\n\nexpected: \n")
    cat(expected_txt, sep = "\n")
    #  browser() # nolint
  }

  testthat::expect_equal(ans_txt, expected_txt)
}

















expect_subset <- function(bigger, smaller, verbose = TRUE) {
  ans <- sub_rec(bigger, smaller, verbose = verbose) # nolint
  testthat::expect_true(ans)
}

sub_rec <- function(bigger, smaller, key = NULL, verbose = FALSE) {

  show_error <- function(..., item = NULL, key_val = key) {
    if (verbose) {
      if (missing(item)) {
        cat("\n\nbigger: \n")
        str(bigger, max = 2)
        cat("\nsmaller: \n")
        str(smaller, max = 2)
        cat("\n")
      } else {
        str(item)
      }
      stop(key_val, " - ", ...)
    } else {
      return(FALSE)
    }
  }

  if (identical(bigger, smaller)) {
    return(TRUE)
  }

  if (is.null(bigger)) {
    if (is.null(smaller)) {
      return(TRUE)
    } else {
      return(show_error("subset provided non null value when null expected"))
    }
  }

  if (!is.list(bigger)) {
    if (is.list(smaller)) {
      return(show_error("subset list provided when scalar expected"))
    }
    if (identical(bigger, smaller)) {
      return(TRUE)
    } else {
      return(show_error("non matching scalars"))
    }
  } else {
    # bigger is list
    if (is.null(smaller)) {
      return(TRUE)
    }
    if (!is.list(smaller)) {
      return(show_error("non-list subset provided when list expected"))
    }

    if (!is.list(bigger)) {
      return(show_error("subset list provided to non list"))
    }

    if (!is.null(names(smaller))) {
      if (is.null(names(bigger))) {
        return(show_error("subset list has names where names are not provided"))
      }
      for (name in names(smaller)) {
        item_ans <- sub_rec(bigger[[name]], smaller[[name]], str_c(key, "$", name), verbose)
        if (!item_ans) {
          return(FALSE)
        }
      }
      return(TRUE)

    } else {
      # is array
      if (length(bigger) != length(smaller)) {
        return(
          show_error(
            "subset list (", length(smaller), ")",
            " is not same length as expected list (", length(bigger), ")"
          )
        )
      }

      for (pos in seq_along(smaller)) {
        bigger_item <- bigger[[pos]]
        smaller_item <- smaller[[pos]]
        new_key <- str_c(key, str_c("[[", pos, "]]"))

        item_ans <- sub_rec(
          bigger_item,
          smaller_item,
          new_key,
          verbose = verbose
        )
        if (!item_ans) {
          return(show_error("could not find list item", item = smaller_item, key_val = new_key))
        }
      }
      return(TRUE)
    }

  }

  show_error("this should not be reached")
}
