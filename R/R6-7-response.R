
#' @export
result2json <- function(result, ...) {

  ret <- list(data = result$data)

  if (result$error_list$has_any_errors()) {
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
    ret$errors <- lapply(result$error_list$errors, function(e) {
      list(message = e)
    })
  }

  ret %>%
    to_json(...)
}
