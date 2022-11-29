# Original server implemented using jug
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
#'   \item{\code{'/'}}{GET. Returns a GraphQL formatted schema definition}
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
#'   curl --data '{"query":"query Droid($someId: String!) {droid(id: $someId) {name, friends { name }}}", "variables": {"someId": "2001"}}' '127.0.0.1:8000/graphql'
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
  if (packageVersion("plumber") < "1.2.0") {
    stop("plumber must be version 1.2.0 or greater.  `install.packages('plumber')`")
  }

  env <- new.env(parent = .GlobalEnv)
  env$log <- log
  env$schema <- schema
  env$initial_value <- initial_value

  query_string_filter_only <- getFromNamespace("defaultPlumberFilters", "plumber")["queryString"]

  pr <- plumber::pr(
    file = system.file("server/plumber.R", package = "gqlr"),
    envir = env,
    filters = query_string_filter_only
  )

  if (!is.null(port)) {
    pr$run(port = port)
  }

  pr

}
# nocov end
