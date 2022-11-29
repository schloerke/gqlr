# load_all(); testthat::test_file(file.path("tests", "testthat", "test-z-execute-simple.R")); # nolint

context("execute-query-simple")

source(testthat::test_path("validate_helper.R"))

test_that("arbitrary code", {

  data <- list(
    a = "Apple",
    b = function(...) {
      return("Banana")
    },
    c = "Cookie",
    d = "Donut",
    e = "Egg",
    f = "Fish",
    rando = function(...) {
      return(runif(1))
    },
    pic = function(obj, args, schema, ...) {
      size <- args$size
      if (is.null(size)) {
        size <- 50
      }
      return(str_c("Pic of size: ", size))
    },
    deep = function(...) {
      return(deepData)
    },
    # promise(...) { return(promiseData()) } # nolint
    promise = function(...) {
      return(data)
    }
  )

  deepData <- list(
    a = function(...) {
      return("Already Been Done")
    },
    b = function(...) {
      return("Boring")
    },
    c = function(...) {
      return(list("Contrived", NULL, "Confusing"))
    },
    deeper = function(...) {
      return(list(data, NULL, data))
    }
  )

# # nolint start
# function promiseData() {
#   return new Promise(resolve => {
#     process.nextTick(() => {
#       resolve(data);
#     });
#   });
# }
# # nolint end

  simple_query <- "
  query Example($size: Int) {
    a,
    b,
    x: c
    ...c
    f
    rando
    ...on Data {
      pic(size: $size)
      promise {
        a
      }
    }
    deep {
      a
      b
      c
      deeper {
        a
        b
        rando
      }
    }
  }
  fragment c on Data {
    d
    e
  }
  "

  expected <- list(
    a = "Apple",
    b = "Banana",
    x = "Cookie",
    d = "Donut",
    e = "Egg",
    f = "Fish",
    pic = "Pic of size: 100",
    promise = list(a = "Apple"),
    deep = list(
      a = "Already Been Done",
      b = "Boring",
      c = list("Contrived", NULL, "Confusing"),
      deeper = list(
        list(a = "Apple", b = "Banana"),
        NULL,
        list(a = "Apple", b = "Banana")
      )
    )
  )

  "
  type Data {
    a: String
    b: String
    c: String
    d: String
    e: String
    f: String
    rando: Float
    pic(size: Int): String
    deep: DeepDataType
    promise: Data
  }
  type DeepDataType {
    a: String
    b: String
    c: [String]
  }
  extend type DeepDataType {
    deeper: [Data]
  }
  schema {
    query: Data
  }
  " %>%
    gqlr_schema() ->
  schema

  ans <- execute_request(
    simple_query,
    schema,
    operation_name = "Example",
    variables = list(size = 100),
    initial_value = data
  )

  expect_true(ans$error_list$has_no_errors())
  expect_true(!identical(ans$data$rando, ans$data$deep$deeper[[1]]$rando))
  expect_true(!identical(ans$data$rando, ans$data$deep$deeper[[3]]$rando))


  # remove rando
  query_doc_exact <- gsub(" rando", " ", simple_query)

  ans_exact <- execute_request(
    query_doc_exact,
    schema,
    operation_name = "Example",
    variables = list(size = 100),
    initial_value = data
  )

  expect_true(ans$error_list$has_no_errors())
  expect_equal(ans_exact$data, expected)

})


test_that("args", {

  "
  type MyObject {
    fieldA(argA: Int!): Int
    fieldB(argB: Int! = 42): Int
    fieldC(argC: Int = 42): Int
  }
  schema {
    query: MyObject
  }
  " %>%
    gqlr_schema() ->
  schema

  expected <- list(data = list(fieldC = 3))

  expect_expected <- function(ret, expected_val = expected) {
    ret$as_json() %>%
      as.character() %>%
      expect_equal(as.character(to_json(expected_val)))
  }

  execute_request("
      {
        fieldC(argC: null)
      }
    ",
    schema,
    variables = list(),
    initial_value = list(fieldA = 1, fieldB = 2, fieldC = 3)
  ) %>%
    expect_expected()

  execute_request("
      {
        fieldC(argC: 5)
      }
    ",
    schema,
    variables = list(),
    initial_value = list(fieldA = 1, fieldB = 2, fieldC = 3)
  ) %>%
    expect_expected()

  execute_request("
      query args($argVal: Int) {
        fieldC(argC: $argVal)
      }
    ",
    schema,
    variables = list(argVal = 6),
    initial_value = list(fieldA = 1, fieldB = 2, fieldC = 3)
  ) %>%
    expect_expected()

  execute_request("
      query args($argVal: Int) {
        fieldC(argC: $argVal)
      }
    ",
    schema,
    variables = list(argVal = NULL),
    initial_value = list(fieldA = 1, fieldB = 2, fieldC = 3)
  ) %>%
    expect_expected()

  execute_request("
      query arg($intVal: Int!) {
        fieldA(argA: $intVal)
      }
    ",
    schema,
    variables = list(intVal = "Barret"),
    initial_value = list(fieldA = 1, fieldB = 2, fieldC = 3),
    verbose_errors = FALSE
  ) %>%
    expect_expected(
      list(data = NULL, errors = list(list(
        message = "6.1.2: Coercing Variable Values
Value cannot be coerced according to the input coercion rules
Location: 2:17 to 2:30
Error String: '$intVal: Int!'"
      )))
    )


})


test_that("Scalars", {
  expect_equal(coerce_boolean(TRUE), TRUE)
  expect_equal(coerce_boolean(FALSE), FALSE)
  expect_equal(coerce_boolean("Barret"), NULL)

  expect_equal(coerce_int(5.4), 5)
  expect_equal(coerce_int("5.4"), 5)

  expect_equal(coerce_float(5.4), 5.4)
  expect_equal(coerce_float("5.4"), 5.4)

  expect_equal(coerce_string(5.4), "5.4")
  expect_equal(coerce_string("5.4"), "5.4")

})
