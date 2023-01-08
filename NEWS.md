# gqlr 0.1.0

## Breaking changes

* `...` has been added into `server()` ahead of `log=` and `initial_value=`. These two paramters must now be named. (#11)
* `...` has been added into `execute_request()` ahead of `operation_name=`, `variables=`, and `initialial_value=`. These parameters must now be named. (#11)
* `server()`'s `/` route now redirects to `/graphiql` iff `server(graphiql=TRUE)`. (#11)

## New features and improvements

* Add support for [GraphiQL](https://github.com/graphql/graphiql/blob/graphiql%402.2.0/packages/graphiql/README.md). To view the GraphiQL interface of your schema, run `gqlr::server(MY_SCHEMA, graphiql = TRUE)` and visit `http://localhost:8000/graphiql/`. By default, GraphiQL suport is only enabled when run interactively. (#11)
* Add support for `execute_request(verbose_errors=)`. If `TRUE` (legacy behavior), error-like messages will be displayed in real time. By default, this value is `TRUE` when run interactively. (#11)
* Remove `__typename` from the fields. This is a meta field that should not be attached to the object structure. (#11)

## Bug Fixes

* Fix bug in mutation execution where the query operation was being used for validation (#9)
* Add support for introspection type `subscriptionType` and have the value return `NULL` to signify that it is not supported. (#11)

# gqlr 0.0.2

* Export `server` function
* Use `plumber` instead of `jug` for `server` function
* Fix R installation bug
* Delay evaluation of R6 class definitions to `.onLoad` call to avoid long compile times and large compiled files

# gqlr 0.0.1

* Initial release
