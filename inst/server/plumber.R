library(plumber)
options(plumber.trailingSlash = TRUE)

server_execute_query <- function(req, res, query, variables, operation_name, pretty) {

  pretty <- isTRUE(as.logical(ifnull(pretty, FALSE)))

  if (!is.character(query) || is.null(query)) {
    stop("'query' parameter must be supplied as a GraphQL string")
  }

  req[["_gqlr"]] <- list(
    query = query,
    variables = variables,
    operation_name = operation_name,
    pretty = pretty
  )

  ans <- execute_request(
    query,
    schema, # nolint
    variables = ifnull(variables, list()),
    operation_name = operation_name,
    initial_value = initial_value # nolint
  )

  ret <- ans$as_json(pretty = pretty)

  if (!is.null(ans$errors)) {
    res$status <- 500L
  }

  ret
}

set_res_json_serializer <- function(res) {
  res$serializer <- function(val, req, res, errorHandler) {
    tryCatch({
      res$setHeader("Content-Type", "application/json")
      res$body <- to_json(val)
      return(res$toResponse())
    }, error = function(e) {
      errorHandler(req, res, e)
    })
  }

  invisible(res)
}



#' @plumber
function(pr) {
  if (isTRUE(log)) {
    log_var <- function(val, name) {
      if (is.null(val)) {
        return(NULL)
      }
      if (is.list(val)) {
        val <- to_json(val, pretty = FALSE)
      }
      paste0(name, ": '", val, "'")
    }
    pr$registerHook("postroute", function(data, req, res) {
      vars <- ifnull(req[["_gqlr"]], list())
      cat(paste0(
        date(), " - ",
        req$REQUEST_METHOD, " ",
        paste(
          c(
            req$PATH_INFO,
            log_var(vars$query, "query"),
            log_var(vars$variables, "variables"),
            log_var(vars$operation_name, "operationName")
          ),
          collapse = " - "
        ),
        "\n"
      ))

      NULL
    })
  }

  pr$set404Handler(function(req, res, err) {
    res$status <- 404
    set_res_json_serializer(res)

    list(
      data = NULL,
      errors = list(
        list(
          message = str_c(
            "server(): route '", req$PATH_INFO, "' not served.",
            "  gqlr::server() only understands '/' and '/graphql'" # nolint
          )
        )
      )
    )
  })
  pr$setErrorHandler(function(req, res, err) {
    set_res_json_serializer(res)
    res$status <- 500L
    errs_string <- paste("server(): ", paste(err$message, collapse = "\n"))
    cat("ERROR:\n", errs_string, "\n")

    list(
      data = NULL,
      errors = list(list(message = errs_string))
    )
  })
  pr
}

#* @get /
## makes it "true" GraphQL, but it can't be viewed in a browser
#* @serializer contentType list(type="application/graphql")
function() {
  format(schema$get_schema())
}

#* @post /graphql
#* @serializer contentType list(type="application/json")
function(req, res) {

  body <- paste0(req$rook.input$read_lines(), collapse = "\n")

  if (identical(req$HEADERS[["content-type"]], "application/graphql")) {
    query <- body
    variables <- list()
    operation_name <- NULL
    pretty <- FALSE

  } else {
    if (!jsonlite::validate(body)) {
      stop("non-json body provided to POST /graphql")
    }
    body <- jsonlite::fromJSON(body)
    query <- body$query
    variables <- body$variables
    operation_name <- body$operationName
    pretty <- body$pretty
  }

  server_execute_query(req, res, query, variables, operation_name, pretty)
}


#* @get /graphql
#* @serializer contentType list(type="application/json")
function(req, res) {
  query <- req$args$query
  variables <- req$args$variables
  if (!is.null(req$args$variables)) {
    variables <- jsonlite::fromJSON(req$args$variables)
  }
  operation_name <- req$args$operationName # can be null
  pretty <- req$args$pretty # can be null

  server_execute_query(req, res, query, variables, operation_name, pretty)
}

# #* @get /graphiql/
# function(req, res) {
#   plumber::include_html(system.file("graphiql/index.html", package = "gqlr"), res)
# }

#* @plumber
function(pr) {
  pr %>%
    pr_static("/graphiql", system.file("graphiql", package = "gqlr"))
}
