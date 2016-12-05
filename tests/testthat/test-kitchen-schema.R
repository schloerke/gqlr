# testthat::test_file(file.path("tests", "testthat", "test-kitchen-schema.R"))

context("kitchen schema")

expect_str <- function(a, txt) {
  testthat::expect_equal(
    paste(capture.output(str(a)), collapse = "\n"),
    txt
  )
}

test_that("schema obj", {

"
schema {
  query: QueryType
  mutation: MutationType
}
"
a <- SchemaDefinition$new(
  operationTypes = list(
    OperationTypeDefinition$new(
      operation = "query",
      type = NamedType$new(name = Name$new(value = "QueryType"))
    ),
    OperationTypeDefinition$new(
      operation = "mutation",
      type = NamedType$new(name = Name$new(value = "MutationType"))
    )
  ),
  directives = NULL
)

expect_str(a,
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

"
type Foo implements Bar {
  one: Type
  two(argument: InputType!): Type
  three(argument: InputType, other: String): Int
  four(argument: String = \"string\"): String
  five(argument: [String] = [\"string\", \"string\"]): String
  six(argument: InputType = {key: \"value\"}): Type
  seven(argument: Int = null): Type
}
"
a <- ObjectTypeDefinition$new(
  name = Name$new(value = "Foo"),
  interfaces = list(
    NamedType$new(name = Name$new(value = "Bar"))
  ),
  fields = list(
    FieldDefinition$new(
      # one: Type
      name = Name$new(value = "one"),
      type = NamedType$new(name = Name$new(value = "Type")),
      arguments = NULL
    ),
    FieldDefinition$new(
      # two(argument: InputType!): Type
      name = Name$new(value = "two"),
      type = NamedType$new(name = Name$new(value = "Type")),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = NonNullType$new(type = NamedType$new(name = Name$new(value = "InputType")))
        )
      )
    ),
    FieldDefinition$new(
      # three(argument: InputType, other: String): Int
      name = Name$new(value = "three"),
      type = NamedType$new(name = Name$new(value = "Int")),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = NonNullType$new(type = NamedType$new(name = Name$new(value = "InputType")))
        ),
        InputValueDefinition$new(
          name = Name$new(value = "other"),
          type = NamedType$new(name = Name$new(value = "String"))
        )
      )
    ),
    FieldDefinition$new(
      # four(argument: String = \"string\"): String
      name = Name$new(value = "four"),
      type = NamedType$new(name = Name$new(value = "String")),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = NamedType$new(name = Name$new(value = "String")),
          defaultValue = StringValue$new(value = "string")
        )
      )
    ),
    FieldDefinition$new(
      # five(argument: [String] = [\"string\", \"string\"]): String
      name = Name$new(value = "five"),
      type = NamedType$new(name = Name$new(value = "String")),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = ListType$new(type = NamedType$new(name = Name$new(value = "String"))),
          defaultValue = ListValue$new(
            values = list(
              StringValue$new(value = "string"),
              StringValue$new(value = "string")
            )
          )
        )
      )
    ),
    FieldDefinition$new(
      # six(argument: InputType = {key: \"value\"}): Type
      name = Name$new(value = "six"),
      type = NamedType$new(name = Name$new(value = "Type")),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = NamedType$new(name = Name$new(value = "InputType")),
          defaultValue = ObjectValue$new(
            fields = list(
              ObjectField$new(
                name = Name$new(value = "key"),
                value = StringValue$new(value = "value")
              )
            )
          )
        )
      )
    ),
    FieldDefinition$new(
      # seven(argument: Int = null): Type
      name = Name$new(value = "seven"),
      type = NamedType$new(name = Name$new(value = "Type")),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = NamedType$new(name = Name$new(value = "Int")),
          defaultValue = NULL
        )
      )
    )
  )
)


expect_str(a,
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



test_that("anootate", {

"
type AnnotatedObject @onObject(arg: \"value\") {
  annotatedField(arg: Type = \"default\" @onArg): Type @onField
}
"
a <- ObjectTypeDefinition$new(
  name = Name$new(value = "AnnotatedObject"),
  directives = list(
    Directive$new(
      name = Name$new(value = "onObject"),
      arguments = list(
        name = Name$new(value = "arg"),
        value = StringValue(value = "value")
      )
    )
  ),
  fields = list(
    FieldDefinition$new(
      name = Name$new(value = "annotatedField"),
      type = NamedType$new(name = Name$new(value = "Type")),
      directives = list(
        Directive$new(name = Name$new(value = "onField"))
      ),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "arg"),
          type = NamedType$new(name = Name$new(value = "Type")),
          defaultValue = StringValue$new("default"),
          directives = list(
            Directive$new(
              name = Name$new(value = "onArg")
            )
          )
        )
      )
    )
  )
)

expect_str(a,
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

"
interface Bar {
  one: Type
  four(argument: String = \"string\"): String
}
"
a <- InterfaceTypeDefinition$new(
  name = Name$new(value = "Bar"),
  fields = list(
    FieldDefinition$new(
      name = Name$new(value = "one"),
      type = NamedType$new(name = Name$new(value = "Type"))
    ),
    FieldDefinition$new(
      name = Name$new(value = "four"),
      type = NamedType$new(name = Name$new(value = "String")),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = NamedType$new(name = Name$new(value = "String")),
          defaultValue = StringValue$new(value = "string")
        )
      )
    )
  )
)

expect_str(a,
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
. . type: `String`"
)

})



test_that("annotated interface", {

"
interface AnnotatedInterface @onInterface {
  annotatedField(arg: Type @onArg): Type @onField
}
"
a <- InterfaceTypeDefinition$new(
  name = Name$new(value = "AnnotatedInterface"),
  directives = list(
    Directive$new(
      name = Name$new(value = "onInterface")
    )
  ),
  fields = list(
    FieldDefinition$new(
      name = Name$new(value = "annotatedField"),
      type = NamedType$new(name = Name$new(value = "Type")),
      directives = list(
        Directive$new(
          name = Name$new(value = "onField")
        )
      ),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "arg"),
          type = NamedType$new(name = Name$new(value = "Type")),
          directives = list(
            Directive$new(
              name = Name$new(value = "onArg")
            )
          )
        )
      )
    )
  )
)

expect_str(a,
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

"
union Feed = Story | Article | Advert
"
a <- UnionTypeDefinition$new(
  name = Name$new(value = "Feed"),
  types = list(
    NamedType$new(name = Name$new(value = "Story")),
    NamedType$new(name = Name$new(value = "Article")),
    NamedType$new(name = Name$new(value = "Advert"))
  )
)


expect_str(a,
"<UnionTypeDefinition>
. name: `Feed`
. types:
. 1 - `Story`
. 2 - `Article`
. 3 - `Advert`")

})



test_that("annotated union", {

"
union AnnotatedUnion @onUnion = A | B
"
a <- UnionTypeDefinition$new(
  name = Name$new(value = "AnnotatedUnion"),
  directives = list(
    Directive$new(name = Name$new(value = "onUnion"))
  ),
  types = list(
    NamedType$new(name = Name$new(value = "A")),
    NamedType$new(name = Name$new(value = "B"))
  )
)

expect_str(a,
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

"
scalar CustomScalar
"
a <- ScalarTypeDefinition$new(
  name = Name$new(value = "CustomScalar"),
  parse_value = function(...) NULL,
  parse_literal = function(...) NULL,
  serialize = function(...) NULL
)

expect_str(a,
"<ScalarTypeDefinition>
. name: `CustomScalar`
. serialize: fn
. parse_value: fn
. parse_literal: fn")

})


test_that("annotated scalar", {

"
scalar AnnotatedScalar @onScalar
"
a <- ScalarTypeDefinition$new(
  name = Name$new(value = "AnnotatedScalar"),
  directives = list(
    Directive$new(
      name = Name$new(value = "onScalar")
    )
  ),
  parse_value = function(...) NULL,
  parse_literal = function(...) NULL,
  serialize = function(...) NULL
)

expect_str(a,
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

"
enum Site {
  DESKTOP
  MOBILE
}
"
a <- EnumTypeDefinition$new(
  name = Name$new(value = "Site"),
  values = list(
    EnumValueDefinition$new(name = Name$new(value = "DESKTOP")),
    EnumValueDefinition$new(name = Name$new(value = "MOBILE"))
  )
)

expect_str(a,
"<EnumTypeDefinition>
. name: `Site`
. values:
. 1 - <EnumValueDefinition>
. . name: `DESKTOP`
. 2 - <EnumValueDefinition>
. . name: `MOBILE`")

})



test_that("annotated enum", {

"
enum AnnotatedEnum @onEnum {
  ANNOTATED_VALUE @onEnumValue
  OTHER_VALUE
}
"
a <- EnumTypeDefinition$new(
  name = Name$new(value = "AnnotatedEnum"),
  directives = list(
    Directive$new(name = Name$new(value = "onEnum"))
  ),
  values = list(
    EnumValueDefinition$new(
      name = Name$new(value = "ANNOTATED_VALUE"),
      directives = list(
        Directive$new(name = Name$new(value = "onEnumValue"))
      )
    ),
    EnumValueDefinition$new(name = Name$new(value = "OTHER_VALUE"))
  )
)

expect_str(a,
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

"
input InputType {
  key: String!
  answer: Int = 42
}
"
a <- InputObjectTypeDefinition$new(
  name = Name$new(value = "InputType"),
  fields = list(
    InputValueDefinition$new(
      name = Name$new(value = "key"),
      type = NonNullType$new(type = NamedType$new(name = Name$new(value = "String")))
    ),
    InputValueDefinition$new(
      name = Name$new(value = "answer"),
      type = NamedType$new(name = Name$new(value = "Int")),
      defaultValue = IntValue$new(value = 42)
    )
  )
)

expect_str(a,
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

"
input AnnotatedInput @onInputObjectType {
  annotatedField: Type @onField
}
"
a <- InputObjectTypeDefinition$new(
  name = Name$new(value = "AnnotatedInput"),
  directives = list(
    Directive$new(name = Name$new(value = "onInputObjectType"))
  ),
  fields = list(
    InputValueDefinition$new(
      name = Name$new(value = "annotatedField"),
      type = NamedType$new(name = Name$new(value = "Type")),
      directives = list(
        Directive$new(name = Name$new(value = "onField"))
      )
    )
  )
)

expect_str(a,
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

"
extend type Foo {
  seven(argument: [String]): Type
}
"
a <- TypeExtensionDefinition$new(
  definition = ObjectTypeDefinition$new(
    name = Name$new(value = "Foo"),
    interfaces = list(
      NameType$new(name = Name$new(value = "Foo"))
    ),
    fields = list(
      FieldDefinition$new(
        name = Name$new(value = "seven"),
        type = NamedType$new(name = Name$new(value = "Type")),
        arguments = list(
          InputValueDefinition$new(
            name = Name$new(value = "argument"),
            type = ListType$new(type = NamedType$new(name = Name$new(value = "String")))
          )
        )
      )
    )
  )
)

expect_str(a,
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

"
extend type Foo @onType {}
"
a <- TypeExtensionDefinition$new(
  definition = ObjectTypeDefinition$new(
    name = Name$new(value = "Foo"),
    interfaces = list(
      NameType$new(name = Name$new(value = "Foo"))
    ),
    directives = list(
      Directive$new(name = Name$new(value = "onType"))
    ),
    fields = NULL
  )
)

expect_str(a,
"<TypeExtensionDefinition>
. definition: <ObjectTypeDefinition>
. . name: `Foo`
. . directives:
. . 1 - <Directive>
. . . name: `onType`")

})


test_that("no fields type", {

"
type NoFields {}
"
a <- ObjectTypeDefinition$new(
  name = Name$new(value = "NoFields"),
  fields = NULL
)

expect_str(a,
"<ObjectTypeDefinition>
. name: `NoFields`")

})


test_that("directive", {

"
directive @skip(if: Boolean!) on FIELD | FRAGMENT_SPREAD | INLINE_FRAGMENT
"
a <- DirectiveDefinition$new(
  name = Name$new(value = "skip"),
  arguments = list(
    InputValueDefinition$new(
      name = Name$new(value = "if"),
      type = NonNullType(type = NamedType$new(name = Name$new(value = "Boolean")))
    )
  ),
  locations = list(
    Name$new(value = "FIELD"),
    Name$new(value = "FRAGMENT_SPREAD"),
    Name$new(value = "INLINE_FRAGMENT")
  ),
  .resolve = function(...) TRUE
)


expect_str(a,
"<DirectiveDefinition>
. name: `skip`
. locations:
. 1 - `FIELD`
. 2 - `FRAGMENT_SPREAD`
. 3 - `INLINE_FRAGMENT`
. .resolve: fn")

})


test_that("directive", {

"
directive @include(if: Boolean!)
  on FIELD
   | FRAGMENT_SPREAD
   | INLINE_FRAGMENT
"
a <- DirectiveDefinition$new(
  name = Name$new(value = "include"),
  arguments = list(
    InputValueDefinition$new(
      name = Name$new(value = "if"),
      type = NonNullType$new(type = NamedType$new(name = Name$new(value = "Boolean")))
    )
  ),
  locations = list(
    Name$new(value = "FIELD"),
    Name$new(value = "FRAGMENT_SPREAD"),
    Name$new(value = "INLINE_FRAGMENT")
  ),
  .resolve = function(...) TRUE
)

expect_str(a,
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
