# As R6

Debug method that strips all gqlr classes and assigns the class as
`'R6'`

## Usage

``` r
as_R6(x)
```

## Arguments

- x:

  any object. If it inherits `'R6'`, then the class of `x` is set to
  `'R6'`

## Examples

``` r
Int <- getFromNamespace("Int", "gqlr")$clone()
print(Int)
#> <graphql definition>
#>   | scalar Int
print(as_R6(Int))
#> <R6>
#>   Public:
#>     .argNames: active binding
#>     .args: list
#>     .format: function (...) 
#>     .parse_ast: active binding
#>     .resolve: active binding
#>     .title: active binding
#>     clone: function (deep = FALSE) 
#>     description: active binding
#>     directives: active binding
#>     initialize: function (loc = NULL, description = NULL, name, directives = NULL, 
#>     loc: active binding
#>     name: active binding
```
