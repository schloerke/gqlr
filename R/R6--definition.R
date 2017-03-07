#' @include R6--aaa-utils.R


# 4.1.4
# http://facebook.github.io/graphql/#sec-Type-Name-Introspection
# Type Name Introspection
#
# GraphQL supports type name introspection at any point within a query by the meta field __typename: String! when querying against any Object, Interface, or Union. It returns the name of the object type currently being queried.
#
# This is most often used when querying against Interface or Union types to identify which actual type of the possible types has been returned.
#
# This field is implicit and does not appear in the fields list in any defined type.
# introspection_typename = function() {
#   return(self$type)
# }



# ASTTypes <- list(
#   SCALAR = "SCALAR",
#   OBJECT = "OBJECT",
#   INTERFACE = "INTERFACE",
#   UNION = "UNION",
#   ENUM = "ENUM",
#   INPUT_OBJECT = "INPUT_OBJECT",
#   LIST = "LIST",
#   NON_NULL = "NON_NULL"
# )


format_list = function(list_vals, .before = "", .after = "", .collapse = "", ...) {
  if (is.null(list_vals)) stop("received null list")
  if (length(list_vals) == 0) return(NULL)

  list_vals %>%
    lapply(function(x) {
      x$.format(...)
    }) %>%
    unlist() ->
  txt_arr

  collapse(.before, txt_arr, .after, collapse = .collapse)
}


AST <- R6Class("AST",
  public = list(
    .format = function(...) {
      str(self)
      stop("Not implemented")
    }
  ),
  active = list(
    .title = function() {
      if (!is.null(self$name)) {
        return(self$name$value)
      }
      self$.kind
    },
    .argNames = function() {
      names(self$.args)
    },
    .kind = function() {
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
Source <- R6_from_args(
  inherit = AST,
  "Source",
  " name: string;
    body: string;",
  active = list(
    name = function(value) {
      if (missing(value)) {
        return(self$.args$name$value)
      }

      if (is.null(value)) {
        value <- "GraphQL"
      }
      self$.args$name$value <- value
      value
    }
  )
)



Location <- R6_from_args(
  inherit = AST,
  "Location",
  " start: number;
    end: number;
    source?: ?Source;",
  public = list(
    # .str = function(maxLevel = -1, ...) {
    #   if (maxLevel == 0) {
    #     return()
    #   }
    #
    #   cat("<", self$.kind, "> (", self$start, ", ", self$end, ")", sep = "")
    # }
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
#                  | SchemaDefinition
#                  | OperationTypeDefinition
#                  | ScalarTypeDefinition
#                  | ObjectTypeDefinition
#                  | FieldDefinition
#                  | InputValueDefinition
#                  | InterfaceTypeDefinition
#                  | UnionTypeDefinition
#                  | EnumTypeDefinition
#                  | EnumValueDefinition
#                  | InputObjectTypeDefinition
#                  | TypeExtensionDefinition
#                  | DirectiveDefinition
Node <- R6_from_args("Node", inherit = AST)


Name <- R6_from_args(
  inherit = Node,
  "Name",
  " loc?: ?Location;
    value: string;",
  public = list(
    .format = function(...) {
      self$value
    }
  ),
  active = list(
    value = function(value) {
      if (missing(value)) {
        return(self$.args$value$value)
      }
      if (!str_detect(value, "^[_A-Za-z][_0-9A-Za-z]*$")) {
        stop0("Name value must match the regex of: /[_A-Za-z][_0-9A-Za-z]*/. Received value: '", value, "'")
      }
      self$.args$value$value <- value
      value
    }
  )
)



Document <- R6_from_args(
  inherit = Node,
  "Document",
  " loc?: ?Location;
    definitions: Array<Definition>;",
  private = list(
    # init_validate = function() {
    #   validate_operation_names(self)
    # }
  ),
  public = list(
    .format = function(...) {
      format_list(self$definitions, .collapse = "\n\n")
    },
    .get_operations = function() {
      ret <- list()
      for (defintion in self$definitions) {
        if (inherits(definition, "OperationDefinition")) {
          ret <- append(ret, definition)
        }
      }

      ret
    }
  )
)


# export type Definition = OperationDefinition
#                        | FragmentDefinition
#                        | TypeSystemDefinition
Definition <- R6_from_args("Definition", inherit = Node)

OperationDefinition <- R6_from_args(
  inherit = Definition,
  "OperationDefinition",
  " loc?: ?Location;
    operation: 'query' | 'mutation' | 'subscription';
    name?: ?Name;
    variableDefinitions?: ?Array<VariableDefinition>;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;",
  public = list(
    .format = function(...) {

      if (!(
        is.null(self$name) & is.null(self$variableDefinitions) & is.null(self$directives)
      )) {
        name_txt <- variable_txt <- directive_txt <- NULL

        if (!is.null(self$name)) {
          name_txt <- str_c(" ", self$name$.format())
        }
        if (!is.null(self$variableDefinitions)) {
          variable_txt <- collapse(
            "(", format_list(self$variableDefinitions, .collapse = ", "), ")"
          )
        }
        if (!is.null(self$directives)) {
          directive_txt <- format_list(self$directives, .before = " ")
        }

        pre_text <- collapse(self$operation, name_txt, variable_txt, directive_txt, " ")
      } else {
        pre_text <- NULL
      }

      collapse(
        pre_text, self$selectionSet$.format(sapce_count = 2)
      )
    }
  )
)


VariableDefinition <- R6_from_args(
  inherit = Node,
  "VariableDefinition",
  " loc?: ?Location;
    variable: Variable;
    type: Type;
    defaultValue?: ?Value;",
  public = list(
    .format = function(...) {
      collapse(
        self$variable$.format(), ": ", self$type$.format(),
        if (!is.null(self$defaultValue)) str_c(" = ", self$defaultValue$.format())
      )
    },
    .get_name = function() {
      self$variable$name$value
    }
  )
)

SelectionSet <- R6_from_args(
  inherit = Node,
  "SelectionSet",
  " loc?: ?Location;
    selections: Array<Selection>;",
  public = list(
    .format = function(..., space_count = 2) {
      before_spaces <- collapse(rep(" ", max(c(space_count - 2, 0))))

      collapse(
        "{\n",
        format_list(
          .before = collapse(rep(" ", space_count)),
          self$selections,
          .collapse = "\n",
          space_count = space_count + 2
        ), "\n",
        before_spaces, "}"
      )
    }
  )
)



# export type Selection = Field
#                       | FragmentSpread
#                       | InlineFragment
Selection = R6_from_args("Selection", inherit = Node)



Field = R6_from_args(
  inherit = Selection,
  "Field",
  " loc?: ?Location;
    alias?: ?Name;
    name: Name;
    arguments?: ?Array<Argument>;
    directives?: ?Array<Directive>;
    selectionSet?: ?SelectionSet;",
  public = list(
    .format = function(..., space_count = 0) {
      collapse(
        if (!is.null(self$alias))
          collapse(self$alias$.format(), ": "),
        self$name$.format(),
        if (!is.null(self$arguments))
          collapse("(", format_list(self$arguments, .collapse = ", "), ")"),
        if (!is.null(self$directives))
          collapse(" ", format_list(self$directives)),
        if (!is.null(self$selectionSet))
          str_c(" ", self$selectionSet$.format(space_count = space_count))
      )
    }
  )
)


Argument = R6_from_args(
  inherit = Node,
  "Argument",
  " loc?: ?Location;
    name: Name;
    value: Value;",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(),
        ": ",
        self$value$.format()
      )
    }
  )
)


FragmentSpread = R6_from_args(
  inherit = Selection,
  "FragmentSpread",
  " loc?: ?Location;
    name: Name;
    directives?: ?Array<Directive>;",
  public = list(
    .format = function(...) {
      collapse(
        "...",
        self$name$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ")
      )
    }
  )
)


InlineFragment = R6_from_args(
  inherit = Selection,
  "InlineFragment",
  " loc?: ?Location;
    typeCondition?: ?NamedType;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;",
  public = list(
    .format = function(..., space_count = 0) {
      collapse(
        "...",
        if (!is.null(self$typeCondition))
          collapse(" on ", self$typeCondition$.format()),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " "),
        " ",
        self$selectionSet$.format(space_count = space_count)
      )
    }
  )
)



FragmentDefinition = R6_from_args(
  inherit = Definition,
  "FragmentDefinition",
  " loc?: ?Location;
    name: Name;
    typeCondition: NamedType;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;",
  public = list(
    .format = function(...) {
      collapse(
        "fragment ",
        self$name$.format(),
        if (!is.null(self$typeCondition))
          collapse(" on ", self$typeCondition$.format()),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " "),
        " ", self$selectionSet$.format(space_count = 2)
      )
    }
  )
)



# // Values

# export type Value = Variable
#                   | IntValue
#                   | FloatValue
#                   | StringValue
#                   | BooleanValue
#                   | NullValue
#                   | EnumValue
#                   | ListValue
#                   | ObjectValue
Value <- R6_from_args("Value",
  inherit = Node,
  public = list(
    # serialize = function(x) {
    #   x
    # },
    # .parse_value = function(x) {
    #   x
    # },
    # .parse_literal = function(...) {
    #   self$.parse_value(...)
    # }
  )
)

Variable <- R6_from_args(
  inherit = Value,
  "Variable",
  " loc?: ?Location;
    name: Name; ",
  public = list(
    .format = function(...) {
      collapse("$", self$name$.format())
    }
  )
)

scalar_active_value <- function(value) {
  if (missing(value)) {
    return(self$.args[["value"]]$value)
  }

  self$.args[["value"]]$value <- self$.parse_value(value)
  return(invisible(value))
}

IntValue = (function(){
  # coerce_int = function (value) {
  #   MAX_INT =  2147483647
  #   MIN_INT = -2147483648
  #   num <- as.integer(value)
  #   if (is.integer(num)) {
  #     if (length(num) == 1) {
  #       if (num <= MAX_INT && num >= MIN_INT) {
  #         return(num)
  #       }
  #     }
  #   }
  #   return(NULL)
  # }

  R6_from_args(
    inherit = Value,
    "IntValue",
    " loc?: ?Location;
      value: string;",
    public = list(
      .format = function(...) {
        as.character(self$value)
      }
      # .parse_literal = coerce_int,
      # .serialize = coerce_int,
      # .parse_value = coerce_int,
      # .MAX_INT =  2147483647,
      # .MIN_INT = -2147483648
    ),
    active = list(
      # value = scalar_active_value
    )
  )
})()

FloatValue = R6_from_args(
  inherit = Value,
  "FloatValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    .format = function(...) {
      as.character(self$value)
    }
    # .parse_literal = coerce_helper(as.numeric, is.numeric),
    # .serialize = coerce_helper(as.numeric, is.numeric),
    # .parse_value = coerce_helper(as.numeric, is.numeric)
  ),
  active = list(
    # value = scalar_active_value
  )
)

StringValue = R6_from_args(
  inherit = Value,
  "StringValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    .format = function(...) {
      collapse("\"", as.character(self$value), "\"")
    }
    # .parse_literal = coerce_helper(as.character, is.character),
    # .serialize = coerce_helper(as.character, is.character),
    # .parse_value = coerce_helper(as.character, is.character)
  ),
  active = list(
    # value = scalar_active_value
  )
)

BooleanValue = R6_from_args(
  inherit = Value,
  "BooleanValue",
  " loc?: ?Location;
    value: boolean;",
  public = list(
    .format = function(...) {
      if (isTRUE(self$value)) {
        "true"
      } else {
        "false"
      }
    }
    # .parse_literal = coerce_helper(as.logical, is.logical),
    # .serialize = coerce_helper(as.logical, is.logical),
    # .parse_value = coerce_helper(as.logical, is.logical)
  ),
  active = list(
    # value = scalar_active_value
  )
)
NullValue = R6_from_args(
  inherit = Value,
  "NullValue",
  " loc?: ?Location;",
  public = list(
    .format = function(...) {
      "null"
    }
  )
)
EnumValue = R6_from_args(
  inherit = Value,
  "EnumValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    .format = function(...) {
      as.character(self$value)
    }
  )
)
ListValue = R6_from_args(
  inherit = Value,
  "ListValue",
  " loc?: ?Location;
    values: Array<Value>;",
  public = list(
    .format = function(...) {
      collapse(
        "[",
        format_list(self$values, .collapse = ", "),
        "]"
      )
    }
  )
)

object_get_by_field_name = function(name_obj) {
  for (field in self$fields) {
    if (identical(field$name$value, name_obj$value)) {
      return(field)
    }
  }
  return(NULL)
}
ObjectValue = R6_from_args(
  inherit = Value,
  "ObjectValue",
  " loc?: ?Location;
    fields: Array<ObjectField>;",
  private = list(
    # init_validate = function() {
    #   validate_input_object_field_uniqueness(self)
    # }
  ),
  public = list(
    .get_field_by_name = object_get_by_field_name,
    .format = function(...) {
      collapse(
        "{",
        format_list(self$fields, collapse = ", "),
        "}"
      )
    }
  )
)
ObjectField = R6_from_args(
  inherit = Node,
  "ObjectField",
  " loc?: ?Location;
    name: Name;
    value: Value;
  ",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(),
        ": ",
        self$value$.format()
      )
    }
  )
)



# // Directives

Directive = R6_from_args(
  inherit = Node,
  "Directive",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    arguments?: ?Array<Argument>;",
  public = list(
    .format = function(...) {
      collapse(
        "@", self$name$.format(),
        if (!is.null(self$arguments))
          collapse("(", format_list(self$arguments, .collapse = ", "), ")")
      )
    }
  )
)



# // Type Reference

# export type Type = NamedType
#                  | ListType
#                  | NonNullType
Type = R6_from_args(
  inherit = Node,
  "Type"
)


NamedType = R6_from_args(
  inherit = Type,
  "NamedType",
  " loc?: ?Location;
    name: Name;
    description?: ?string;",
  public = list(
    .matches = function(name_obj) {
      if (!inherits(name_obj, "Type")) {
        str(name_obj)
        stop("supply a Type obj")
        return(FALSE)
      }

      if (!inherits(name_obj, "NamedType")) {
        return(FALSE)
      }

      return(identical(
        self$.format(),
        name_obj$.format()
      ))
    },
    .format = function(...) {
      self$name$.format()
    }
  )
)

ListType = R6_from_args(
  inherit = Type,
  "ListType",
  " loc?: ?Location;
    type: Type;
    description?: ?string;",
  public = list(
    .format = function(...) {
      collapse(
        "[",
        self$type$.format(),
        "]"
      )
    }
  )
)

NonNullType = R6_from_args(
  inherit = Type,
  "NonNullType",
  " loc?: ?Location;
    type: NamedType | ListType;
    description?: ?string;",
  public = list(
    .format = function(...) {
      collapse(
        self$type$.format(),
        "!"
      )
    }
  )
)


# // Type Definition

# export type TypeSystemDefinition = | SchemaDefinition
#                                    | TypeDefinition
#                                    | TypeExtensionDefinition
#                                    | DirectiveDefinition
TypeSystemDefinition = R6_from_args("TypeSystemDefinition", inherit = Definition)

SchemaDefinition = R6_from_args(
  inherit = TypeSystemDefinition,
  "SchemaDefinition",
  # Changed default behavior of directives to be optional
  " loc?: ?Location;
    directives?: ?Array<Directive>;
    operationTypes: Array<OperationTypeDefinition>;",
  public = list(
    .format = function(...) {
      collapse(
        "schema",
        if (!is.null(self$directives))
          format_list(self$directives, .before = " "),
        " {\n",
          format_list(self$operationTypes, .before = "  ", .after = "\n"),
        "}"
      )
    }
  )
)


OperationTypeDefinition = R6_from_args(
  inherit = Node,
  "OperationTypeDefinition",
  " loc?: ?Location;
    operation: 'query' | 'mutation' | 'subscription';
    type: NamedType;",
  public = list(
    .format = function(...) {
      collapse(
        self$operation,
        ": ",
        self$type$.format()
      )
    }
  )
)

# export type TypeDefinition = ScalarTypeDefinition
#                            | ObjectTypeDefinition
#                            | InterfaceTypeDefinition
#                            | UnionTypeDefinition
#                            | EnumTypeDefinition
#                            | InputObjectTypeDefinition
TypeDefinition = R6_from_args("TypeDefinition", inherit = TypeSystemDefinition)

ScalarTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "ScalarTypeDefinition",
  # Changed default behavior of directives to be optional
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    .serialize?: ?fn;
    .parse_value?: ?fn;
    .parse_literal?: ?fn;",
  public = list(
    .format = function(...) {
      collapse(
        "scalar ",
        self$name$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ")
      )
    },
    initialize = function(
      loc = NULL,
      description = NULL,
      name,
      directives = NULL,
      .serialize = NULL,
      .parse_value = NULL,
      .parse_literal = NULL
    ) {
      if (is.character(name)) {
        name = Name$new(value = name)
      }
      self$name = name
      if (!missing(.serialize)) {
        self$.serialize = .serialize
      } else {
        warning(
          str_c(
            "Scalar: '", self$name$value,
            "': Setting '.serialize' to return 'NULL'"
          )
        )
        self$.serialize = function(x){ return(NULL) }
      }

      if (!missing(description)) {
        self$description = description
      }
      if (!missing(directives)) {
        self$directives = directives
      }

      if ((!missing(.parse_value)) || (!missing(.parse_literal))) {
        if (missing(.parse_value) || missing(.parse_literal)) {
          stop0(self$name, " must provide both .parse_value and .parse_literal functions")
        }
        self$.parse_value = .parse_value
        self$.parse_literal = .parse_literal
      } else {
        warning(
          str_c(
            "Scalar: '", self$name$value,
            "': Setting '.parse_value' and '.parse_literal' to return 'NULL'"
          )
        )
        self$.parse_value = function(x) { return(NULL) }
        self$.parse_literal = function(x) { return(NULL) }
      }

    }
  )
)


interface_or_object_get_field = function(field_obj) {
  find_name <- field_obj$name$value
  for (field in self$fields) {
    if (field$name$value == find_name) {
      return(field)
    }
  }
  return(NULL)
}

ObjectTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "ObjectTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    interfaces?: ?Array<NamedType>;
    directives?: ?Array<Directive>;
    fields: Array<FieldDefinition>;",
  public = list(
    .format = function(...) {
      collapse(
        "type ",
        self$name$.format(),
        if (!is.null(self$interfaces))
          collapse(
            " implements ",
            format_list(self$interfaces)
          ),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " "),
        " {\n",
        format_list(self$fields, .before = "  ", .after = "\n"),
        "}"
      )
    },
    .does_implement = function(named_type) {
      interfaces <- self$interfaces
      if (is.null(interfaces)) {
        return(FALSE)
      }
      for (interface_name in interfaces) {
        if (interface_name$.matches(named_type)) {
          return(TRUE)
        }
      }
      return(FALSE)
    },
    .get_field = interface_or_object_get_field,
    .contains_field = function(field_obj) {
      !is.null(self$.get_field(field_obj))
    }
  )
)

FieldDefinition = R6_from_args(
  inherit = TypeDefinition,
  # Changed default behavior of arguments to be optional
  "FieldDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    arguments?: ?Array<InputValueDefinition>;
    type: Type;
    directives?: ?Array<Directive>;
    .resolve?: ?fn;",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(),
        if (!is.null(self$arguments))
          collapse("(", format_list(self$arguments, .collapse = ", "), ")"),
        ": ",
        self$type$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ")
      )
    }
  )
)

InputValueDefinition = R6_from_args(
  inherit = Node,
  "InputValueDefinition",
  " loc?: ?Location;
    name: Name;
    type: Type;
    defaultValue?: ?Value;
    directives?: ?Array<Directive>;",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(),
        ": ",
        self$type$.format(),
        if (!is.null(self$defaultValue))
          collapse(" = ", self$defaultValue$.format()),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ")
      )
    }
  )
)

InterfaceTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "InterfaceTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    fields: Array<FieldDefinition>;",
  public = list(
    .format = function(...) {
      collapse(
        "interface ",
        self$name$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " "),
        " {\n",
          format_list(self$fields, .before = "  ", .after = "\n"),
        "}"
      )
    },
    .get_field = interface_or_object_get_field
  )
)

UnionTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "UnionTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    types: Array<NamedType>;",
  public = list(
    .format = function(...) {
      collapse(
        "union ",
        self$name$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " "),
        " = ",
        format_list(self$types, .collapse = " | ")
      )
    },
    .does_implement = function(named_type) {
      types <- self$types
      for (union_named_type in self$types) {
        if (union_named_type$.matches(named_type)) {
          return(TRUE)
        }
      }
      return(FALSE)
    }
  )
)

EnumTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "EnumTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    values: Array<EnumValueDefinition>;",
  public = list(
    .format = function(...) {
      collapse(
          "enum ",
          self$name$.format(),
          if (!is.null(self$directives))
            format_list(self$directives, .before = " "),
          " {\n",
            format_list(self$values, .before = "  ", .after = "\n"),
          "}"
      )
    },
    .parse_literal = function(value_obj) {

      # if (inherits(value_obj, "IntValue")) {
      #   int_val <- value_obj$value
      #   if (int_val > 0 & int_val <= length(self$values)) {
      #     return(self$values[[int_val]]$name$value)
      #   }
      #   return(NULL)
      # }

      if (!inherits(value_obj, "EnumValue")) {
        return(NULL)
      }

      for (value in self$values) {
        if (identical(value$name$value, value_obj$value)) {
          return(value_obj$value)
        }
      }

      return(NULL)
    }
  )
)

EnumValueDefinition = R6_from_args(
  inherit = Node,
  "EnumValueDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ")
      )
    }
  )
)

InputObjectTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "InputObjectTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    fields: Array<InputValueDefinition>;",
  public = list(
    .format = function(...) {
      collapse(
        "input ",
        self$name$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " "),
        " {\n",
          format_list(self$fields, .before = "  ", .after = "\n"),
        "}"
      )
    },
    .get_field_by_name = object_get_by_field_name
  )
)

TypeExtensionDefinition = R6_from_args(
  inherit = Definition,
  "TypeExtensionDefinition",
  " loc?: ?Location;
    definition: ObjectTypeDefinition;",
  public = list(
    .format = function(...) {
      collapse(
        "extend ",
        self$definition$.format()
      )
    }
  )
)


DirectiveDefinition = R6_from_args(
  inherit = Definition,
  "DirectiveDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    arguments?: ?Array<InputValueDefinition>;
    locations: Array<Name>;
    .resolve?: ?fn;",
  public = list(
    .format = function(...) {
      collapse(
        "directive @", self$name$.format(),
        if (!is.null(self$arguments))
          collapse(
            "(",
            format_list(self$arguments, .collapse = ", "),
            ")"
          ),
        "\n  on ",
        format_list(self$locations, .collapse = "\n   | ")
      )
    }
  )
)
