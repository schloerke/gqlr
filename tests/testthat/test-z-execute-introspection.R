# load_all(); testthat::test_file(file.path("tests", "testthat", "test-z-execute-introspection.R")); # nolint


compare_ans_and_expected <- function(ans, name) {

  testthat::expect_true(ans$error_list$has_no_errors())
  tmpfile <- tempfile(fileext = ".json")
  on.exit(
    {
      unlink(tmpfile)
    },
    add = TRUE
  )
  write(to_json(ans$data), tmpfile)
  testthat::expect_snapshot_file(tmpfile, cran = TRUE, name = name, compare = testthat::compare_file_text)
  # if (length(ans_txt) != length(expected)) {
  #   e1 <- tempfile()
  #   e2 <- tempfile()
  #   cat(ans_txt, sep = "\n", file = e1)
  #   cat(expected, sep = "\n", file = e2)
  #   system(str_c("diff ", e1, " ", e2))

  #   cat(e1, "\n")
  # }
}


empty_schema <- "
  schema {
    query: QueryRoot
  }
  type QueryRoot {
    onlyField: String
  }
  "

for (info in list(
  list(name = "empty", schema = empty_schema),
  list(name = "dog_cat", schema = dog_cat_schema),
  list(name = "star_wars", schema = star_wars_schema)
)) {
  test_that(paste0(info$name, " introspection"), {

    introspection_query <- paste0(
      readLines(testthat::test_path(file.path("introspection", "execution-introspection.graphql"))),
      collapse = "\n"
    )

    ans <- execute_request(
      introspection_query,
      info$schema
    )

    compare_ans_and_expected(ans, paste0("introspection-", info$name, ".json"))
  })
}
