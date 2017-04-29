# load_all(); testthat::test_file(file.path("tests", "testthat", "test-execute-simple.R"))


context("execute-simple")

source("validate_helper.R")

test_that("arbitrary code", {

  data = list(
    a = "Apple",
    b = function(...) { return("Banana") },
    c = "Cookie",
    d = "Donut",
    e = "Egg",
    f = "Fish",
    rando = function(...) { return(runif(1))},
    pic = function(obj, args, schema, ...) {
      size <- args$size
      if (is.null(size)) {
        size <- 50
      }
      return(str_c("Pic of size: ", size))
    },
    deep = function(...) { return(deepData) },
    # promise(...) { return(promiseData()) }
    promise = function(...) { return(data) }
  )

  deepData = list(
    a = function(...) { return("Already Been Done"); },
    b = function(...) { return("Boring"); },
    c = function(...) { return(list("Contrived", NULL, "Confusing")) },
    deeper = function(...) { return(list(data, NULL, data)) }
  )

# function promiseData() {
#   return new Promise(resolve => {
#     process.nextTick(() => {
#       resolve(data);
#     });
#   });
# }

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

  expected = list(
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
        list( a = "Apple", b = "Banana" ),
        NULL,
        list( a = "Apple", b = "Banana" )
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
    deeper: [Data]
  }
  schema {
    query: Data
  }
  " %>%
    graphql2obj() ->
  schema_doc

  oh <- ObjectHelpers$new(schema_doc, ErrorList$new())
  query_doc <- simple_query %>%
    graphql2obj() %>%
    validate_query(oh = oh)

  ans <- execute_request(
    query_doc,
    operation_name = "Example",
    variable_values = list(size = 100),
    initial_value = data,
    oh = oh
  )

  # str(ans)

  expect_true(oh$error_list$has_no_errors())
  expect_true(!identical(ans$data$rando, ans$data$deep$deeper[[1]]$rando))
  expect_true(!identical(ans$data$rando, ans$data$deep$deeper[[3]]$rando))




  oh <- ObjectHelpers$new(schema_doc, ErrorList$new())

  # remove rando
  query_doc_exact <- simple_query %>%
    gsub(" rando", " ", .) %>%
    graphql2obj() %>%
    validate_query(oh = oh)

  ans_exact <- execute_request(
    query_doc_exact,
    operation_name = "Example",
    variable_values = list(size = 100),
    initial_value = data,
    oh = oh
  )

  # str(ans_exact)
  expect_true(oh$error_list$has_no_errors())
  expect_equal(ans_exact$data, expected)

})
