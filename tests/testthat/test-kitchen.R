# load_all(); testthat::test_file(file.path("tests", "testthat", "test-kitchen.R")); # nolint

context("kitchen")

txt_to_obj <- function(txt, ...) {
  suppressWarnings(graphql2obj(txt, ...))
}

expect_format <- function(txt, clean_txt, parse_schema = FALSE) {
  final_txt <- txt %>% txt_to_obj(parse_schema = parse_schema) %>% format() # nolint

  clean_lines <- strsplit(clean_txt, "\n")[[1]]
  final_lines <- strsplit(final_txt, "\n")[[1]]

  testthat::expect_equal(clean_lines, final_lines)
}

read_kitchen <- function(file_name) {
  collapse(readLines(file.path("kitchen", file_name)), collapse = "\n")
}

test_that("formatting", {

  schema_txt <- read_kitchen("schema-kitchen-sink.graphql")
  schema_clean_txt <- read_kitchen("schema-kitchen-sink-clean.graphql")

  # can go from text to graphql objects to text
  expect_format(schema_clean_txt, schema_clean_txt, parse_schema = TRUE)

  # even with comments and different commas sep'ing the fields
  expect_format(schema_txt, schema_clean_txt, parse_schema = TRUE)


  request_txt <- read_kitchen("request-kitchen-sink.graphql")
  request_clean_txt <- read_kitchen("request-kitchen-sink-clean.graphql")

  # can go from text to graphql objects to text
  expect_format(request_clean_txt, request_clean_txt)

  # even with comments and different commas sep'ing the fields
  expect_format(request_txt, request_clean_txt)

})

test_that("structure", {

  schema <- read_kitchen("schema-kitchen-sink.graphql") %>% txt_to_obj(parse_schema = TRUE)

  # expect structure output to match
  expect_str <- function(s, file, all_fields) {
    tmpfile <- tempfile(fileext = ".txt")
    on.exit({unlink(tmpfile)}, add = TRUE) # nolint
    write(format_str(s, all_fields = all_fields), tmpfile)
    testthat::expect_snapshot_file(tmpfile, name = file, compare = testthat::compare_file_text)
  }
  expect_str(schema, "schema-str.txt", all_fields = FALSE)
  expect_str(schema, "schema-str-all.txt", all_fields = TRUE)


  request_obj <- read_kitchen("request-kitchen-sink.graphql") %>% txt_to_obj()
  expect_str(request_obj, "request-str.txt", all_fields = FALSE)
  expect_str(request_obj, "request-str-all.txt", all_fields = TRUE)
})
