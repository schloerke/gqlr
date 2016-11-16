# 3.1.8
# http://facebook.github.io/graphql/#sec-Non-Null

# Non-Null
#
# By default, all types in GraphQL are nullable; the null value is a valid response for all of the above types. To declare a type that disallows null, the GraphQL Non‐Null type can be used. This type wraps an underlying type, and this type acts identically to that wrapped type, with the exception that null is not a valid response for the wrapping type. A trailing exclamation mark is used to denote a field that uses a Non‐Null type like this: name: String!.
#
# Result Coercion
#
# In all of the above result coercion, null was considered a valid value. To coerce the result of a Non Null type, the coercion of the wrapped type should be performed. If that result was not null, then the result of coercing the Non Null type is that result. If that result was null, then a field error must be raised.
#
# Input Coercion
#
# If the argument of a Non Null type is not provided, a query error must be raised.
#
# If an argument of a Non Null type is provided with a literal value, it is coerced using the input coercion for the wrapped type.
#
# If the argument of a Non Null is provided with a variable, a query error must be raised if the runtime provided value is not provided or is null in the provided representation (usually JSON). Otherwise, the coerced value is the result of using the input coercion for the wrapped type.

# TODO
gql_NonNullType = R6_from_args(
  inherit = Type,
  "NonNullType",
  " loc?: ?Location;
    type: NamedType | ListType;",


  active = list(
    ofType = function() {
      self$type$kind
    },
    type = function(value) {
      if (missing(value)) {
        return(self$.args$type$value)
      }
      if (!(inherits(value, "NamedType") || inherits(value, "ListType"))) {
        stop0("expected value with class of NamedType or ListType. Received ", value$kind)
      }
      self$.args$type$value <- value
      value
    }
  )
)
