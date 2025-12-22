# GraphQL Schema object

Manages a GraphQL schema definition. A Schema can add more GraphQL type
definitions, assist in determining definition types, retrieve particular
definitions, and can combine with other schema definitions.

Typically, Schema class objects are created using
[`gqlr_schema()`](http://schloerke.com/gqlr/reference/gqlr_schema.md).
Creating a `Schema$new()` object should be reserved for when multiple
Schema objects are combined.

## Usage


    ## using star_wars_schema from
    # example(gqlr_schema)
    star_wars_schema$get_schema()
    star_wars_schema$is_enum("Episode") # TRUE
    star_wars_schema$is_object("Episode") # FALSE
    execute_request("{ hero { name } }", star_wars_schema)

## Initialize

- schema:

  Either a character GraphQL definition of a schema or another Schema
  object. Extending methods and descriptions should be added with
  `gqlr_schema`

The initialize function will automatically add

- Scalars: Int, Float, String, Boolean

- Directives: @skip and @include

- Introspection Capabilities

## Details

`$add(obj)`: function to add either another Schema's definitions or
Document of definitions. `obj` must inherit class of either `'Schema'`
or `'Document'`

`$is_scalar(name)`, `$is_enum(name)`, `$is_object(name)`,
`$is_interface(name)`, `$is_union(name)`, `$is_input_object(name)`,
`$is_directive(name)`, `$is_value(name)`: methods to determine if there
is a definition of the corresponding definition type for the provided
name.

`$get_scalar(name)`, `$get_enum(name)`, `$get_object(name)`,
`$get_interface(name)`, `$get_union(name)`, `$get_input_object(name)`,
`$get_directive(name)`, `$get_value(name)`: methods to retrieve a
definition of the corresponding definition type for the provided name.
If the object can't be found, `NULL` is returned. When printed, it
quickly conveys all known information of the definition. Due to the
nature of R6 objects, definitions may be retrieved and altered after
retrieval. This is helpful for adding descriptions or resolve after the
initialization.

`$get_scalars(name)`, `$get_enums(name)`, `$get_objects(name)`,
`$get_interfaces(name)`, `$get_unions(name)`,
`$get_input_objects(name)`, `$get_directives(name)`,
`$get_values(name)`: methods to retrieve all definitions of the
corresponding definition type.

`$get_type(name)`: method to retrieve an object of unknown type. If the
object can't be found, `NULL` is returned. When printed, it quickly
conveys all known information of the definition.

`$get_type(name)`: method to retrieve an object of unknown type. If the
object can't be found, `NULL` is returned.

`$get_schema()`: method to retrieve full definition of schema. When
printed, it quickly conveys all types in the schema.

`$get_query_object()`, `$get_mutation_object()`: helper method to
retrieve the schema definition query or mutation object.

`$implements_interface()`: helper method to retrieve all objects who
implement a particular interface.

`$is_valid`: boolean that determines if a Schema object has been
validated. All Schema objects are validated at the time of request
execution. The Schema will remain valid until new definitions are added.

## See also

[`gqlr_schema()`](http://schloerke.com/gqlr/reference/gqlr_schema.md)
