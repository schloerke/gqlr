# http://bart6114.github.io/jug/articles/jug.html

# http://localhost:8000
# http://localhost:8000/graphql?query={hero{name,friends{name,id}}}&pretty=TRUE

#' Run basic GraphQL server
#'
#' Run a basic GraphQL server with the jug package.  This server is provided to show basic interaction with GraphQL.  The server will run until the function execution is cancelled.
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
#'   # GET R2-D2 and his friends' names
#'   curl '127.0.0.1:8000/graphql?query=%7Bhero%7Bname%2Cfriends%7Bname%7D%7D%7D&pretty=TRUE'
#'
#'   # POST for R2-D2 and his friends' names
#'   curl --data '{"query":"{hero{name}}"}' '127.0.0.1:8000/graphql' # defaults to parse as JSON
#'   curl --data '{"query":"{hero{name}}"}' '127.0.0.1:8000/graphql' --header "Content-Type:application/json"
#'   curl --data '{hero{name}}' '127.0.0.1:8000/graphql' --header "Content-Type:application/graphql"
#' }
#'
#' @param schema Schema object to use execute requests
#' @param port web port to serve the server from.  Set port to \code{NULL} to not run the jug server and return it.
#' @param log boolean that determines if server logging is done.  Defaults to TRUE
# nocov start
#' @param initial_value default value to use in \code{\link{execute_request}()}
server <- function(schema, port = 8000L, log = TRUE, initial_value = NULL) {

  if (!requireNamespace("jug")) {
    stop("jug must be installed.  install.packages('jug')")
  }

  # Create a new router
  jug_router <- jug::jug()
  if (isTRUE(log)) {
    jug_router <- jug_router %>%
      jug::get(path = NULL, function(req, res, err) {
        print(paste0(
          date(), " - ",
          "GET", " ",
          paste(
            c(
              req$path,
              if (!is.null(req$params$query))
                paste0("query: '", req$params$query, "'"),
              if (!is.null(req$params$variables))
                paste0("variables: '", req$params$variables, "'"),
              if (!is.null(req$params$operationName))
                paste0("operationName: '", req$params$operationName, "'")
            ),
            sep = " - "
          )
        ))

        NULL
      })
  }


  server_execute_query <- function(res, query, variables, operation_name, pretty) {

    if (!is.character(query) || is.null(query)) {
      ans <- list(
        data = NULL,
        errors = list(
          list(
            message = "server(): 'query' parameter must be supplied as a graphql string"
          )
        )
      )
      res$status <- 500L
      res$json(ans)
      return()
    }

    ans <- execute_request(
      query,
      schema,
      variables = variables,
      operation_name = operation_name,
      initial_value = initial_value
    )

    ret <- ans$as_json(pretty = pretty)

    res$content_type("application/json")
    if (!is.null(ans$errors)) {
      res$status <- 500L
    }
    res$body <- ret

    return()
  }



  server <- jug_router %>%

    jug::get(path = "/", function(req, res, err) {
      ans <- format(schema$get_schema())
      res$text(ans)

      # makes it "true" graphql, but it can't be viewed in a browser
      # nolint start
      ## res$content_type("application/graphql")
      ## res$body <- ans
      ## NULL
      # nolint end

    }) %>%

    jug::post(path = "/graphql", function(req, res, err) { # nolint

      if (identical(req$headers$content_type, "application/json")) {
        query <- req$params$query
        variables <- req$params$variables # can be null
        operation_name <- req$params$operationName # can be null
        pretty <- isTRUE(as.logical(req$params$pretty)) # can be null
      } else if (identical(req$headers$content_type, "application/graphql")) {
        query <- req$body
        variables <- list()
        operation_name <- NULL
        pretty <- FALSE
      } else {
        body <- jsonlite::fromJSON(req$body)
        query <- body$query
        variables <- ifnull(body$variables, list())
        operation_name <- body$operationName
        pretty <- isTRUE(as.logical(ifnull(body$pretty, FALSE)))
      }

      server_execute_query(res, query, variables, operation_name, pretty)
    }) %>%

    jug::get(path = "/graphql", function(req, res, err) { # nolint
      query <- req$params$query
      if (is.null(req$params$variables)) {
        variables <- NULL
      } else {
        variables <- jsonlite::fromJSON(req$params$variables)
      }
      operation_name <- req$params$operationName # can be null
      pretty <- isTRUE(as.logical(req$params$pretty)) # can be null

      server_execute_query(res, query, variables, operation_name, pretty)
    }) %>%

    # jug::simple_error_handler_json() %>%
    jug::use(path = NULL, function(req, res, err) {
      res$content_type("application/json")
      if (err$occurred) {
        res$status <- 500L
        errs_string <- paste("server(): ", paste(err$errors, collapse = "\n"))
        if (getOption("jug.verbose"))
          cat("ERROR:\n", errs_string, "\n")
        res$body <- to_json(list(
          data = NULL,
          errors = list(list(message = errs_string))
        ))
      } else {
        res$status <- 404L
        res$body <- to_json(list(
          data = NULL,
          errors = list(
            list(
              message = str_c(
                "server(): route '", req$path, "' not served.",
                "  gqlr::server() only understands '/' and '/graphql'" # nolint
              )
            )
          )
        ))
      }
      NULL
    })

  if (is.null(port)) {
    server %>% jug::serve_it(port = port)
  }

  invisible(server)
}
# nocov end
