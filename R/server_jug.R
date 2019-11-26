# http://bart6114.github.io/jug/articles/jug.html

# http://localhost:8000
# http://localhost:8000/graphql?query={hero{name,friends{name,id}}}&pretty=TRUE

#' Run basic GraphQL server
#'
#' Run a basic GraphQL server using plumber.  This server is provided to show basic interaction with GraphQL.  The server will run until the function execution is canceled.
#'
#' \code{server()} implements the basic necessities described in \url{http://graphql.org/learn/serving-over-http/}.  There are three routes implemented:
#'
#' \describe{
#'   \item{\code{'/'}}{GET. Returns a GraphQL formated schema definition}
#'   \item{\code{'/graphql'}}{GET. Executes a query.  The parameter \code{'query'} (which contains a GraphQL formatted query string) must be included.  Optional parameters include: \code{'variables'} a JSON string containing a dictionary of variables (defaults to an empty named list), \code{'operationName'} name of the particular query operation to execute (defaults to NULL), and \code{'pretty'} boolean to determine if the response should be compact (FALSE, default) or expanded (TRUE)}
#'   \item{\code{'/graphql'}}{POST. Executes a query.  Must provide Content-Type of either 'application/json' or 'application/graphql'.
#'
#' If 'application/json' is provided, a named JSON list containing 'query', 'operationName' (optional, default = \code{NULL}), 'variables' (optional, default = list()) and 'pretty' (optional, default = \code{TRUE}).  The information will used just the same as the GET-'/graphql' route.
#'
#' If 'application/graphql' is provided, the POST body will be interpreted as the query string.  All other possible parameters will take on their default value.
#' }
#' }
#'
#' Using bash's curl, we can ask the server questions:
#' \preformatted{ #R
#'   # load Star Wars schema from 'execute_request' example
#'   example(gqlr_schema)
#'   # run server
#'   server(star_wars_schema, port = 8000)
#' }
#'
#' \preformatted{ #bash
#'   # GET Schema definition
#'   curl '127.0.0.1:8000/'
#'
#'   ## POST for R2-D2 and his friends' names
#'   # defaults to parse as JSON
#'   curl --data '{"query":"{hero{name, friends { name }}}", "pretty": true}' '127.0.0.1:8000/graphql'
#'   # send json header
#'   curl --data '{"query":"{hero{name, friends { name }}}"}' '127.0.0.1:8000/graphql' --header "Content-Type:application/json"
#'   # send graphql header
#'   curl --data '{hero{name, friends { name }}}' '127.0.0.1:8000/graphql' --header "Content-Type:application/graphql"
#'   # use variables
#'   curl --data '{"query":"query Droid($someId: String!) {droid(id: $someId){name, friends { name }}}", "variables": {"someId": "2001"}}' '127.0.0.1:8000/graphql'
#'
#'   # GET R2-D2 and his friends' names
#'   curl '127.0.0.1:8000/graphql?query=%7Bhero%7Bname%2Cfriends%7Bname%7D%7D%7D&pretty=TRUE'
#'   # ... using a variable
#'   curl '127.0.0.1:8000/graphql?query=query%20Droid(%24someId%3A%20String!)%20%7Bdroid(id%3A%20%24someId)%7Bname%2C%20friends%20%7B%20name%20%7D%7D%7D&variables=%7B%22someId%22%3A%222001%22%7D'
#'
#' }
#'
#' @param schema Schema object to use execute requests
#' @param port web port to serve the server from.  Set port to \code{NULL} to not run the plumber server and return it.
#' @param log boolean that determines if server logging is done.  Defaults to TRUE
# nocov start
#' @param initial_value default value to use in \code{\link{execute_request}()}
#' @export
server <- function(schema, port = 8000L, log = TRUE, initial_value = NULL) {

  if (!requireNamespace("plumber")) {
    stop("plumber must be installed.  `install.packages('plumber')`")
  }

  # Create a new router
  pr <- plumber::plumber$new()
  if (isTRUE(log)) {
    log_var <- function(val, name) {
      if (is.null(val)) return(NULL)
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
      schema,
      variables = ifnull(variables, list()),
      operation_name = operation_name,
      initial_value = initial_value
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

  pr$handle(
    "GET", "/",
    ## makes it "true" GraphQL, but it can't be viewed in a browser
    # serializer = plumber::serializer_content_type("application/graphql"),
    serializer = plumber::serializer_content_type("text/plain"),
    function() {
      format(schema$get_schema())
    }
  )

  pr$handle(
    "POST", "/graphql",
    # must preempt on postBody as graphql code triggers at json, but fails to parse.
    preempt = "postBody",
    serializer = plumber::serializer_content_type("application/json"),
    function(req, res) {

      body <- paste0(req$rook.input$read_lines(), collapse = "\n")

      if (identical(req$HEADERS[['content-type']], "application/graphql")) {
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
  )

  pr$handle(
    "GET", "/graphql",
    serializer = plumber::serializer_content_type("application/json"),
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
  )

  if (!is.null(port)) {
    pr$run(port = port)
  }

  pr
}
# nocov end
