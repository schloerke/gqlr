
m <- base::missing
self_value <- function(key, classVal, selfObj, value, isMissing) {
  if (isMissing) {
    return(selfObj[[key]])
  }

  if (is.null(value)) {
    selfObj[[key]] <- value
    return(value)
  }

  if (!inherits(value, classVal)) {
    stop0(
      "Attempting to set ", class(selfObj)[1], ".", str_replace(key, "_", ""), ".\n",
      "Expected value with class of |", classVal, "|.\n",
      "Received ", paste(class(value), collapse = ", ")
    )
  }
  selfObj[[key]] <- value
}
self_array_value <- function(key, classVal, selfObj, value, isMissing) {
  if (isMissing) {
    return(selfObj[[key]])
  }

  if (inherits(value, "R6")) {
    stop0(
      "Attempting to set ", class(selfObj)[1], ".", str_replace(key, "_", ""), ".\n",
      "Expected value should be an array of ", classVal, " objects."
    )
  }
  lapply(value, function(valItem) {
    if (!inherits(valItem, classVal)) {
      stop0(
        "Attempting to set ", class(selfObj)[1], ".", str_replace(key, "_", ""), ".\n",
        "Expected value with class of |", classVal, "|.\n",
        "Received ", paste(class(valItem), collapse = ", ")
      )
    }
  })

  selfObj[[key]] <- value
  value
}

self_base_value <- function(key, parse_fn, selfObj, value, isMissing) {
  if (isMissing) {
    return(selfObj[[key]])
  }
  value <- parse_fn(value)
  selfObj[[key]] <- value
  value
}


self_numeric_value <- function(key, selfObj, value, isMissing) {
  self_base_value(key, as.numeric, selfObj, value, isMissing)
}
self_integer_value <- function(key, selfObj, value, isMissing) {
  self_base_value(key, as.integer, selfObj, value, isMissing)
}
self_string_value <- function(key, selfObj, value, isMissing) {
  self_base_value(key, as.character, selfObj, value, isMissing)
}
self_boolean_value <- function(key, selfObj, value, isMissing) {
  self_base_value(key, as.logical, selfObj, value, isMissing)
}

# XClass <- R6Class("XClass", public = list(kind = "XClass", y = 2))
# YClass <- R6Class("YClass", public = list(kind = "YClass", y = 2))
# Simple <- R6Class("SimpleActive",
#   public = list("_w" = NULL, "_z" = NULL),
#   active = list(
#     w = function(value) {
#       self_value(self, "_w", value, missing(value), "YClass")
#     },
#     z = function(v) {self_value("_z", "YClass", self, v, m(v))}
#   )
# )
# xObj <- XClass$new()
# yObj <- YClass$new()
# s <- Simple$new()
# s
# s$w <- yObj
# s$z <- yObj
# s
# s$z <- xObj


r6_from_json <- function(obj, level = 0, keys = c(), objPos = NULL) {
  objClass <- obj$kind
  if (is.null(objPos)) {
    keys <- append(keys, objClass)
  } else {
    keys <- append(keys, str_c(objClass, "-", objPos))
  }
  level <- level + 1


  r6Obj <- get_class_obj(objClass)

  ret <- r6Obj$new()

  fieldNames <- names(ret)
  fieldNames <- fieldNames[str_detect(fieldNames, "^_")] %>% str_replace("_", "")

  for (activeKey in fieldNames) {
    cat(level, "-", paste(keys, collapse = ","), "-", activeKey, "\n")
    objVal <- obj[[activeKey]]

    if (is.list(objVal)) {
      if (length(objVal) == 0) {
        ret[[activeKey]] <- NULL
      } else {
        if (identical(class(objVal), "list")) {
          # lapply(objVal, r6_from_json, keys = keys, level = level)
          ret[[activeKey]] <- lapply(seq_along(objVal), function(i) {
            r6_from_json(objVal[[i]], keys = keys, level = level, objPos = i)
          })
        } else {
          ret[[activeKey]] <- r6_from_json(objVal, keys = keys, level = level)
        }
      }
    } else {
      ret[[activeKey]] <- objVal
    }
  }
  ret
}


gqlr_str <- (function() {
  cat_ret_spaces <- function(spaces, ...) {
    cat("\n", rep(" ", spaces), ..., sep = "")
  }

  str_obj <- function(x, spaceCount = 0, showNull) {

    r6ObjClass <- class(x)[1]

    cat("<", r6ObjClass, ">", sep = "")

    fieldNames <- names(x)
    fieldNames <- fieldNames[str_detect(fieldNames, "^_")] %>% str_replace("_", "")

    for (fieldName in fieldNames) {
      if (fieldName %in% c("loc")) {
        next
      }

      fieldVal <- x[[fieldName]]

      if (!inherits(fieldVal, "R6")) {
        if (is.list(fieldVal)) {
          # is list
          cat_ret_spaces(spaceCount + 2, fieldName, ":")
          for (itemPos in seq_along(fieldVal)) {
            fieldItem <- fieldVal[[itemPos]]
            cat_ret_spaces(spaceCount + 4, itemPos, " - ")
            str_obj(fieldItem, spaceCount + 4, showNull)
          }

        } else {
          # is value
          if (is.null(fieldVal)) {
            fieldVal <- "NULL"
            if (showNull) {
              cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
            }
          } else if (is.numeric(fieldVal)) {
            cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
          } else if (is.character(fieldVal)) {
            cat_ret_spaces(spaceCount + 2, fieldName, ": '", fieldVal, "'")
          }
        }

      } else {
        # recursive call to_string
        cat_ret_spaces(spaceCount + 2, fieldName, ": ")
        str_obj(fieldVal, spaceCount + 2, showNull)
      }

    }
  }

  function(x, showNull = FALSE) {
    str_obj(x, 0, showNull)
    cat("\n")
  }
})()





AST <- R6Class("AST",
  public = list(
    # print = function(...) {
    #   cat()
    # }
    # initialize = function(obj) {
    #   selfKind <- self$kind
    #
    #   classObj = get_class_obj(kind)
    #
    #   ret <- classObj$new()
    #
    #   for (key in names(classObj$active)) {
    #     ret[[key]] <- classObj$init_from_obj(obj[[key]])
    #   }
    #   ret
    #   browser()
    # }
  ),
  active = list(
    kind = function() {
      class(self)[1]
    }
  )
)




# /**
#  * A representation of source input to GraphQL. The name is optional,
#  * but is mostly useful for clients who store GraphQL documents in
#  * source files; for example, if the GraphQL input is in a file Foo.graphql,
#  * it might be useful for name to be "Foo.graphql".
#  */
Source <- R6Class("Source",
  # body: string;
  # name: string;
  public = list(
    "_body" = NULL, "_name" = NULL,
    initialize = function(body, name) {
      if (!missing(body)) self$body <- body
      if (!missing(name)) self$name <- name else self$name <- "GraphQLR"
    }
  ),
  active = list(
    body = function(v) { self_string_value("_body", self, v, m(v)) },
    name = function(v) { self_string_value("_name", self, v, m(v)) }
  )
)



Location <- R6Class("Location",
  inherit = AST,
  # export type Location = {
  #   start: number;
  #   end: number;
  #   source?: ?Source
  # }
  public = list(
    "_start" = NULL, "_end" = NULL, "_source" = NULL,
    initialize = function(start, end, source) {
      if(!missing(start)) self$start = start
      if(!missing(end)) self$end = end
      if(!missing(source)) self$source = source
    }
  ),
  active = list(
    start = function(v) { self_integer_value("_start", self, v, m(v)) },
    end = function(v) { self_integer_value("_end", self, v, m(v)) },
    source = function(v) { self_value("_source", "Source", self, v, m(v)) }
  )
)


class_with_name <- function(className, inheritR6Obj) {
  R6Class(className,
    inherit = inheritR6Obj,
    public = list("_name" = NULL),
    active = list(
      name = function(v) { self_value("_name", "Name", self, v, m(v)) }
    )
  )
}



# /**
#  * The list of all possible AST node types.
#  */
# export type Node = Name
#                  | Document
#                  | OperationDefinition
#                  | VariableDefinition
#                  | Variable
#                  | SelectionSet
#                  | Field
#                  | Argument
#                  | FragmentSpread
#                  | InlineFragment
#                  | FragmentDefinition
#                  | IntValue
#                  | FloatValue
#                  | StringValue
#                  | BooleanValue
#                  | EnumValue
#                  | ListValue
#                  | ObjectValue
#                  | ObjectField
#                  | Directive
#                  | NamedType
#                  | ListType
#                  | NonNullType
#                  | ObjectTypeDefinition
#                  | FieldDefinition
#                  | InputValueDefinition
#                  | InterfaceTypeDefinition
#                  | UnionTypeDefinition
#                  | ScalarTypeDefinition
#                  | EnumTypeDefinition
#                  | EnumValueDefinition
#                  | InputObjectTypeDefinition
#                  | TypeExtensionDefinition

GQLR_HasLocation <- R6Class("GQLR_HasLocation",
  inherit = AST,
  public = list(
    "_loc" = NULL
  ),
  active = list(
    loc = function(v) { self_value("_loc", "Location", self, v, m(v)) }
  )
)
Node <- R6Class("Node",
  inherit = GQLR_HasLocation
)



Name <- R6Class("Name",
  inherit = Node,
  # kind: 'Name';
  # loc?: ?Location;
  # value: string;
  public = list(
    "_value" = NULL
  ),
  active = list(
    value = function(v) { self_string_value("_value", self, v, m(v)) }
  )
)
GQLR_NodeWithName <- R6Class("GQLR_NodeWithName",
  inherit = Node,
  public = list("_name" = NULL),
  active = list(
    name = function(v) { self_value("_name", "Name", self, v, m(v)) }
  )
)



Document <- R6Class("Document",
  inherit = Node,
  # kind: 'Document';
  # loc?: ?Location;
  # definitions: Array<Definition>;
  public = list(
    "_definitions" = NULL
  ),
  active = list(
    definitions = function(v) {
      self_array_value("_definitions", "Definition", self, v, m(v))
    }
  )
)


Definition <- R6Class("Definition",
  inherit = Node,
  # export type Definition = OperationDefinition
  #                        | FragmentDefinition
  #                        | TypeDefinition
  #                        | TypeExtensionDefinition
)

GQLR_DefinitionWithName <- class_with_name("GQLR_DefinitionWithName", Definition)


OperationDefinition <- R6Class("OperationDefinition",
  inherit = Definition,
  # kind: 'OperationDefinition';
  # loc?: ?Location;
  # operation: 'query' | 'mutation' | 'subscription';
  # name?: ?Name;
  # variableDefinitions?: ?Array<VariableDefinition>;
  # directives?: ?Array<Directive>;
  # selectionSet: SelectionSet;
  public = list(
    "_operation" = NULL,
    "_variableDefinitions" = NULL,
    "_directives" = NULL,
    "_selectionSet" = NULL
  ),
  active = list(
    operation = function(value) {
      if (missing(value)) {
        return(self$"_operation")
      }
      if (! (value %in% c("query", "mutation", "subscription"))) {
        stop0("invalid value supplied to operation: |", value, "|.")
      }
      self$"_operation" <- value
      value
    },
    variableDefinitions = function(v) {
      self_array_value(
        "_variableDefinitions", "VariableDefinition",
        self, v, m(v)
      )
    },
    directives = function(v) {
      self_array_value("_directives", "Directive", self, v, m(v))
    },
    selectionSet = function(v) {
      self_value("_selectionSet", "SelectionSet", self, v, m(v))
    }
  )

)



VariableDefinition <- R6Class("VariableDefinition",
  inherit = Node,
  # kind: 'VariableDefinition';
  # loc?: ?Location;
  # variable: Variable;
  # type: Type;
  # defaultValue?: ?Value;
  public = list(
    "_variable" = NULL, "_type" = NULL, "_defaultValue" = NULL
  ),
  active = list(
    variable = function(v) {
      self_value("_variable", "Variable", self, v, m(v))
    },
    type = function(v) {
      self_value("_type", "Type", self, v, m(v))
    },
    defaultValue = function(v) {
      self_value("_defaultValue", "Value", self, v, m(v))
    }
  )
)



SelectionSet <- R6Class("SelectionSet",
  inherit = Node,
  # kind: 'SelectionSet';
  # loc?: ?Location;
  # selections: Array<Selection>;
  public = list("_selections" = NULL),
  active = list(
    selections = function(v) {
      self_array_value("_selections", "Selection", self, v, m(v))
    }
  )
)



Selection = R6Class("Selection",
  # export type Selection = Field
  #                       | FragmentSpread
  #                       | InlineFragment
  inherit = Node
)
GQLR_SelectionWithName <- class_with_name("GQLR_SelectionWithName", Selection)



Field = R6Class("Field",
  inherit = GQLR_SelectionWithName,
  # kind: 'Field';
  # loc?: ?Location;
  # alias?: ?Name;
  # name: Name;
  # arguments?: ?Array<Argument>;
  # directives?: ?Array<Directive>;
  # selectionSet?: ?SelectionSet;
  public = list(
    "_alias" = NULL, "_arguments" = NULL, "_directives" = NULL, "_selectionSet" = NULL
  ),
  active = list(
    alias = function(v) {
      self_value("_alias", "Alias", self, v, m(v))
    },
    arguments = function(v) {
      self_array_value("_arguments", "Argument", self, v, m(v))
    },
    directives = function(v) {
      self_array_value("_directives", "Directive", self, v, m(v))
    },
    selectionSet = function(v) {
      self_value("_selectionSet", "SelectionSet", self, v, m(v))
    }
  )
)



Argument = R6Class("Argument",
  inherit = Node,
  # kind: 'Argument';
  # loc?: ?Location;
  # name: Name;
  # value: Value;
  public = list(
    "_value" = NULL
  ),
  active = list(
    value = function(v) {
      self_value("_value", "Value", self, v, m(v))
    }
  )
)


FragmentSpread = R6Class("FragmentSpread",
  inherit = GQLR_SelectionWithName,
  # kind: 'FragmentSpread';
  # loc?: ?Location;
  # name: Name;
  # directives?: ?Array<Directive>;
  public = list("_directives" = NULL),
  active = list(
    directives = function(v) {
      self_array_value("_directives", "Directive", self, v, m(v))
    }
  )
)


InlineFragment = R6Class("InlineFragment",
  inherit = Selection,
  # kind: 'InlineFragment';
  # loc?: ?Location;
  # typeCondition?: ?NamedType;
  # directives?: ?Array<Directive>;
  # selectionSet: SelectionSet;
  public = list("_typeCondition" = NULL,"_directives" = NULL, "_selectionSet" = NULL),
  active = list(
    typeCondition = function(v) {
      self_value("_typeCondition", "NamedType", self, v, m(v))
    },
    directives = function(v) {
      self_array_value("_directives", "Directive", self, v, m(v))
    },
    selectionSet = function(v) {
      self_value("_selectionSet", "SelectionSet", self, v, m(v))
    }
  )
)



FragmentDefinition = R6Class("FragmentDefinition",
  inherit = GQLR_DefinitionWithName,
  # kind: 'FragmentDefinition';
  # loc?: ?Location;
  # name: Name;
  # typeCondition: NamedType;
  # directives?: ?Array<Directive>;
  # selectionSet: SelectionSet;
  public = list("_typeCondition" = NULL,"_directives" = NULL, "_selectionSet" = NULL),
  active = list(
    typeCondition = function(v) {
      self_value("_typeCondition", "NamedType", self, v, m(v))
    },
    directives = function(v) {
      self_array_value("_directives", "Directive", self, v, m(v))
    },
    selectionSet = function(v) {
      self_value("_selectionSet", "SelectionSet", self, v, m(v))
    }
  )
)




# // Values

Value <- R6Class("Value",
  inherit = Node
  # export type Value = Variable
  #                   | IntValue
  #                   | FloatValue
  #                   | StringValue
  #                   | BooleanValue
  #                   | EnumValue
  #                   | ListValue
  #                   | ObjectValue
)


Variable <- R6Class("Variable",
  inherit = Value,
  # kind: 'Variable';
  # loc?: ?Location;
  # name: Name;
  public = list("_name" = NULL),
  active = list(
    name = function(v) { self_value("_name", "Name", self, v, m(v)) }
  )
)


GQLR_ValueIsString = R6Class("IntValue",
  inherit = Value,
  # loc?: ?Location;
  # value: string;
  public = list("_value" = NULL),
  active = list(
    value = function(v) { self_string_value("_value", self, v, m(v)) }
  )
)
IntValue = R6Class("IntValue",
  inherit = GQLR_ValueIsString,
  # kind: 'IntValue';
  # loc?: ?Location;
  # value: string;
)
FloatValue = R6Class("FloatValue",
  inherit = GQLR_ValueIsString,
  # kind: 'FloatValue';
  # loc?: ?Location;
  # value: string;
)
StringValue = R6Class("StringValue",
  inherit = GQLR_ValueIsString,
  # kind: 'StringValue';
  # loc?: ?Location;
  # value: string;
)
BooleanValue = R6Class("BooleanValue",
  inherit = Value,
  # kind: 'BooleanValue';
  # loc?: ?Location;
  # value: boolean;
  public = list("_value" = NULL),
  active = list(
    value = function(v) { self_boolean_value("_value", self, v, m(v)) }
  )
)
EnumValue = R6Class("EnumValue",
  inherit = GQLR_ValueIsString,
  # kind: 'EnumValue';
  # loc?: ?Location;
  # value: string;
)
ListValue = R6Class("ListValue",
  inherit = Value,
  # kind: 'ListValue';
  # loc?: ?Location;
  # values: Array<Value>;
  public = list("_values" = NULL),
  active = list(
    values = function(v) { self_array_value("_values", "Value", self, v, m(v)) }
  )
)
ObjectValue = R6Class("ObjectValue",
  inherit = Value,
  # kind: 'ObjectValue';
  # loc?: ?Location;
  # fields: Array<ObjectField>;
  public = list("_fields" = NULL),
  active = list(
    fields = function(v) { self_array_value("_fields", "ObjectField", self, v, m(v)) }
  )
)

ObjectField = R6Class("ObjectField",
  inherit = GQLR_NodeWithName,
  # kind: 'ObjectField';
  # loc?: ?Location;
  # name: Name;
  # value: Value;
  public = list("_value" = NULL),
  active = list(
    value = function(v) { self_array_value("_value", "Value", self, v, m(v)) }
  )
)



# // Directives

Directive = R6Class("Directive",
  inherit = GQLR_NodeWithName,
  # kind: 'Directive';
  # loc?: ?Location;
  # name: Name;
  # arguments?: ?Array<Argument>;
  public = list("_arguments" = NULL),
  active = list(
    arguments = function(v) { self_array_value("_arguments", "Argument", self, v, m(v)) }
  )
)



# // Type Reference

Type = R6Class("Type",
  inherit = Node
  # export type Type = NamedType
  #                  | ListType
  #                  | NonNullType
)


NamedType = R6Class("NamedType",
  inherit = Type,
  # kind: 'NamedType';
  # loc?: ?Location;
  # name: Name;
  public = list("_name" = NULL),
  active = list(
    name = function(v) { self_value("_name", "Name", self, v, m(v)) }
  )
)
ListType = R6Class("ListType",
  inherit = Type,
  # kind: 'ListType';
  # loc?: ?Location;
  # type: Type;
  public = list("_type" = NULL),
  active = list(
    type = function(v) { self_value("_type", "Type", self, v, m(v)) }
  )
)
NonNullType = R6Class("NonNullType",
  inherit = Type,
  # kind: 'NonNullType';
  # loc?: ?Location;
  # type: NamedType | ListType;
  public = list("_type" = NULL),
  active = list(
    type = function(v) {
      if (missing(v)) {
        return(self$"_type")
      }
      if (!(inherits(v, "NamedType") || inherits(v, "ListType"))) {
        stop0("expected value with class of NamedType or ListType. Received ", value$kind)
      }
      self_value("_type", "Type", self, v, m(v))
    }
  )
)



# // Type Definition
TypeDefinition = R6Class("TypeDefinition",
  inherit = GQLR_DefinitionWithName
  # export type TypeDefinition = ObjectTypeDefinition
  #                            | InterfaceTypeDefinition
  #                            | UnionTypeDefinition
  #                            | ScalarTypeDefinition
  #                            | EnumTypeDefinition
  #                            | InputObjectTypeDefinition
)



ObjectTypeDefinition = R6Class("ObjectTypeDefinition",
  inherit = TypeDefinition,
  # kind: 'ObjectTypeDefinition';
  # loc?: ?Location;
  # name: Name;
  # interfaces?: ?Array<NamedType>;
  # fields: Array<FieldDefinition>;
  public = list("_interfaces" = NULL, "_fields" = NULL),
  active = list(
    interfaces = function(v) { self_array_value("_interfaces", "NamedType", self, v, m(v)) },
    fields = function(v) { self_array_value("_fields", "FieldDefinition", self, v, m(v)) }
  )
)



FieldDefinition = R6Class("FieldDefinition",
  inherit = TypeDefinition,
  # kind: 'FieldDefinition';
  # loc?: ?Location;
  # name: Name;
  # arguments: Array<InputValueDefinition>;
  # type: Type;
  public = list("_arguments" = NULL, "_type" = NULL),
  active = list(
    arguments = function(v) {
      self_array_value("_arguments", "InputValueDefinition", self, v, m(v))
    },
    type = function(v) { self_value("_type", "Type", self, v, m(v)) }
  )
)



InputValueDefinition = R6Class("InputValueDefinition",
  inherit = GQLR_NodeWithName,
  # kind: 'InputValueDefinition';
  # loc?: ?Location;
  # name: Name;
  # type: Type;
  # defaultValue?: ?Value;
  public = list("_type" = NULL, "_defaultValue" = NULL),
  active = list(
    type = function(v) { self_value("_type", "Type", self, v, m(v)) },
    defaultValue = function(v) { self_value("_defaultValue", "Value", self, v, m(v)) }
  )
)

InterfaceTypeDefinition = R6Class("InputValueDefinition",
  inherit = TypeDefinition,
  # kind: 'InterfaceTypeDefinition';
  # loc?: ?Location;
  # name: Name;
  # fields: Array<FieldDefinition>;
  public = list("_fields" = NULL),
  active = list(
    fields = function(v) { self_array_value("_fields", "FieldDefinition", self, v, m(v)) }
  )
)


UnionTypeDefinition = R6Class("UnionTypeDefinition",
  inherit = TypeDefinition,
  # kind: 'UnionTypeDefinition';
  # loc?: ?Location;
  # name: Name;
  # types: Array<NamedType>;
  public = list("_types" = NULL),
  active = list(
    types = function(v) { self_array_value("_types", "NamedType", self, v, m(v)) }
  )
)

ScalarTypeDefinition = R6Class("ScalarTypeDefinition",
  inherit = TypeDefinition,
  # kind: 'ScalarTypeDefinition';
  # loc?: ?Location;
  # name: Name;
)

EnumTypeDefinition = R6Class("EnumTypeDefinition",
  inherit = TypeDefinition,
  # kind: 'EnumTypeDefinition';
  # loc?: ?Location;
  # name: Name;
  # values: Array<EnumValueDefinition>;
  public = list("_values" = NULL),
  active = list(
    values = function(v) { self_array_value("_values", "EnumValueDefinition", self, v, m(v)) }
  )
)
EnumValueDefinition = R6Class("EnumValueDefinition",
  inherit = GQLR_NodeWithName,
  # kind: 'EnumValueDefinition';
  # loc?: ?Location;
  # name: Name;
)

InputObjectTypeDefinition = R6Class("InputObjectTypeDefinition",
  inherit = TypeDefinition,
  # kind: 'InputObjectTypeDefinition';
  # loc?: ?Location;
  # name: Name;
  # fields: Array<InputValueDefinition>;
  public = list("_fields" = NULL),
  active = list(
    fields = function(v) { self_array_value("_fields", "InputValueDefinition", self, v, m(v)) }
  )
)




TypeExtensionDefinition = R6Class("TypeExtensionDefinition",
  inherit = Definition,
  # kind: 'TypeExtensionDefinition';
  # loc?: ?Location;
  # definition: ObjectTypeDefinition;
  public = list("_definition" = NULL),
  active = list(
    definition = function(v) { self_value("_definition", "ObjectTypeDefinition", self, v, m(v)) }
  )
)












get_class_obj <- (function(){
  classList <- list(
    AST = AST,
    Location = Location,
    Node = Node,
    Name = Name,
    Document = Document,
    Definition = Definition,
    OperationDefinition = OperationDefinition,
    VariableDefinition = VariableDefinition,
    Variable = Variable,
    SelectionSet = SelectionSet,
    Selection = Selection,
    Field = Field,
    Argument = Argument,
    FragmentSpread = FragmentSpread,
    InlineFragment = InlineFragment,
    FragmentDefinition = FragmentDefinition,
    Value = Value,
    IntValue = IntValue,
    FloatValue = FloatValue,
    StringValue = StringValue,
    BooleanValue = BooleanValue,
    EnumValue = EnumValue,
    ListValue = ListValue,
    ObjectValue = ObjectValue,
    ObjectField = ObjectField,
    Directive = Directive,
    Type = Type,
    NamedType = NamedType,
    ListType = ListType,
    NonNullType = NonNullType,
    TypeDefinition = TypeDefinition,
    ObjectTypeDefinition = ObjectTypeDefinition,
    FieldDefinition = FieldDefinition,
    InputValueDefinition = InputValueDefinition,
    InterfaceTypeDefinition = InterfaceTypeDefinition,
    UnionTypeDefinition = UnionTypeDefinition,
    ScalarTypeDefinition = ScalarTypeDefinition,
    EnumTypeDefinition = EnumTypeDefinition,
    EnumValueDefinition = EnumValueDefinition,
    InputObjectTypeDefinition = InputObjectTypeDefinition,
    TypeExtensionDefinition = TypeExtensionDefinition
  )

  function(classVal) {
    obj = classList[[classVal]]
    if (is.null(obj)) {
      stop0("Could not find object with class: ", classVal)
    }
    obj
  }
})()
