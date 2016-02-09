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





Schema <- R6Class("Schema",
  private = list(),
  public = list(
    isDone = FALSE, objects = list(), interfaces = list(), inputs = list(),

    add = function(obj) {
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

      objKind = obj$kind
      objName = obj$name$value
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

    add_document = function(documentObj) {
      check_if_gqlr_object(documentObj, "Document")

      defs <- documentObj$definitions
      for (i in seq_along(defs)) {
        self$add(defs[[i]])
      }
      self$validate()
      invisible(self)

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
