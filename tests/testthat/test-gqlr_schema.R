
# load_all(); testthat::test_file(file.path("tests", "testthat", "test-gqlr_schema.R")); # nolint


context("gqlr_schema()")


test_that("gqlr_schema information", {

  resolve_my_scalar <- function(a, b) {
    "scalar"
  }
  resolve_my_object <- function(a, b) {
    "object"
  }
  resolve_my_other_object <- function(a, b) {
    "other_object"
  }
  resolve_my_enum <- function(a, b) {
    "enum"
  }
  resolve_my_interface <- function(a, b) {
    "interface"
  }
  resolve_my_union <- function(a, b) {
    "union"
  }
  resolve_my_directive <- function(a, b) {
    "directive"
  }

  "
  scalar MyScalar

  type MyObject {
    fieldA: Int
    fieldB: String
  }

  type MyOtherObject {
    fieldC: Boolean
  }

  enum MyEnum  {
    ValA
    ValB
  }

  interface MyInterface {
    fieldA: Int
  }

  union MyUnion = MyObject | MyOtherObject

  input MyInput {
    key: String!
    answer: Int = 42
  }

  directive @MyDirective(if: Boolean!) on FIELD | FRAGMENT_SPREAD | INLINE_FRAGMENT
  " %>%
    Schema$new() ->
  MySchema

  schema <- gqlr_schema(
    MySchema,
    MyScalar = resolve_my_scalar,
    MyObject = resolve_my_object,
    MyOtherObject = resolve_my_other_object,
    MyEnum = resolve_my_enum,
    MyInterface = resolve_my_interface,
    MyUnion = resolve_my_union,
    MyInput = list(),
    MyDirective = resolve_my_directive
  )

  expect_equal(schema$get_scalar("MyScalar")$.resolve, resolve_my_scalar)
  expect_equal(schema$get_object("MyObject")$.resolve, resolve_my_object)
  expect_equal(schema$get_object("MyOtherObject")$.resolve, resolve_my_other_object)
  expect_equal(schema$get_enum("MyEnum")$.resolve, resolve_my_enum)
  expect_equal(schema$get_interface("MyInterface")$.resolve_type, resolve_my_interface)
  expect_equal(schema$get_union("MyUnion")$.resolve_type, resolve_my_union)
  expect_equal(schema$get_directive("MyDirective")$.resolve, resolve_my_directive)


  expect_equal(schema$get_scalar("MyScalar")$description, NULL)
  expect_equal(schema$get_object("MyObject")$description, NULL)
  expect_equal(schema$get_object("MyOtherObject")$description, NULL)
  expect_equal(schema$get_enum("MyEnum")$description, NULL)
  expect_equal(schema$get_interface("MyInterface")$description, NULL)
  expect_equal(schema$get_union("MyUnion")$description, NULL)
  expect_equal(schema$get_input_object("MyInput")$description, NULL)
  expect_equal(schema$get_directive("MyDirective")$description, NULL)

  expect_equal(schema$get_object("MyObject")$fields[[1]]$description, NULL)
  expect_equal(schema$get_object("MyObject")$fields[[2]]$description, NULL)


  d <- list(
    MyScalar = "MyScalar desc",
    MyObject = "MyObject desc",
    MyOtherObject = "MyOtherObject desc",
    MyEnum = "MyEnum desc",
    MyInterface = "MyInterface desc",
    MyUnion = "MyUnion desc",
    MyInput = "MyInput desc",
    MyDirective = "MyDirective desc",
    fieldA = "fieldA desc",
    fieldB = "fieldB desc",
    fieldC = "fieldC desc",
    ValA = "ValA desc",
    ValB = "ValB desc"
  )

  parse_my_scalar <- function(a, b) {
    "parse"
    NULL
  }

  schema <- gqlr_schema(
    MySchema,
    MyScalar = list(
      resolve = resolve_my_scalar,
      description = d$MyScalar,
      parse_ast = parse_my_scalar
    ),
    MyObject = list(
      resolve = resolve_my_object,
      description = d$MyObject,
      fields = list(
        fieldA = d$fieldA,
        fieldB = d$fieldB
      )
    ),
    MyOtherObject = list(
      resolve = resolve_my_other_object,
      description = d$MyOtherObject,
      fields = list(
        fieldC = d$fieldC
      )
    ),
    MyEnum = list(
      resolve = resolve_my_enum,
      description = d$MyEnum,
      values = list(
        ValA = d$ValA,
        ValB = d$ValB
      )
    ),
    MyInterface = list(
      resolve_type = resolve_my_interface,
      description = d$MyInterface
    ),
    MyUnion = list(
      resolve_type = resolve_my_union,
      description = d$MyUnion
    ),
    MyInput = list(
      description = d$MyInput
    ),
    MyDirective = list(
      resolve = resolve_my_directive,
      description = d$MyDirective
    )
  )


  expect_equal(schema$get_scalar("MyScalar")$.resolve, resolve_my_scalar)
  expect_equal(schema$get_object("MyObject")$.resolve, resolve_my_object)
  expect_equal(schema$get_object("MyOtherObject")$.resolve, resolve_my_other_object)
  expect_equal(schema$get_enum("MyEnum")$.resolve, resolve_my_enum)
  expect_equal(schema$get_interface("MyInterface")$.resolve_type, resolve_my_interface)
  expect_equal(schema$get_union("MyUnion")$.resolve_type, resolve_my_union)
  expect_equal(schema$get_directive("MyDirective")$.resolve, resolve_my_directive)

  expect_equal(schema$get_scalar("MyScalar")$description, d$MyScalar)
  expect_equal(schema$get_object("MyObject")$description, d$MyObject)
  expect_equal(schema$get_object("MyOtherObject")$description, d$MyOtherObject)
  expect_equal(schema$get_enum("MyEnum")$description, d$MyEnum)
  expect_equal(schema$get_interface("MyInterface")$description, d$MyInterface)
  expect_equal(schema$get_union("MyUnion")$description, d$MyUnion)
  expect_equal(schema$get_input_object("MyInput")$description, d$MyInput)
  expect_equal(schema$get_directive("MyDirective")$description, d$MyDirective)

  expect_equal(schema$get_object("MyObject")$fields[[1]]$description, d$fieldA)
  expect_equal(schema$get_object("MyObject")$fields[[2]]$description, d$fieldB)





  expect_error({
      gqlr_schema(
        MySchema,
        5
      )
    },
    "must be uniquely named arguments"
  )

  expect_error({
      gqlr_schema(
        MySchema,
        DoesntExist = list(
          description = "No where"
        )
      )
    },
    "could not find schema definition"
  )

  expect_error({
      gqlr_schema(
        MySchema,
        MyScalar = 5
      )
    },
    "named arguments should either be a named list"
  )

  expect_error({
      gqlr_schema(
        MySchema,
        MyScalar = list(
          other_field = 5
        )
      )
    },
    "ScalarTypeDefinition"
  )
  expect_error({
      gqlr_schema(
        MySchema,
        MyObject = list(
          other_field = 5
        )
      )
    },
    "ObjectTypeDefinition"
  )
  expect_error({
      gqlr_schema(
        MySchema,
        MyEnum = list(
          other_field = 5
        )
      )
    },
    "EnumTypeDefinition"
  )
  expect_error({
      gqlr_schema(
        MySchema,
        MyInterface = list(
          other_field = 5
        )
      )
    },
    "InterfaceTypeDefinition"
  )
  expect_error({
      gqlr_schema(
        MySchema,
        MyUnion = list(
          other_field = 5
        )
      )
    },
    "UnionTypeDefinition"
  )
  expect_error({
      gqlr_schema(
        MySchema,
        MyInput = list(
          other_field = 5
        )
      )
    },
    "InputObjectTypeDefinition"
  )
  expect_error({
      gqlr_schema(
        MySchema,
        MyDirective = list(
          other_field = 5
        )
      )
    },
    "DirectiveDefinition"
  )

  expect_error({
      gqlr_schema(
        MySchema,
        MyObject = list(
          description = "desc 1",
          description = "desc 2"
        )
      )
    },
    "uniquely named"
  )

  expect_error({
      gqlr_schema(
        MySchema,
        MyObject = list(
          fields = list(
            fieldZ = "fieldZ desc"
          )
        )
      )
    },
    "Could not find field"
  )

  expect_error({
      gqlr_schema(
        MySchema,
        MyEnum = list(
          values = list(
            ValZ = "ValZ desc"
          )
        )
      )
    },
    "Could not find value"
  )


})
