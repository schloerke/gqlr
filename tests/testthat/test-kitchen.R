# testthat::test_file(file.path("tests", "testthat", "test-kitchen.R"))

context("kitchen")

expect_str <- function(x, structure_txt) {
  testthat::expect_equal(
    capture.output(str(x)),
    strsplit(structure_txt, "\n")[[1]]
  )
}

txt_to_obj <- function(txt) {
  suppressWarnings(graphql2obj(txt))
}

expect_format <- function(txt, clean_txt) {
  final_txt <- txt %>% txt_to_obj() %>% format()

  clean_lines <- strsplit(clean_txt, "\n")[[1]]
  final_lines <- strsplit(final_txt, "\n")[[1]]

  expect_equal(clean_lines, final_lines)
}

read_kitchen <- function(file_name) {
  collapse(readLines(file.path("kitchen", file_name)), collapse = "\n")
}

test_that("formatting", {

  schema_txt <- read_kitchen("schema-kitchen-sink.graphql")
  schema_clean_txt <- read_kitchen("schema-kitchen-sink-clean.graphql")

  # can go from text to graphql objects to text
  expect_format(schema_clean_txt, schema_clean_txt)

  # even with comments and different commas sep'ing the fields
  expect_format(schema_txt, schema_clean_txt)


  request_txt <- read_kitchen("request-kitchen-sink.graphql")
  request_clean_txt <- read_kitchen("request-kitchen-sink-clean.graphql")

  # can go from text to graphql objects to text
  expect_format(request_clean_txt, request_clean_txt)

  # even with comments and different commas sep'ing the fields
  expect_format(request_txt, request_clean_txt)

})

test_that("structure", {

  schema_txt <- read_kitchen("schema-kitchen-sink.graphql")
  schema_structure <- read_kitchen('schema-kitchen-sink-str.txt')

  # expect structure output to match
  schema_obj <- txt_to_obj(schema_txt)
  expect_str(schema_obj, schema_structure)


  request_txt <- read_kitchen("request-kitchen-sink.graphql")
  request_structure <- read_kitchen('request-kitchen-sink-str.txt')

  # expect structure output to match
  request_obj <- txt_to_obj(request_txt)
  expect_str(request_obj, request_structure)
})
