source("dog_cat_schema.R")


from_json <- function(...) {
  jsonlite::fromJSON(..., simplifyDataFrame=FALSE, simplifyVector=FALSE)
}

expect_r6 <- function(query, ..., schema_obj = dog_cat_schema) {

  oh <- ObjectHelpers$new(schema_obj, ErrorList$new())

  ans <- query %>%
    graphql2obj() %>%
    validate_query(oh = oh)

  expect_equal(oh$error_list$.format(), "<ErrorList> No errors")

  expect_true(R6::is.R6(ans), ...)
}

expect_err <- function(query, ..., schema_obj = dog_cat_schema) {

  oh <- ObjectHelpers$new(schema_obj, ErrorList$new())

  ans <- query %>%
    graphql2obj() %>%
    validate_query(oh = oh)

  expect_true(oh$error_list$has_any_errors())

  expect_error(
    {
      stop(oh$error_list$.format())
    },
    ...
  )
}

expect_subset <- function(bigger, smaller, verbose = TRUE) {
  ans <- sub_rec(bigger, smaller, verbose = verbose)
  expect_true(ans)
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
        # cat("\n\n")
        # print(name)
        # str(bigger, max = 2)
        # str(smaller, max = 2)
        item_ans <- sub_rec(bigger[[name]], smaller[[name]], str_c(key, "$", name), verbose)
        if (!item_ans) {
          return(FALSE)
        }
      }
      return(TRUE)

    } else {
      # is array
      if (length(bigger) != length(smaller)) {
        return(show_error("subset list (", length(smaller), ") is not same length as expected list (", length(bigger), ")"))
      }

      for (pos in seq_along(smaller)) {
        bigger_item <- bigger[[pos]]
        smaller_item <- smaller[[pos]]
        new_key <- str_c(key, str_c("[[", pos, "]]"))

        # browser()
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
