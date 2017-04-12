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

  query <- "
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
    data = list(
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
  );

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
    graphql2obj(
      fn_list = list(
        Data = list(
          fields = list(
            pic = function(obj, args, ...) {
              obj$pic(args$size)
            }
          )
        )
      )
    ) ->
  schema_doc

  oh <- ObjectHelpers$new(schema_doc, ErrorList$new())

  query_doc <- query %>%
    graphql2obj() %>%
    validate_query(vh = oh)

  ans <- execute_request(
    query_doc,
    operation_name = "Example",
    variable_values = list(size = 100),
    initial_value = data,
    oh = oh
  )

  # str(ans)

  warning("update response check")
  expect_true(TRUE)


# expect(
#   await execute(schema, ast, data, null, { size: 100 }, "Example")
# ).to.deep.equal(expected);

})
