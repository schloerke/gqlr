



#' Scalar Int Coercion
#' The Int scalar type represents a signed 32-bit numeric non-fractional values. Response formats that support a 32-bit integer or a number type should use that type to represent this scalar.
#
#' Result Coercion
#
#' GraphQL servers should coerce non-int raw values to Int when possible otherwise they must raise a field error. Examples of this may include returning 1 for the floating-point number 1.0, or 2 for the string "2".
#
#' Input Coercion
#
#' When expected as an input type, only integer input values are accepted. All other input values, including strings with numeric content, must raise a query error indicating an incorrect type. If the integer input value represents a value less than -231 or greater than or equal to 231, a query error should be raised.
#'
#' Note: Numeric integer values larger than 32-bit should either use String or a custom-defined Scalar type, as not all platforms and transports support encoding integer numbers larger than 32-bit.
#' @param x variable in question
#' @seealso \url{https://github.com/facebook/graphql/blob/master/spec/Section%203%20--%20Type%20System.md#int}
#' @rdname scalar_intput_int
#' @export
scalar_input_int <- (function() {
  maxInt <- as.double(2^31)
  minInt <- as.double(-2^31)

  function(x) {
    x <- floor(as.integer(x))
    if(is.na(x)) {
      stop0("NA results produced when coercing to int. X: ", x)
    }
    if (x >= maxInt) {
      stop0("integer value: ", x, " is too large.  Must be less than 2^31")
    }
    if (x < minInt) {
      stop0("integer value: ", x, " is too negative.  Must be greater than 2^31")
    }
    x
  }
})()
#' @rdname scalar_intput_int
#' @export
scalar_result_int <- scalar_input_int



#' Scalar Float Coercion
#
#' The Float scalar type represents signed double-precision fractional values as specified by IEEE 754. Response formats that support an appropriate double-precision number type should use that type to represent this scalar.
#'
#' Result Coercion
#'
#' GraphQL servers should coerce non-floating-point raw values to Float when possible otherwise they must raise a field error. Examples of this may include returning 1.0 for the integer number 1, or 2.0 for the string "2".
#'
#' Input Coercion
#'
#' When expected as an input type, both integer and float input values are accepted. Integer input values are coerced to Float by adding an empty fractional part, for example 1.0 for the integer input value 1. All other input values, including strings with numeric content, must raise a query error indicating an incorrect type. If the integer input value represents a value not representable by IEEE 754, a query error should be raised.
#' @param x variable in question
#' @seealso \url{https://github.com/facebook/graphql/blob/master/spec/Section%203%20--%20Type%20System.md#float}
#' @rdname scalar_intput_float
#' @export
scalar_input_float <- function(x) {
  # should return with a decimal point inside
  x <- as.double(x)
  if(is.na(x)) {
    stop0("NA results produced when coercing to float. X: ", x)
  }
  x
}
#' @rdname scalar_intput_float
#' @export
scalar_result_float <- scalar_input_float




#' Scalar String Coercion
#'
#' The String scalar type represents textual data, represented as UTF-8 character sequences. The String type is most often used by GraphQL to represent free-form human-readable text. All response formats must support string representations, and that representation must be used here.
#'
#' Result Coercion
#'
#' GraphQL servers should coerce non-string raw values to String when possible otherwise they must raise a field error. Examples of this may include returning the string "true" for a boolean true value, or the string "1" for the integer 1.
#'
#' Input Coercion
#'
#' When expected as an input type, only valid UTF-8 string input values are accepted. All other input values must raise a query error indicating an incorrect type.
#' @seealso \url{https://github.com/facebook/graphql/blob/master/spec/Section%203%20--%20Type%20System.md#string}
#' @param x varible in question
#' @rdname scalar_intput_string
#' @export
scalar_input_string <- function(x) {

  # should return with a decimal point inside
  x <- as.character(x)
  if(is.na(x)) {
    stop0("NA results produced when coercing to character. X: ", x)
  }
  x
}
#' @rdname scalar_intput_string
#' @export
scalar_result_string <- scalar_input_string





#' Scalar Boolean Coercion
#'
#' The Boolean scalar type represents true or false. Response formats should use a built-in boolean type if supported; otherwise, they should use their representation of the integers 1 and 0.
#'
#' Result Coercion
#'
#' GraphQL servers should coerce non-boolean raw values to Boolean when possible otherwise they must raise a field error. Examples of this may include returning true for any non-zero number.
#'
#' Input Coercion
#'
#' When expected as an input type, only boolean input values are accepted. All other input values must raise a query error indicating an incorrect type.
#'
#' @seealso \url{https://github.com/facebook/graphql/blob/master/spec/Section%203%20--%20Type%20System.md#boolean}
#' @param x variable in question
#' @rdname scalar_input_boolean
#' @export
scalar_input_boolean <- function(x) {

  # should return with a decimal point inside
  x <- as.logical(x)
  if(is.na(x)) {
    stop0("NA results produced when coercing to logical. X: ", x)
  }
  x
}
#' @rdname scalar_input_boolean
#' @export
scalar_result_boolean <- scalar_input_boolean




#' Scalar ID Coercion
#' The ID scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type is serialized in the same way as a String; however, it is not intended to be human-readable. While it is often numeric, it should always serialize as a String.
#'
#' Result Coercion
#'
#' GraphQL is agnostic to ID format, and serializes to string to ensure consistency across many formats ID could represent, from small auto-increment numbers, to large 128-bit random numbers, to base64 encoded values, or string values of a format like GUID.
#'
#' GraphQL servers should coerce as appropriate given the ID formats they expect. When coercion is not possible they must raise a field error.
#'
#' Input Coercion
#'
#' When expected as an input type, any string (such as "4") or integer (such as 4) input value should be coerced to ID as appropriate for the ID formats a given GraphQL server expects. Any other input value, including float input values (such as 4.0), must raise a query error indicating an incorrect type.
#' @seealso \url{https://github.com/facebook/graphql/blob/master/spec/Section%203%20--%20Type%20System.md#id}
#' @rdname scalar_input_id
#' @export
scalar_input_id <- function(x) {
  if (is.numeric(x)) {
    if (x != floor(x)) {
      stop("float values may not be used for ID's")
    }
  }

  scalar_input_string(x)
}
#' @rdname scalar_intput_id
#' @export
scalar_result_id <- scalar_input_id
