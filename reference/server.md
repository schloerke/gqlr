# Run basic GraphQL server with GraphiQL support

Run a basic GraphQL server using plumber. This server is provided to
show basic interaction with GraphQL. The server will run until the
function execution is canceled.

## Usage

``` r
server(
  schema,
  port = 8000L,
  ...,
  graphiql = interactive(),
  log = TRUE,
  initial_value = NULL
)
```

## Arguments

- schema:

  Schema object to use execute requests

- port:

  web port to serve the server from. Set port to `NULL` to not run the
  plumber server and return it.

- ...:

  ignored for paramter expansion

- graphiql:

  logical to determine if the GraphiQL interface should be enabled. By
  default, this route is only available when running the server
  interactively.

- log:

  boolean that determines if server logging is done. Defaults to TRUE

- initial_value:

  default value to use in
  [`execute_request()`](http://schloerke.com/gqlr/reference/execute_request.md)

## Details

To view the GraphiQL user interface, navigate to the URL provided when
the server is started. The default location is
`http://localhost:8000/graphiql/`. By default, this route is only
available when running the server interactively
(`graphiql = rlang::is_interactive()`).

`server()` implements the basic necessities described in
<http://graphql.org/learn/serving-over-http/>. There are four routes
implemented:

- `/` (GET) If run interactively, forwards to `/graphiql` for user
  interaction with the GraphQL server. This route is diabled if
  `graphiql = rlang::is_interactive()` is not `TRUE`.

- `/graphiql/` (GET) Returns a [GraphiQL formatted schema
  definition](https://github.com/graphql/graphiql/blob/graphiql%402.2.0/packages/graphiql/README.md)
  interface to manually interact with the GraphQL server. By default
  this route is disabled if `graphiql = rlang::is_interactive()` is not
  `TRUE`.

- `/graphql` (GET) Executes a query. The parameter `'query'` (which
  contains a GraphQL formatted query string) must be included. Optional
  parameters include: `'variables'` a JSON string containing a
  dictionary of variables (defaults to an empty named list),
  `'operationName'` name of the particular query operation to execute
  (defaults to NULL), and `'pretty'` boolean to determine if the
  response should be compact (FALSE, default) or expanded (TRUE)

- `/graphql` (POST) Executes a query. Must provide Content-Type of
  either 'application/json' or 'application/graphql'.

  - If 'application/json' is provided, a named JSON list containing
    'query', 'operationName' (optional, default = `NULL`), 'variables'
    (optional, default = list()) and 'pretty' (optional, default =
    `TRUE`). The information will used just the same as the
    GET-'/graphql' route.

  - If 'application/graphql' is provided, the POST body will be
    interpreted as the query string. All other possible parameters will
    take on their default value.

Using bash's curl, we can ask the server questions:

     #R
      # load Star Wars schema from 'execute_request' example
      example(gqlr_schema)
      # run server
      server(star_wars_schema, port = 8000)

     #bash
      # GET Schema definition
      curl '127.0.0.1:8000/'

      ## POST for R2-D2 and his friends' names
      # defaults to parse as JSON
      curl --data '{"query":"{hero{name, friends { name }}}", "pretty": true}' '127.0.0.1:8000/graphql'
      # send json header
      curl --data '{"query":"{hero{name, friends { name }}}"}' '127.0.0.1:8000/graphql' --header "Content-Type:application/json"
      # send graphql header
      curl --data '{hero{name, friends { name }}}' '127.0.0.1:8000/graphql' --header "Content-Type:application/graphql"
      # use variables
      curl --data '{"query":"query Droid($someId: String!) {droid(id: $someId) {name, friends { name }}}", "variables": {"someId": "2001"}}' '127.0.0.1:8000/graphql'

      # GET R2-D2 and his friends' names
      curl '127.0.0.1:8000/graphql?query=
      # ... using a variable
      curl '127.0.0.1:8000/graphql?query=query
