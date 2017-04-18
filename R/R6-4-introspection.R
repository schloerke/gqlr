#' @include R6-3.2-directives.R
#' @include graphql_json.R
#' @include R6-Schema.R

# setup_instrospection <- function() {

"
# __Schema desc here
type __Schema {
  # types desc here
  types: [__Type!]!
  # queryType desc here
  queryType: __Type!
  mutationType: __Type
  directives: [__Directive!]!
}

type __Type {
  kind: __TypeKind!
  name: String
  description: String

  # OBJECT and INTERFACE only
  fields(includeDeprecated: Boolean = false): [__Field!]

  # OBJECT only
  interfaces: [__Type!]

  # INTERFACE and UNION only
  possibleTypes: [__Type!]

  # ENUM only
  enumValues(includeDeprecated: Boolean = false): [__EnumValue!]

  # INPUT_OBJECT only
  inputFields: [__InputValue!]

  # NON_NULL and LIST only
  ofType: __Type
}

type __Field {
  name: String!
  description: String
  args: [__InputValue!]!
  type: __Type!
  isDeprecated: Boolean!
  deprecationReason: String
}

type __InputValue {
  name: String!
  description: String
  type: __Type!
  defaultValue: String
}

type __EnumValue {
  name: String!
  description: String
  isDeprecated: Boolean!
  deprecationReason: String
}

enum __TypeKind {
  SCALAR
  OBJECT
  INTERFACE
  UNION
  ENUM
  INPUT_OBJECT
  LIST
  NON_NULL
}

type __Directive {
  name: String!
  description: String
  locations: [__DirectiveLocation!]!
  args: [__InputValue!]!
}

enum __DirectiveLocation {
  # Operations
  QUERY
  MUTATION
  # SUBSCRIPTION
  FIELD
  FRAGMENT_DEFINITION
  FRAGMENT_SPREAD
  INLINE_FRAGMENT

  # Schema Definitions
  SCHEMA
  SCALAR
  OBJECT
  FIELD_DEFINITION
  ARGUMENT_DEFINITION
  INTERFACE
  UNION
  ENUM
  ENUM_VALUE
  INPUT_OBJECT
  INPUT_FIELD_DEFINITION
}

type QueryRootFields {
  __schema: __Schema!
  __type(name: String!): __Type
}
" %>%
  graphql2obj(fn_list = list(
    "__Schema" = list(
      description = collapse(
        "A GraphQL Schema defines the capabilities of a GraphQL server. It ",
        "exposes all available types and directives on the server, as well as ",
        "the entry points for query, mutation, and subscription operations." ,
        "  Subscriptions are not implemented in gqlr."
      ),
      fields = list(
        "types" = "A list of all types supported by this server.",
        "queryType" = "The type that query operations will be rooted at.",
        "mutationType" = "The type that mutation operations will be rooted at.",
        "directives" = "A list of all directives supported by this server."
      )
    ),

    "__Type" = list(),


    "__Field" = list(
      description = collapse(
        "Object and Interface types are described by a list of Fields, each of ",
        "which has a name, potentially a list of arguments, and a return type."
      ),
      fields = list(
        args = "returns a List of __InputValue representing the arguments this field accepts",
        type = "must return a __Type that represents the type of value returned by this field",
        isDeprecated = "returns true if this field should no longer be used, otherwise false",
        deprecationReason = "optionally provides a reason why this field is deprecated"
      )
    ),

    "__InputValue" = list(
      description = collapse(
        "Arguments provided to Fields or Directives and the input fields of an ",
        "InputObject are represented as Input Values which describe their type ",
        "and optionally a default value."
      ),
      fields = list(
        type = "must return a __Type that represents the type this input value expects",
        defaultValue = collapse(
          "may return a String encoding (using the GraphQL language) of the default value used by ",
          "this input value in the condition a value is not provided at runtime. If this input ",
          "value has no default value, returns null."
        )
      )
    ),

    "__EnumValue" = list(
      description = collapse(
        "One possible value for a given Enum. Enum values are unique values, not ",
        "a placeholder for a string or numeric value. However an Enum value is ",
        "returned in a JSON response as a string."
      )
    ),

    "__TypeKind" = list(
      description = "An enum describing what kind of type a given `__Type` is.",
      fields = list(
        SCALAR = "Indicates this type is a scalar.",
        OBJECT = "Indicates this type is an object. `fields` and `interfaces` are valid fields.",
        INTERFACE = "Indicates this type is an interface. `fields` and `possibleTypes` are valid fields.",
        UNION = "Indicates this type is a union. `possibleTypes` is a valid field.",
        ENUM = "Indicates this type is an enum. `enumValues` is a valid field.",
        INPUT_OBJECT = "Indicates this type is an input object. `inputFields` is a valid field.",
        LIST = "Indicates this type is a list. `ofType` is a valid field.",
        NON_NULL = "Indicates this type is a non-null. `ofType` is a valid field."
      )
    ),

    "__Directive" = list(
      description = collapse(
        "A Directive provides a way to describe alternate runtime execution and ",
        "type validation behavior in a GraphQL document.",
        "\n\nIn some cases, you need to provide options to alter GraphQL's ",
        "execution behavior in ways field arguments will not suffice, such as ",
        "conditionally including or skipping a field. Directives provide this by ",
        "describing additional information to the executor."
      ),
      fields = list(
        locations = "returns a List of __DirectiveLocation representing the valid locations this directive may be placed",
        args = "returns a List of __InputValue representing the arguments this directive accepts"
      )
    ),

    "__DirectiveLocation" = list(
      description = collapse(
        "A Directive can be adjacent to many parts of the GraphQL language, a ",
        "__DirectiveLocation describes one such possible adjacencies."
      ),
      fields = list(
        # Operations
        QUERY = "Location adjacent to a query",
        MUTATION = "Location adjacent to a mutation",
        FIELD = "Location adjacent to a field",
        FRAGMENT_DEFINITION = "Location adjacent to a fragment definition",
        FRAGMENT_SPREAD = "Location adjacent to a fragment spread",
        INLINE_FRAGMENT = "Location adjacent to a inline fragment",
        # Schema Definitions
        SCHEMA = "Location adjacent to a schema definition",
        SCALAR = "Location adjacent to a scalar definition",
        OBJECT = "Location adjacent to a object definition",
        FIELD_DEFINITION = "Location adjacent to a field definition",
        ARGUMENT_DEFINITION = "Location adjacent to a argument definition",
        INTERFACE = "Location adjacent to a interface definition",
        UNION = "Location adjacent to a union definition",
        ENUM = "Location adjacent to a enum definition",
        ENUM_VALUE = "Location adjacent to a enum value definition",
        INPUT_OBJECT = "Location adjacent to a input object definition",
        INPUT_FIELD_DEFINITION = "Location adjacent to a input field definition"
      )
    ),

    "QueryRootFields" = list()
  )) %>%
  magrittr::extract2("definitions") ->
introspection_definitions


Introspection__Schema <<- introspection_definitions[[1]]
Introspection__Type <<- introspection_definitions[[2]]
Introspection__Field <<- introspection_definitions[[3]]
Introspection__InputValue <<- introspection_definitions[[4]]
Introspection__EnumValue <<- introspection_definitions[[5]]
Introspection__TypeKind <<- introspection_definitions[[6]]
Introspection__Directive <<- introspection_definitions[[7]]
Introspection__DirectiveLocation <<- introspection_definitions[[8]]


# # types: [__Type!]!
# Introspection__Schema$fields[[1]]$.resolve <- function(z1, z2, schema_obj) {
#   all_types <- list() %>%
#     append(schema_obj$get_scalars()) %>%
#     append(schema_obj$get_objects()) %>%
#     append(schema_obj$get_interfaces()) %>%
#     append(schema_obj$get_unions()) %>%
#     append(schema_obj$get_enums()) %>%
#     append(schema_obj$get_input_objects()) %>%
#     # append(schema_obj$get_directives()) %>%
#     append(schema_obj$get_values())
#
#   all_types %>% lapply(return__type, schema_obj = schema_obj)
# }
#
# # queryType: __Type!
# Introspection__Schema$fields[[2]]$.resolve <- function(z1, z2, schema_obj) {
#   cat("\n\n\tGetting Query!\n\n")
#   query_type <- schema_obj$get_schema_definition("query")
#   ret <- return__type(query_type, schema_obj = schema_obj)
#   browser()
#   ret
# }
#
# # mutationType: __Type
# Introspection__Schema$fields[[3]]$.resolve <- function(z1, z2, schema_obj) {
#   mutation_type <- schema_obj$get_schema_definition("mutation")
#   return__type(mutation_type, schema_obj = schema_obj)
# }
#
# # directives: [__Directive!]!
# Introspection__Schema$fields[[4]]$.resolve <- function(z1, z2, schema_obj) {
#   directives <- schema_obj$get_directives()
#   lapply(directives, return__directive, schema_obj = schema_obj)
# }



Introspection__QueryRootFields <<- introspection_definitions[[9]]
# DONE
# Introspection__QueryRootFields$fields[[1]]$.resolve <- function(z1, z2, schema_obj) {
#   return__schema(schema_obj)
# }
# Introspection__QueryRootFields$fields[[2]]$.resolve <- function(z1, args, schema_obj) {
#   type_obj <- schema_obj$as_type(args$name)
#   return__type(type_obj, schema_obj)
# }




# done?
return__schema = function(schema_obj) {
  # function(z1, z2, z3) {

  list(
    # types: [__Type!]!
    types = function(z1, z2, z3) {
      all_types <- list() %>%
        append(schema_obj$get_scalars()) %>%
        append(schema_obj$get_objects()) %>%
        append(schema_obj$get_interfaces()) %>%
        append(schema_obj$get_unions()) %>%
        append(schema_obj$get_enums()) %>%
        append(schema_obj$get_input_objects()) %>%
        # append(schema_obj$get_directives()) %>%
        append(schema_obj$get_values())

      all_types %>% lapply(return__type, schema_obj = schema_obj)
    },

    # queryType: __Type!
    queryType = function(z1, z2, z3) {
      query_type <- schema_obj$get_schema_definition("query")
      return__type(query_type, schema_obj = schema_obj)
    },

    # mutationType: __Type
    mutationType = function(z1, z2, z3) {
      mutation_type <- schema_obj$get_schema_definition("mutation")
      if (is.null(mutation_type)) return(NULL)
      return__type(mutation_type, schema_obj = schema_obj)
    },

    # directives: [__Directive!]!
    directives = function(z1, z2, z3) {
      directives <- schema_obj$get_directives()
      lapply(directives, return__directive, schema_obj = schema_obj)
    }
  )
  # }
}


# done?
return__type = function(type_obj, schema_obj) {
  type_obj <- schema_obj$as_type(type_obj)

  # kind: __TypeKind!
  # name: String
  # description: String
  ret <- list(
    kind = function(z1, z2, z3) {
      return__type_kind(type_obj, schema_obj)
    },
    name = function(z1, z2, z3) {
      if (inherits(type_obj, "ListType")) return(NULL)
      if (inherits(type_obj, "NonNullType")) return(NULL)
      schema_obj$name_helper(type_obj)
    },
    description = function(z1, z2, z3) {
      if (inherits(type_obj, "ListType")) return(NULL)
      if (inherits(type_obj, "NonNullType")) return(NULL)
      obj <- schema_obj$get_type(type_obj)
      obj$.description
    }
  )

  # # NON_NULL and LIST only
  # ofType: __Type
  if (
    inherits(type_obj, "NonNullType") ||
    inherits(type_obj, "ListType")
  ) {
    ret$ofType <- function(z1, z2, z3) {
      inner_type <- type_obj$type
      return__type(inner_type, schema_obj = schema_obj)
    }
    return(ret)
  }


  # # OBJECT and INTERFACE only
  # fields(includeDeprecated: Boolean = false): [__Field!]
  if (
    schema_obj$is_object(type_obj) ||
    schema_obj$is_interface(type_obj)
  ) {
    ret$fields <- function(z1, args, z2) {
      # include_deprecated <- args$includeDeprecated; FALSE
      obj <- ifnull(
        schema_obj$get_object(type_obj),
        schema_obj$get_interface(type_obj)
      )
      fields <- obj$fields
      if (length(fields) == 0) {
        return(NULL)
      }
      lapply(fields, return__field, obj = obj, schema_obj = schema_obj)
    }
  }

  # # OBJECT only
  # interfaces: [__Type!]
  if (schema_obj$is_object(type_obj)) {
    ret$interfaces <- function(z1, z2, z3) {
      obj <- schema_obj$get_object(type_obj)
      obj_interfaces <- obj$interfaces
      if (is.null(obj_interfaces)) return(NULL)
      if (length(obj_interfaces) == 0) return(NULL)
      lapply(obj_interfaces, return__type, schema_obj = schema_obj)
    }
  }

  # # INTERFACE and UNION only
  # possibleTypes: [__Type!]
  if (schema_obj$is_interface(type_obj)) {
    ret$possibleTypes <- function(z1, z2, z3) {
      possible_types <- schema_obj$objects_that_implement_interface(type_obj)
      lapply(possible_types, return__type, schema_obj = schema_obj)
    }
  } else if (schema_obj$is_union(type_obj)) {
    ret$possibleTypes <- function(z1, z2, z3) {
      union_obj <- schema_obj$get_union(type_obj)
      union_type_names <- union_obj$types
      lapply(union_type_names, return__type, schema_obj = schema_obj)
    }
  }

  # # ENUM only
  # enumValues(includeDeprecated: Boolean = false): [__EnumValue!]
  if (schema_obj$is_enum(type_obj)) {
    ret$enumValues <- function(z1, args, z3) {
      includeDeprecated <- args$includeDeprecated

      enum_obj <- schema_obj$get_enum(type_obj)
      enum_values <- enum_obj$values
      lapply(enum_values, return__enum_value, schema_obj = schema_obj)
    }
  }

  # # INPUT_OBJECT only
  # inputFields: [__InputValue!]
  if (schema_obj$is_input_object(type_obj)) {
    ret$inputFields <- function(z1, z2, z3) {
      input_obj <- schema_obj$get_input_object(type_obj)
      input_obj_fields <- input_obj$fields
      lapply(input_obj_fields, return__input_value, schema_obj = schema_obj)
    }
  }

  ret
}

# type __InputValue {
#   name: String!
#   description: String
#   type: __Type!
#   defaultValue: String
# }
return__input_value <- function(input_value, schema_obj) {

  ret <- list(
    name = format(input_value$name),
    description = input_value$description,
    type = return__type(input_value$type, schema_obj),
    defaultValue = input_value$defaultValue$value
  )
}

# type __EnumValue {
#   name: String!
#   description: String
#   isDeprecated: Boolean!
#   deprecationReason: String
# }
return__enum_value <- function(enum_value, schema_obj) {
  list(
    name = format(enum_value$name),
    description = enum_value$description,
    isDeprecated = FALSE,
    deprecationReason = NULL
  )
}

# type __Field {
#   name: String!
#   description: String
#   args: [__InputValue!]!
#   type: __Type!
#   isDeprecated: Boolean!
#   deprecationReason: String
# }
return__field <- function(field_obj, obj, schema_obj) {
  list(
    name = format(field_obj$name),
    description = field_obj$description,
    args = lapply(field_obj$arguments, return__input_value, schema_obj = schema_obj),
    type = return__type(field_obj$type, schema_obj),
    isDeprecated = FALSE,
    deprecationReason = FALSE
  )
}


# DONE
return__type_kind <- function(type_obj, schema_obj) {
  if (inherits(type_obj, "NonNullType")) return("NON_NULL")
  if (inherits(type_obj, "ListType")) return("LIST")
  if (schema_obj$is_scalar(type_obj)) return("SCALAR")
  if (schema_obj$is_object(type_obj)) return("OBJECT")
  if (schema_obj$is_interface(type_obj)) return("INTERFACE")
  if (schema_obj$is_union(type_obj)) return("UNION")
  if (schema_obj$is_enum(type_obj)) return("ENUM")
  if (schema_obj$is_input_object(type_obj)) return("INPUT_OBJECT")
  stop("this should not be reached")
}

# type __Directive {
#   name: String!
#   description: String
#   locations: [__DirectiveLocation!]!
#   args: [__InputValue!]!
# }
return__directive <- function(directive_obj, schema_obj) {
  list(
    name = format(directive_obj$name),
    description = directive_obj$description,
    locations = lapply(directive_obj$locations, format),
    args = lapply(directive_obj$arguments, return__input_value, schema_obj = schema_obj)
  )
}



# fields = list(
#   "__schema" = function(a, b, schema_obj, ...) {
#     cat("\n\nreturning schema obj!!!\n")
#     schema_obj
#   },
#   "__type" = function(a, args, schema_obj, ...) {
#     schema_obj$get_type(args$name)
#   }
# )
