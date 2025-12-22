# Parse AST

This is a helper function for Scalars. Given a particular kind and a
resolve function, it produces a function that will only parse values of
a particular kind.

## Usage

``` r
parse_ast(kind, resolve)
```

## Arguments

- kind:

  single character name of a class to parse

- resolve:

  function to parse the value if the kind is correct

## Value

function that takes `obj` and `schema` that will only parse the value if
the `kind` is inherited in the `obj`

## Details

Typically, `kind` is the same as the class of the Scalar. When making a
new Scalar, parse_ast defaults to use the name of the scalar and the
scalar's parse value function.

This function should only need to be used when defining a schema in
[`gqlr_schema()`](http://schloerke.com/gqlr/reference/gqlr_schema.md)

## Examples

``` r
parse_date_value <- function(obj, schema) {
  as.Date(obj)
}
parse_ast("Date", parse_date_value)
#> function (obj, schema) 
#> {
#>     if (inherits(obj, "Date")) {
#>         (function (obj, schema) 
#>         {
#>             as.Date(obj)
#>         })(obj$value, schema)
#>     }
#>     else {
#>         NULL
#>     }
#> }
#> <environment: namespace:gqlr>

# Example from Int scalar
parse_int <- function(value, ...) {
  MAX_INT <-  2147483647
  MIN_INT <- -2147483648
  num <- suppressWarnings(as.integer(value))
  if (!is.na(num)) {
    if (num <= MAX_INT && num >= MIN_INT) {
      return(num)
    }
  }
  return(NULL)
}
parse_ast("IntValue", parse_int)
#> function (obj, schema) 
#> {
#>     if (inherits(obj, "IntValue")) {
#>         (function (value, ...) 
#>         {
#>             MAX_INT <- 2147483647
#>             MIN_INT <- -2147483648
#>             num <- suppressWarnings(as.integer(value))
#>             if (!is.na(num)) {
#>                 if (num <= MAX_INT && num >= MIN_INT) {
#>                   return(num)
#>                 }
#>             }
#>             return(NULL)
#>         })(obj$value, schema)
#>     }
#>     else {
#>         NULL
#>     }
#> }
#> <environment: namespace:gqlr>
```
