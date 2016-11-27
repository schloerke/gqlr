# type Foo implements Bar {
#   one: Type
#   two(argument: InputType!): Type
#   three(argument: InputType, other: String): Int
#   four(argument: String = "string"): String
#   five(argument: [String] = ["string", "string"]): String
#   six(argument: InputType = {key: "value"}): Type
# }
#
# interface Bar {
#   one: Type
#   four(argument: String = "string"): String
# }
#
# union Feed = Story | Article | Advert
#
# scalar CustomScalar
#
# enum Site {
#   DESKTOP
#   MOBILE
# }
#
# input InputType {
#   key: String!
#   answer: Int = 42
# }
#
# extend type Foo {
#   seven(argument: [String]): Type
# }
#







zSchema <- R6_from_args(
  "zSchema",
  " query: GraphQLObjectType;
    mutation?: ?GraphQLObjectType;
    directives?: ?Array<GraphQLDirective>;",
  public = list(
    initialize = function(query, mutation = NULL, directives = NULL) {
      self$query = query
      if (!missing(mutation)) {
        self$mutation = mutation
      }

      all_directives <- list(IncludeDirective, SkipDirective)

      if (!missing(directives)) {
        all_directives <- append(all_directives, directives)
      }
      self$directives <- all_directives


    },
    get_directive = function(name) {
      dirs <- self$directives
      dirNames <- lapply(dirs, "[[", "name") %>% unlist()
      matchesName = which(dirNames == name)
      if (length(matchesName) == 0) {
        stop0("there is no directive with name: ", name)
      }
      dirs[min(matchesName)]
    }
  ),
  private = list(
    validate = function() {

    }
  ),
  active = list()
)



SchemaObj <- R6Class(
  "SchemaAllInOne",
  private = list(
  ),
  public = list(
    isDone = FALSE, objects = list(), interfaces = list(), inputs = list(),
    typeMap = list(),

    initialize = function(documentObj = r6_from_list(eval_json(text), fnList), text = NULL, fnList = list()) {

      if (missing(text) & missing(documentObj)) {
        stop("Either 'documentObj' or 'text' must be supplied")
      }
      # if (!missing(text)) {
      #   documentObj <- eval_json(text, fnList)
      # } else if (missing(documentObj)) {
      #   stop("Either 'documentObj' or 'text' must be supplied")
      # }



      check_if_gqlr_object(documentObj, "Document")

      defs <- documentObj$definitions
      for (i in seq_along(defs)) {
        self$add(defs[[i]], fnList)
      }
      self$validate()
      invisible(self)
    },

    add = function(obj, fnList) {
      if (!inherit(obj, "AST")) {
        stop0(
          "Object must be of class AST to add to a Schema. Received: ",
          paste(class(obj), collapse = ", ")
        )
      }

      self$isDone <- FALSE

      groups = list(
        "ObjectTypeDefinition" = "objects",
        "InterfaceTypeDefinition" = "interfaces",
        "UnionTypeDefinition" = "objects",
        "ScalarTypeDefinition" = "objects",
        "EnumTypeDefinition" = "objects",
        "InputObjectTypeDefinition" = "inputs"
      )

      objKind <- obj$kind
      objName <- obj$name$value
      if (is.null(objName) ) {
        stop("To add an object to a Schema, it must have a name.")
      }

      objGroup = groups[[objKind]]

      if (objKind != "TypeExtensionDefinition") {
        if (is.null(objGroup)) {
          print(obj)
          stop0("Unknown object type requested to be added to schema. Type: ", objKind)
        }

        if ( objName %in% self$schema_names) {
          print(self$schema_names)
          cat('\n')
          print(obj)
          stop0(objKind, " already defined. ", objKind, ": ", objName)
        }

        self[[objGroup]][[objName]] <- obj
        return(invisible(self))
      }

      ## object is a TypeExtensionDefinition object
      #
      # "TypeExtensionDefinition",
      # " loc?: ?Location;
      #   definition: ObjectTypeDefinition;"
      #
      # "ObjectTypeDefinition",
      # " loc?: ?Location;
      #   name: Name;
      #   interfaces?: ?Array<NamedType>;
      #   fields: Array<FieldDefinition>;"

      extObj <- obj$definition
      extObjName <- extObj$name

      isInterface <- extObjName %in% names(self$interfaces)
      isObject <- extObjName %in% names(self$objects)

      extObjType <- NULL
      if (isInterface) {
        extObjType <- "interfaces"
      } else if (isObject) {
        extObjType <- "objects"
      } else {
        print(obj)
        stop0("object with name: ", extObjName, " can not be extended as it does not exist")
      }

      extObjFieldNames <- names(extObj$fieldTypes)
      originalObject <- self[[extObjType]][[extObjName]]
      objFieldNames <- originalObject$fields$name
      if (any(extObjFieldNames %in% objFieldNames)) {
        print(obj)
        stop0("object with name: ", extObjName, " can not stomp prior names")
      }

      originalObject$fieldTypes <- append(originalObject$fieldTypes, extObj$fieldTypes)
      originalObject$fieldArguments <- append(originalObject$fieldArguments, extObj$fieldArguments)

      self[[extObjType]][[extObjName]] <- originalObject

      return(invisible(self))
    },


    validate = function() {
      # This must be done at the very end.
      # TypeExtensionDefinitions screw everything up as something could be valid before,
      # but not after.

      # get the names for each group
      allNames <- self$schema_names

      # make sure none of the names are duplicated
      if (any(duplicated(allNames))) {
        duplicatedNames <- allNames[duplicated(allNames)]
        print(duplicatedNames)
        stop0("duplicated names are above.  Schema names may only be supplied once")
      }

      interfaceNames <- names(self$interfaces)
      objectNames <- names(self$objects)
      check_is_valid_type_obj <- function(typeObj) {
        if (typeObj$'_kind' != "Type" ) {
          stop0("object fieldType is not 'Type'. Received: ", typeObj[['_kind']])
        }

        type <- typeObj$type
        if (type %in% c("Type", "Int", "String")) {
          # good
        } else {
          stop0("Invalid field type received: |", type, "|. Known field types: |", paste(objectNames, collapse = ", "), "|")
        }
      }

      # for every schema object
      schemaObj$objects <- lapply(schemaObj$objects, function(objectObj) {

        # Conversely, GraphQL type system authors must not define any types, fields, arguments, or any other type system artifact with two leading underscores.
        # TODO

        # for UnionTypeDefinition
        lapply(objectObj$types, check_is_valid_type_obj)

        # for ObjectTypeDefinition
        lapply(objectObj$fieldTypes, check_is_valid_type_obj)

        # for ObjectTypeDefinition arguments
        lapply(objectObj$fieldArguments, function(fieldArgObj) {
          # fieldArgObj = three(argument: InputType, other: String = "string"): Int

          lapply(fieldArgObj, function(argObj) {
            # argObj = {argument: InputType, other: String = "string"}

            lapply(argObj, function(argValObj) {
              argValObj <- as.list(argValObj)
              # argObj = {String = "string"}
              argType <- argValObj$type

              defaultValueKind <- argValObj$defaultValueKind

              # TODO. find proper types
            })

          })
        })

        # lapply(objectObj$fieldArguments, function(argObj) {
        #
        # })



        # // Assert each interface field is implemented.
        lapply(objectObj$interfaces, function(objectInterfaceObj) {
          interfaceType <- objectInterfaceObj$type

          # // Assert interface field exists on object.
          if (!(interfaceType %in% interfaceNames)) {
            print(objectObj)
            stop0("Schema object '", objectObj$name, "' is trying to implement a missing interface '", interfaceType, "'")
          }
          interfaceObj <- schemaObj$interfaces[[interfaceType]]

          # // Assert interface field type is satisfied by object field type,
          # by being a valid subtype. (covariant)
          lapply(names(interfaceObj$fieldTypes), function(interfaceFieldName) {
            interFieldObj <- interfaceObj$fieldTypes[[interfaceFieldName]]

          })


          # for each field of the interface, make sure it's added or stomped
          for (name in names(interfaceObj$fieldTypes)) {
            # if the field doesn't exist, add it
            if (is.null(objectObj$fieldTypes[[name]])) {
              objectObj$fieldTypes[[name]] <<- interfaceObj$fieldTypes[[name]]
              objectObj$fieldArguments[[name]] <<- interfaceObj$fieldArguments[[name]]
            }
          }
        })

        objectObj
      })

      schemaObj$interfaces <- NULL

      schemaObj$isDone <- TRUE
      schemaObj

    },

    introspection = function() {
      # type __Schema {
      #   types: [__Type!]!
      #   queryType: __Type!
      #   mutationType: __Type
      #   directives: [__Directive!]!
      # }
      # __schema : __Schema!
      # __type(name: String!) : __Type
    }

  ),
  active = list(
    schema_names = function() {
      unlist(c(
        names(self$objects),
        names(self$interfaces),
        names(self$inputs)
      ))
    }
  )
)




#
# Introspection__Schema <- R6_from_args(
#   inherit = AST,
#   "__Schema",
#   " types: Array<__Type>;
#     queryType: __Type;
#     mutationType: ?__Type;
#     directives: ?Array<__Directive>;"
# }
#
# Introspection__Type <- R6_from_args(
#   inherit = AST,
#   "__Type",
#   " kind: __TypeKind;
#     name: string;
#     description: string;"
# )
# type __Type {
#   kind: __TypeKind!
#   name: String
#   description: String
#
#   # OBJECT and INTERFACE only
#   fields(includeDeprecated: Boolean = false): [__Field!]
#
#   # OBJECT only
#   interfaces: [__Type!]
#
#   # INTERFACE and UNION only
#   possibleTypes: [__Type!]
#
#   # ENUM only
#   enumValues(includeDeprecated: Boolean = false): [__EnumValue!]
#
#   # INPUT_OBJECT only
#   inputFields: [__InputValue!]
#
#   # NON_NULL and LIST only
#   ofType: __Type
# }
#


DirectiveLocationNames <- (function() {
  ret <- list()
  for (name in c(
    # operations
    "QUERY",
    "MUTATION",
    "SUBSCRIPTION",
    "FIELD",
    "FRAGMENT_DEFINITION",
    "FRAGMENT_SPREAD",
    "INLINE_FRAGMENT",
    # Schema Definitions
    "SCHEMA",
    "SCALAR",
    "OBJECT",
    "FIELD_DEFINITION",
    "ARGUMENT_DEFINITION",
    "INTERFACE",
    "UNION",
    "ENUM",
    "ENUM_VALUE",
    "INPUT_OBJECT",
    "INPUT_FIELD_DEFINITION"
  )) {
    ret[[name]] <- Name$new(value = name)
  }
  ret
})()


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
  name = Name$new(value = "__Schema"),
  description = collapse(
    "A GraphQL Schema defines the capabilities of a GraphQL server. It ",
    "exposes all available types and directives on the server, as well as ",
    "the entry points for query, mutation, and subscription operations." ,
    "  Subscriptions are not implemented in gqlr."
  ),
  fields = list(
    FieldDefinition$new(
      description = "A list of all types supported by this server.",
      name = Name$new(value = "types"),
      type = NonNullType$new(type = ListType$new(type = NonNullType$new(type = NamedType$new(name = Name$new(value = "__Type")))))
    ),
    FieldDefinition$new(
      description = "The type that query operations will be rooted at.",
      name = Name$new(value = "queryType"),
      type = NonNullType$new(type = NamedType$new(name = Name$new(value = "__Type")))
    ),
    FieldDefinition$new(
      description = "The type that mutation operations will be rooted at.",
      name = Name$new(value = "mutationType"),
      type = NamedType$new(name = Name$new(value = "__Type"))
    ),
    FieldDefinition$new(
      description = "A list of all directives supported by this server.",
      name = Name$new(value = "directives"),
      type = NonNullType$new(type = ListType$new(type = NonNullType$new(type = NamedType$new(name = Name$new(value = "__Directive")))))
    )
  )
)
# Introspection__Schema$.str()


"
type __Directive {
  name: String!
  description: String
  locations: [__DirectiveLocation!]!
  args: [__InputValue!]!
}
"
Introspection__Directive <- ObjectTypeDefinition$new(
  name = Name$new(value = "__Directive"),
  description = collapse(
    "A Directive provides a way to describe alternate runtime execution and ",
    "type validation behavior in a GraphQL document.",
    "\n\nIn some cases, you need to provide options to alter GraphQL's ",
    "execution behavior in ways field arguments will not suffice, such as ",
    "conditionally including or skipping a field. Directives provide this by ",
    "describing additional information to the executor."
  ),
  fields = list(
    FieldDefinition$new(
      name = Name$new(value = "name"),
      type = NonNullType$new(type = NamedType$new(name = Name$new(value = "String")))
    ),
    FieldDefinition$new(
      name = Name$new(value = "description"),
      type = NamedType$new(name = Name$new(value = "String"))
    ),
    FieldDefinition$new(
      name = Name$new(value = "locations"),
      type = NonNullType$new(type = ListType$new(
        type = NonNullType$new(type = NamedType$new(name = Name$new(value = "__DirectiveLocation")))
      ))
    ),
    FieldDefinition$new(
      name = Name$new(value = "args"),
      type = NonNullType$new(type = ListType$new(
        type = NonNullType$new(type = NamedType$new(name = Name$new(value = "__InputValue")))
      ))
    )
  )
)
# Introspection__Directive$.str()


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
    name = Name$new(value = "__DirectiveLocation"),
    description = collapse(
      "A Directive can be adjacent to many parts of the GraphQL language, a ",
      "__DirectiveLocation describes one such possible adjacencies."
    ),
    values = enum_values
  )
})()



Introspection__Type <- ObjectTypeDefinition$new(
  name = Name$new(value = "__Type"),
  fields = list(
    FieldDefinition$new(
      name = Name$new(value = "kind"),
      type = NonNullType$new(type = NamedType$new(name = Name$new(value = "__TypeKind"))),
      .resolve = function(type) {
        # if (inherits(type, ))
      }
    ),
    FieldDefinition$new(
      name = Name$new(value = "name"),
      type = NamedType$new(name = Name$new(value = "String"))
    ),
    FieldDefinition$new(
      name = Name$new(value = "description"),
      type = NamedType$new(name = Name$new(value = "String"))
    ),
    FieldDefinition$new(
      name = Name$new(value = "fields"),
      type = NonNullType(type = NamedType$new(name = Name$new(value = "__Field"))),
      .resolve = function(type, includeDeprecated) {
        if (
          !(
            inherits(type, "ObjectTypeDefinition") || inherits(type, "InterfaceTypeDefinition")
          )
        ) {
          return(NULL)
        }

        # get field names %TODO
        type$fields

      }
    )

  )
)
# Introspection__Type$.str()



introspection_spec <- function(){

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
}"
}

introspection_imp <- function() {
  list(
    "__Schema" = list(
      .description = collapse(
        'A GraphQL Schema defines the capabilities of a GraphQL server. It ',
        'exposes all available types and directives on the server, as well as ',
        'the entry points for query, mutation, and subscription operations.'
      ),

      types = with_description(
        description = 'A list of all types supported by this server.',
        function(schemaObj, ...) {
          schemaObj$typeMap
        }
      ),

      queryType = with_description(
        description = 'The type that query operations will be rooted at.',
        function(schemaObj, ...) {
          schemaObj$queryType
        }
      ),

      mutationType = with_description(
        description = collapse(
          'If this server supports mutation, the type that ',
          'mutation operations will be rooted at.'
        ),
        function(schemaObj, ...) {
         schemaObj$mutationType
        }
      ),

      subscriptionType = with_description(
        description = collapse(
          'If this server support subscription, the type that ',
          'subscription operations will be rooted at.'
        ),
        function(schemaObj, ...) {
          schemaObj$subscriptionType
        }
      ),

      directives = with_description(
        description = 'A list of all directives supported by this server.',
        function(schemaObj) {
          schemaObj$directives
        }
      )
    ),


    "__Type" = list(
      .description = collapse(
        'The fundamental unit of any GraphQL Schema is the type. There are ',
        'many kinds of types in GraphQL as represented by the `__TypeKind` enum.',
        '\n\nDepending on the kind of a type, certain fields describe ',
        'information about that type. Scalar types provide no information ',
        'beyond a name and description, while Enum types provide their values. ',
        'Object and Interface types provide the fields they describe. Abstract ',
        'types, Union and Interface, provide the Object types possible ',
        'at runtime. List and NonNull types compose other types.'
      ),

      kind = function(obj, ...) {
        print("fix type values")
        browser()
        if (inherits(obj, "scalar")) {
          return("scalar")
        }
        # if (type instanceof GraphQLScalarType) {
        #   return TypeKind.SCALAR;
        # } else if (type instanceof GraphQLObjectType) {
        #   return TypeKind.OBJECT;
        # } else if (type instanceof GraphQLInterfaceType) {
        #   return TypeKind.INTERFACE;
        # } else if (type instanceof GraphQLUnionType) {
        #   return TypeKind.UNION;
        # } else if (type instanceof GraphQLEnumType) {
        #   return TypeKind.ENUM;
        # } else if (type instanceof GraphQLInputObjectType) {
        #   return TypeKind.INPUT_OBJECT;
        # } else if (type instanceof GraphQLList) {
        #   return TypeKind.LIST;
        # } else if (type instanceof GraphQLNonNull) {
        #   return TypeKind.NON_NULL;
        # }
        stop0('Unknown kind of type: ', type)
      },

      fields = function(typeObj, includeDeprecated = FALSE, ...) {
        print("fix types")
        browser()

        if (! (inherits(typeObj, "object") || inherits(typeObj, "interface"))) {
          return(NULL)
        }
        fieldMap = typeObj$fields
        if (!includeDeprecated) {
          fieldMap <- Filter(function(fieldVal) {
            !is.null(fieldVal$deprecationReason)
          }, fieldMap)
        }
        fieldMap
      },

      interfaces = function(typeObj, ...) {
        if (inherits(typeObj, "object")) {
          typeObj$interfaces
        } else {
          NULL
        }
      },

      possibleTypes = function(typeObj, args, context, schema, ...) {
        if (inherits(typeObj, "interface") || inherits(typeObj, "union")) {
          schema$possibleTypes
        } else {
          NULL
        }
      },

      enumValues = function(typeObj, includeDeprecated = FALSE, ...) {
        if (inherits(typeObj, "enum")) {
          values = typeObj$values
          if (!includeDeprecated) {
            values = Filter(function(enumVal) {
              ! is.null(enumVal$deprecationReason)
            }, values)
          }
          return(values)
        }
        return(NULL)
      },

      inputFields = function(typeObj, ...) {
        if (inherits(typeObj, "inputobject")) {
          return(typeObj$fields)
        }
        return(NULL)
      }
      # ofType: { type: __Type }
    ),


    "__Field" = list(
      .description = collapse(
        'Object and Interface types are described by a list of Fields, each of ',
        'which has a name, potentially a list of arguments, and a return type.'
      ),

      args = function(fieldObj, ...) {
        ret <- fieldObj$args
        if (is.null(ret)) {
          ret <- list()
        }
        return(ret)
      },

      isDeprecated = function(fieldObj, ...) {
        !is.null(fieldObj$deprecationReason)
      }
    ),


    "__InputValue" = list(
      .description = collapse(
        'Arguments provided to Fields or Directives and the input fields of an ',
        'InputObject are represented as Input Values which describe their type ',
        'and optionally a default value.'
      ),

      # ,
      defaultValue = with_description(
        description = collapse(
          'A GraphQL-formatted string representing the default value for this ',
          'input value.'
        ),
        function(inputValueObj, ...) {
          if (is.null(inputValueObj$defaultValue)) {
            return(NULL)
          }
          # print(astFromValue(inputVal.defaultValue, inputVal))
          return(inputValueObj$defaultValue)
        }
      )
    ),


    "__EnumValue" = list(
      .description = collapse(
        'One possible value for a given Enum. Enum values are unique values, not ',
        'a placeholder for a string or numeric value. However an Enum value is ',
        'returned in a JSON response as a string.'
      ),

      isDeprecated = function(fieldObj, ...) {
        !is.null(fieldObj$deprecationReason)
      }
    ),


    "__TypeKind" = list(
      .description = 'An enum describing what kind of type a given `__Type` is.',

      SCALAR = 'Indicates this type is a scalar.',
      OBJECT = 'Indicates this type is an object. `fields` and `interfaces` are valid fields.',
      INTERFACE = 'Indicates this type is an interface. `fields` and `possibleTypes` are valid fields.',
      UNION = 'Indicates this type is a union. `possibleTypes` is a valid field.',
      ENUM = 'Indicates this type is an enum. `enumValues` is a valid field.',
      INPUT_OBJECT = 'Indicates this type is an input object. `inputFields` is a valid field.',
      LIST = 'Indicates this type is a list. `ofType` is a valid field.',
      NON_NULL = 'Indicates this type is a non-null. `ofType` is a valid field.'
    ),


    "__Directive" = list(
      .description = collapse(
        'A Directive provides a way to describe alternate runtime execution and ',
        'type validation behavior in a GraphQL document.',
        '\n\nIn some cases, you need to provide options to alter GraphQL’s ',
        'execution behavior in ways field arguments will not suffice, such as ',
        'conditionally including or skipping a field. Directives provide this by ',
        'describing additional information to the executor.'
      ),
      args = function(directiveObj, ...) {
        ret = directiveObj$args
        if (is.null(ret)) {
          ret <- list()
        }
        return(ret)
      }
    ),


    "__DirectiveLocation" = list(
      .description = collapse(
        'A Directive can be adjacent to many parts of the GraphQL language, a ',
        '__DirectiveLocation describes one such possible adjacencies.'
      ),

      QUERY               = 'Location adjacent to a query operation.',
      MUTATION            = 'Location adjacent to a mutation operation.',
      SUBSCRIPTION        = 'Location adjacent to a subscription operation.',
      FIELD               = 'Location adjacent to a field.',
      FRAGMENT_DEFINITION = 'Location adjacent to a fragment definition.',
      FRAGMENT_SPREAD     = 'Location adjacent to a fragment spread.',
      INLINE_FRAGMENT     = 'Location adjacent to an inline fragment.'
    )
  )
}




enum_value_upgrade = function(key, obj = NULL) {
  if (typeof(obj) %in% c("character", "NULL")) {
    obj = list(description = obj)
  }
  if (typeof(obj) != "list") {
    stop("'obj' type must be a list or a plain character")
  }
  if (is.null(obj$key)) {
    obj$key = key
  }
  if (is.null(obj$key)) {
    obj$isDeprecated = FALSE
  }
}








#
#
#
# # field_from_list <- function(description = NULL, type = NULL, resolve = NULL, arguments = ) {
# #   FieldDefinition$new(
# #     description = description,
# #     type = type,
# #     resolve = resolve
# #   )
# # }
# object_from_list <- function(name = NULL, description = NULL, fields = NULL) {
#   ObjectTypeDefinition$new(
#     name = Name$new(value = name),
#     description = description,
#     fields = lapply(do.call, field_from_list, what = FieldDefinition$new)
#   )
# }
#
#
#
# Introspection__Schema = object_from_list(list(
#   name = "__Schema",
#   description = str_c(
#     'A GraphQL Schema defines the capabilities of a GraphQL server. It ',
#     'exposes all available types and directives on the server, as well as ',
#     'the entry points for query, mutation, and subscription operations.'
#   ),
#   fields = list(
#     types = list(
#       description = 'A list of all types supported by this server.',
#       type = NULL, # TODO Add type arg
#       resolve = function(schemaObj, ...) {
#         unname(schemaObj$typeMap)
#       }
#     ),
#
#   )
# ))
#
# Introspection__Type = R6_from_args(
#   inherit = AST,
#   "__Type",
#   " types: Array<__Type>;
#     queryType: __Type;
#     mutationType?: ?__Type;
#     directives: [__Directive];"
# )
