
# Scalars
#
# As expected by the name, a scalar represents a primitive value in GraphQL. GraphQL responses take the form of a hierarchical tree; the leaves on these trees are GraphQL scalars.
#
# All GraphQL scalars are representable as strings, though depending on the response format being used, there may be a more appropriate primitive for the given scalar type, and server should use those types when appropriate.
#
# GraphQL provides a number of built-in scalars, but type systems can add additional scalars with semantic meaning. For example, a GraphQL system could define a scalar called Time which, while serialized as a string, promises to conform to ISO-8601. When querying a field of type Time, you can then rely on the ability to parse the result with an ISO-8601 parser and use a client-specific primitive for time. Another example of a potentially useful custom scalar is Url, which serializes as a string, but is guaranteed by the server to be a valid URL.
#
# A server may omit any of the built-in scalars from its schema, for example if a schema does not refer to a floating-point number, then it will not include the Float type. However, if a schema includes a type with the name of one of the types described here, it must adhere to the behavior described. As an example, a server must not include a type called Int and use it to represent 128-bit numbers, or internationalization information.
#
# Result Coercion
#
# A GraphQL server, when preparing a field of a given scalar type, must uphold the contract the scalar type describes, either by coercing the value or producing an error.
#
# For example, a GraphQL server could be preparing a field with the scalar type Int and encounter a floating-point number. Since the server must not break the contract by yielding a non-integer, the server should truncate the fractional value and only yield the integer value. If the server encountered a boolean true value, it should return 1. If the server encountered a string, it may attempt to parse the string for a base-10 integer value. If the server encounters some value that cannot be reasonably coerced to an Int, then it must raise a field error.
#
# Since this coercion behavior is not observable to clients of the GraphQL server, the precise rules of coercion are left to the implementation. The only requirement is that the server must yield values which adhere to the expected Scalar type.
#
# Input Coercion
#
# If a GraphQL server expects a scalar type as input to an argument, coercion is observable and the rules must be well defined. If an input value does not match a coercion rule, a query error must be raised.
#
# GraphQL has different constant literals to represent integer and floating-point input values, and coercion rules may apply differently depending on which type of input value is encountered. GraphQL may be parameterized by query variables, the values of which are often serialized when sent over a transport like HTTP. Since some common serializations (ex. JSON) do not discriminate between integer and floating-point values, they are interpreted as an integer input value if they have an empty fractional part (ex. 1.0) and otherwise as floating-point input value.
#
# For all types below, with the exception of Non-Null, if the explicit value null is provided, then the result of input coercion is null.



#' @export
parse_literal <- function(kind_val, parse_value_fn) {
  fn <- function(obj, schema_obj) {
    if (inherits(obj, kind_val)) {
      parse_value_fn(obj$value, schema_obj)
    } else {
      NULL
    }
  }
  pryr_unenclose(fn)
}


coerce_int <- function (value, ...) {
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



Int <- ScalarTypeDefinition$new(
  name = Name$new(value = "Int"),
  description = paste0(
    "The Int scalar type represents a signed 32-bit numeric non-fractional value. ",
    "Response formats that support a 32-bit integer or a number type should use that ",
    "type to represent this scalar."
  ),
  .serialize = coerce_int,
  .parse_value = coerce_int,
  .parse_literal = parse_literal("IntValue", coerce_int)

)



coerce_float <- function (value, ...) {
  num <- suppressWarnings(as.numeric(value))
  if (is.numeric(num)) {
    return(num)
  } else {
    return(NULL)
  }
}
Float <- ScalarTypeDefinition$new(
  name = Name$new(value = "Float"),
  description = collapse(
    "The `Float` scalar type represents signed double-precision fractional ",
    "values as specified by ",
    "[IEEE 754](http://en.wikipedia.org/wiki/IEEE_floating_point)."
  ),
  .serialize = coerce_float,
  .parse_value = coerce_float,
  .parse_literal = pryr_unenclose(function(obj, schema_obj) {
    if (
      inherits(obj, "IntValue") ||
      inherits(obj, "FloatValue")
    ) {
      coerce_float(obj$value, schema_obj)
    } else {
      NULL
    }
  })
)


coerce_string <- function(value, ...) {
  char <- suppressWarnings(as.character(value))
  if (is.character(char)) {
    return(char)
  } else {
    return(NULL)
  }
}
String <- ScalarTypeDefinition$new(
  name = Name$new(value = "String"),
  description = collapse(
    "The `String` scalar type represents textual data, represented as UTF-8 ",
    "character sequences. The String type is most often used by GraphQL to ",
    "represent free-form human-readable text."
  ),
  .serialize = coerce_string,
  .parse_value = coerce_string,
  .parse_literal = parse_literal("StringValue", coerce_string)
)


coerce_boolean <- function (value, ...) {
  val <- suppressWarnings(as.logical(value))
  if (is.logical(val)) {
    return(val)
  } else {
    return(NULL)
  }
}
Boolean <- ScalarTypeDefinition$new(
  name = Name$new(value = "Boolean"),
  description = "The `Boolean` scalar type represents `TRUE` or `FALSE`.",
  .serialize = coerce_boolean,
  .parse_value = coerce_boolean,
  .parse_literal = parse_literal("BooleanValue", coerce_boolean)
)


# nolint start

## Not including in R setup
# # no literal AST definition, but defining as such
# ID = ScalarTypeDefinition$new(
#   name = Name$new(value = "ID"),
#   description = collapse(
#     "The `ID` scalar type represents a unique identifier, often used to ",
#     "refetch an object or as key for a cache. The ID type appears in a JSON ",
#     "response as a String; however, it is not intended to be human-readable. ",
#     "When expected as an input type, any string (such as `"4"`) or integer ",
#     "(such as `4`) input value will be accepted as an ID."
#   ),
#   .serialize = as.character,
#   .parse_value = as.character,
#   .parse_literal = function(astObj) {
#     if (
#       inherits(astObj, "String") ||
#       inherits(astObj, "Int")
#     ) {
#       return(as.character(astObj$value))
#     } else {
#       return(NULL)
#     }
#   }
# )

# nolint end
