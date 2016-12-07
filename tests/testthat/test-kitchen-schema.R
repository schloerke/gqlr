# testthat::test_file(file.path("tests", "testthat", "test-kitchen-schema.R"))

context("kitchen schema")



source("source_helper.R")

expect_str <- function(a, txt) {
  testthat::expect_equal(
    paste(capture.output(str(a)), collapse = "\n"),
    txt
  )
}

test_that("schema obj", {

source_kitchen_schema("Schema") %>%
expect_str(
"<SchemaDefinition>
. operationTypes:
. 1 - <OperationTypeDefinition>
. . operation: 'query'
. . type: `QueryType`
. 2 - <OperationTypeDefinition>
. . operation: 'mutation'
. . type: `MutationType`")

})




test_that("object", {

source_kitchen_schema("Foo") %>%
expect_str(
"<ObjectTypeDefinition>
. name: `Foo`
. interfaces:
. 1 - `Bar`
. fields:
. 1 - <FieldDefinition>
. . name: `one`
. . type: `Type`
. 2 - <FieldDefinition>
. . name: `two`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `argument`
. . . type: `InputType!`
. . type: `Type`
. 3 - <FieldDefinition>
. . name: `three`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `argument`
. . . type: `InputType!`
. . 2 - <InputValueDefinition>
. . . name: `other`
. . . type: `String`
. . type: `Int`
. 4 - <FieldDefinition>
. . name: `four`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `argument`
. . . type: `String`
. . . defaultValue: <StringValue>
. . . . value: 'string'
. . type: `String`
. 5 - <FieldDefinition>
. . name: `five`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `argument`
. . . type: `[String]`
. . . defaultValue: <ListValue>
. . . . values:
. . . . 1 - <StringValue>
. . . . . value: 'string'
. . . . 2 - <StringValue>
. . . . . value: 'string'
. . type: `String`
. 6 - <FieldDefinition>
. . name: `six`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `argument`
. . . type: `InputType`
. . . defaultValue: <ObjectValue>
. . . . fields:
. . . . 1 - <ObjectField>
. . . . . name: `key`
. . . . . value: <StringValue>
. . . . . . value: 'value'
. . type: `Type`
. 7 - <FieldDefinition>
. . name: `seven`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `argument`
. . . type: `Int`
. . type: `Type`")

})



test_that("annotate", {

source_kitchen_schema("AnnotatedObject") %>%
expect_str(
"<ObjectTypeDefinition>
. name: `AnnotatedObject`
. directives:
. 1 - <Directive>
. . name: `onObject`
. fields:
. 1 - <FieldDefinition>
. . name: `annotatedField`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `arg`
. . . type: `Type`
. . . directives:
. . . 1 - <Directive>
. . . . name: `onArg`
. . type: `Type`
. . directives:
. . 1 - <Directive>
. . . name: `onField`")

})



test_that("interface", {

source_kitchen_schema("Bar") %>%
expect_str(
"<InterfaceTypeDefinition>
. name: `Bar`
. fields:
. 1 - <FieldDefinition>
. . name: `one`
. . type: `Type`
. 2 - <FieldDefinition>
. . name: `four`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `argument`
. . . type: `String`
. . . defaultValue: <StringValue>
. . . . value: 'string'
. . type: `String`")

})



test_that("annotated interface", {

source_kitchen_schema("AnnotatedInterface") %>%
expect_str(
"<InterfaceTypeDefinition>
. name: `AnnotatedInterface`
. directives:
. 1 - <Directive>
. . name: `onInterface`
. fields:
. 1 - <FieldDefinition>
. . name: `annotatedField`
. . arguments:
. . 1 - <InputValueDefinition>
. . . name: `arg`
. . . type: `Type`
. . . directives:
. . . 1 - <Directive>
. . . . name: `onArg`
. . type: `Type`
. . directives:
. . 1 - <Directive>
. . . name: `onField`")

})



test_that("union", {

source_kitchen_schema("Feed") %>%
expect_str(
"<UnionTypeDefinition>
. name: `Feed`
. types:
. 1 - `Story`
. 2 - `Article`
. 3 - `Advert`")

})



test_that("annotated union", {

source_kitchen_schema("AnnotatedUnion") %>%
expect_str(
"<UnionTypeDefinition>
. name: `AnnotatedUnion`
. directives:
. 1 - <Directive>
. . name: `onUnion`
. types:
. 1 - `A`
. 2 - `B`")

})


test_that("custom scalar", {

source_kitchen_schema("CustomScalar") %>%
expect_str(
"<ScalarTypeDefinition>
. name: `CustomScalar`
. serialize: fn
. parse_value: fn
. parse_literal: fn")

})


test_that("annotated scalar", {

source_kitchen_schema("AnnotatedScalar") %>%
expect_str(
"<ScalarTypeDefinition>
. name: `AnnotatedScalar`
. directives:
. 1 - <Directive>
. . name: `onScalar`
. serialize: fn
. parse_value: fn
. parse_literal: fn")

})



test_that("enum", {

source_kitchen_schema("Site") %>%
expect_str(
"<EnumTypeDefinition>
. name: `Site`
. values:
. 1 - <EnumValueDefinition>
. . name: `DESKTOP`
. 2 - <EnumValueDefinition>
. . name: `MOBILE`")

})



test_that("annotated enum", {

source_kitchen_schema("AnnotatedEnum") %>%
expect_str(
"<EnumTypeDefinition>
. name: `AnnotatedEnum`
. directives:
. 1 - <Directive>
. . name: `onEnum`
. values:
. 1 - <EnumValueDefinition>
. . name: `ANNOTATED_VALUE`
. . directives:
. . 1 - <Directive>
. . . name: `onEnumValue`
. 2 - <EnumValueDefinition>
. . name: `OTHER_VALUE`")

})


test_that("input type", {

source_kitchen_schema("InputType") %>%
expect_str(
"<InputObjectTypeDefinition>
. name: `InputType`
. fields:
. 1 - <InputValueDefinition>
. . name: `key`
. . type: `String!`
. 2 - <InputValueDefinition>
. . name: `answer`
. . type: `Int`
. . defaultValue: <IntValue>
. . . value: '42'")

})


test_that("annotated input", {

source_kitchen_schema("AnnotatedInputType") %>%
expect_str(
"<InputObjectTypeDefinition>
. name: `AnnotatedInput`
. directives:
. 1 - <Directive>
. . name: `onInputObjectType`
. fields:
. 1 - <InputValueDefinition>
. . name: `annotatedField`
. . type: `Type`
. . directives:
. . 1 - <Directive>
. . . name: `onField`")

})


test_that("extended type", {

source_kitchen_schema("ExtendedFoo") %>%
expect_str(
"<TypeExtensionDefinition>
. definition: <ObjectTypeDefinition>
. . name: `Foo`
. . fields:
. . 1 - <FieldDefinition>
. . . name: `seven`
. . . arguments:
. . . 1 - <InputValueDefinition>
. . . . name: `argument`
. . . . type: `[String]`
. . . type: `Type`")

})


test_that("extend type directive", {

source_kitchen_schema("DirectiveExtendedFoo") %>%
expect_str(
"<TypeExtensionDefinition>
. definition: <ObjectTypeDefinition>
. . name: `Foo`
. . directives:
. . 1 - <Directive>
. . . name: `onType`")

})


test_that("no fields type", {

source_kitchen_schema("NoFields") %>%
expect_str(
"<ObjectTypeDefinition>
. name: `NoFields`")

})


test_that("directive", {

source_kitchen_schema("DirectiveSkip") %>%
expect_str(
"<DirectiveDefinition>
. name: `skip`
. locations:
. 1 - `FIELD`
. 2 - `FRAGMENT_SPREAD`
. 3 - `INLINE_FRAGMENT`
. .resolve: fn")

})


test_that("directive", {

source_kitchen_schema("DirectiveInclude") %>%
expect_str(
"<DirectiveDefinition>
. name: `include`
. arguments:
. 1 - <InputValueDefinition>
. . name: `if`
. . type: `Boolean!`
. locations:
. 1 - `FIELD`
. 2 - `FRAGMENT_SPREAD`
. 3 - `INLINE_FRAGMENT`
. .resolve: fn")

})
