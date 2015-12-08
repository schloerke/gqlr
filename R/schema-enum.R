



#' Enums
#'
#' GraphQL Enums are a variant on the Scalar type, which represents one of a finite set of possible values.
#'
#' GraphQL Enums are not references for a numeric value, but are unique values in their own right. They serialize as a string: the name of the represented value.
#'
#' Result Coercion
#'
#' GraphQL servers must return one of the defined set of possible values. If a reasonable coercion is not possible they must raise a field error.
#'
#' Input Coercion
#'
#' GraphQL has a constant literal to represent enum input values. GraphQL string literals must not be accepted as an enum input and instead raise a query error.
#'
#' Query variable transport serializations which have a different representation for non-string symbolic values (for example, EDN) should only allow such values as enum input values. Otherwise, for most transport serializations that do not, strings may be interpreted as the enum input value with the same name.
#' @url https://github.com/facebook/graphql/blob/master/spec/Section%203%20--%20Type%20System.md#enums
schema_enum <- function(values) {

  result_coercion <- function(value) {
    if (!(value %in% values)) {
      stop0("Returned value: ", value, " is not a valid enum. Possible values:", paste0(values, collapse = ", "))
    }
    scalar_result_string(value)
  }

  input_coercion <- result_coercion

  list(input = input_coercion, result = result_coercion)
}
