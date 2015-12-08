# /* @flow */
# /**
#  *  Copyright (c) 2015, Facebook, Inc.
#  *  All rights reserved.
#  *
#  *  This source code is licensed under the BSD-style license found in the
#  *  LICENSE file in the root directory of this source tree. An additional grant
#  *  of patent rights can be found in the PATENTS file in the same directory.
#  */

# /**
#  * Contains a range of UTF-8 character offsets that identify
#  * the region of the source from which the AST derived.
#  */


language_ast_type <- (function() {
  language_ast_type <- lat <- function(name) {
    ret <- typeList[[name]]

    if(is.null(ret)) {
      stop(paste0("'", name, "' name not found in language ast types"))
    }

    ret
  }
  cat_spaces <- function(spaces, ...) {
    cat(rep(" ", spaces), ..., "\n", sep = "")
  }
  to_string <<- function(obj, kind = obj$kind, name = "", spaces = 0, s2 = spaces + 2) {
    typeObj <- lat(kind)

    if (kind == "Location") {
      return()
    }
    if (stringr::str_length(name) > 0) {
      cat_spaces(spaces, name, ": {")
    } else {
      cat_spaces(spaces, "{")
    }
    cat_spaces(s2, "kind: ", kind)

    if (typeObj$isOrType) {
      print("Is OR TYPE")
      browser()
    }

    # print(typeObj$items)
    lapply(names(typeObj$items), function(typeItemName) {

      # print(typeItemName)
      if (typeItemName == "kind") {
        return()
      }
      # print(typeItemName)
      # browser()
      typeItemInfo <- typeObj$items[[typeItemName]]

      if (kind == "Value") {
        browser()
      }


      objItem <- obj[[typeItemName]]

      if (is.null(objItem)) {
        if (typeItemInfo$isRequired) {
          print(obj)
          stop(paste0(typeItemName, " not supplied to ", kind))
        } else {
          # nothing to print.  return
          return()
        }
      }

      if (typeItemInfo$isArray) {
        cat_spaces(s2, typeItemName, ": [")
        lapply(objItem, function(objArrItem) {
          to_string(objArrItem, kind = objArrItem$kind, name = "", spaces = s2 + 2)
          cat_spaces(s2, ",")
        })
        cat_spaces(s2, "]")
      } else {
        if (typeItemInfo$isPrimitive) {
          cat_spaces(s2, typeItemName, ": ", objItem)
        } else {

          objItemKind = typeItemInfo$kind
          if (is.list(objItem)) {
            if (! is.null(objItem$kind)) {
              objItemKind <- objItem$kind
            }
          }
          if (objItemKind == "Value") {
            browser()
          }
          to_string(objItem, kind = objItemKind, name = typeItemName, spaces = s2)
        }
      }

    })
    cat_spaces(spaces, "}")
  }



  make_type = function(kind, ..., to_string, parser = NULL) {

    items <- lapply(list(...), function(arg) {
      ret <- list(isOrType = FALSE, isRequired = TRUE, isArray = FALSE, isPrimitive = FALSE)
      if (length(arg) > 1) {
        ret[["kind"]] <- ifelse(is.character(arg[1]), "_string", "_number")
        ret[["isPrimitive"]] <- TRUE
        ret[["values"]] <- arg
        return(ret)
      }


      firstChar <- stringr::str_sub(arg, 1, 1)
      if (firstChar == "?") {
        ret[["isRequired"]] <- FALSE
        arg <- stringr::str_sub(arg, 2)
      }

      arrChar <- stringr::str_sub(arg, 1, 6)
      if (arrChar == "array_") {
        ret[["isArray"]] = TRUE
        arg <- stringr::str_sub(arg, 7)
      }



      ret[["kind"]] <- arg
      ret[["isPrimitive"]] <- arg %in% c("_string", "_number")

      ret
    })

    ret <- list(
      items = items,
      kind = kind,
      isOrType = FALSE
    )
    # ret$parser <- parser
    # ret$to_string <- function(obj, spaces) {
    #   if (is.null(obj)) {return()}
    #   to_string(obj, spaces)
    # }

    ret
  }

  make_or_type <- function(kind, types) {
    ret <- list(isOrType = TRUE, types = types, kind = kind)
    ret
  }

  typeList <- list(

    # // Location
    Location = make_type(
      kind = "Location",
      start = "_number",
      end = "_number" ,
      # source = "?Source",
      to_string = function(obj, spaces = 0, s2 = spaces + 2) {
        cat_spaces(spaces, "Location: {")
        cat_spaces(s2, "start: ", obj$start)
        cat_spaces("end: ", obj$end, "}")
        # lat("Source")$to_string(obj$source, spaces + 2)
        cat_spaces(spaces, "}")
      } #,
      # parser = function(obj){
      #   # long hair don't care
      #   return(NULL)
      # }
    ),

    # // Name
    Name = make_type(
      kind = "Name",
      loc = "?Location",
      value = "_string"
    ),

    # // Document
    Document = make_type(
      kind = "Document",
      loc = "?Location",
      definitions = "array_Definition"
    ),

    OperationDefinition = make_type(
      kind                = "OperationDefinition",
      loc                 = "?Location",
      # // Note: subscription is an experimental non-spec addition.
      operation           = c("query", "mutation", "subscription"),
      name                = "?Name",
      variableDefinitions = "?array_VariableDefinition",
      directives          = "?array_Directive",
      selectionSet        = "SelectionSet"
    ),

    VariableDefinition = make_type(
      kind         = "VariableDefinition",
      loc          = "?Location",
      variable     = "Variable",
      type         = "Type",
      defaultValue = "?Value"
    ),

    Variable = make_type(
      kind = "Variable",
      loc  = "?Location",
      name = "Name"
    ),

    SelectionSet = make_type(
      kind = "SelectionSet",
      loc = "?Location",
      selections = "array_Selection"
    ),

    Field = make_type(
      kind         = "Field",
      loc          = "?Location",
      alias        = "?Name",
      name         = "Name",
      arguments    = "?array_Argument",
      directives   = "?array_Directive",
      selectionSet = "?SelectionSet"
    ),

    Argument = make_type(
      kind  = "Argument",
      loc   = "?Location",
      name  = "Name",
      value = "Value"
    ),


    # // Fragments

    FragmentSpread = make_type(
      kind       = "FragmentSpread",
      loc        = "?Location",
      name       = "Name",
      directives = "?array_Directive"
    ),

    InlineFragment = make_type(
      kind          = "InlineFragment",
      loc           = "?Location",
      typeCondition = "?NamedType",
      directives    = "?array_Directive",
      selectionSet  = "SelectionSet"
    ),

    FragmentDefinition = make_type(
      kind          = "FragmentDefinition",
      loc           = "?Location",
      name          = "Name",
      typeCondition = "NamedType",
      directives    = "?array_Directive",
      selectionSet  = "SelectionSet"
    ),


    # // Values

    Value =  make_or_type(
      kind = "Value",
      c(
        "Variable",
        "IntValue",
        "FloatValue",
        "StringValue",
        "BooleanValue",
        "EnumValue",
        "ListValue",
        "ObjectValue"
      )
    ),

    # added this one!
    ArrayValue = make_type(
      kind = "ArrayValue",
      loc = "?Location",
      values = "array_Value"
    ),

    IntValue = make_type(
      kind  = "IntValue",
      loc   = "?Location",
      value = "_string"
    ),

    FloatValue = make_type(
      kind  = "FloatValue",
      loc   = "?Location",
      value = "_string"
    ),

    StringValue = make_type(
      kind  = "StringValue",
      loc   = "?Location",
      value = "_string"
    ),

    BooleanValue = make_type(
      kind  = "BooleanValue",
      loc   = "?Location",
      value = "_boolean"
    ),

    EnumValue = make_type(
      kind  = "EnumValue",
      loc   = "?Location",
      value = "_string"
    ),

    ListValue = make_type(
      kind = "ListValue",
      loc = "?Location",
      values = "array_Value"
    ),

    ObjectValue = make_type(
      kind   = "ObjectValue",
      loc    = "?Location",
      fields = "array_ObjectField"
    ),

    ObjectField = make_type(
      kind  = "ObjectField",
      loc   = "?Location",
      name  = "Name",
      value = "Value"
    ),


    # // Directives

    Directive = make_type(
      kind      = "Directive",
      loc       = "?Location",
      name      = "Name",
      arguments = "?array_Argument"
    ),


    # // Type Reference

    Type = make_or_type(kind = "Type", c(
      "NamedType",
      "ListType",
      "NonNullType"
    )),

    NamedType = make_type(
      kind = "NamedType",
      loc  = "?Location",
      name = "Name"
    ),

    ListType = make_type(
      kind = "ListType",
      loc  = "?Location",
      type = "Type"
    ),

    NonNullType = make_type(
      kind = "NonNullType",
      loc  = "?Location",
      type = c("NamedType", "ListType")
    ),

    # // Type Definition

    TypeDefinition = make_or_type(kind = "TypeDefinition", c(
      "ObjectTypeDefinition",
      "InterfaceTypeDefinition",
      "UnionTypeDefinition",
      "ScalarTypeDefinition",
      "EnumTypeDefinition",
      "InputObjectTypeDefinition",
      "TypeExtensionDefinition"
    )),

    ObjectTypeDefinition = make_type(
      kind       = "ObjectTypeDefinition",
      loc        = "?Location",
      name       = "Name",
      interfaces = "?array_NamedType",
      fields     = "array_FieldDefinition"
    ),

    FieldDefinition = make_type(
      kind      = "FieldDefinition",
      loc       = "?Location",
      name      = "Name",
      arguments = "array_InputValueDefinition",
      type      = "Type"
    ),

    InputValueDefinition = make_type(
      kind         = "InputValueDefinition",
      loc          = "?Location",
      name         = "Name",
      type         = "Type",
      defaultValue = "?Value"
    ),

    InterfaceTypeDefinition = make_type(
      kind   = "InterfaceTypeDefinition",
      loc    = "?Location",
      name   = "Name",
      fields = "array_FieldDefinition"
    ),

    UnionTypeDefinition = make_type(
      kind  = "UnionTypeDefinition",
      loc   = "?Location",
      name  = "Name",
      types = "array_NamedType"
    ),

    ScalarTypeDefinition = make_type(
      kind = "ScalarTypeDefinition",
      loc  = "?Location",
      name = "Name"
    ),

    EnumTypeDefinition = make_type(
      kind   = "EnumTypeDefinition",
      loc    = "?Location",
      name   = "Name",
      values = "array_EnumValueDefinition"
    ),

    EnumValueDefinition = make_type(
      kind = "EnumValueDefinition",
      loc  = "?Location",
      name = "Name"
    ),

    InputObjectTypeDefinition = make_type(
      kind   = "InputObjectTypeDefinition",
      loc    = "?Location",
      name   = "Name",
      fields = "array_InputValueDefinition"
    ),

    TypeExtensionDefinition = make_type(
      kind       = "TypeExtensionDefinition",
      loc        = "?Location",
      definition = "ObjectTypeDefinition"
    ),




    # /**
    #  * The list of all possible AST node types.
    #  */
    Node = make_or_type(kind = "Node", c(
      "Name",
      "Document",
      "OperationDefinition",
      "VariableDefinition",
      "Variable",
      "SelectionSet",
      "Field",
      "Argument",
      "FragmentSpread",
      "InlineFragment",
      "FragmentDefinition",
      "IntValue",
      "FloatValue",
      "StringValue",
      "BooleanValue",
      "EnumValue",
      "ListValue",
      "ObjectValue",
      "ObjectField",
      "Directive",
      "ListType",
      "NonNullType",
      "ObjectTypeDefinition",
      "FieldDefinition",
      "InputValueDefinition",
      "InterfaceTypeDefinition",
      "UnionTypeDefinition",
      "ScalarTypeDefinition",
      "EnumTypeDefinition",
      "EnumValueDefinition",
      "InputObjectTypeDefinition",
      "TypeExtensionDefinition"
    )),

    Definition = make_or_type(kind = "Definition", c(
      "OperationDefinition",
      "FragmentDefinition",
      "TypeDefinition"
    )),

    Selection = make_or_type(kind = "Selection", c(
      "Field",
      "FragmentSpread",
      "InlineFragment"
    ))
  )

  language_ast_type
})()
