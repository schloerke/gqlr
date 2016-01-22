
# _queryType: GraphQLObjectType;
# _mutationType: ?GraphQLObjectType;
# _subscriptionType: ?GraphQLObjectType;
# _directives: Array<GraphQLDirective>;


gql_schema <- function(queryType, mutationType = NULL, subscriptionType = NULL, directives = NULL) {

  stop("TODO implement schema")
}


gql_type_scalar <- function(type = c("int", "float", "string", "boolean", "id"), serialize = I) {

}

gql_type_enum <- function() {

}

gql_type_object <- function() {

}

gql_type_interface <- function() {

}

gql_type_union <- function() {

}

gql_type_list <- function() {

}

gql_type_non_null <- function() {

}

gql_type_input_obect <- function() {

}
















# Copyright (c) 2015, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.





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



# testSchema <- eval_json(test_string("kitchen_schema"))
# testSchema <- eval_json("enum Site {
#   DESKTOP
#   MOBILE
# }
# # ")
# str(testSchema$definitions)

#' formal function to make sure all of the objects are gqlr objects
check_if_gqlr_object <- function(x, kind = class(x)) {
  if (!is.list(x)) {
    cat("this object is not a list. look at it\n")
    print(x)
    browser()
    stop("object is not a list")
  }
  if (is.null(x$kind)) {
    stop("object kind is null.  Do not know how to parse")
  }

  if (! is.null(kind)) {
    if (x$kind != kind) {
      stop(paste("supplied kind: ", x$kind, " does not match expected kind: ", kind, sep = ""))
    }
  }

  invisible(NULL)
}

#' Generic method to parse graphql json objects
#' @template gqlr_parse_args
#' @examples
#' gqlr_parse(test_json("simple-film-schema"))
gqlr_parse <- function(obj, ...) {
  if (is.null(obj)) {
    return(obj)
  }
  check_if_gqlr_object(obj)
  UseMethod("gqlr_parse")
}

u_na <- unlist_and_replace_null_with_na <- function(x) {
  isNull <- lapply(x, is.null) %>% unlist()
  x[isNull] <- NA
  unlist(x)
}


argument_mat_from_input_value_definitions <- function(arguments) {
  fieldKeys = lapply(arguments, "[[", "key") %>% unlist()
  types = lapply(arguments, "[[", "type")
  defaultValues = lapply(arguments, "[[", "defaultValue")

  data.frame(
    keys = fieldKeys,
    isNonNull = lapply(types, "[[", "isNonNull") %>% u_na(),
    isList = lapply(types, "[[", "isList") %>% u_na(),
    type = lapply(types, "[[", "type") %>% u_na(),
    defaultValue = lapply(defaultValues, "[[", "value") %>% u_na(),
    defaultValueKind = lapply(defaultValues, "[[", "kind") %>% u_na()
  )
}


field_arguments_and_types = function(fields) {
  fieldNames <- lapply(fields, "[[", "name") %>% unlist()

  fieldTypes <- lapply(fields, "[[", "type")
  names(fieldTypes) <- fieldNames
  fieldArguments <- lapply(fields, "[[", "arguments")
  names(fieldArguments) <- fieldNames

  list(
    types = fieldTypes,
    arguments = fieldArguments
  )
}







#' default method to help with implementing new types
gqlr_parse.default <- function(obj, ...) {
  str(obj, 3)
  stop0("no applicable method for 'gqlr_parse' applied to an object of class '", class(obj), "'")
}

#' parse graphql Document
#'
#' Evaluating requests
#'
#' To evaluate a request, the executor must have a parsed Document (as defined in the “Query Language” part of this spec) and a selected operation name to run if the document defines multiple operations.
#'
#' The executor should find the Operation in the Document with the given operation name. If no such operation exists, the executor should throw an error. If the operation is found, then the result of evaluating the request should be the result of evaluating the operation according to the “Evaluating operations” section.
#' @template gqlr_parse_args
#' @examples
#' gqlr_parse(test_json("simple-film-schema"))
gqlr_parse.Document <- function(obj, ...) {
  # kind = "Document",
  # loc = "?Location",
  # definitions = "array_Definition"

  if (length(obj$definitions) == 0) {
    print(obj)
    stop("no definitions found in Document object")
  }

  list(
    "_kind" = "Document",
    definitions = lapply(obj$definitions, gqlr_parse)
  )
}

#' parse graphql Name
#' @template gqlr_parse_args
#' @examples
#' nameObj <- test_json("simple-film-schema")$definitions[[1]]$name
#' gqlr_parse(nameObj)
gqlr_parse.Name <- function(obj, ...) {
  # kind = "Name",
  # loc = "?Location",
  # value = "string"

  name <- obj$value
  name
}


#' parse graphql EnumTypeDefinition
#' @template gqlr_parse_args
#' @examples
#' enumObj <- test_json("kitchen_schema")$definitions[[5]]
#' gqlr_parse(enumObj)
gqlr_parse.EnumTypeDefinition <- function(obj, ...) {
  # kind   = "EnumTypeDefinition",
  # loc    = "?Location",
  # name   = "Name",
  # values = "[EnumValueDefinition]"

  name = gqlr_parse(obj$name)
  list(
    "_kind" = "EnumTypeDefinition",
    name = name,
    key = name,
    values = lapply(obj$values, gqlr_parse) %>% unlist()
  )
}

#' parse graphql EnumValueDefinition
#' @template gqlr_parse_args
#' @examples
#' enumValueObj <- test_json("kitchen_schema")$definitions[[5]]$values[[1]]
#' gqlr_parse(enumValueObj)
gqlr_parse.EnumValueDefinition <- function(x) {
  # kind = "EnumValueDefinition",
  # loc  = "?Location",
  # name = "Name"

  value <- gqlr_parse(x$name)
  value
}



#' parse graphql InputObjectTypeDefinition
#' @template gqlr_parse_args
#' @examples
#' inputObj <- test_json("kitchen_schema")$definitions[[6]]
#' gqlr_parse(inputObj)
gqlr_parse.InputObjectTypeDefinition <- function(x) {
  # kind   = "InputObjectTypeDefinition",
  # loc    = "?Location",
  # name   = "Name",
  # fields = "[InputValueDefinition]"

  fields = lapply(x$fields, gqlr_parse)

  list(
    "_kind" = "InputObjectTypeDefinition",
    name = gqlr_parse(x$name),
    # fields = fields,
    fieldMat = argument_mat_from_input_value_definitions(fields)
  )
}





#' parse graphql Type NamedType
#' @template gqlr_parse_args
#' @examples
#' namedTypeObj <- test_json("simple-film-schema")$definitions[[1]]$fields[[1]]$type
#' gqlr_parse(namedTypeObj)
gqlr_parse.NamedType <- function(obj, ...) {
  # kind = "NamedType",
  # loc  = "?Location",
  # name = "Name"
  list(
    "_kind" = "Type",
    isNonNull = FALSE,
    isList = FALSE,
    type = gqlr_parse(obj$name)
  )
}

#' parse graphql Type NonNullType
#' @template gqlr_parse_args
#' @examples
#' nonNullObj <- test_json("simple-film-schema")$definitions[[1]]$fields[[2]]$type
#' gqlr_parse(nonNullObj)
gqlr_parse.NonNullType <- function(obj, ...) {
  # kind = NonNullType
  # loc  = "?Location",
  # type = NamedType | ListType
  ret <- gqlr_parse(obj$type)
  ret$isNonNull <- TRUE
  ret
}

#' parse graphql Type NonNullType
#' @template gqlr_parse_args
#' @examples
#' listObj <- test_json("simple-film-schema")$definitions[[1]]$fields[[3]]$type
#' gqlr_parse(listObj)
gqlr_parse.ListType <- function(obj, ...) {
  # kind = "ListType",
  # loc  = "?Location",
  # type = "Type"
  ret <- gqlr_parse(obj$type)
  ret$isList <- TRUE
  ret
}










#' parse graphql Definition UnionTypeDefinition
#' @template gqlr_parse_args
#' @examples
#' unionObj <- test_json("kitchen_schema")$definitions[[3]]
#' gqlr_parse(unionObj)
gqlr_parse.UnionTypeDefinition <- function(obj, ...) {
  # kind  = "UnionTypeDefinition",
  # loc   = "?Location",
  # name  = "Name",
  # types = "[NamedType]"
  list(
    "_kind" = "UnionTypeDefinition",
    name = gqlr_parse(obj$name),
    types = lapply(obj$types, gqlr_parse)
  )
}

#' parse graphql Definition ScalarTypeDefinition
#' @template gqlr_parse_args
#' @examples
#' scalarObj <- test_json("kitchen_schema")$definitions[[4]]
#' gqlr_parse(scalarObj)
gqlr_parse.ScalarTypeDefinition <- function(obj, ...) {
  # kind = "ScalarTypeDefinition",
  # loc  = "?Location",
  # name = "Name"
  list(
    "_kind" = "ScalarTypeDefinition",
    name = gqlr_parse(obj$name)
  )
}

#' parse graphql Definition ObjectTypeDefinition
#' @template gqlr_parse_args
#' @examples
#' objObj <- test_json("kitchen_schema")$definitions[[1]]
#' gqlr_parse(objObj)
gqlr_parse.ObjectTypeDefinition <- function(obj, ...) {
  # kind       = "ObjectTypeDefinition",
  # loc        = "?Location",
  # name       = "Name",
  # interfaces = "?[NamedType]",
  # fields     = "[FieldDefinition]"

  fields <- lapply(obj$fields, gqlr_parse)
  fieldTypeArgList <- field_arguments_and_types(fields)

  list(
    "_kind" = "ObjectTypeDefinition",
    name = gqlr_parse(obj$name),
    interfaces = lapply(obj$interfaces, gqlr_parse),
    fieldTypes = fieldTypeArgList$types,
    fieldArguments = fieldTypeArgList$arguments
  )
}

#' parse graphql Definition FieldDefinition
#' @template gqlr_parse_args
#' @examples
#' objObj <- test_json("kitchen_schema")$definitions[[1]]
#' fieldObj <- objObj$fields[[1]]
#' gqlr_parse(fieldObj)
gqlr_parse.FieldDefinition <- function(obj, ...) {
  # kind      = "FieldDefinition",
  # loc       = "?Location",
  # name      = "Name",
  # arguments = "[InputValueDefinition]",
  # type      = "Type"

  inputValuesDefs <- lapply(obj$arguments, gqlr_parse)

  list(
    "_kind" = "FieldDefinition",
    name = gqlr_parse(obj$name),
    type = gqlr_parse(obj$type),
    arguments = argument_mat_from_input_value_definitions(inputValuesDefs)
  )
}

#' parse graphql Definition InputValueDefinition
#' @template gqlr_parse_args
#' @examples
#' inputValObj <- test_json("kitchen_schema")$definitions[[6]]$fields[[1]]
#' gqlr_parse(inputValObj)
gqlr_parse.InputValueDefinition <- function(obj, ...) {
  # kind         = "InputValueDefinition",
  # loc          = "?Location",
  # name         = "Name",
  # type         = "Type",
  # defaultValue = "?Value"

  if (length(obj$arguments) > 0) {
    cat("this obj has arguments. look at it")
    browser()
  }
  list(
    "_kind" = "InputValueDefinition",
    key = gqlr_parse(obj$name),
    type = gqlr_parse(obj$type),
    defaultValue = gqlr_parse(obj$defaultValue)
  )
}

#' parse graphql Definition InterfaceTypeDefinition
#' @template gqlr_parse_args
#' @examples
#' interfaceObj <- test_json("kitchen_schema")$definitions[[2]]
#' gqlr_parse(interfaceObj)
gqlr_parse.InterfaceTypeDefinition <- function(obj, ...) {
  # kind   = "InterfaceTypeDefinition",
  # loc    = "?Location",
  # name   = "Name",
  # fields = "[FieldDefinition]"

  fields <- lapply(obj$fields, gqlr_parse)
  fieldTypeArgList <- field_arguments_and_types(fields)

  list(
    "_kind" = "InterfaceTypeDefinition",
    name = gqlr_parse(obj$name),
    fieldTypes = fieldTypeArgList$types,
    fieldArguments = fieldTypeArgList$arguments
  )
}

#' parse graphql Definition TypeExtensionDefinition
#' @template gqlr_parse_args
#' @examples
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.TypeExtensionDefinition <- function(obj, ...) {
  # kind       = "TypeExtensionDefinition",
  # loc        = "?Location",
  # definition = "ObjectTypeDefinition"

  list(
    "_kind" = "TypeExtensionDefinition",
    definition = gqlr_parse(obj$definition)
  )
}
















gqlr_init_schema <- function() {
  list(
    isDone = FALSE,
    objects = list(),
    interfaces = list(),
    inputs = list()
  )
}


#' Add item to schema
#'
#' @param schemaObj schema object to add to
#' @param obj parsed object to add to the schemaObj
#' @examples
#' defs <- test_json("kitchen_schema")$definitions
#' cat(test_string("kitchen_schema"))
#' schemaObj <- gqlr_init_schema() %>%
#'   gqlr_add_to_schema(gqlr_parse(defs[[1]])) %>%
#'   gqlr_add_to_schema(gqlr_parse(defs[[2]])) %>%
#'   gqlr_add_to_schema(gqlr_parse(defs[[3]])) %>%
#'   gqlr_add_to_schema(gqlr_parse(defs[[4]])) %>%
#'   gqlr_add_to_schema(gqlr_parse(defs[[5]])) %>%
#'   gqlr_add_to_schema(gqlr_parse(defs[[6]])) %>%
#'   gqlr_add_to_schema(gqlr_parse(defs[[7]])) %>%
#'   gqlr_validate_schema()
#' str(schemaObj, 3)
gqlr_add_to_schema <- function(schemaObj, obj) {

  schemaObj$isDone <- FALSE

  groups = list(
    "ObjectTypeDefinition" = "objects",
    "InterfaceTypeDefinition" = "interfaces",
    "UnionTypeDefinition" = "objects",
    "ScalarTypeDefinition" = "objects",
    "EnumTypeDefinition" = "objects",
    "InputObjectTypeDefinition" = "inputs"
  )

  objKind = obj[["_kind"]]
  objName = obj[["name"]]
  objGroup = groups[[objKind]]

  if (objKind != "TypeExtensionDefinition") {
    if (is.null(objGroup)) {
      print(obj)
      stop0("Unknown object type requested to be added to schema. Type: ", objKind)
    }
    if ( !is.null(schemaObj[[objGroup]][[objName]])) {
      print(schemaObj)
      cat('\n')
      print(obj)
      stop0(objKind, " already defined. ", objKind, ": ", objName)
    }

    schemaObj[[objGroup]][[objName]] <- obj
  } else {

    extObj <- obj$definition
    extObjName <- extObj$name

    isInterface <- extObjName %in% names(schemaObj$interfaces)
    isObject <- extObjName %in% names(schemaObj$objects)

    extObjType <- NULL
    if (isInterface && isObject) {
      print(obj)
      stop0("object with name: ", extObjName, " can not be extended as it is both an interface and an object")
    } else if (isInterface) {
      extObjType <- "interfaces"
    } else if (isObject) {
      extObjType <- "objects"
    } else {
      print(obj)
      stop0("object with name: ", extObjName, " can not be extended as it does not exist")
    }

    extObjFieldNames <- extObj$fieldTypeMat$name
    originalObject <- schemaObj[[extObjType]][[extObjName]]
    objFieldNames <- originalObject$fieldMat$name
    if (any(extObjFieldNames %in% objFieldNames)) {
      print(obj)
      stop0("object with name: ", extObjName, " can not stomp prior names")
    }

    originalObject$fieldTypes <- append(originalObject$fieldTypes, extObj$fieldTypes)
    originalObject$fieldArguments <- append(originalObject$fieldArguments, extObj$fieldArguments)

    schemaObj[[extObjType]][[extObjName]] <- originalObject
  }

  schemaObj
}


gqlr_validate_schema <- function(schemaObj) {
  # get the names for each group
  schemaNames <- lapply(schemaObj, names)

  allNames <- unlist(schemaNames)
  # make sure none of the names are duplicated
  if (any(isDuplicated <- duplicated(allNames))) {
    duplicatedNames <- allNames[isDuplicated]
    print(duplicatedNames)
    stop0("duplicated names are above.  Schema names may only be supplied once")
  }

  interfaceNames <- schemaNames$interfaces
  # for every schema object
  schemaObj$objects <- lapply(schemaObj$objects, function(objectObj) {
    # for each interface of the object
    lapply(objectObj$interfaces, function(objectInterfaceObj) {
      interfaceType <- objectInterfaceObj$type
      # make sure the interface exists
      if (!(interfaceType %in% interfaceNames)) {
        print(objectObj)
        stop0("Schema object '", objectObj$name, "' is trying to implement a missing interface '", interfaceType, "'")
      }

      # for each field of the interface, make sure it's added or stomped
      interfaceObj <- schemaObj$interfaces[[interfaceType]]
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























































# handle code below differently as it is for runtime





# Query
#' parse graphql Definition OperationDefinition
#' @template gqlr_parse_args
#' @examples
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.OperationDefinition <- function(obj, ...) {
  # kind                = "OperationDefinition",
  # loc                 = "?Location",
  # # // Note: subscription is an experimental non-spec addition.
  # operation           = c("query", "mutation", "subscription"),
  # name                = "?Name",
  # variableDefinitions = "?[VariableDefinition]",
  # directives          = "?[Directive]",
  # selectionSet        = "SelectionSet"

  list(
    "_kind" = "OperationDefinition",
    name = gqlr_parse(obj$name),
    variableDefinitions = lapply(obj$variableDefinitions, gqlr_parse),
    directives = lapply(obj$directives, gqlr_parse),
    selectionSet = gqlr_parse(obj$selectionSet),
    definition = gqlr_parse(obj$definition)
  )
}


#' parse graphql Definition VariableDefinition
#' @template gqlr_parse_args
#' @examples
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.VariableDefinition <- function(obj, ...) {
  # kind         = "VariableDefinition",
  # loc          = "?Location",
  # variable     = "Variable",
  # type         = "Type",
  # defaultValue = "?Value"

  list(
    "_kind" = "OperationDefinition",
    variable = gqlr_parse(obj$variable),
    type = gqlr_parse(obj$type),
    defaultValue = gqlr_parse(obj$defaultValue)
  )
}

#' parse graphql Variable
#' @template gqlr_parse_args
#' @examples
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.Variable <- function(obj, ...) {
  # kind = "Variable",
  # loc  = "?Location",
  # name = "Name"

  gqlr_parse(obj$name)
}

#' parse graphql Value
#' @template gqlr_parse_args
#' @examples
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.IntValue <-
gqlr_parse.FloatValue <-
gqlr_parse.StringValue <-
gqlr_parse.BooleanValue <-
gqlr_parse.EnumValue <-
gqlr_parse.EnumValue <- function(obj, ...) {
  # kind  = "EnumValue",
  # loc   = "?Location",
  # value = "string"
  list("_kind" = obj$kind, kind = obj$kind, value = obj$value)
}

gqlr_parse.ListValue <- function(obj, ...) {
  # kind = "ListValue",
  # loc = "?Location",
  # values = "[Value]"
  list("_kind" = "ListValue", values = lapply(obj$values, gqlr_parse))
}
gqlr_parse.ObjectValue <- function(obj, ...) {
  # kind   = "ObjectValue",
  # loc    = "?Location",
  # fields = "[ObjectField]"
  fields = lapply(obj$fields, gqlr_parse)
  fields = lapply(fields, function(field) {
    list(
      key = field$key,
      value = field$value$value,
      valueKind = field$value$kind
    )
  })
  names(fields) <- lapply(fields, "[[", "key") %>% unlist()
  list("_kind" = "ObjectValue", fields = fields)
}
gqlr_parse.ObjectField <- function(obj, ...) {
  # kind  = "ObjectField",
  # loc   = "?Location",
  # name  = "Name",
  # value = "Value"
  list("_kind" = "ObjectField", key = gqlr_parse(obj$name), value = gqlr_parse(obj$value))

}

#' parse graphql SelectionSet
#' @template gqlr_parse_args
#' @examples
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.SelectionSet <- function(obj, ...) {
  # kind = "SelectionSet",
  # loc = "?Location",
  # selections = "[Selection]"
  list("_kind" = "SelectionSet", selections = gqlr_parse(selections))
}





# does everything that gqlr_parse does, without formating
gqlr_parse2 <- function(obj, layer = 0, ...) {
  if (is.null(obj)) {
    return(NULL)
  }
  if (is.character(obj) || is.logical(obj)) {
    return(obj)
  }

  UseMethod("gqlr_parse2")
}

gqlr_parse2.Name <- function(obj, ...) {
  obj$value
}

gqlr_parse2.default <- function(obj, layer = 0,...) {

  Sys.sleep(0.25)
  str(obj)
  cat("layer = ", layer, "\n\n")


  obj$loc <- NULL
  lapply(obj, function(item) {
    if (is.list(item)) {
      if (class(item) == "list") {
        return(lapply(item, gqlr_parse2, layer = layer + 1))
      }
    }
    return(gqlr_parse2(item, layer = layer + 1))
  })
}
