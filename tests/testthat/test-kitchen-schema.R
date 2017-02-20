# testthat::test_file(file.path("tests", "testthat", "test-kitchen-schema.R"))

context("kitchen schema")

expect_str <- function(a, txt) {
  testthat::expect_equal(
    capture.output(str(a)),
    strsplit(txt, "\n")[[1]]
  )
}


test_that("kitchen schema", {

test_obj("kitchen-schema") %>%
expect_str(
"<Document>
. definitions:
. 1 - <SchemaDefinition>
. . operationTypes:
. . 1 - <OperationTypeDefinition>
. . . operation: 'query'
. . . type: `QueryType`
. . 2 - <OperationTypeDefinition>
. . . operation: 'mutation'
. . . type: `MutationType`
. 2 - <ObjectTypeDefinition>
. . name: `Foo`
. . interfaces:
. . 1 - `Bar`
. . fields:
. . 1 - <FieldDefinition>
. . . name: `one`
. . . type: `Type`
. . 2 - <FieldDefinition>
. . . name: `two`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `InputType!`
. . . type: `Type`
. . 3 - <FieldDefinition>
. . . name: `three`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `InputType`
. . . 2 - <InputValueDefinition>
. . . . name: `other`
. . . . type: `String`
. . . type: `Int`
. . 4 - <FieldDefinition>
. . . name: `four`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `String`
. . . . defaultValue: <StringValue>
. . . . . value: 'string'
. . . type: `String`
. . 5 - <FieldDefinition>
. . . name: `five`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `[String]`
. . . . defaultValue: <ListValue>
. . . . . values:
. . . . . 1 - <StringValue>
. . . . . . value: 'string'
. . . . . 2 - <StringValue>
. . . . . . value: 'string'
. . . type: `String`
. . 6 - <FieldDefinition>
. . . name: `six`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `InputType`
. . . . defaultValue: <ObjectValue>
. . . . . fields:
. . . . . 1 - <ObjectField>
. . . . . . name: `key`
. . . . . . value: <StringValue>
. . . . . . . value: 'value'
. . . type: `Type`
. . 7 - <FieldDefinition>
. . . name: `seven`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `Int`
. . . . defaultValue: <NullValue>
. . . type: `Type`
. 3 - <ObjectTypeDefinition>
. . name: `AnnotatedObject`
. . directives:
. . 1 - <Directive>
. . . name: `onObject`
. . . arguments:
. . . 1 - <Argument>
. . . . name: `arg`
. . . . value: <StringValue>
. . . . . value: 'value'
. . fields:
. . 1 - <FieldDefinition>
. . . name: `annotatedField`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `arg`
. . . . type: `Type`
. . . . defaultValue: <StringValue>
. . . . . value: 'default'
. . . . directives:
. . . . 1 - <Directive>
. . . . . name: `onArg`
. . . type: `Type`
. . . directives:
. . . 1 - <Directive>
. . . . name: `onField`
. 4 - <InterfaceTypeDefinition>
. . name: `Bar`
. . fields:
. . 1 - <FieldDefinition>
. . . name: `one`
. . . type: `Type`
. . 2 - <FieldDefinition>
. . . name: `four`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `String`
. . . . defaultValue: <StringValue>
. . . . . value: 'string'
. . . type: `String`
. 5 - <InterfaceTypeDefinition>
. . name: `AnnotatedInterface`
. . directives:
. . 1 - <Directive>
. . . name: `onInterface`
. . fields:
. . 1 - <FieldDefinition>
. . . name: `annotatedField`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `arg`
. . . . type: `Type`
. . . . directives:
. . . . 1 - <Directive>
. . . . . name: `onArg`
. . . type: `Type`
. . . directives:
. . . 1 - <Directive>
. . . . name: `onField`
. 6 - <UnionTypeDefinition>
. . name: `Feed`
. . types:
. . 1 - `Story`
. . 2 - `Article`
. . 3 - `Advert`
. 7 - <UnionTypeDefinition>
. . name: `AnnotatedUnion`
. . directives:
. . 1 - <Directive>
. . . name: `onUnion`
. . types:
. . 1 - `A`
. . 2 - `B`
. 8 - <ScalarTypeDefinition>
. . name: `CustomScalar`
. . .serialize: fn
. . .parse_value: fn
. . .parse_literal: fn
. 9 - <ScalarTypeDefinition>
. . name: `AnnotatedScalar`
. . directives:
. . 1 - <Directive>
. . . name: `onScalar`
. . .serialize: fn
. . .parse_value: fn
. . .parse_literal: fn
. 10 - <EnumTypeDefinition>
. . name: `Site`
. . values:
. . 1 - <EnumValueDefinition>
. . . name: `DESKTOP`
. . 2 - <EnumValueDefinition>
. . . name: `MOBILE`
. 11 - <EnumTypeDefinition>
. . name: `AnnotatedEnum`
. . directives:
. . 1 - <Directive>
. . . name: `onEnum`
. . values:
. . 1 - <EnumValueDefinition>
. . . name: `ANNOTATED_VALUE`
. . . directives:
. . . 1 - <Directive>
. . . . name: `onEnumValue`
. . 2 - <EnumValueDefinition>
. . . name: `OTHER_VALUE`
. 12 - <InputObjectTypeDefinition>
. . name: `InputType`
. . fields:
. . 1 - <InputValueDefinition>
. . . name: `key`
. . . type: `String!`
. . 2 - <InputValueDefinition>
. . . name: `answer`
. . . type: `Int`
. . . defaultValue: <IntValue>
. . . . value: '42'
. 13 - <InputObjectTypeDefinition>
. . name: `AnnotatedInput`
. . directives:
. . 1 - <Directive>
. . . name: `onInputObjectType`
. . fields:
. . 1 - <InputValueDefinition>
. . . name: `annotatedField`
. . . type: `Type`
. . . directives:
. . . 1 - <Directive>
. . . . name: `onField`
. 14 - <TypeExtensionDefinition>
. . definition: <ObjectTypeDefinition>
. . . name: `Foo`
. . . fields:
. . . 1 - <FieldDefinition>
. . . . name: `seven`
. . . . arguments:
. . . . 1 - <InputValueDefinition>
. . . . . name: `argument`
. . . . . type: `[String]`
. . . . type: `Type`
. 15 - <DirectiveDefinition>
. . name: `skip`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `if`
. . . type: `Boolean!`
. . locations:
. . 1 - `FIELD`
. . 2 - `FRAGMENT_SPREAD`
. . 3 - `INLINE_FRAGMENT`
. 16 - <DirectiveDefinition>
. . name: `include`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `if`
. . . type: `Boolean!`
. . locations:
. . 1 - `FIELD`
. . 2 - `FRAGMENT_SPREAD`
. . 3 - `INLINE_FRAGMENT`"
)
})
