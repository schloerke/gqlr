# load_all(); testthat::test_file(file.path("tests", "testthat", "test-execute-introspection.R"))


context("execute-introspection")

source("validate_helper.R")

test_that("kitchen introspection", {


  # expected <- list(
  #   data = list(
  #     a = "Apple",
  #     b = "Banana",
  #     x = "Cookie",
  #     d = "Donut",
  #     e = "Egg",
  #     f = "Fish",
  #     pic = "Pic of size: 100",
  #     promise = list(a = "Apple"),
  #     deep = list(
  #       a = "Already Been Done",
  #       b = "Boring",
  #       c = list("Contrived", NULL, "Confusing"),
  #       deeper = list(
  #         list( a = "Apple", b = "Banana" ),
  #         NULL,
  #         list( a = "Apple", b = "Banana" )
  #       )
  #     )
  #   )
  # );

  query <- readLines(file.path("kitchen", "execution-introspection.graphql")) %>% collapse()
  query <- "
  query IntrospectionQuery {
    __schema {
      queryType { name }
      mutationType { name }
      # subscriptionType { name }
    # types {
    #    ...FullType
    # }
    directives {
      name
      description
      # args {
      #   ...InputValue
      # }
      locations
    }
    }
  }
  "

  oh <- ObjectHelpers$new(dog_cat_schema, ErrorList$new())

  query_doc <- query %>%
    graphql2obj() %>%
    validate_query(vh = oh)

  ans <- execute_request(
    query_doc,
    operation_name = "IntrospectionQuery",
    initial_value = list(),
    oh = oh
  )


  warning("update introspection response check")
  expect_true(TRUE)

  # cat("\n\nans:\n")
  # str(ans)

  if (is.null(ans)) {
    cat("\n\n")
    str(oh$error_list)
  }


# expect(
#   await execute(schema, ast, data, null, { size: 100 }, "Example")
# ).to.deep.equal(expected);

})
