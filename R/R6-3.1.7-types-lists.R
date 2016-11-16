# 3.1.7
# http://facebook.github.io/graphql/#sec-Lists
#
# Lists
#
# A GraphQL list is a special collection type which declares the type of each item in the List (referred to as the item type of the list). List values are serialized as ordered lists, where each item in the list is serialized as per the item type. To denote that a field uses a List type the item type is wrapped in square brackets like this: pets: [Pet].
#
# Result Coercion
#
# GraphQL servers must return an ordered list as the result of a list type. Each item in the list must be the result of a result coercion of the item type. If a reasonable coercion is not possible they must raise a field error. In particular, if a non‐list is returned, the coercion should fail, as this indicates a mismatch in expectations between the type system and the implementation.
#
# Input Coercion
#
# When expected as an input, list values are accepted only when each item in the list can be accepted by the list’s item type.
#
# If the value passed as an input to a list type is not as list, it should be coerced as though the input was a list of size one, where the value passed is the only item in the list. This is to allow inputs that accept a “var args” to declare their input type as a list; if only one argument is passed (a common case), the client can just pass that value rather than constructing the list.
