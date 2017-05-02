
result_as_json <- function(result, ...) {

  ret <- list(data = result$data)

  if (result$error_list$has_any_errors()) {
    # nolint start
    # # should be
    # list(
    #   list(
    #     message = "asdf",
    #     locations = list(
    #       line = 1,
    #       column = 1
    #     )
    #   ),
    #   ...
    # )
    # nolint end
    ret$errors <- lapply(result$error_list$errors, function(e) {
      list(message = e)
    })
  }

  ret %>%
    to_json(...)
}
