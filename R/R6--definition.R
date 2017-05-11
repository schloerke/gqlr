#' @include R6--aaa-utils.R
#' @include S3--aaa-setup.R

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("self"))
}


format_list <- function(list_vals, .before = "", .after = "", .collapse = "", ...) {
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
      stop(".format() not implemented")
    }
  ),
  active = list(
    .title = function() {
      if (!is.null(self$name)) {
        return(format(self$name))
      }
      class(self)[1]
    },
    .argNames = function() {
      names(self$.args)
    }

  )
)



# # nolint start
# # /**
# #  * A representation of source input to GraphQL. The name is optional,
# #  * but is mostly useful for clients who store GraphQL documents in
# #  * source files; for example, if the GraphQL input is in a file Foo.graphql,
# #  * it might be useful for name to be "Foo.graphql".
# #  */
# Source <- R6_from_args(
#   inherit = AST,
#   "Source",
#   " name: string;
#     body: string;",
#   active = list(
#     name = function(value) {
#       if (missing(value)) {
#         return(self$.args$name$value)
#       }
#
#       if (is.null(value)) {
#         value <- "GraphQL"
#       }
#       self$.args$name$value <- value
#       value
#     },
#     .format = function(...) {
#       stop("implement!")
#     }
#   )
# )
# # nolint end



Position <- R6_from_args(
  inherit = AST,
  "Position",
  " line: numeric;
    column: numeric;",
  public = list(
    .format = function(...) {
      str_c(self$line, ":", self$column)
    }
  )
)

Location <- R6_from_args(
  inherit = AST,
  "Location",
  " start: Position;
    end: Position;
    source?: ?Source;",
  public = list(
    initialize = function(start, end, source = NULL) {
      self$start <- Position$new(line = start$line, column = start$column)
      self$end <- Position$new(line = end$line, column = end$column)
      self$source <- source
      invisible(self)
    },
    .format = function(...) {
      str_c("location ", format(self$start), " to ", format(self$end))
    }
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
        stop(
          "Name value must match the regex of: /[_A-Za-z][_0-9A-Za-z]*/. ",
          "Received value: '", value, "'"
        )
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
  public = list(
    .format = function(...) {
      format_list(self$definitions, .collapse = "\n\n", ...)
    },
    .get_operations = function() {
      ret <- list()
      for (definition in self$definitions) {
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
    operation: 'query' | 'mutation';
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
          name_txt <- str_c(" ", self$name$.format(...))
        }
        if (!is.null(self$variableDefinitions)) {
          variable_txt <- collapse(
            "(", format_list(self$variableDefinitions, .collapse = ", ", ...), ")"
          )
        }
        if (!is.null(self$directives)) {
          directive_txt <- format_list(self$directives, .before = " ", ...)
        }

        pre_text <- collapse(self$operation, name_txt, variable_txt, directive_txt, " ")
      } else {
        pre_text <- NULL
      }

      collapse(
        pre_text, self$selectionSet$.format(space_count = 2, ...)
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
        self$variable$.format(...), ": ", self$type$.format(...),
        if (!is.null(self$defaultValue)) str_c(" = ", self$defaultValue$.format(...))
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
          space_count = space_count + 2,
          ...
        ), "\n",
        before_spaces, "}"
      )
    }
  )
)



# export type Selection = Field
#                       | FragmentSpread
#                       | InlineFragment
Selection <- R6_from_args("Selection", inherit = Node)



Field <- R6_from_args(
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
          collapse(self$alias$.format(...), ": "),
        self$name$.format(...),
        if (!is.null(self$arguments))
          collapse("(", format_list(self$arguments, .collapse = ", ", ...), ")"),
        if (!is.null(self$directives))
          collapse(" ", format_list(self$directives, ...)),
        if (!is.null(self$selectionSet))
          str_c(" ", self$selectionSet$.format(space_count = space_count, ...))
      )
    },
    .show_in_format = TRUE,
    .get_matching_argument = function(argument) {
      self_args <- self$arguments
      if (is.null(self_args)) return(NULL)
      if (length(self_args) == 0) return(NULL)

      argument_name <- argument$.get_name()

      for (self_arg in self_args) {
        if (identical(self_arg$name$value, argument_name)) {
          return(self_arg)
        }
      }
      return(NULL)
    }
  )
)


Argument <- R6_from_args(
  inherit = Node,
  "Argument",
  " loc?: ?Location;
    name: Name;
    value: Value;",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(...),
        ": ",
        self$value$.format(...)
      )
    }
  )
)


FragmentSpread <- R6_from_args(
  inherit = Selection,
  "FragmentSpread",
  " loc?: ?Location;
    name: Name;
    directives?: ?Array<Directive>;",
  public = list(
    .format = function(...) {
      collapse(
        "...",
        self$name$.format(...),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...)
      )
    }
  )
)


InlineFragment <- R6_from_args(
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
          collapse(" on ", self$typeCondition$.format(...)),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...),
        " ",
        self$selectionSet$.format(space_count = space_count, ...)
      )
    }
  )
)



FragmentDefinition <- R6_from_args(
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
        self$name$.format(...),
        if (!is.null(self$typeCondition))
          collapse(" on ", self$typeCondition$.format(...)),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...),
        " ", self$selectionSet$.format(space_count = 2, ...)
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
Value <- R6_from_args("Value", inherit = Node)

Variable <- R6_from_args(
  inherit = Value,
  "Variable",
  " loc?: ?Location;
    name: Name; ",
  public = list(
    .format = function(...) {
      collapse("$", self$name$.format(...))
    }
  )
)

IntValue <- R6_from_args(
  inherit = Value,
  "IntValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    .format = function(...) {
      as.character(self$value)
    }
  )
)

FloatValue <- R6_from_args(
  inherit = Value,
  "FloatValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    .format = function(...) {
      as.character(self$value)
    }
  )
)

StringValue <- R6_from_args(
  inherit = Value,
  "StringValue",
  " loc?: ?Location;
    value: string;",
  public = list(
    .format = function(...) {
      collapse("\"", as.character(self$value), "\"")
    }
  )
)

BooleanValue <- R6_from_args(
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
  )
)
NullValue <- R6_from_args(
  inherit = Value,
  "NullValue",
  " loc?: ?Location;",
  public = list(
    .format = function(...) {
      "null"
    }
  )
)
EnumValue <- R6_from_args(
  inherit = Value,
  "EnumValue",
  " loc?: ?Location;
    description?: ?string;
    value: string;",
  public = list(
    .format = function(...) {
      as.character(self$value)
    }
  )
)
ListValue <- R6_from_args(
  inherit = Value,
  "ListValue",
  " loc?: ?Location;
    values: Array<Value>;",
  public = list(
    .format = function(...) {
      collapse(
        "[",
        format_list(self$values, .collapse = ", ", ...),
        "]"
      )
    }
  )
)


get_by_field <- function(field_obj) {
  field_name <- field_obj$name$value
  for (field in self$fields) {
    if (identical(field$name$value, field_name)) {
      return(field)
    }
  }
  return(NULL)
}
ObjectValue <- R6_from_args(
  inherit = Value,
  "ObjectValue",
  " loc?: ?Location;
    fields: Array<ObjectField>;",
  public = list(
    .get_field = get_by_field,
    .format = function(...) {
      collapse(
        "{",
        format_list(self$fields, collapse = ", ", ...),
        "}"
      )
    }
  )
)
ObjectField <- R6_from_args(
  inherit = Node,
  "ObjectField",
  " loc?: ?Location;
    name: Name;
    value: Value;
  ",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(...),
        ": ",
        self$value$.format(...)
      )
    }
  )
)



# // Directives

Directive <- R6_from_args(
  inherit = Node,
  "Directive",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    arguments?: ?Array<Argument>;",
  public = list(
    .format = function(...) {
      collapse(
        "@", self$name$.format(...),
        if (!is.null(self$arguments))
          collapse("(", format_list(self$arguments, .collapse = ", ", ...), ")")
      )
    }
  )
)



# // Type Reference

# export type Type = NamedType
#                  | ListType
#                  | NonNullType
Type <- R6_from_args(
  inherit = Node,
  "Type",
  public = list(
    .matches = function(name_obj) {
      if (!inherits(name_obj, "Type")) {
        str(name_obj)
        stop("Must supply a Type object")
        return(FALSE)
      }

      return(identical(
        self$.format(),
        name_obj$.format()
      ))
    }
  )
)


NamedType <- R6_from_args(
  inherit = Type,
  "NamedType",
  " loc?: ?Location;
    name: Name;
    description?: ?string;",
  public = list(
    .format = function(...) {
      self$name$.format(...)
    }
  )
)

ListType <- R6_from_args(
  inherit = Type,
  "ListType",
  " loc?: ?Location;
    type: Type;
    description?: ?string;",
  public = list(
    .format = function(...) {
      collapse(
        "[",
        self$type$.format(...),
        "]"
      )
    }
  )
)

NonNullType <- R6_from_args(
  inherit = Type,
  "NonNullType",
  " loc?: ?Location;
    type: NamedType | ListType;
    description?: ?string;",
  public = list(
    .format = function(...) {
      collapse(
        self$type$.format(...),
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
TypeSystemDefinition <- R6_from_args("TypeSystemDefinition", inherit = Definition)

SchemaDefinition <- R6_from_args(
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
          format_list(self$directives, .before = " ", ...),
        " {\n",
          format_list(self$operationTypes, .before = "  ", .after = "\n", ...),
        "}"
      )
    },
    .get_definition_type = function(def_name) {
      if (!(def_name %in% c("query", "mutation"))) {
        stop("'def_name' must be either 'query' or 'mutation'")
      }

      for (operation_type in self$operationTypes) {
        if (identical(operation_type$operation, def_name)) {
          return(operation_type$type)
        }
      }

      return(NULL)
    }
  )
)


OperationTypeDefinition <- R6_from_args(
  inherit = Node,
  "OperationTypeDefinition",
  " loc?: ?Location;
    operation: 'query' | 'mutation';
    type: NamedType;",
  public = list(
    .format = function(...) {
      collapse(
        self$operation,
        ": ",
        self$type$.format(...)
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
TypeDefinition <- R6_from_args("TypeDefinition", inherit = TypeSystemDefinition)

ScalarTypeDefinition <- R6_from_args(
  inherit = TypeDefinition,
  "ScalarTypeDefinition",
  # Changed default behavior of directives to be optional
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    .resolve: fn;
    .parse_ast?: ?fn;",
  public = list(
    .format = function(...) {
      collapse(
        "scalar ",
        self$name$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...)
      )
    },
    initialize = function(
      loc = NULL,
      description = NULL,
      name,
      directives = NULL,
      # takes in a raw value, such as: "5", 5, 5.0
      .resolve = function(x, schema) {
        stop(".resolve() not implemented for Scalar of type: ", format(self$name))
      },
      # takes in AST value object: <BooleanValue>
      .parse_ast = NULL
    ) {
      self$name <- name
      self$description <- description
      self$directives <- directives
      self$.resolve <- .resolve
      if (missing(.parse_ast)) {
        self$.parse_ast <- parse_ast(format(self$name), .resolve)
      } else {
        self$.parse_ast <- .parse_ast
      }

      invisible(self)
    }
  )
)


ObjectTypeDefinition <- R6_from_args(
  inherit = TypeDefinition,
  "ObjectTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    interfaces?: ?Array<NamedType>;
    directives?: ?Array<Directive>;
    fields: Array<FieldDefinition>;
    .resolve?: ?fn;",
  public = list(
    .format = function(..., all_fields = FALSE) {
      fields <- self$fields
      if (!isTRUE(all_fields)) {
        show_fields <- lapply(fields, "[[", ".show_in_format") %>% unlist()
        fields <- fields[show_fields]
      }

      collapse(
        "type ",
        self$name$.format(),
        if (!is.null(self$interfaces))
          collapse(
            " implements ",
            format_list(self$interfaces, .collapse = ", ", ...)
          ),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...),
        " {\n",
        format_list(fields, .before = "  ", .after = "\n", ...),
        "}"
      )
    },
    .has_interface = function(named_type) {
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
    .get_field = get_by_field,
    .contains_field = function(field_obj) {
      !is.null(self$.get_field(field_obj))
    },
    initialize = function(
      loc = NULL,
      description = NULL,
      name,
      interfaces = NULL,
      directives = NULL,
      fields,
      .resolve = NULL
    ) {
      self$loc <- loc
      self$description <- description
      self$name <- name
      self$interfaces <- interfaces
      self$directives <- directives

      typename_field <- FieldDefinition$new(
        name = Name$new(value = "__typename"),
        type = NamedType$new(name = Name$new(value = "String"))
      )
      typename_field$.allow_double_underscore <- TRUE
      typename_field$.show_in_format <- FALSE
      self$fields <- append(fields, typename_field)

      self$.resolve <- .resolve

      invisible(self)
    }
  )
)

FieldDefinition <- R6_from_args(
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
          collapse("(", format_list(self$arguments, .collapse = ", ", ...), ")"),
        ": ",
        self$type$.format(),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...)
      )
    },
    .allow_double_underscore = FALSE,
    .show_in_format = TRUE,
    initialize = function(
      loc = NULL,
      description = NULL,
      name,
      arguments = NULL,
      type,
      directives = NULL,
      .resolve = NULL
    ) {
      self$loc <- loc
      self$description <- description
      self$name <- name
      self$arguments <- arguments
      self$type <- type
      self$directives <- directives
      self$.resolve <- .resolve

      invisible(self)
    }
  )
)

InputValueDefinition <- R6_from_args(
  inherit = Node,
  "InputValueDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    type: Type;
    defaultValue?: ?Value;
    directives?: ?Array<Directive>;",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(...),
        ": ",
        self$type$.format(...),
        if (!is.null(self$defaultValue))
          collapse(" = ", self$defaultValue$.format(...)),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...)
      )
    },
    .get_name = function() {
      self$name$value
    }
  )
)

InterfaceTypeDefinition <- R6_from_args(
  inherit = TypeDefinition,
  "InterfaceTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    fields: Array<FieldDefinition>;
    .resolve_type?: ?fn;",
  public = list(
    .format = function(..., all_fields = FALSE) {
      fields <- self$fields
      if (!isTRUE(all_fields)) {
        show_fields <- lapply(fields, "[[", ".show_in_format") %>% unlist()
        fields <- fields[show_fields]
      }

      collapse(
        "interface ",
        self$name$.format(...),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...),
        " {\n",
          format_list(fields, .before = "  ", .after = "\n", ...),
        "}"
      )
    },
    initialize = function(
      loc = NULL,
      name,
      directives = NULL,
      fields,
      .resolve_type = function(obj, schema) {
        stop(".resolve_type not initialized for interface of type: ", format(self$name))
      }
    ) {
      self$loc <- loc
      self$name <- name
      self$directives <- directives
      typename_field <- FieldDefinition$new(
        name = Name$new(value = "__typename"),
        type = NamedType$new(name = Name$new(value = "String"))
      )
      typename_field$.allow_double_underscore <- TRUE
      typename_field$.show_in_format <- FALSE
      self$fields <- append(fields, typename_field)
      self$.resolve_type <- .resolve_type

      invisible(self)
    },
    .get_field = get_by_field
  )
)

UnionTypeDefinition <- R6_from_args(
  inherit = TypeDefinition,
  "UnionTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    types: Array<NamedType>;
    .resolve_type?: ?fn;",
  public = list(
    .format = function(...) {
      collapse(
        "union ",
        self$name$.format(...),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...),
        " = ",
        format_list(self$types, .collapse = " | ", ...)
      )
    },
    initialize = function(
      loc = NULL,
      description = NULL,
      name,
      directives = NULL,
      types,
      .resolve_type = function(obj, schema) {
        stop(".resolve_type not initialized for object of type: ", format(self$name))
      }
    ) {
      self$loc <- loc
      self$description <- description
      self$name <- name
      self$directives <- directives
      self$types <- types
      self$.resolve_type <- .resolve_type

      invisible(self)
    },
    .has_type = function(named_type) {
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

EnumTypeDefinition <- R6_from_args(
  inherit = TypeDefinition,
  "EnumTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    values: Array<EnumValueDefinition>;
    .resolve?: ?fn;",
  public = list(
    .format = function(...) {
      collapse(
          "enum ",
          self$name$.format(...),
          if (!is.null(self$directives))
            format_list(self$directives, .before = " ", ...),
          " {\n",
            format_list(self$values, .before = "  ", .after = "\n", ...),
          "}"
      )
    },
    initialize = function(
      loc = NULL,
      description = NULL,
      name,
      directives = NULL,
      values,
      .resolve = NULL
    ) {
      if (missing(.resolve)) .resolve <- self$.default_resolve

      self$loc <- loc
      self$description <- description
      self$name <- name
      self$directives <- directives
      self$values <- values
      self$.resolve <- .resolve

      invisible(self)
    },
    .default_resolve = function(x, schema) {
      if (is_nullish(x)) return(NULL)
      as.character(toupper(x))
    },
    .parse_ast = function(value_obj, schema) {

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

EnumValueDefinition <- R6_from_args(
  inherit = Node,
  "EnumValueDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;",
  public = list(
    .format = function(...) {
      collapse(
        self$name$.format(...),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...)
      )
    }
  )
)

InputObjectTypeDefinition <- R6_from_args(
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
        self$name$.format(...),
        if (!is.null(self$directives))
          format_list(self$directives, .before = " ", ...),
        " {\n",
          format_list(self$fields, .before = "  ", .after = "\n", ...),
        "}"
      )
    },
    .get_field = get_by_field
  )
)

TypeExtensionDefinition <- R6_from_args(
  inherit = TypeSystemDefinition,
  "TypeExtensionDefinition",
  " loc?: ?Location;
    definition: ObjectTypeDefinition;",
  public = list(
    .format = function(...) {
      collapse(
        "extend ",
        self$definition$.format(...)
      )
    }
  )
)


DirectiveDefinition <- R6_from_args(
  inherit = TypeSystemDefinition,
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
        "directive @", self$name$.format(...),
        if (!is.null(self$arguments))
          collapse(
            "(",
            format_list(self$arguments, .collapse = ", ", ...),
            ")"
          ),
        "\n  on ",
        format_list(self$locations, .collapse = "\n   | ", ...)
      )
    }
  )
)
