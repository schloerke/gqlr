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





AST <- R6Class("AST",
  public = list(
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
    .str = function(maxLevel = -1, ...) {
      if (maxLevel == 0) {
        return()
      }

      cat("<", self$.kind, "> (", self$start, ", ", self$end, ")", sep = "")
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
    selectionSet: SelectionSet;"
)


VariableDefinition <- R6_from_args(
  inherit = Node,
  "VariableDefinition",
  " loc?: ?Location;
    variable: Variable;
    type: Type;
    defaultValue?: ?Value;"
)

SelectionSet <- R6_from_args(
  inherit = Node,
  "SelectionSet",
  " loc?: ?Location;
    selections: Array<Selection>;"
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
    selectionSet?: ?SelectionSet;"
)


Argument = R6_from_args(
  inherit = Node,
  "Argument",
  " loc?: ?Location;
    name: Name;
    value: Value;"
)


FragmentSpread = R6_from_args(
  inherit = Selection,
  "FragmentSpread",
  " loc?: ?Location;
    name: Name;
    directives?: ?Array<Directive>;"
)


InlineFragment = R6_from_args(
  inherit = Selection,
  "InlineFragment",
  " loc?: ?Location;
    typeCondition?: ?NamedType;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;"
)



FragmentDefinition = R6_from_args(
  inherit = Definition,
  "FragmentDefinition",
  " loc?: ?Location;
    name: Name;
    typeCondition: NamedType;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;"
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
    name: Name; "
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
  " loc?: ?Location;"
)
EnumValue = R6_from_args(
  inherit = Value,
  "EnumValue",
  " loc?: ?Location;
    value: string;"
)
ListValue = R6_from_args(
  inherit = Value,
  "ListValue",
  " loc?: ?Location;
    values: Array<Value>;"
)
ObjectValue = R6_from_args(
  inherit = Value,
  "ObjectValue",
  " loc?: ?Location;
    fields: Array<ObjectField>;",
  private = list(
    # init_validate = function() {
    #   validate_input_object_field_uniqueness(self)
    # }
  )
)
ObjectField = R6_from_args(
  inherit = Node,
  "ObjectField",
  " loc?: ?Location;
    name: Name;
    value: Value;
  "
)



# // Directives

Directive = R6_from_args(
  inherit = Node,
  "Directive",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    arguments?: ?Array<Argument>;"
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
    description?: ?string;"
)

ListType = R6_from_args(
  inherit = Type,
  "ListType",
  " loc?: ?Location;
    type: Type;
    description?: ?string;"
)

NonNullType = R6_from_args(
  inherit = Type,
  "NonNullType",
  " loc?: ?Location;
    type: NamedType | ListType;
    description?: ?string;"
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
    operationTypes: Array<OperationTypeDefinition>;"
)

OperationTypeDefinition = R6_from_args(
  inherit = Node,
  "OperationTypeDefinition",
  " loc?: ?Location;
    operation: 'query' | 'mutation' | 'subscription';
    type: NamedType;"
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
    .resolve?: ?fn;"
)

InputValueDefinition = R6_from_args(
  inherit = Node,
  "InputValueDefinition",
  " loc?: ?Location;
    name: Name;
    type: Type;
    defaultValue?: ?Value;
    directives?: ?Array<Directive>;"
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
    types: Array<NamedType>;"
)

EnumTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "EnumTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    values: Array<EnumValueDefinition>;"
)

EnumValueDefinition = R6_from_args(
  inherit = Node,
  "EnumValueDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;"
)

InputObjectTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "InputObjectTypeDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    directives?: ?Array<Directive>;
    fields: Array<InputValueDefinition>;"
)

TypeExtensionDefinition = R6_from_args(
  inherit = Definition,
  "TypeExtensionDefinition",
  " loc?: ?Location;
    definition: ObjectTypeDefinition;"
)


DirectiveDefinition = R6_from_args(
  inherit = Definition,
  "DirectiveDefinition",
  " loc?: ?Location;
    description?: ?string;
    name: Name;
    arguments?: ?Array<InputValueDefinition>;
    locations: Array<Name>;
    .resolve?: ?fn;"
)
