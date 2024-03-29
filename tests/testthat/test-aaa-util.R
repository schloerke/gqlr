# load_all(); testthat::test_file(file.path("tests", "testthat", "test-aaa-util.R")) # nolint


test_that("chai tests", {
  tested_object <- list(
    a = "b",
    c = "d"
  )

  expect_false(sub_rec(tested_object, list(a = "notB")))


  tested_object <- list(
    a = "b",
    c = "d",
    e = list(
      list(
        foo = "a"
      ),
      list(
        foo = "bar",
        baz = list(
          qux = "quux"
        )
      )
    )
  )

  expect_subset(
    tested_object,
    list(a = "b", e = list(list(foo = "a"), list(foo = "bar")))
  )
  expect_subset(
    tested_object,
    list(e = list(list(foo = "a"), list(foo = "bar", baz = list(qux = "quux"))))
  )
  expect_subset(
    tested_object,
    list(a = "b", c = "d", e = list(list(foo = "a"), list(foo = "bar", baz = list(qux = "quux"))))
  )

  expect_false(sub_rec(
    tested_object,
    list(e = list(list(foo = "a"), list(foo = "bar", baz = list(qux = "notAQuux"))))
  ))

  expect_false(sub_rec(
    tested_object,
    list(e = 5)
  ))

  expect_false(sub_rec(NULL, list(a = 1)))
  expect_subset(list(a = 1), NULL)
  expect_subset(5, 5)
  expect_subset("hi", "hi")

  child <- list()
  parent <- list(children = list(child))
  expect_subset(
    list(a = 1, b = "two", c = parent),
    list(c = parent)
  )

})






test_that("parse_ast()", {

  int_val <- IntValue$new(value = 5)
  bool_val <- BooleanValue$new(value = TRUE)
  float_val <- FloatValue$new(value = 5.0)
  string_val <- StringValue$new(value = "Barret")

  int_lit <- gqlr:::parse_ast("IntValue", gqlr:::coerce_int)
  bool_lit <- gqlr:::parse_ast("BooleanValue", gqlr:::coerce_boolean)
  float_lit <- gqlr:::parse_ast("FloatValue", gqlr:::coerce_float)
  string_lit <- gqlr:::parse_ast("StringValue", gqlr:::coerce_string)

  expect_equal(int_lit(int_val), 5)
  expect_equal(float_lit(float_val), 5.0)
  expect_equal(bool_lit(bool_val), TRUE)
  expect_equal(string_lit(string_val), "Barret")

  expect_equal(int_lit(string_val), NULL)
  expect_equal(bool_lit(string_val), NULL)
  expect_equal(float_lit(string_val), NULL)
  expect_equal(string_lit(int_val), NULL)

})


test_that("format()", {
  dog_r6 <- as_R6(dog_cat_doc$clone(deep = TRUE))
  expect_true(
    str_detect(
      format(dog_r6),
      "^<R6>"
    )
  )


  capture.output(print(dog_cat_doc)) %>%
    str_detect("__typename") %>%
    sum() %>%
    expect_equal(0)

  capture.output(print(dog_cat_doc, all_fields = TRUE)) %>%
    str_detect("__typename") %>%
    sum() %>%
    expect_equal(0)

})


test_that("get_definition()", {

  dog_obj <- gqlr:::get_definition(dog_cat_schema, "Dog")
  expect_equal(format(dog_obj$name), "Dog")

})


test_that("PkgObjsGen()", {

  MyPkgObjs <- PkgObjs$clone()
  MyPkgObjs$add("Barret", "Value")
  expect_true(MyPkgObjs$is_registered("Barret"))
  expect_equal(MyPkgObjs$get_class_obj("Barret"), "Value")
  expect_true(!is.null(MyPkgObjs$names))

})


test_that("default active wrappers", {

  "
  {
    name
  }
  " %>%
    gqlr:::graphql2obj() ->
  query_doc

  expect_error({
      query_doc$definitions[[1]]$operation <- "Barret"
    },
    "not in accepted values"
  )

  "
  type Barret {
    fieldA: Int
    fieldB: [Int]
    fieldC: Barret
    fieldD: NotBarret
  }
  schema {
    query: MyObject
  }
  " %>%
    gqlr:::graphql2obj(parse_schema = TRUE) ->
  doc

  Barret <- doc$definitions[[1]]

  expect_error({
      Barret$fields <- 5
    },
    "Attempting to set ObjectTypeDefinition"
  )
  expect_error({
      Barret$fields[[1]] <- 5
    },
    "Attempting to set ObjectTypeDefinition"
  )
  expect_error({
      Barret$directives <- 5
    },
    "\\|Directive\\|"
  )
  expect_error({
      Barret$directives <- list(5)
    },
    "\\|Directive\\|"
  )

})
