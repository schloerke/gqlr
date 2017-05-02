# load_all(); testthat::test_file(file.path("tests", "testthat", "test-input-object-coercion.R")); # nolint


context("input-object-coercion")

source("validate_helper.R")

test_that("small input objects", {

  "
  input ExampleInputObject {
    a: String
    b: Int!
  }
  input ExampleListInputObject {
    a: [Int]
    b: [Int]!
    c: [Int!]
    d: [Int!]!
  }
  type SearchRoot {
    field(arg: ExampleInputObject): Int
    list_field(arg: ExampleListInputObject): Int
  }
  schema {
    query: SearchRoot
  }
  " %>%
    Schema$new() ->
  ts

  "{ field(arg: { a: \"abc\", b: 123 }) }" %>% expect_r6(schema_obj = ts)
  "{ field(arg: {b: 123 }) }" %>% expect_r6(schema_obj = ts)
  "{ field(arg: {a: \"abc\" }) }" %>% expect_err("found missing value", schema_obj = ts)
  "{ field(arg: {a: \"abc\", b: null }) }" %>% expect_err("found null value", schema_obj = ts)

  "{ list_field(arg: { a: [5], b: [5], c: [5], d: [5] }) }" %>% expect_r6(schema_obj = ts)
  "{ list_field(arg: { a: 5, b: 5, c: 5, d: 5 }) }" %>% expect_r6(schema_obj = ts)
  "{ list_field(arg: { a: [], b: [], c: [5], d: [5] }) }" %>% expect_r6(schema_obj = ts)
  "{ list_field(arg: { b: [], d: [5] }) }" %>% expect_r6(schema_obj = ts)
  "{ list_field(arg: { b: [null], d: [5] }) }" %>% expect_r6(schema_obj = ts)
  "{ list_field(arg: { b: [], c: [null], d: [5] }) }" %>%
    expect_err("found null value", schema_obj = ts)
  "{ list_field(arg: { d: [5] }) }" %>% expect_err("found missing value", schema_obj = ts)

})

  # { a: "abc", b: 123 }	null	{ a: "abc", b: 123 }
  # { a: 123, b: "123" }	null	{ a: "123", b: 123 }
  # { a: "abc" }	null	Error: Missing required field b
  # { a: "abc", b: null }	null	Error: b must be non‐null.
  # { a: null, b: 1 }	null	{ a: null, b: 1 }
  # { b: $var }	{ var: 123 }	{ b: 123 }
  # { b: $var }	{}	Error: Missing required field b.
  # { b: $var }	{ var: null }	Error: b must be non‐null.
  # { a: $var, b: 1 }	{ var: null }	{ a: null, b: 1 }
  # { a: $var, b: 1 }	{}	{ b: 1 }
