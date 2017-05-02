

Result <- R6Class(
  "Result",
  public = list(
    error_list = NULL,
    data = NULL,
    as_json = function(...) {
      result_as_json(self, ...)
    },
    initialize = function(error_list = ErrorList$new()) {
      self$error_list <- error_list
      self$data <- NULL
      invisible(self)
    },
    print = function(...) {
      print(self$as_json(...))
    }
  )
)
format.Result <- function(x, ...) {
  x$as_json(...)
}
