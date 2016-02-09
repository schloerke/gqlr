# 3.1.5

# http://facebook.github.io/graphql/#sec-Enums
# Enums
#
# GraphQL Enums are a variant on the Scalar type, which represents one of a finite set of possible values.
#
# GraphQL Enums are not references for a numeric value, but are unique values in their own right. They serialize as a string: the name of the represented value.
#
# Result Coercion
#
# GraphQL servers must return one of the defined set of possible values. If a reasonable coercion is not possible they must raise a field error.
#
# Input Coercion
#
# GraphQL has a constant literal to represent enum input values. GraphQL string literals must not be accepted as an enum input and instead raise a query error.
#
# Query variable transport serializations which have a different representation for non‐string symbolic values (for example, EDN) should only allow such values as enum input values. Otherwise, for most transport serializations that do not, strings may be interpreted as the enum input value with the same name.

GraphQLEnumValueDefinition = R6_from_args(
  "GraphQLEnumValueDefinition",
  " name: string;
    description?: ?string;
    deprecationReason?: ?string;
    value: any"
)
EnumValue = R6_from_args(
  inherit = Value,
  "EnumValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    "_values" = NULL,
    get_values = function() {
      self$values
    },

    "_nameList" = NULL,
    "_get_by_name" = function(nameVal) {
      if (is.null(self$"_nameList")) {
        nameList = as.list(self$get_values())
        names(nameList) <- lapply(nameList, "[[", "name") %>% unlist() %>% as.character()
        self$"_nameList" <- nameList
      }
      self[["_nameList"]][[nameVal]]
    },

    "_valueList" = NULL,
    "_get_by_value" = function(nameVal) {
      if (is.null(self$"_valueList")) {
        valueList = as.list(self$get_values())
        names(valueList) <- lapply(nameList, "[[", "value") %>% unlist() %>% as.character()
        self$"_valueList" <- valueList
      }
      self[["_valueList"]][[nameVal]]
    },

    serialize = function(value) {
      enumObj = self[["_get_by_value"]](value)
      if (!is.null(enumObj)) {
        enumObj$name
      } else {
        NULL
      }
    },
    parse_value = function(nameVal) {
      enumObj = self[["_get_by_name"]](nameVal)
      if (!is.null(enumObj)) {
        enumObj$value
      } else {
        NULL
      }
    },
    parse_literal = function(astObj) {
      if (astObj$kind == "EnumValue") {
        enumObj = self[["_get_by_name"]](astObj$value)
        if (!is.null(enumObj)) {
          return(enumObj$value)
        }
      }
      return(NULL)
    }


  )
)
