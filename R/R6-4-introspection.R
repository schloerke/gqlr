
#' @include R6-3.2-directives.R





TypeKindValues <- list(
  SCALAR = "SCALAR",
  OBJECT = "OBJECT",
  INTERFACE = "INTERFACE",
  UNION = "UNION",
  ENUM = "ENUM",
  INPUT_OBJECT = "INPUT_OBJECT",
  LIST = "LIST",
  NON_NULL = "NON_NULL"
)


"
type __Schema {
  types: [__Type!]!
  queryType: __Type!
  mutationType: __Type
  directives: [__Directive!]!
}
"
Introspection__Schema <- ObjectTypeDefinition$new(
  name = name_from_txt("__Schema"),
  description = collapse(
    "A GraphQL Schema defines the capabilities of a GraphQL server. It ",
    "exposes all available types and directives on the server, as well as ",
    "the entry points for query, mutation, and subscription operations." ,
    "  Subscriptions are not implemented in gqlr."
  ),
  fields = list(
    field_type_obj_from_txt(
      "types",
      "[__Type!]!",
      "A list of all types supported by this server."
    ),
    field_type_obj_from_txt(
      "queryType",
      "__Type!",
      "The type that query operations will be rooted at."
    ),
    field_type_obj_from_txt(
      "mutationType",
      "__Type",
      "The type that mutation operations will be rooted at."
    ),
    field_type_obj_from_txt(
      "directives",
      "[__Directive!]!",
      "A list of all directives supported by this server."
    )
  )
)
# Introspection__Schema$.str()

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
"
Introspection__Type <- ObjectTypeDefinition$new(
  name = name_from_txt("__Type"),
  fields = list(
    field_type_obj_from_txt(
      "kind",
      "__TypeKind!",
      .resolve = function(type) {
        # if (inherits(type, ))
      }
    ),
    field_type_obj_from_txt(
      "name",
      "String"
    ),
    field_type_obj_from_txt(
      "description",
      "String"
    ),
    field_type_obj_from_txt(
      "fields",
      "__Field!",
      arguments = list(
        InputValueDefinition$new(
          name = name_from_txt("includeDeprecated"),
          type = NamedType(name = name_from_txt("Boolean")),
          defaultValue = FALSE
        )
      ),
      .resolve = function(obj, includeDeprecated) {
        if (
          !(
            inherits(obj, "ObjectTypeDefinition") || inherits(obj, "InterfaceTypeDefinition")
          )
        ) {
          return(NULL)
        }

        # get field names %TODO
        obj$fields
      }
    ),

    field_type_obj_from_txt(
      "interfaces",
      "[__Type!]",
      .resolve = function(obj) {
        if (
          !(
            inherits(obj, "ObjectTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get field names %TODO
        obj$interfaces
      }
    ),
    field_type_obj_from_txt(
      "possibleTypes",
      "[__Type!]",
      .resolve = function(obj) {
        if (
          !(
            inherits(obj, "InterfaceTypeDefinition") || inherits(obj, "UnionTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get possible types %TODO
        obj
      }
    ),
    field_type_obj_from_txt(
      "enumValues",
      "[__EnumValue!]",
      arguments = list(
        InputValueDefinition$new(
          name = name_from_txt("includeDeprecated"),
          type = NamedType(name = name_from_txt("Boolean")),
          defaultValue = FALSE
        )
      ),
      .resolve = function(obj) {
        if (
          !(
            inherits(obj, "EnumTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get enum values %TODO
        obj
      }
    ),
    field_type_obj_from_txt(
      "inputFields",
      "[__InputValue!]",
      .resolve = function(obj) {
        if (
          !(
            inherits(obj, "InputObjectTypeDefinition")
          )
        ) {
          return(NULL)
        }
        # get input object fields %TODO
        obj
      }
    ),
    field_type_obj_from_txt(
      "ofType",
      "__Type",
      .resolve = function(obj) {
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
    )
  )
)
# Introspection__Type$.str()


"
type __Field {
  name: String!
  description: String
  args: [__InputValue!]!
  type: __Type!
  isDeprecated: Boolean!
  deprecationReason: String
}
"

Introspection__Field <- ObjectTypeDefinition$new(
  name = name_from_txt("__Field"),
  description = collapse(
    "Object and Interface types are described by a list of Fields, each of ",
    "which has a name, potentially a list of arguments, and a return type."
  ),
  fields = list(
    field_type_obj_from_txt(
      "name",
      "String!"
    ),
    field_type_obj_from_txt(
      "description",
      "String"
    ),
    field_type_obj_from_txt(
      "args",
      "[__InputValue!]!",
      "returns a List of __InputValue representing the arguments this field accepts"
    ),
    field_type_obj_from_txt(
      "type",
      "__Type!",
      "must return a __Type that represents the type of value returned by this field"
    ),
    field_type_obj_from_txt(
      "isDeprecated",
      "Boolean!",
      "returns true if this field should no longer be used, otherwise false"
    ),
    field_type_obj_from_txt(
      "deprecationReason",
      "String",
      "optionally provides a reason why this field is deprecated"
    )
  )
)
# Introspection__Field$.str()



"
type __InputValue {
  name: String!
  description: String
  type: __Type!
  defaultValue: String
}
"
Introspection__InputValue <- ObjectTypeDefinition$new(
  name = name_from_txt("__InputValue"),
  description = collapse(
    "Arguments provided to Fields or Directives and the input fields of an ",
    "InputObject are represented as Input Values which describe their type ",
    "and optionally a default value."
  ),
  fields = list(
    field_type_obj_from_txt(
      "name",
      "String!"
    ),
    field_type_obj_from_txt(
      "description",
      "String"
    ),
    field_type_obj_from_txt(
      "type",
      "__Type!",
      "must return a __Type that represents the type this input value expects"
    ),
    field_type_obj_from_txt(
      "defaultValue",
      "String",
      collapse(
        "may return a String encoding (using the GraphQL language) of the default value used by ",
        "this input value in the condition a value is not provided at runtime. If this input ",
        "value has no default value, returns null."
      )
    )
  )
)
# Introspection__InputValue$.str()


"
type __EnumValue {
  name: String!
  description: String
  isDeprecated: Boolean!
  deprecationReason: String
}
"
Introspection__EnumValue <- ObjectTypeDefinition$new(
  name = name_from_txt("__EnumValue"),
  description = collapse(
    "One possible value for a given Enum. Enum values are unique values, not ",
    "a placeholder for a string or numeric value. However an Enum value is ",
    "returned in a JSON response as a string."
  ),
  fields = list(
    field_type_obj_from_txt(
      "name",
      "String!"
    ),
    field_type_obj_from_txt(
      "description",
      "String"
    ),
    field_type_obj_from_txt(
      "isDeprecated",
      "Boolean!"
    ),
    field_type_obj_from_txt(
      "deprecationReason",
      "String"
    )
  )
)
# Introspection__EnumValue$.str()


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
"
Introspection__TypeKind <- (function(){

  value_description <- list(
    SCALAR = 'Indicates this type is a scalar.',
    OBJECT = 'Indicates this type is an object. `fields` and `interfaces` are valid fields.',
    INTERFACE = 'Indicates this type is an interface. `fields` and `possibleTypes` are valid fields.',
    UNION = 'Indicates this type is a union. `possibleTypes` is a valid field.',
    ENUM = 'Indicates this type is an enum. `enumValues` is a valid field.',
    INPUT_OBJECT = 'Indicates this type is an input object. `inputFields` is a valid field.',
    LIST = 'Indicates this type is a list. `ofType` is a valid field.',
    NON_NULL = 'Indicates this type is a non-null. `ofType` is a valid field.'
  )

  value_list <- list()
  for (val_name in names(value_description)) {
    value_list[[length(value_list) + 1]] <- EnumValueDefinition$new(
      name = name_from_txt(val_name),
      description = value_description[[val_name]]
    )
  }

  EnumTypeDefinition$new(
    name = name_from_txt("__TypeKind"),
    description = "An enum describing what kind of type a given `__Type` is.",
    values = value_list
  )
})()
# Introspection__TypeKind$.str()


"
type __Directive {
  name: String!
  description: String
  locations: [__DirectiveLocation!]!
  args: [__InputValue!]!
}
"
Introspection__Directive <- ObjectTypeDefinition$new(
  name = name_from_txt("__Directive"),
  description = collapse(
    "A Directive provides a way to describe alternate runtime execution and ",
    "type validation behavior in a GraphQL document.",
    "\n\nIn some cases, you need to provide options to alter GraphQL's ",
    "execution behavior in ways field arguments will not suffice, such as ",
    "conditionally including or skipping a field. Directives provide this by ",
    "describing additional information to the executor."
  ),
  fields = list(
    field_type_obj_from_txt(
      "name",
      "String!"
    ),
    field_type_obj_from_txt(
      "description",
      "String"
    ),
    field_type_obj_from_txt(
      "locations",
      "[__DirectiveLocation!]!",
      "returns a List of __DirectiveLocation representing the valid locations this directive may be placed"
    ),
    field_type_obj_from_txt(
      "args",
      "[__InputValue!]!",
      "returns a List of __InputValue representing the arguments this directive accepts"
    )
  )
)
# Introspection__Directive$.str()


"
enum __DirectiveLocation {
  QUERY
  MUTATION
  FIELD
  FRAGMENT_DEFINITION
  FRAGMENT_SPREAD
  INLINE_FRAGMENT
}
"
Introspection__DirectiveLocation <- (function() {
  enum_values <- list()
  for (key in names(DirectiveLocationNames)) {
    enum_values <- append(enum_values,
      EnumValueDefinition$new(
        name = DirectiveLocationNames[[key]],
        description = str_c("Location adjacent to a ", str_replace(tolower(key), "_", " "))
      )
    )
  }

  EnumTypeDefinition$new(
    name = name_from_txt("__DirectiveLocation"),
    description = collapse(
      "A Directive can be adjacent to many parts of the GraphQL language, a ",
      "__DirectiveLocation describes one such possible adjacencies."
    ),
    values = enum_values
  )
})()
