# The fundamental unit of any GraphQL Schema is the type. There are eight kinds of types in GraphQL.
# Scalar
# Enum
# Object
# Interface
# Union
# List
# Non-Null
# Input Object

# ID ?



# Scalar
#
# As expected by the name, a scalar represents a primitive value in GraphQL. GraphQL responses take the form of a hierarchical tree; the leaves on these trees are GraphQL scalars.
#
# All GraphQL scalars are representable as strings, though depending on the response format being used, there may be a more appropriate primitive for the given scalar type, and server should use those types when appropriate.
#
# GraphQL provides a number of built‐in scalars, but type systems can add additional scalars with semantic meaning. For example, a GraphQL system could define a scalar called Time which, while serialized as a string, promises to conform to ISO‐8601. When querying a field of type Time, you can then rely on the ability to parse the result with an ISO‐8601 parser and use a client‐specific primitive for time. Another example of a potentially useful custom scalar is Url, which serializes as a string, but is guaranteed by the server to be a valid URL.
#
# Result Coercion
#
# A GraphQL server, when preparing a field of a given scalar type, must uphold the contract the scalar type describes, either by coercing the value or producing an error.
#
# For example, a GraphQL server could be preparing a field with the scalar type Int and encounter a floating‐point number. Since the server must not break the contract by yielding a non‐integer, the server should truncate the fractional value and only yield the integer value. If the server encountered a boolean true value, it should return 1. If the server encountered a string, it may attempt to parse the string for a base‐10 integer value. If the server encounters some value that cannot be reasonably coerced to an Int, then it must raise a field error.
#
# Since this coercion behavior is not observable to clients of the GraphQL server, the precise rules of coercion are left to the implementation. The only requirement is that the server must yield values which adhere to the expected Scalar type.
#
# Input Coercion
#
# If a GraphQL server expects a scalar type as input to an argument, coercion is observable and the rules must be well defined. If an input value does not match a coercion rule, a query error must be raised.
#
# GraphQL has different constant literals to represent integer and floating‐point input values, and coercion rules may apply differently depending on which type of input value is encountered. GraphQL may be parameterized by query variables, the values of which are often serialized when sent over a transport like HTTP. Since some common serializations (ex. JSON) do not discriminate between integer and floating‐point values, they are interpreted as an integer input value if they have an empty fractional part (ex. 1.0) and otherwise as floating‐point input value.



# // Values

# export type Value = Variable
#                   | IntValue
#                   | FloatValue
#                   | StringValue
#                   | BooleanValue
#                   | EnumValue
#                   | ListValue
#                   | ObjectValue
Value <- R6Class("Value", inherit = Node,
  public = list(
    parse_literal = function(astObj) {
      if (astObj$kind == self$kind) {
        self$parse_value(astObj$value)
      } else {
        NULL
      }
    }
  )
)


Variable <- R6_from_args(
  inherit = Value,
  "Variable",
  " loc?: ?Location;
    name: Name; ",
  public = list(
    parse_literal = function(x) {
      stop("TODO implement")
    }
  )
)



coerce_int = function (value) {
  num <- as.integer(value)
  if (!is.na(num)) {
    if (num <= self$MAX_INT && num >= self$MIN_INT) {
      return(num)
    }
  }
  return(NULL)
}
IntValue = R6_from_args(
  inherit = Value,
  "IntValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    MAX_INT = 2147483647L,
    MIN_INT = -2147483648L,
    serialize = coerce_int,
    parse_value = coerce_int
  )
)



coerce_float = function (value) {
  num <- as.numeric(value)
  if (is.numeric(num)) {
    return(num)
  } else {
    return(NULL)
  }
}
FloatValue = R6_from_args(
  inherit = Value,
  "FloatValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    serialize = coerce_float,
    parse_value = coerce_float,
    parse_literal = function(astObj) {
      kind = astObj$kind
      if (kind == "IntValue" || kind == "FloatValue") {
        self$parse_value(astObj$value)
      } else {
        NULL
      }
    }
  )
)


StringValue = R6_from_args(
  inherit = Value,
  "StringValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    serialize = as.character,
    parse_value = as.character
  )
)


coerce_boolean = function (value) {
  val <- as.logical(value)
  if (is.logical(val)) {
    return(val)
  } else {
    return(NULL)
  }
}
BooleanValue = R6_from_args(
  inherit = Value,
  "BooleanValue",
  " loc?: ?Location;
    value: boolean;",
  public = list(
    serialize = coerce_boolean,
    parse_value = coerce_boolean
  )
)


# no literal AST definition, but defining as such
GraphQLID = R6_from_args(
  inherit = Value,
  "ID",
  " loc?: ?Location;
    value: boolean;",
  public = list(
    serialize = as.character,
    parseValue = as.character,
    parseLiteral = function(astObj) {
      if (astObj$kind == "StringValue" || astObj$kind == "IntValue") {
        return(astObj$value)
      } else {
        return(NULL)
      }
    }
  )
)

ListValue = R6_from_args(
  inherit = Value,
  "ListValue",
  " loc?: ?Location;
    values: Array<Value>;"
)
ObjectValue = R6_from_args(
  inherit = Value,
  "ObjectValue",
  " loc?: ?Location;
    fields: Array<ObjectField>;"
)

ObjectField = R6_from_args(
  inherit = Node,
  "ObjectField",
  " loc?: ?Location;
    name: Name;
    value: Value;
  "
)
