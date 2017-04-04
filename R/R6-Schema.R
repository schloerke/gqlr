#' @include R6--definition.R
#' @include R6-3.2-directives.R
#' @include R6-3.1.1-types-scalars.R


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







# zSchema <- R6_from_args(
#   "zSchema",
#   " query: GraphQLObjectType;
#     mutation?: ?GraphQLObjectType;
#     directives?: ?Array<GraphQLDirective>;",
#   public = list(
#     initialize = function(query, mutation = NULL, directives = NULL) {
#       self$query = query
#       if (!missing(mutation)) {
#         self$mutation = mutation
#       }
#
#       all_directives <- list(IncludeDirective, SkipDirective)
#
#       if (!missing(directives)) {
#         all_directives <- append(all_directives, directives)
#       }
#       self$directives <- all_directives
#
#
#     },
#     get_directive = function(name) {
#       dirs <- self$directives
#       dirNames <- lapply(dirs, "[[", "name") %>% unlist()
#       matchesName = which(dirNames == name)
#       if (length(matchesName) == 0) {
#         stop0("there is no directive with name: ", name)
#       }
#       dirs[min(matchesName)]
#     }
#   ),
#   private = list(
#     validate = function() {
#
#     }
#   ),
#   active = list()
# )


desc_fn <- function(desc, fn, fn_name = "resolve") {
  if (missing(desc) || missing(fn)) {
    stop("both 'desc' and 'fn' must be supplied")
  }
  ret <- list()
  ret$description <- desc
  ret[[fn_name]] <- fn
  ret
}



GQLRSchema <- R6Class(
  "GQLRSchema",
  private = list(

    # check_and_add_to_directives = function(obj) {
    #
    #   # Schema Definitions
    #   # "SCHEMA",
    #   if (inherits(obj, "SchemaDefinition")) {
    #     if (!is.null(obj$directives)) {
    #       stop("not implemented")
    #     }
    #
    #   # "SCALAR",
    #   } else if (
    #     inherits(obj, "ScalarTypeDefinition") ||
    #     FALSE
    #   ) {
    #     if (!is.null(obj$directives)) {
    #       if (length(obj$directives) > 0) {
    #         private$has_directive_list[[obj$name$value]] <- obj
    #         return(invisible(self))
    #       }
    #     }
    #
    #
    #   # "OBJECT",
    #   # "FIELD_DEFINITION",
    #   } else if (
    #     inherits(obj, "ObjectTypeDefinition")
    #   ) {
    #
    #   }
    #   # inherits(obj, "ObjectTypeDefinition") ||
    #   #
    #   # "ARGUMENT_DEFINITION",
    #   # "INTERFACE",
    #   # "UNION",
    #   # "ENUM",
    #   # "ENUM_VALUE",
    #   # "INPUT_OBJECT",
    #   # "INPUT_FIELD_DEFINITION"
    #
    # },


    is_done = FALSE,

    schema_definition = NULL,

    scalars = list(),
    enums = list(),
    objects = list(),
    interfaces = list(),
    unions = list(),
    input_objects = list(),
    directives = list(),
    values = list(),

    # has_directive_list = list(),
    exists_by_name = function(name_obj, obj_list_txt) {
      name_val <- self$name_helper(name_obj)
      name_val %in% names(private[[obj_list_txt]])
    },
    get_by_name = function(name_obj, obj_list_txt) {
      name_val <- self$name_helper(name_obj)
      private[[obj_list_txt]][[name_val]]
    },

    objects_that_implement_interface_list = list(),

    types = list()
  ),
  public = list(

    initialize = function(document_obj, ...) {

      self$add(Int)
      self$add(Float)
      self$add(String)
      self$add(Boolean)
      # self$add(ID)

      self$add(SkipDirective)
      self$add(IncludeDirective)


      if (!missing(document_obj)) {
        if (inherits(document_obj, "character")) {
          document_obj <- graphql2obj(document_obj)
        }

        lapply(document_obj$definitions, self$add)
      }

      return(invisible(self))
    },

    # returns a NamedType
    get_inner_type = function(type_obj) {
      if (is.character(type_obj)) {
        return(
          NamedType$new(name = Name$new(value = type_obj))
        )
      }

      while(
        inherits(type_obj, "NonNullType") ||
        inherits(type_obj, "ListType")
      ) {
        type_obj <- type_obj$type
      }
      type_obj
    },

    name_helper = function(name_obj) {
      if (is.character(name_obj)) {
        name_obj
      } else if (inherits(name_obj, "Name")) {
        name_obj$value
      } else if (inherits(name_obj, "Type")) {
        # non null, list, named
        name_obj <- self$get_inner_type(name_obj)
        name_obj$name$value
      } else {
        stop("must supply a string, Name, or NamedType")
      }
    },

    is_scalar       = function(name) private$exists_by_name(name, "scalars"),
    is_enum         = function(name) private$exists_by_name(name, "enums"),
    is_object       = function(name) private$exists_by_name(name, "objects"),
    is_interface    = function(name) private$exists_by_name(name, "interfaces"),
    is_union        = function(name) private$exists_by_name(name, "unions"),
    is_input_object = function(name) private$exists_by_name(name, "input_objects"),
    is_directive    = function(name) private$exists_by_name(name, "directives"),
    is_value        = function(name) private$exists_by_name(name, "values"),

    is_object_interface_or_union = function(name) {
      return(
        self$is_object(name) ||
        self$is_interface(name) ||
        self$is_union(name)
      )
    },

    get_schema_definition = function(def_name) {
      schema_def <- private$schema_definition
      if (is.null(schema_def)) {
        stop("schema definition not found")
      }
      schema_def$.get_definition_type(def_name)
    },
    get_query_object = function() {
      query_type <- self$get_schema_definition("query")
      self$get_object_interface_or_union(query_type)
    },

    get_scalar       = function(name) private$get_by_name(name, "scalars"),
    get_enum         = function(name) private$get_by_name(name, "enums"),
    get_object       = function(name) private$get_by_name(name, "objects"),
    get_interface    = function(name) private$get_by_name(name, "interfaces"),
    get_union        = function(name) private$get_by_name(name, "unions"),
    get_input_object = function(name) private$get_by_name(name, "input_objects"),
    get_directive    = function(name) private$get_by_name(name, "directives"),
    get_value        = function(name) private$get_by_name(name, "values"),

    get_scalars       = function() private$scalars,
    get_enums         = function() private$enums,
    get_objects       = function() private$objects,
    get_interfaces    = function() private$interfaces,
    get_unions        = function() private$unions,
    get_input_objects = function() private$input_objects,
    get_directives    = function() private$directives,
    get_values        = function() private$values,

    get_type         = function(name) {
      ifnull(
        self$get_scalar(name),        ifnull(
        self$get_enum(name),          ifnull(
        self$get_object(name),        ifnull(
        self$get_interface(name),     ifnull(
        self$get_union(name),         ifnull(
        self$get_input_object(name),  ifnull(
        self$get_directive(name),
        self$get_value(name)
      )))))))
    },


    # returns a char vector or NULL of names of objs that implement a particular interface
    objects_that_implement_interface = function(name) {
      name_val <- self$name_helper(name)
      names(private$objects_that_implement_interface_list[[name_val]])
    },

    get_possible_types = function(name_obj) {
      name_val <- self$name_helper(name_obj)
      if (!is.null(self$get_object(name_val))) {
        return(name_val)
      }
      if (!is.null(self$get_interface(name_val))) {
        return(self$objects_that_implement_interface(name_val))
      }
      union_obj <- self$get_union(name_val)
      if (!is.null(union_obj)) {
        union_names <- unlist(lapply(union_obj$types, self$name_helper))
        return(union_names)
      }
      stop("type: ", name_val, " is not an object, interface, or union")

    },

    # interface_is_super_of = function(interface_obj, name_obj) {
    #
    # },
    # interface_can_implement_type = function(interface_obj, name_obj) {
    #   self_interfaces <- ifnull(self$interfaces, list())
    #   for (interface in self_interfaces) {
    #     if (self$interface_is_super_of(name_obj)) {
    #       return(TRUE)
    #     }
    #   }
    #   return(FALSE)
    # },

    # .does_object_implement_interface_type = function(object, interface_type, ..., oh) {
    #
    #   object_interfaces <- object$interfaces
    #   if (is.null(object_interfaces)) return(FALSE)
    #
    #   for (object_interface in object_interfaces) {
    #     if (object_interface$.matches(interface_type)) {
    #       return(TRUE)
    #     }
    #   }
    #   return(FALSE)
    # },



    get_scalar_or_enum = function(name_obj) {
      name_val <- self$name_helper(name_obj)
      ifnull(
        self$get_scalar(name_val),
        self$get_enum(name_val)
      )
    },
    get_object_interface_or_union = function(name_obj) {
      name_val <- self$name_helper(name_obj)
      ifnull(
        self$get_object(name_val),
        ifnull(
          self$get_interface(name_val),
          self$get_union(name_val)
        )
      )

      # recursively go until the named type is found
      # self$get_object_interface_or_union(type_obj$type)
    },

    # is_input_type_coercible = function(from_type, to_type) {
    #   # if ()
    # },

    # get_directive_objs = function() private$has_directive_list,


    # initialize = function(
    #   document_obj = r6_from_list(graphql2list(text), fnList),
    #   text = NULL,
    #   fnList = list()
    # ) {
    #
    #   if (missing(text) & missing(document_obj)) {
    #     stop("Either 'document_obj' or 'text' must be supplied")
    #   }
    #
    #   if(!inherits(document_obj, "Document")) {
    #     stop("'document_obj' must be supplied")
    #   }
    #
    #   defs <- documentObj$definitions
    #   for (i in seq_along(defs)) {
    #     self$add(defs[[i]], fnList)
    #   }
    #   self$validate()
    #   invisible(self)
    # },
    add = function(obj, fnList) {
      if (!inherits(obj, "AST")) {
        stop0(
          "Object must be of class AST to add to a Schema. Received: ",
          paste(class(obj), collapse = ", ")
        )
      }

      if (inherits(obj, "SchemaDefinition")) {
        if (!is.null(private$schema_definition)) {
          stop("Existing schema definition already found. Can not add a second definition")
        }
        private$schema_definition <- obj
        return(invisible(self))
      }

      private$is_done <- FALSE

      obj_kind <- obj$.kind
      obj_name <- obj$name$value
      if (is.null(obj_name) ) {
        stop("To add an object to a Schema, it must have a name.")
      }

      if (obj_kind != "TypeExtensionDefinition") {

        # private$check_and_add_to_directives(obj)

        groups = list(
          "ObjectTypeDefinition" = "objects",
          "InterfaceTypeDefinition" = "interfaces",
          "UnionTypeDefinition" = "unions",
          "ScalarTypeDefinition" = "scalars",
          "EnumTypeDefinition" = "enums",
          "InputObjectTypeDefinition" = "input_objects",
          "DirectiveDefinition" = "directives"
        )
        obj_group <- groups[[obj_kind]]

        if (is.null(obj_group)) {
          print(obj)
          stop0("Unknown object type requested to be added to schema. Type: ", obj_kind)
        }

        if (!is.null(private[[obj_group]][[obj_name]])) {
          print(private[[obj_group]][[obj_name]])
          stop0(obj_name, " already defined in ", obj_kind)
        }

        private[[obj_group]][[obj_name]] <- obj

        if (obj_kind == "ObjectTypeDefinition") {
          if (!is.null(obj$interfaces)) {
            obj_name_val <- self$name_helper(obj$name)
            for (interface_obj in obj$interfaces) {
              interface_obj_name <- self$name_helper(interface_obj$name)
              if (
                is.null(
                  private$objects_that_implement_interface_list[[interface_obj_name]]
                )
              ) {
                private$objects_that_implement_interface_list[[interface_obj_name]] <- list()
              }

              private$objects_that_implement_interface_list[[
                interface_obj_name
              ]][[obj_name_val]] <- obj_name_val
            }
          }
        }

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

      # TODO
      stop("implement later!")

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
    }#,

    # validate = function() {
    #   for (list_name in c()) {
    #
    #   }
    # }


    # validate = function() {
    #   # This must be done at the very end.
    #   # TypeExtensionDefinitions screw everything up as something could be valid before,
    #   # but not after.
    #
    #   # get the names for each group
    #   allNames <- self$schema_names
    #
    #   # make sure none of the names are duplicated
    #   if (any(duplicated(allNames))) {
    #     duplicatedNames <- allNames[duplicated(allNames)]
    #     print(duplicatedNames)
    #     stop0("duplicated names are above.  Schema names may only be supplied once")
    #   }
    #
    #   interfaceNames <- names(self$interfaces)
    #   objectNames <- names(self$objects)
    #   check_is_valid_type_obj <- function(typeObj) {
    #     if (typeObj$'_kind' != "Type" ) {
    #       stop0("object fieldType is not 'Type'. Received: ", typeObj[['_kind']])
    #     }
    #
    #     type <- typeObj$type
    #     if (type %in% c("Type", "Int", "String")) {
    #       # good
    #     } else {
    #       stop0("Invalid field type received: |", type, "|. Known field types: |", paste(objectNames, collapse = ", "), "|")
    #     }
    #   }
    #
    #   # for every schema object
    #   schemaObj$objects <- lapply(schemaObj$objects, function(objectObj) {
    #
    #     # Conversely, GraphQL type system authors must not define any types, fields, arguments, or any other type system artifact with two leading underscores.
    #     # TODO
    #
    #     # for UnionTypeDefinition
    #     lapply(objectObj$types, check_is_valid_type_obj)
    #
    #     # for ObjectTypeDefinition
    #     lapply(objectObj$fieldTypes, check_is_valid_type_obj)
    #
    #     # for ObjectTypeDefinition arguments
    #     lapply(objectObj$fieldArguments, function(fieldArgObj) {
    #       # fieldArgObj = three(argument: InputType, other: String = "string"): Int
    #
    #       lapply(fieldArgObj, function(argObj) {
    #         # argObj = {argument: InputType, other: String = "string"}
    #
    #         lapply(argObj, function(argValObj) {
    #           argValObj <- as.list(argValObj)
    #           # argObj = {String = "string"}
    #           argType <- argValObj$type
    #
    #           defaultValueKind <- argValObj$defaultValueKind
    #
    #           # TODO. find proper types
    #         })
    #
    #       })
    #     })
    #
    #     # lapply(objectObj$fieldArguments, function(argObj) {
    #     #
    #     # })
    #
    #
    #
    #     # // Assert each interface field is implemented.
    #     lapply(objectObj$interfaces, function(objectInterfaceObj) {
    #       interfaceType <- objectInterfaceObj$type
    #
    #       # // Assert interface field exists on object.
    #       if (!(interfaceType %in% interfaceNames)) {
    #         print(objectObj)
    #         stop0("Schema object '", objectObj$name, "' is trying to implement a missing interface '", interfaceType, "'")
    #       }
    #       interfaceObj <- schemaObj$interfaces[[interfaceType]]
    #
    #       # // Assert interface field type is satisfied by object field type,
    #       # by being a valid subtype. (covariant)
    #       lapply(names(interfaceObj$fieldTypes), function(interfaceFieldName) {
    #         interFieldObj <- interfaceObj$fieldTypes[[interfaceFieldName]]
    #
    #       })
    #
    #
    #       # for each field of the interface, make sure it's added or stomped
    #       for (name in names(interfaceObj$fieldTypes)) {
    #         # if the field doesn't exist, add it
    #         if (is.null(objectObj$fieldTypes[[name]])) {
    #           objectObj$fieldTypes[[name]] <<- interfaceObj$fieldTypes[[name]]
    #           objectObj$fieldArguments[[name]] <<- interfaceObj$fieldArguments[[name]]
    #         }
    #       }
    #     })
    #
    #     objectObj
    #   })
    #
    #   schemaObj$interfaces <- NULL
    #
    #   schemaObj$isDone <- TRUE
    #   schemaObj
    #
    # }

  ),
  active = list(
    # schema_names = function() {
    #   unlist(c(
    #     names(self$objects),
    #     names(self$interfaces),
    #     names(self$inputs)
    #   ))
    # }
  )
)













# introspection_spec <- function(){
#
# "
#
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
# type __Field {
#   name: String!
#   description: String
#   args: [__InputValue!]!
#   type: __Type!
#   isDeprecated: Boolean!
#   deprecationReason: String
# }
#
# type __InputValue {
#   name: String!
#   description: String
#   type: __Type!
#   defaultValue: String
# }
#
# type __EnumValue {
#   name: String!
#   description: String
#   isDeprecated: Boolean!
#   deprecationReason: String
# }
#
# enum __TypeKind {
#   SCALAR
#   OBJECT
#   INTERFACE
#   UNION
#   ENUM
#   INPUT_OBJECT
#   LIST
#   NON_NULL
# }
#
# type __Directive {
#   name: String!
#   description: String
#   locations: [__DirectiveLocation!]!
#   args: [__InputValue!]!
# }
#
# enum __DirectiveLocation {
#   QUERY
#   MUTATION
#   FIELD
#   FRAGMENT_DEFINITION
#   FRAGMENT_SPREAD
#   INLINE_FRAGMENT
# }"
# }
#
# introspection_imp <- function() {
#   list(
#     "__Schema" = list(
#       .description = collapse(
#         'A GraphQL Schema defines the capabilities of a GraphQL server. It ',
#         'exposes all available types and directives on the server, as well as ',
#         'the entry points for query, mutation, and subscription operations.'
#       ),
#
#       types = with_description(
#         description = 'A list of all types supported by this server.',
#         function(schemaObj, ...) {
#           schemaObj$typeMap
#         }
#       ),
#
#       queryType = with_description(
#         description = 'The type that query operations will be rooted at.',
#         function(schemaObj, ...) {
#           schemaObj$queryType
#         }
#       ),
#
#       mutationType = with_description(
#         description = collapse(
#           'If this server supports mutation, the type that ',
#           'mutation operations will be rooted at.'
#         ),
#         function(schemaObj, ...) {
#          schemaObj$mutationType
#         }
#       ),
#
#       subscriptionType = with_description(
#         description = collapse(
#           'If this server support subscription, the type that ',
#           'subscription operations will be rooted at.'
#         ),
#         function(schemaObj, ...) {
#           schemaObj$subscriptionType
#         }
#       ),
#
#       directives = with_description(
#         description = 'A list of all directives supported by this server.',
#         function(schemaObj) {
#           schemaObj$directives
#         }
#       )
#     ),
#
#
#     "__Type" = list(
#       .description = collapse(
#         'The fundamental unit of any GraphQL Schema is the type. There are ',
#         'many kinds of types in GraphQL as represented by the `__TypeKind` enum.',
#         '\n\nDepending on the kind of a type, certain fields describe ',
#         'information about that type. Scalar types provide no information ',
#         'beyond a name and description, while Enum types provide their values. ',
#         'Object and Interface types provide the fields they describe. Abstract ',
#         'types, Union and Interface, provide the Object types possible ',
#         'at runtime. List and NonNull types compose other types.'
#       ),
#
#       kind = function(obj, ...) {
#         print("fix type values")
#         browser()
#         if (inherits(obj, "scalar")) {
#           return("scalar")
#         }
#         # if (type instanceof GraphQLScalarType) {
#         #   return TypeKind.SCALAR;
#         # } else if (type instanceof GraphQLObjectType) {
#         #   return TypeKind.OBJECT;
#         # } else if (type instanceof GraphQLInterfaceType) {
#         #   return TypeKind.INTERFACE;
#         # } else if (type instanceof GraphQLUnionType) {
#         #   return TypeKind.UNION;
#         # } else if (type instanceof GraphQLEnumType) {
#         #   return TypeKind.ENUM;
#         # } else if (type instanceof GraphQLInputObjectType) {
#         #   return TypeKind.INPUT_OBJECT;
#         # } else if (type instanceof GraphQLList) {
#         #   return TypeKind.LIST;
#         # } else if (type instanceof GraphQLNonNull) {
#         #   return TypeKind.NON_NULL;
#         # }
#         stop0('Unknown kind of type: ', type)
#       },
#
#       fields = function(typeObj, includeDeprecated = FALSE, ...) {
#         print("fix types")
#         browser()
#
#         if (! (inherits(typeObj, "object") || inherits(typeObj, "interface"))) {
#           return(NULL)
#         }
#         fieldMap = typeObj$fields
#         if (!includeDeprecated) {
#           fieldMap <- Filter(function(fieldVal) {
#             !is.null(fieldVal$deprecationReason)
#           }, fieldMap)
#         }
#         fieldMap
#       },
#
#       interfaces = function(typeObj, ...) {
#         if (inherits(typeObj, "object")) {
#           typeObj$interfaces
#         } else {
#           NULL
#         }
#       },
#
#       possibleTypes = function(typeObj, args, context, schema, ...) {
#         if (inherits(typeObj, "interface") || inherits(typeObj, "union")) {
#           schema$possibleTypes
#         } else {
#           NULL
#         }
#       },
#
#       enumValues = function(typeObj, includeDeprecated = FALSE, ...) {
#         if (inherits(typeObj, "enum")) {
#           values = typeObj$values
#           if (!includeDeprecated) {
#             values = Filter(function(enumVal) {
#               ! is.null(enumVal$deprecationReason)
#             }, values)
#           }
#           return(values)
#         }
#         return(NULL)
#       },
#
#       inputFields = function(typeObj, ...) {
#         if (inherits(typeObj, "inputobject")) {
#           return(typeObj$fields)
#         }
#         return(NULL)
#       }
#       # ofType: { type: __Type }
#     ),
#
#
#     "__Field" = list(
#       .description = collapse(
#         'Object and Interface types are described by a list of Fields, each of ',
#         'which has a name, potentially a list of arguments, and a return type.'
#       ),
#
#       args = function(fieldObj, ...) {
#         ret <- fieldObj$args
#         if (is.null(ret)) {
#           ret <- list()
#         }
#         return(ret)
#       },
#
#       isDeprecated = function(fieldObj, ...) {
#         !is.null(fieldObj$deprecationReason)
#       }
#     ),
#
#
#     "__InputValue" = list(
#       .description = collapse(
#         'Arguments provided to Fields or Directives and the input fields of an ',
#         'InputObject are represented as Input Values which describe their type ',
#         'and optionally a default value.'
#       ),
#
#       # ,
#       defaultValue = with_description(
#         description = collapse(
#           'A GraphQL-formatted string representing the default value for this ',
#           'input value.'
#         ),
#         function(inputValueObj, ...) {
#           if (is.null(inputValueObj$defaultValue)) {
#             return(NULL)
#           }
#           # print(astFromValue(inputVal.defaultValue, inputVal))
#           return(inputValueObj$defaultValue)
#         }
#       )
#     ),
#
#
#     "__EnumValue" = list(
#       .description = collapse(
#         'One possible value for a given Enum. Enum values are unique values, not ',
#         'a placeholder for a string or numeric value. However an Enum value is ',
#         'returned in a JSON response as a string.'
#       ),
#
#       isDeprecated = function(fieldObj, ...) {
#         !is.null(fieldObj$deprecationReason)
#       }
#     ),
#
#
#     "__TypeKind" = list(
#       .description = 'An enum describing what kind of type a given `__Type` is.',
#
#       SCALAR = 'Indicates this type is a scalar.',
#       OBJECT = 'Indicates this type is an object. `fields` and `interfaces` are valid fields.',
#       INTERFACE = 'Indicates this type is an interface. `fields` and `possibleTypes` are valid fields.',
#       UNION = 'Indicates this type is a union. `possibleTypes` is a valid field.',
#       ENUM = 'Indicates this type is an enum. `enumValues` is a valid field.',
#       INPUT_OBJECT = 'Indicates this type is an input object. `inputFields` is a valid field.',
#       LIST = 'Indicates this type is a list. `ofType` is a valid field.',
#       NON_NULL = 'Indicates this type is a non-null. `ofType` is a valid field.'
#     ),
#
#
#     "__Directive" = list(
#       .description = collapse(
#         'A Directive provides a way to describe alternate runtime execution and ',
#         'type validation behavior in a GraphQL document.',
#         '\n\nIn some cases, you need to provide options to alter GraphQL’s ',
#         'execution behavior in ways field arguments will not suffice, such as ',
#         'conditionally including or skipping a field. Directives provide this by ',
#         'describing additional information to the executor.'
#       ),
#       args = function(directiveObj, ...) {
#         ret = directiveObj$args
#         if (is.null(ret)) {
#           ret <- list()
#         }
#         return(ret)
#       }
#     ),
#
#
#     "__DirectiveLocation" = list(
#       .description = collapse(
#         'A Directive can be adjacent to many parts of the GraphQL language, a ',
#         '__DirectiveLocation describes one such possible adjacencies.'
#       ),
#
#       QUERY               = 'Location adjacent to a query operation.',
#       MUTATION            = 'Location adjacent to a mutation operation.',
#       SUBSCRIPTION        = 'Location adjacent to a subscription operation.',
#       FIELD               = 'Location adjacent to a field.',
#       FRAGMENT_DEFINITION = 'Location adjacent to a fragment definition.',
#       FRAGMENT_SPREAD     = 'Location adjacent to a fragment spread.',
#       INLINE_FRAGMENT     = 'Location adjacent to an inline fragment.'
#     )
#   )
# }




# enum_value_upgrade = function(key, obj = NULL) {
#   if (typeof(obj) %in% c("character", "NULL")) {
#     obj = list(description = obj)
#   }
#   if (typeof(obj) != "list") {
#     stop("'obj' type must be a list or a plain character")
#   }
#   if (is.null(obj$key)) {
#     obj$key = key
#   }
#   if (is.null(obj$key)) {
#     obj$isDeprecated = FALSE
#   }
# }








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
