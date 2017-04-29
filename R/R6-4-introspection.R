#' @include R6-3.2-directives.R
#' @include graphql_json.R
#' @include R6--definition.R

# setup_instrospection <- function() {

get_definition <- function(x, name) {
  x$.get_definition(name)
}

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
" %>%
  graphql2obj(
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
      ),
      .resolve = function(null, schema_obj) {
        list(
          # types: [__Type!]!
          types = function(z1, z2, z3) {
            all_types <- list() %>%
              append(names(schema_obj$get_scalars())) %>%
              append(names(schema_obj$get_objects())) %>%
              append(names(schema_obj$get_interfaces())) %>%
              append(names(schema_obj$get_unions())) %>%
              append(names(schema_obj$get_enums())) %>%
              append(names(schema_obj$get_input_objects())) %>%
              # append(names(schema_obj$get_directives())) %>%
              append(names(schema_obj$get_values()))

            all_types
          },

          # queryType: __Type!
          queryType = function(z1, z2, z3) {
            query_type <- schema_obj$get_schema_definition("query")
            query_type
          },

          # mutationType: __Type
          mutationType = function(z1, z2, z3) {
            mutation_type <- schema_obj$get_schema_definition("mutation")
            if (is.null(mutation_type)) return(NULL)
            mutation_type
          },

          # directives: [__Directive!]!
          directives = function(z1, z2, z3) {
            directives <- schema_obj$get_directives()
            directives
          }
        )
        # }
      }
    )
  ) %>%
  get_definition("__Schema") ->
Introspection__Schema



"
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
" %>%
  graphql2obj(
    "__Type" = list(
      .resolve = function(type_obj, schema_obj) {
        type_obj <- schema_obj$as_type(type_obj)
        # kind: __TypeKind!
        # name: String
        # description: String
        ret <- list(
          kind = type_obj,
          name = function(z1, z2, z3) {
            if (inherits(type_obj, "ListType")) return(NULL)
            if (inherits(type_obj, "NonNullType")) return(NULL)
            schema_obj$name_helper(type_obj)
          },
          description = function(z1, z2, z3) {
            if (inherits(type_obj, "ListType")) return(NULL)
            if (inherits(type_obj, "NonNullType")) return(NULL)
            obj <- schema_obj$get_type(type_obj)
            obj$description
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
            inner_type
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
            include_deprecated <- args$includeDeprecated
            if (!is.null(include_deprecated)) {
              # warning("not listening to includeDeprecated enumValues")
            }

            obj <- ifnull(
              schema_obj$get_object(type_obj),
              schema_obj$get_interface(type_obj)
            )
            fields <- obj$fields
            if (is.null(fields)) return(NULL)
            fields
          }
        }

        # # OBJECT only
        # interfaces: [__Type!]
        if (schema_obj$is_object(type_obj)) {
          ret$interfaces <- function(z1, z2, z3) {
            obj <- schema_obj$get_object(type_obj)
            obj_interfaces <- obj$interfaces
            if (is.null(obj_interfaces)) return(NULL)
            obj_interfaces
          }
        }

        # # INTERFACE and UNION only
        # possibleTypes: [__Type!]
        if (schema_obj$is_interface(type_obj)) {
          ret$possibleTypes <- function(z1, z2, z3) {
            possible_types <- schema_obj$objects_that_implement_interface(type_obj)
            if (is.null(possible_types)) return(NULL)
            possible_types
          }
        } else if (schema_obj$is_union(type_obj)) {
          ret$possibleTypes <- function(z1, z2, z3) {
            union_obj <- schema_obj$get_union(type_obj)
            union_type_names <- union_obj$types
            if (is.null(union_type_names)) return(NULL)
            union_type_names
          }
        }

        # # ENUM only
        # enumValues(includeDeprecated: Boolean = false): [__EnumValue!]
        if (schema_obj$is_enum(type_obj)) {
          ret$enumValues <- function(z1, args, z3) {
            include_deprecated <- args$includeDeprecated
            if (!is.null(include_deprecated)) {
              # warning("not listening to includeDeprecated enumValues")
            }

            enum_obj <- schema_obj$get_enum(type_obj)
            enum_values <- enum_obj$values
            if (is.null(enum_values)) return(NULL)
            enum_values
          }
        }

        # # INPUT_OBJECT only
        # inputFields: [__InputValue!]
        if (schema_obj$is_input_object(type_obj)) {
          ret$inputFields <- function(z1, z2, z3) {
            input_obj <- schema_obj$get_input_object(type_obj)
            input_obj_fields <- input_obj$fields
            if (is.null(input_obj_fields)) return(NULL)
            input_obj_fields
          }
        }

        ret
      }
    )
  ) %>%
  get_definition("__Type") ->
Introspection__Type



"
type __Field {
  name: String!
  description: String
  args: [__InputValue!]!
  type: __Type!
  isDeprecated: Boolean!
  deprecationReason: String
}
" %>%
  graphql2obj(
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
      ),
      .resolve = function(field_obj, schema_obj) {
        list(
          name = format(field_obj$name),
          description = field_obj$description,
          args = ifnull(field_obj$arguments, list()),
          type = field_obj$type,
          isDeprecated = FALSE,
          deprecationReason = NULL
        )
      }
    )
  ) %>%
  get_definition("__Field") ->
Introspection__Field



"
type __InputValue {
  name: String!
  description: String
  type: __Type!
  defaultValue: String
}
" %>%
  graphql2obj(
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
      ),
      .resolve = function(input_value, schema_obj) {
        list(
          name = format(input_value$name),
          description = input_value$description,
          type = input_value$type,
          defaultValue = input_value$defaultValue$value
        )
      }
    )
  ) %>%
  get_definition("__InputValue") ->
Introspection__InputValue




"
type __EnumValue {
  name: String!
  description: String
  isDeprecated: Boolean!
  deprecationReason: String
}
" %>%
  graphql2obj(
    "__EnumValue" = list(
      description = collapse(
        "One possible value for a given Enum. Enum values are unique values, not ",
        "a placeholder for a string or numeric value. However an Enum value is ",
        "returned in a JSON response as a string."
      ),
      .resolve = function(enum_value, schema_obj) {
        list(
          name = format(enum_value$name),
          description = enum_value$description,
          isDeprecated = FALSE,
          deprecationReason = NULL
        )
      }
    )
  ) %>%
  get_definition("__EnumValue") ->
Introspection__EnumValue



"
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
" %>%
  graphql2obj(
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
      ),
      .parse_value = function(type_obj, schema_obj) {
        if (inherits(type_obj, "NonNullType")) return("NON_NULL")
        if (inherits(type_obj, "ListType")) return("LIST")
        if (schema_obj$is_scalar(type_obj)) return("SCALAR")
        if (schema_obj$is_object(type_obj)) return("OBJECT")
        if (schema_obj$is_interface(type_obj)) return("INTERFACE")
        if (schema_obj$is_union(type_obj)) return("UNION")
        if (schema_obj$is_enum(type_obj)) return("ENUM")
        if (schema_obj$is_input_object(type_obj)) return("INPUT_OBJECT")
        str(type_obj)
        stop("this should not be reached")
      }
    )
  ) %>%
  get_definition("__TypeKind") ->
Introspection__TypeKind


"
type __Directive {
  name: String!
  description: String
  locations: [__DirectiveLocation!]!
  args: [__InputValue!]!
}
" %>%
  graphql2obj(
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
      ),
      .resolve = function(directive_obj, schema_obj) {
        list(
          name = format(directive_obj$name),
          description = directive_obj$description,
          locations = lapply(directive_obj$locations, format),
          args = ifnull(directive_obj$arguments, list())
        )
      }
    )
  ) %>%
  get_definition("__Directive") ->
Introspection__Directive


"
enum __DirectiveLocation {
  # Operations
  QUERY
  MUTATION
  # SUBSCRIPTION
  FIELD
  FRAGMENT_DEFINITION
  FRAGMENT_SPREAD
  INLINE_FRAGMENT

  # # Schema Definitions
  # SCHEMA
  # SCALAR
  # OBJECT
  # FIELD_DEFINITION
  # ARGUMENT_DEFINITION
  # INTERFACE
  # UNION
  # ENUM
  # ENUM_VALUE
  # INPUT_OBJECT
  # INPUT_FIELD_DEFINITION
}
" %>%
  graphql2obj(
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
    )
  ) %>%
  get_definition("__DirectiveLocation") ->
Introspection__DirectiveLocation



"
type QueryRootFields {
  __schema: __Schema!
  __type(name: String!): __Type
}
" %>%
  graphql2obj() %>%
  get_definition("QueryRootFields") ->
Introspection__QueryRootFields
Introspection__QueryRootFields$fields[[1]]$.show_in_format <- FALSE
Introspection__QueryRootFields$fields[[1]]$.allow_double_underscore <- TRUE
Introspection__QueryRootFields$fields[[2]]$.show_in_format <- FALSE
Introspection__QueryRootFields$fields[[2]]$.allow_double_underscore <- TRUE
