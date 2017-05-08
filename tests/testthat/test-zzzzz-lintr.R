
# https://github.com/jimhester/lintr
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Style", {

    (function() {
      Sys.setlocale(locale = "C")
      on.exit({
          Sys.setlocale(locale = "en_US.UTF-8")
      })

      lintr::expect_lint_free(cache = TRUE)
    })()

  })
}
