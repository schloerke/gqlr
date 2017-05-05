
# https://github.com/jimhester/lintr
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Style", {
    suppressWarnings(lintr::expect_lint_free(cache = TRUE))
  })
}
