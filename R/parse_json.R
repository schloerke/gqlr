#' @include wrappers.R

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
#' @example
#' gqlr_parse(test_json("simple-film-schema"))
gqlr_parse <- function(obj, ...) {
  if (is.null(obj)) {
    return(obj)
  }
  check_if_gqlr_object(obj)
  UseMethod("gqlr_parse")
}

#' default method to help with implementing new types
gqlr_parse.default <- function(obj, ...) {
  str(obj, 3)
  stop0("no applicable method for 'gqlr_parse' applied to an object of class '", class(obj), "'")
}

#' parse graphql Document
#' @template gqlr_parse_args
#' @example
#' gqlr_parse(test_json("simple-film-schema"))
gqlr_parse.Document <- function(obj, ...) {
  # kind = "Document",
  # loc = "?Location",
  # definitions = "array_Definition"

  list(
    "_kind" = "Document",
    definitions = lapply(obj$definitions, gqlr_parse)
  )
}

#' parse graphql Name
#' @template gqlr_parse_args
#' @example
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
#' @example
#' enumObj <- test_json("kitchen_schema")$definitions[[5]]
#' gqlr_parse(enumObj)
gqlr_parse.EnumTypeDefinition <- function(obj, ...) {
  # kind   = "EnumTypeDefinition",
  # loc    = "?Location",
  # name   = "Name",
  # values = "[EnumValueDefinition]"

  list(
    "_kind" = "EnumTypeDefinition",
    key = gqlr_parse(obj$name),
    values = lapply(obj$values, gqlr_parse) %>% unlist()
  )
}

#' parse graphql EnumValueDefinition
#' @template gqlr_parse_args
#' @example
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
#' @example
#' inputObj <- test_json("kitchen_schema")$definitions[[6]]
#' gqlr_parse(inputObj)
gqlr_parse.InputObjectTypeDefinition <- function(x) {
  # kind   = "InputObjectTypeDefinition",
  # loc    = "?Location",
  # name   = "Name",
  # fields = "[InputValueDefinition]"
  list(
    "_kind" = "InputObjectTypeDefinition",
    name = gqlr_parse(x$name),
    fields = lapply(x$fields, gqlr_parse)
  )
}





#' parse graphql Type NamedType
#' @template gqlr_parse_args
#' @example
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
#' @example
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
#' @example
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
#' @example
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
#' @example
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
#' @example
#' objObj <- test_json("kitchen_schema")$definitions[[1]]
#' gqlr_parse(objObj)
gqlr_parse.ObjectTypeDefinition <- function(obj, ...) {
  # kind       = "ObjectTypeDefinition",
  # loc        = "?Location",
  # name       = "Name",
  # interfaces = "?[NamedType]",
  # fields     = "[FieldDefinition]"

  list(
    "_kind" = "ObjectTypeDefinition",
    name = gqlr_parse(obj$name),
    interfaces = lapply(obj$interfaces, gqlr_parse),
    fields = lapply(obj$fields, gqlr_parse)
  )
}

#' parse graphql Definition FieldDefinition
#' @template gqlr_parse_args
#' @example
#' objObj <- test_json("kitchen_schema")$definitions[[1]]
#' fieldObj <- objObj$fields[[1]]
#' gqlr_parse(fieldObj)
gqlr_parse.FieldDefinition <- function(obj, ...) {
  # kind      = "FieldDefinition",
  # loc       = "?Location",
  # name      = "Name",
  # arguments = "[InputValueDefinition]",
  # type      = "Type"

  list(
    "_kind" = "FieldDefinition",
    name = gqlr_parse(obj$name),
    type = gqlr_parse(obj$type),
    arguments = lapply(obj$arguments, gqlr_parse)
  )
}

#' parse graphql Definition InputValueDefinition
#' @template gqlr_parse_args
#' @example
#' inputValObj <- test_json("kitchen_schema")$definitions[[6]]$fields[[1]]
#' gqlr_parse(inputValObj)
gqlr_parse.InputValueDefinition <- function(obj, ...) {
  # kind         = "InputValueDefinition",
  # loc          = "?Location",
  # name         = "Name",
  # type         = "Type",
  # defaultValue = "?Value"

  if (length(obj$arguments) > 0) {
    browser()
  }
  list(
    "_kind" = "InputValueDefinition",
    key = gqlr_parse(obj$name),
    type = gqlr_parse(obj$type)
  )
}

#' parse graphql Definition InterfaceTypeDefinition
#' @template gqlr_parse_args
#' @example
#' interfaceObj <- test_json("kitchen_schema")$definitions[[2]]
#' gqlr_parse(interfaceObj)
gqlr_parse.InterfaceTypeDefinition <- function(obj, ...) {
  # kind   = "InterfaceTypeDefinition",
  # loc    = "?Location",
  # name   = "Name",
  # fields = "[FieldDefinition]"

  list(
    "_kind" = "InterfaceTypeDefinition",
    name = gqlr_parse(obj$name),
    fields = lapply(obj$fields, gqlr_parse)
  )
}

#' parse graphql Definition TypeExtensionDefinition
#' @template gqlr_parse_args
#' @example
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


























































# handle code below differently as it is for runtime





# Query
#' parse graphql Definition OperationDefinition
#' @template gqlr_parse_args
#' @example
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
#' @example
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
#' @example
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.Variable <- function(obj, ...) {
  # kind = "Variable",
  # loc  = "?Location",
  # name = "Name"

  gqlr_parse(obj$name)
}

#' parse graphql EnumValue
#' @template gqlr_parse_args
#' @example
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.EnumValue <- function(obj, ...) {
  # kind  = "EnumValue",
  # loc   = "?Location",
  # value = "string"
  obj$value
}

#' parse graphql SelectionSet
#' @template gqlr_parse_args
#' @example
#' typeExtObj <- test_json("kitchen_schema")$definitions[[7]]
#' gqlr_parse(typeExtObj)
gqlr_parse.SelectionSet <- function(obj, ...) {
  # kind = "SelectionSet",
  # loc = "?Location",
  # selections = "[Selection]"
  list("_kind" = "SelectionSet", selections = gqlr_parse(selections))
}





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
