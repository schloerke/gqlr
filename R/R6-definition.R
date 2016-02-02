
m <- missing
self_value <- function(key, classVal, selfObj, value, isMissing) {
  if (isMissing) {
    selfObj[[key]]
    return(selfObj)
  }

  if (is.null(value)) {
    selfObj[[key]] <- value
    return(selfObj)
  }

  if (!inherits(value, classVal)) {
    stop0("expected value with class of |", classVal, "|. Received ", paste(class(value), collapse = ", "))
  }
  selfObj[[key]] <- value
}
self_array_value <- function(key, classVal, selfObj, value, isMissing) {
  if (isMissing) {
    selfObj[[key]]
    return(selfObj)
  }

  if (inherits(value, "R6")) {
    stop0("expected value should be an array of ", classVal, " objects.")
  }
  lapply(seq_along(value), function(valItem) {
    if (!inherits(valItem, classVal)) {
      stop0("expected value with class of |", classVal, "|. Received ", paste(class(value), collapse = ", "))
    }
  })

  selfObj[[key]] <- value
}

self_base_value <- function(key, parse_fn, selfObj, value, isMissing) {
  if (isMissing) {
    return(selfObj[[key]])
  }
  value <- parse_fn(value)
  selfObj[[key]] <- value
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




AST <- R6Class("AST",
  public = list(
    # print = function(...) {
    #   cat()
    # }
    does_inherit = function(type) {
      inherits(self, type)
    }
  )
)



Source <- R6Class("Source",
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
    kind = function() {
      self$classname
    },
    loc = function(v) { self_value("_loc", "Location", self, v, m(v)) }
  )
)
Node <- R6Class("GQLR_HasLocation",
  inherit = HasLocation
)



Name <- R6Class("Name",
  inherit = Node,
  # loc?: ?Location;
  # value: string;
  public = list(
    "_value" = NULL
  ),
  active = list(
    value = function(v) { self_string_value("_value", self, v, m(v)) }
  )
)



Document <- R6Class("Document",
  inherit = Node,
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

GQLR_NodeWithName <- R6Class("GQLR_NodeWithName",
  inherit = Node,
  public = list("_name" = NULL),
  active = list(
    name = function(v) { self_value("_name", "Name", self, v, m(v)) }
  )
)

Definition <- R6Class("Definition",
  inherit = Node,
  # export type Definition = OperationDefinition
  #                        | FragmentDefinition
  #                        | TypeDefinition
  #                        | TypeExtensionDefinition
)

GQLR_DefinitionWithName <- R6Class("GQLR_DefinitionWithName",
  inherit = Definition,
  # name: Name;
  public = list("_name" = NULL),
  active = list(
    name = function(v) { self_value("_name", "Name", self, v, m(v)) }
  )
)


OperationDefinition <- R6Class("OperationDefinition",
  inherit = Definition,
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
      if (! (value %in% c("query", "mutation", "subscription"))) {
        stop0("invalid value supplied to operation: |", value, "|.")
      }
      self$"_value" <- value
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



Field = R6Class("Field",
  inherit = Selection,
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
  inherit = Selection,
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




# // Values

Value <- R6Class("Value",
  inherit = Node
  # loc?: ?Location;
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
  # loc?: ?Location;
  # name: Name;
  public = list("_name" = NULL),
  active = list(
    name = function(v) { self_value("_name", "Name", self, v, m(v)) }
  )
)


GQLR_ValueIsString = R6Class("IntValue",
  inherit = Value,
  # value: string;
  public = list("_value" = NULL),
  active = list(
    value = function(v) { self_string_value("_value", self, v, m(v)) }
  )
)
IntValue = R6Class("IntValue",
  inherit = GQLR_ValueIsString,
  # value: string;
)
FloatValue = R6Class("FloatValue",
  inherit = GQLR_ValueIsString,
  # value: string;
)
StringValue = R6Class("StringValue",
  inherit = GQLR_ValueIsString,
  # value: string;
)
BooleanValue = R6Class("BooleanValue",
  inherit = Value,
  # value: boolean;
  public = list("_value" = NULL),
  active = list(
    value = function(v) { self_boolean_value("_value", self, v, m(v)) }
  )
)
EnumValue = R6Class("EnumValue",
  inherit = GQLR_ValueIsString,
  # value: string;
)
ListValue = R6Class("ListValue",
  inherit = Value,
  # values: Array<Value>;
  public = list("_values" = NULL),
  active = list(
    values = function(v) { self_array_value("_values", "Value", self, v, m(v)) }
  )
)
ObjectValue = R6Class("ObjectValue",
  inherit = Value,
  # fields: Array<ObjectField>;
  public = list("_fields" = NULL),
  active = list(
    fields = function(v) { self_array_value("_fields", "ObjectField", self, v, m(v)) }
  )
)

ObjectField = R6Class("ObjectField",
  inherit = GQLR_NodeWithName,
  # value: Value;
  public = list("_value" = NULL),
  active = list(
    value = function(v) { self_array_value("_value", "Value", self, v, m(v)) }
  )
)



# // Directives

Directive = R6Class("Directive",
  inherit = GQLR_NodeWithName,
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
  # name: Name;
  public = list("_name" = NULL),
  active = list(
    name = function(v) { self_value("_name", "Name", self, v, m(v)) }
  )
)
ListType = R6Class("ListType",
  inherit = Type,
  # type: Type;
  public = list("_type" = NULL),
  active = list(
    type = function(v) { self_value("_type", "Type", self, v, m(v)) }
  )
)
NonNullType = R6Class("NonNullType",
  inherit = Type,
  # type: NamedType | ListType;
  public = list("_type" = NULL),
  active = list(
    type = function(v) {
      if (!(inherits(v, "NamedType") || inherits(v, "ListType"))) {
        stop0("expected value with class of NamedType or ListType. Received ", value$kind)
      }
      self_value("_type", "Type", self, v, m(v))
    }
  )
)



# // Type Definition
TypeDefinition = R6Class("TypeDefinition",
  inherit = GQLR_NodeWithName
  # export type TypeDefinition = ObjectTypeDefinition
  #                            | InterfaceTypeDefinition
  #                            | UnionTypeDefinition
  #                            | ScalarTypeDefinition
  #                            | EnumTypeDefinition
  #                            | InputObjectTypeDefinition
)



ObjectTypeDefinition = R6Class("ObjectTypeDefinition",
  inherit = TypeDefinition,
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
  # fields: Array<FieldDefinition>;
  public = list("_fields" = NULL),
  active = list(
    fields = function(v) { self_array_value("_fields", "FieldDefinition", self, v, m(v)) }
  )
)


UnionTypeDefinition = R6Class("UnionTypeDefinition",
  inherit = TypeDefinition,
  # types: Array<NamedType>;
  public = list("_types" = NULL),
  active = list(
    types = function(v) { self_array_value("_types", "NamedType", self, v, m(v)) }
  )
)

ScalarTypeDefinition = R6Class("ScalarTypeDefinition",
  inherit = TypeDefinition,
)

EnumTypeDefinition = R6Class("EnumTypeDefinition",
  inherit = TypeDefinition,
  # values: Array<EnumValueDefinition>;
  public = list("_values" = NULL),
  active = list(
    values = function(v) { self_array_value("_values", "EnumValueDefinition", self, v, m(v)) }
  )
)
EnumValueDefinition = R6Class("EnumValueDefinition",
  inherit = GQLR_NodeWithName,
)

InputObjectTypeDefinition = R6Class("InputObjectTypeDefinition",
  inherit = TypeDefinition,
  # fields: Array<InputValueDefinition>;
  public = list("_fields" = NULL),
  active = list(
    fields = function(v) { self_array_value("_fields", "InputValueDefinition", self, v, m(v)) }
  )
)




TypeExtensionDefinition = R6Class("TypeExtensionDefinition",
  inherit = Definition,
  # definition: ObjectTypeDefinition;
  public = list("_definition" = NULL),
  active = list(
    definition = function(v) { self_value("_definition", "ObjectTypeDefinition", self, v, m(v)) }
  )
)
