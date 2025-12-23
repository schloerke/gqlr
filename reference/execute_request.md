# Execute GraphQL server response

Executes a GraphQL server request with the provided request.

## Usage

``` r
execute_request(
  request,
  schema,
  ...,
  operation_name = NULL,
  variables = list(),
  initial_value = NULL,
  verbose_errors = is_interactive()
)
```

## Arguments

- request:

  a valid GraphQL string

- schema:

  a character string (to be used along side `initial_value`) or a schema
  object created from
  [`gqlr_schema()`](http://schloerke.com/gqlr/reference/gqlr_schema.md)

- ...:

  ignored for paramter expansion

- operation_name:

  name of request operation to execute. If not value is provided it will
  use the operation in the request string. If more than one operations
  exist, an error will be produced. See
  <https://spec.graphql.org/October2016/#GetOperation()>

- variables:

  a named list containing variable values.
  <https://spec.graphql.org/October2016/#sec-Language.Variables>

- initial_value:

  default value for executing requests. This value can either be
  provided and/or combined with the resolve method of the query root
  type or mutation root type. The value provided should be a named list
  of the field name (key) and a value matching that field name type. The
  value may be a function that returns a value of the field name type.

- verbose_errors:

  logical to determine if error-like messages should be displayed when
  processing a request that finds unknown structures. Be default, this
  is only enabled when `verbose_errors = rlang::is_interactive()` is
  `TRUE`.

## References

<https://spec.graphql.org/October2016/#sec-Execution>

## Examples

``` r
# \donttest{
# bare bones
schema <- gqlr_schema("
  type Person {
    name: String
    friends: [Person]
  }
  schema {
    query: Person
  }
")

data <- list(
  name = "Barret",
  friends = list(
    list(name = "Ryan", friends = list(list(name = "Bill"), list(name = "Barret"))),
    list(name = "Bill", friends = list(list(name = "Ryan")))
  )
)

ans <- execute_request("{ name }", schema, initial_value = data)
ans$as_json()
#> {
#>   "data": {
#>     "name": "Barret"
#>   }
#> } 

execute_request("
  {
    name
    friends {
      name
      friends {
        name
        friends {
          name
        }
      }
    }
  }",
  schema,
  initial_value = data
)$as_json()
#> {
#>   "data": {
#>     "name": "Barret",
#>     "friends": [
#>       {
#>         "name": "Ryan",
#>         "friends": [
#>           {
#>             "name": "Bill",
#>             "friends": null
#>           },
#>           {
#>             "name": "Barret",
#>             "friends": null
#>           }
#>         ]
#>       },
#>       {
#>         "name": "Bill",
#>         "friends": [
#>           {
#>             "name": "Ryan",
#>             "friends": null
#>           }
#>         ]
#>       }
#>     ]
#>   }
#> } 






# Using resolve method to help with recursion
people <- list(
  "id_Barret" = list(name = "Barret", friends = list("id_Ryan", "id_Bill")),
  "id_Ryan" = list(name = "Ryan", friends = list("id_Barret", "id_Bill")),
  "id_Bill" = list(name = "Bill", friends = list("id_Ryan"))
)
schema <- gqlr_schema("
    type Person {
      name: String
      friends: [Person]
    }
    schema {
      query: Person
    }
  ",
  Person = list(
    resolve = function(name, schema, ...) {
      if (name %in% names(people)) {
        people[[name]]
      } else {
        NULL
      }
    }
  )
)

ans <- execute_request("{ name }", schema, initial_value = "id_Barret")
ans$as_json()
#> {
#>   "data": {
#>     "name": "Barret"
#>   }
#> } 

execute_request("
  {
    name
    friends {
      name
      friends {
        name
        friends {
          name
        }
      }
    }
  }",
  schema,
  initial_value = "id_Barret"
)$as_json()
#> {
#>   "data": {
#>     "name": "Barret",
#>     "friends": [
#>       {
#>         "name": "Ryan",
#>         "friends": [
#>           {
#>             "name": "Barret",
#>             "friends": [
#>               {
#>                 "name": "Ryan"
#>               },
#>               {
#>                 "name": "Bill"
#>               }
#>             ]
#>           },
#>           {
#>             "name": "Bill",
#>             "friends": [
#>               {
#>                 "name": "Ryan"
#>               }
#>             ]
#>           }
#>         ]
#>       },
#>       {
#>         "name": "Bill",
#>         "friends": [
#>           {
#>             "name": "Ryan",
#>             "friends": [
#>               {
#>                 "name": "Barret"
#>               },
#>               {
#>                 "name": "Bill"
#>               }
#>             ]
#>           }
#>         ]
#>       }
#>     ]
#>   }
#> } 
# }
```
