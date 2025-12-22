# Changelog

## gqlr (development version)

### Breaking changes

- `...` has been added into
  [`server()`](http://schloerke.com/gqlr/reference/server.md) ahead of
  `log=` and `initial_value=`. These two paramters must now be named.
  ([\#11](https://github.com/schloerke/gqlr/issues/11))
- `...` has been added into
  [`execute_request()`](http://schloerke.com/gqlr/reference/execute_request.md)
  ahead of `operation_name=`, `variables=`, and `initialial_value=`.
  These parameters must now be named.
  ([\#11](https://github.com/schloerke/gqlr/issues/11))
- [`server()`](http://schloerke.com/gqlr/reference/server.md)’s `/`
  route now redirects to `/graphiql` iff `server(graphiql=TRUE)`.
  ([\#11](https://github.com/schloerke/gqlr/issues/11))

### New features and improvements

- Add support for
  [GraphiQL](https://github.com/graphql/graphiql/blob/graphiql%402.2.0/packages/graphiql/README.md).
  To view the GraphiQL interface of your schema, run
  `gqlr::server(MY_SCHEMA, graphiql = TRUE)` and visit
  `http://localhost:8000/graphiql/`. By default, GraphiQL suport is only
  enabled when run interactively.
  ([\#11](https://github.com/schloerke/gqlr/issues/11))
- Add support for `execute_request(verbose_errors=)`. If `TRUE` (legacy
  behavior), error-like messages will be displayed in real time. By
  default, this value is `TRUE` when run interactively.
  ([\#11](https://github.com/schloerke/gqlr/issues/11))
- Remove `__typename` from the fields. This is a meta field that should
  not be attached to the object structure.
  ([\#11](https://github.com/schloerke/gqlr/issues/11))
- Remove dependency on `pryr` package (which is being archived).
  Required functions (`modify_lang()`, `make_function()`, `unenclose()`,
  `substitute_q()`) have been copied into the package
  ([\#16](https://github.com/schloerke/gqlr/issues/16)).

### Bug Fixes

- Fix bug in mutation execution where the query operation was being used
  for validation ([\#9](https://github.com/schloerke/gqlr/issues/9))
- Add support for introspection type `subscriptionType` and have the
  value return `NULL` to signify that it is not supported.
  ([\#11](https://github.com/schloerke/gqlr/issues/11))

## gqlr 0.0.2

CRAN release: 2019-12-02

- Export `server` function
- Use `plumber` instead of `jug` for `server` function
- Fix R installation bug
- Delay evaluation of R6 class definitions to `.onLoad` call to avoid
  long compile times and large compiled files

## gqlr 0.0.1

CRAN release: 2017-06-07

- Initial release
