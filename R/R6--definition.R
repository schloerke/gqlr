

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



























AST <- R6Class("AST",
  public = list(
  ),
  active = list(
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
    source?: ?Source;"
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

# GQLR_HasLocation <- R6Class("GQLR_HasLocation",
#   inherit = AST,
#   public = list(
#     "_loc" = NULL
#   ),
#   active = list(
#     loc = function(v) { self_value("_loc", "Location", self, v, m(v)) }
#   )
# )
Node <- R6Class("Node", inherit = AST)



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
    definitions: Array<Definition>;"
)


# export type Definition = OperationDefinition
#                        | FragmentDefinition
#                        | TypeDefinition
#                        | TypeExtensionDefinition
Definition <- R6Class("Definition", inherit = Node)

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
Selection = R6Class("Selection", inherit = Node)



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
#                   | EnumValue
#                   | ListValue
#                   | ObjectValue
Value <- R6Class("Value", inherit = Node,
  public = list(
    parse_literal = function(astObj) {
      if (astObj$kind == self$kind) {
        self$parse_value(astObj$value)
      } else {
        NULL
      }
    }
  )
)

Variable <- R6_from_args(
  inherit = Value,
  "Variable",
  " loc?: ?Location;
    name: Name; "
)
IntValue = R6_from_args(
  inherit = Value,
  "IntValue",
  " loc?: ?Location;
    value: string;"
)
FloatValue = R6_from_args(
  inherit = Value,
  "FloatValue",
  " loc?: ?Location;
    value: string;"
)
StringValue = R6_from_args(
  inherit = Value,
  "StringValue",
  " loc?: ?Location;
    value: string;"
)
BooleanValue = R6_from_args(
  inherit = Value,
  "BooleanValue",
  " loc?: ?Location;
    value: boolean;"
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
    fields: Array<ObjectField>;"
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
    name: Name;
    arguments?: ?Array<Argument>;"
)



# // Type Reference

# export type Type = NamedType
#                  | ListType
#                  | NonNullType
Type = R6Class("Type",inherit = Node)


NamedType = R6_from_args(
  inherit = Type,
  "NamedType",
  " loc?: ?Location;
    name: Name;"
)

ListType = R6_from_args(
  inherit = Type,
  "ListType",
  " loc?: ?Location;
    type: Type;"
)

NonNullType = R6_from_args(
  inherit = Type,
  "NonNullType",
  " loc?: ?Location;
    type: NamedType | ListType;"
)


# // Type Definition

# export type TypeDefinition = ObjectTypeDefinition
#                            | InterfaceTypeDefinition
#                            | UnionTypeDefinition
#                            | ScalarTypeDefinition
#                            | EnumTypeDefinition
#                            | InputObjectTypeDefinition
TypeDefinition = R6Class("TypeDefinition", inherit = Definition)

ObjectTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "ObjectTypeDefinition",
  " loc?: ?Location;
    name: Name;
    interfaces?: ?Array<NamedType>;
    fields: Array<FieldDefinition>;"
)

FieldDefinition = R6_from_args(
  inherit = TypeDefinition,
  "FieldDefinition",
  " loc?: ?Location;
    name: Name;
    arguments: Array<InputValueDefinition>;
    type: Type;"
)

InputValueDefinition = R6_from_args(
  inherit = Node,
  "InputValueDefinition",
  " loc?: ?Location;
    name: Name;
    type: Type;
    defaultValue?: ?Value;"
)

InputObjectTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "InputObjectTypeDefinition",
  " loc?: ?Location;
    name: Name;
    fields: Array<InputValueDefinition>;"
)

InterfaceTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "InterfaceTypeDefinition",
  " loc?: ?Location;
    name: Name;
    fields: Array<FieldDefinition>;"
)

UnionTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "UnionTypeDefinition",
  " loc?: ?Location;
    name: Name;
    types: Array<NamedType>;"
)

ScalarTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "ScalarTypeDefinition",
  " loc?: ?Location;
    name: Name;"
)

EnumTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "EnumTypeDefinition",
  " loc?: ?Location;
    name: Name;
    values: Array<EnumValueDefinition>;"
)

EnumValueDefinition = R6_from_args(
  inherit = Node,
  "EnumValueDefinition",
  " loc?: ?Location;
    name: Name;"
)

TypeExtensionDefinition = R6_from_args(
  inherit = Definition,
  "TypeExtensionDefinition",
  " loc?: ?Location;
    definition: ObjectTypeDefinition;"
)
