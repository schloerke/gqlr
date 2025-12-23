# gqlr 0.1.0

## Breaking changes

* `execute_request()` now requires `operation_name`, `variables`, and
  `initial_value` to be named arguments, as `...` has been added ahead of
  these parameters (#11).

* `server()` now requires `log` and `initial_value` to be named arguments, as
  `...` has been added ahead of these parameters (#11).

* `server()`'s `/` route now redirects to `/graphiql` only when
  `graphiql = TRUE` (#11).

## New features

* `execute_request()` gains a `verbose_errors` argument. When `TRUE`,
  error-like messages are displayed in real time. By default, this is `TRUE`
  when run interactively (#11).

* `server()` now supports [GraphiQL](https://github.com/graphql/graphiql/blob/graphiql%402.2.0/packages/graphiql/README.md),
  an interactive GraphQL IDE. To view the GraphiQL interface, run
  `gqlr::server(MY_SCHEMA, graphiql = TRUE)` and visit
  `http://localhost:8000/graphiql/`. By default, GraphiQL support is only
  enabled when run interactively (#11).

## Bug fixes and minor improvements

* The `pryr` package dependency has been removed, as the package is being
  archived. Required functions (`modify_lang()`, `make_function()`,
  `unenclose()`, `substitute_q()`) have been copied into the package (#16).

* Introspection now correctly returns `subscriptionType` as `NULL` to indicate
  that subscriptions are not supported (#11).

* Mutation execution now correctly uses the mutation operation for validation,
  rather than incorrectly using the query operation (#9).

* The `__typename` meta field is no longer attached to object structures (#11).

# gqlr 0.0.2

* Export `server` function
* Use `plumber` instead of `jug` for `server` function
* Fix R installation bug
* Delay evaluation of R6 class definitions to `.onLoad` call to avoid long compile times and large compiled files

# gqlr 0.0.1

* Initial release
