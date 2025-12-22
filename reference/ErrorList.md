# ErrorList

Handles all errors that occur during query validation. This object is
returned from execute request function
(`ans <- `[`execute_request`](http://schloerke.com/gqlr/reference/execute_request.md)`(query, schema)`)
under the field 'error_list' (`ans$error_list`).

## Usage

    answer <- execute_request(my_request, my_schema)
    answer$error_list

## Initialize

- verbose:

  boolean that determines if errors will be printed on occurrence.
  Defaults to `TRUE`

## Details

`$n` count of errors received

`$errors` list of error information

`$verbose` boolean that determines of errors are printed when received

`$has_no_errors()` helper method to determine if there are no errors

`$has_any_errors()` helper method to determine if there are any errors

`$get_sub_source(loc)` helper method to display a subsection of source
text given Location information

`$add(rule_code, ...)` add a new error according to the `rule_code`
provided. Remaining arguments are passed directly to
`paste(..., sep = "")` with extra error rule information

`$.format(...)` formats the error list into user friendly text.
Remaining arguments are ignored

`$print(...)` prints the error list by calling `self$format(...)`

## Examples

``` r
error_list <- ErrorList$new()
error_list
#> <ErrorList> No errors 
error_list$has_any_errors() # FALSE
#> [1] FALSE
error_list$has_no_errors() # TRUE
#> [1] TRUE

error_list$add("3.1.1", "Multiple part", " error about Scalars")
#> Error:
#> * 3.1.1: Scalars
#>   Multiple part error about Scalars
error_list
#> <ErrorList>
#> Errors: 
#> 3.1.1: Scalars
#> Multiple part error about Scalars 
error_list$has_any_errors() # TRUE
#> [1] TRUE
error_list$has_no_errors() # FALSE
#> [1] FALSE
```
