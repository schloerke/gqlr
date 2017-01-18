#' @include R6-3.2-directives.R
#' @include graphql_json.R
#' @include R6-Schema.R

# setup_instrospection <- function() {

"
type __Schema {
  types: [__Type!]!
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
  QUERY
  MUTATION
  FIELD
  FRAGMENT_DEFINITION
  FRAGMENT_SPREAD
  INLINE_FRAGMENT
}
" %>%
  graphql2obj(fn_list = list(
    "__Schema" = list(
      .description = collapse(
        "A GraphQL Schema defines the capabilities of a GraphQL server. It ",
        "exposes all available types and directives on the server, as well as ",
        "the entry points for query, mutation, and subscription operations." ,
        "  Subscriptions are not implemented in gqlr."
      ),
      "types" = desc_fn(
        "A list of all types supported by this server.",
        default_resolve_key_value
      ),
      "queryType" = desc_fn(
        "The type that query operations will be rooted at.",
        default_resolve_key_value
      ),
      "mutationType" = desc_fn(
        "The type that mutation operations will be rooted at.",
        default_resolve_key_value
      ),
      "directives" = desc_fn(
        "A list of all directives supported by this server.",
        default_resolve_key_value
      )
    ),

    "__Type" = list(
      fields = function(obj, includeDeprecated) {
        if (
          !(
            inherits(obj, "ObjectTypeDefinition") || inherits(obj, "InterfaceTypeDefinition")
          )
        ) {
          return(NULL)
        }

        # get field names %TODO
        obj$fields
      },
      interfaces = function(obj) {
        if (
          !(
            inherits(obj, "ObjectTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get field names %TODO
        obj$interfaces
      },
      possibleTypes = function(obj) {
        if (
          !(
            inherits(obj, "InterfaceTypeDefinition") || inherits(obj, "UnionTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get possible types %TODO
        obj
      },
      enumValues = function(obj) {
        if (
          !(
            inherits(obj, "EnumTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get enum values %TODO
        obj
      },
      inputFields = function(obj) {
        if (
          !(
            inherits(obj, "InputObjectTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get input object fields %TODO
        obj
      },
      ofType = function(obj) {
        if (
          !(
            inherits(obj, "NonNullType") || inherits(obj, "ListType")
          )
        ) {
          return(NULL)
        }
        # get type value %TODO
        obj
      }
    ),


    "__Field" = list(
      .description = collapse(
        "Object and Interface types are described by a list of Fields, each of ",
        "which has a name, potentially a list of arguments, and a return type."
      ),
      args = "returns a List of __InputValue representing the arguments this field accepts",
      type = "must return a __Type that represents the type of value returned by this field",
      isDeprecated = "returns true if this field should no longer be used, otherwise false",
      deprecationReason = "optionally provides a reason why this field is deprecated"
    ),

    "__InputValue" = list(
      .description = collapse(
        "Arguments provided to Fields or Directives and the input fields of an ",
        "InputObject are represented as Input Values which describe their type ",
        "and optionally a default value."
      ),
      type = "must return a __Type that represents the type this input value expects",
      defaultValue = collapse(
        "may return a String encoding (using the GraphQL language) of the default value used by ",
        "this input value in the condition a value is not provided at runtime. If this input ",
        "value has no default value, returns null."
      )
    ),

    "__EnumValue" = list(
      .description = collapse(
        "One possible value for a given Enum. Enum values are unique values, not ",
        "a placeholder for a string or numeric value. However an Enum value is ",
        "returned in a JSON response as a string."
      )
    ),

    "__TypeKind" = list(
      .description = "An enum describing what kind of type a given `__Type` is.",
      SCALAR = "Indicates this type is a scalar.",
      OBJECT = "Indicates this type is an object. `fields` and `interfaces` are valid fields.",
      INTERFACE = "Indicates this type is an interface. `fields` and `possibleTypes` are valid fields.",
      UNION = "Indicates this type is a union. `possibleTypes` is a valid field.",
      ENUM = "Indicates this type is an enum. `enumValues` is a valid field.",
      INPUT_OBJECT = "Indicates this type is an input object. `inputFields` is a valid field.",
      LIST = "Indicates this type is a list. `ofType` is a valid field.",
      NON_NULL = "Indicates this type is a non-null. `ofType` is a valid field."
    ),

    "__Directive" = list(
      .description = collapse(
        "A Directive provides a way to describe alternate runtime execution and ",
        "type validation behavior in a GraphQL document.",
        "\n\nIn some cases, you need to provide options to alter GraphQL's ",
        "execution behavior in ways field arguments will not suffice, such as ",
        "conditionally including or skipping a field. Directives provide this by ",
        "describing additional information to the executor."
      ),
      locations = "returns a List of __DirectiveLocation representing the valid locations this directive may be placed",
      args = "returns a List of __InputValue representing the arguments this directive accepts"
    ),

    "__DirectiveLocation" = list(
      .description = collapse(
        "A Directive can be adjacent to many parts of the GraphQL language, a ",
        "__DirectiveLocation describes one such possible adjacencies."
      ),
      QUERY = "Location adjacent to a query",
      MUTATION = "Location adjacent to a mutation",
      FIELD = "Location adjacent to a field",
      FRAGMENT_DEFINITION = "Location adjacent to a fragment definition",
      FRAGMENT_SPREAD = "Location adjacent to a fragment spread",
      INLINE_FRAGMENT = "Location adjacent to a inline fragment"
    )
  )) %>%
  magrittr::extract2("definitions") ->
introspection_definitions


IIntrospection__Schema <<- introspection_definitions[[1]]
IIntrospection__Type <<- introspection_definitions[[2]]
IIntrospection__Field <<- introspection_definitions[[3]]
IIntrospection__InputValue <<- introspection_definitions[[4]]
IIntrospection__EnumValue <<- introspection_definitions[[5]]
IIntrospection__TypeKind <<- introspection_definitions[[6]]
IIntrospection__Directive <<- introspection_definitions[[7]]
IIntrospection__DirectiveLocation <<- introspection_definitions[[8]]


# }
