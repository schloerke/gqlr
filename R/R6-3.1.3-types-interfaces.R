# 3.1.3
# http://facebook.github.io/graphql/#sec-Interfaces
#
#Interfaces
#
#GraphQL Interfaces represent a list of named fields and their arguments. GraphQL object can then implement an interface, which guarantees that they will contain the specified fields.
#
# Fields on a GraphQL interface have the same rules as fields on a GraphQL object; their type can be Scalar, Object, Enum, Interface, or Union, or any wrapping type whose base type is one of those five.
#
# Result Coercion
#
# The interface type should have some way of determining which object a given result corresponds to. Once it has done so, the result coercion of the interface is the same as the result coercion of the object.
#
# Input Coercion
#
# Interfaces are never valid inputs.


GraphQLFieldDefinition <- R6_from_args(
  "GQL_Field_Definition",
  " name: string;
    description?: ?string;
    type: GraphQLOutputType;
    args: Array<GraphQLArgument>;
    resolve?: ?GraphQLFieldResolveFn;
    deprecationReason?: ?string;"
)
GraphQLInterfaceType <- R6_from_args(
  "GQL_Interface_Type",
  " name: string;
    description?: ?string;
    resolve_type: fn;
    implementations?: ?Array<string>;
    fields?: ?Dict<GraphQLFieldDefinition>;",
  public = list(

  )
)
