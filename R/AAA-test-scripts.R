
if (FALSE) {

  load_all(); test_json("simple-query") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("kitchen-query") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("kitchen-query") %>% r6_from_list() %>% gqlr_str(maxLevel = 2)

  # load_all(); test_json("simple-schema") %>% r6_from_list() %>% gqlr_str()
  # load_all(); test_json("kitchen-schema") %>% r6_from_list() %>% gqlr_str()

  # load_all(); test_json("film-schema") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("film-query") %>% r6_from_list() %>% gqlr_str()

  # load_all(); introspection_spec() %>% eval_json() %>% r6_from_list() %>% gqlr_str()
  # load_all(); introspection_imp()


  # a <- SchemaDefinition$new(
  #   operationTypes = list(
  #     OperationTypeDefinition$new(operation = )
  # )


"
schema {
  query: QueryType
  mutation: MutationType
}
"
SchemaDefinition$new(
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
)$.str()

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
ObjectTypeDefinition$new(
  name = Name$new(value = "Foo"),
  interfaces = list(
    NamedType$new(name = Name$new(value = "Bar"))
  ),
  fields = list(
    FieldDefinition$new(
      # one: Type
      name = Name$new(value = "one"),
      type = Type$new(),
      arguments = NULL
    ),
    FieldDefinition$new(
      # two(argument: InputType!): Type
      name = Name$new(value = "two"),
      type = Type$new(),
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
      type = Type$new(),
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
      type = Type$new(),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "argument"),
          type = NamedType$new(name = Name$new(value = "Int")),
          defaultValue = NULL
        )
      )
    )
  )
) -> a
a$.str()





"
type AnnotatedObject @onObject(arg: \"value\") {
  annotatedField(arg: Type = \"default\" @onArg): Type @onField
}
"
ObjectTypeDefinition$new(
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
      type = Type$new(),
      directives = list(
        Directive$new(name = Name$new(value = "onField"))
      ),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "arg"),
          type = Type$new(),
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
) -> a
a$.str()


"
interface Bar {
  one: Type
  four(argument: String = \"string\"): String
}
"
InterfaceTypeDefinition$new(
  name = Name$new(value = "Bar"),
  fields = list(
    FieldDefinition$new(
      name = Name$new(value = "one"),
      type = Type$new()
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
) -> a
a$.str()



"
interface AnnotatedInterface @onInterface {
  annotatedField(arg: Type @onArg): Type @onField
}
"
InterfaceTypeDefinition$new(
  name = Name$new(value = "AnnotatedInterface"),
  directives = list(
    Directive$new(
      name = Name$new(value = "onInterface")
    )
  ),
  fields = list(
    FieldDefinition$new(
      name = Name$new(value = "annotatedField"),
      type = Type$new(),
      directives = list(
        Directive$new(
          name = Name$new(value = "onField")
        )
      ),
      arguments = list(
        InputValueDefinition$new(
          name = Name$new(value = "arg"),
          type = Type$new(),
          directives = list(
            Directive$new(
              name = Name$new(value = "onArg")
            )
          )
        )
      )
    )
  )
) -> a
a$.str()




"
union Feed = Story | Article | Advert
"
UnionTypeDefinition$new(
  name = Name$new(value = "Feed"),
  types = list(
    NamedType$new(name = Name$new(value = "Story")),
    NamedType$new(name = Name$new(value = "Article")),
    NamedType$new(name = Name$new(value = "Advert"))
  )
) -> a
a$.str()


"
union AnnotatedUnion @onUnion = A | B
"
UnionTypeDefinition$new(
  name = Name$new(value = "AnnotatedUnion"),
  directives = list(
    Directive$new(name = Name$new(value = "onUnion"))
  ),
  types = list(
    NamedType$new(name = Name$new(value = "A")),
    NamedType$new(name = Name$new(value = "B"))
  )
) -> a
a$.str()

"
scalar CustomScalar
"
ScalarTypeDefinition$new(
  name = Name$new(value = "CustomScalar")
) -> a
a$.str()


"
scalar AnnotatedScalar @onScalar
"
ScalarTypeDefinition$new(
  name = Name$new(value = "AnnotatedScalar"),
  directives = list(
    Directive$new(
      name = Name$new(value = "onScalar")
    )
  )
) -> a
a$.str()


"
enum Site {
  DESKTOP
  MOBILE
}
"
EnumTypeDefinition$new(
  name = Name$new(value = "Site"),
  values = list(
    EnumValueDefinition$new(name = Name$new(value = "DESKTOP")),
    EnumValueDefinition$new(name = Name$new(value = "MOBILE"))
  )
) -> a
a$.str()


"
enum AnnotatedEnum @onEnum {
  ANNOTATED_VALUE @onEnumValue
  OTHER_VALUE
}
"
EnumTypeDefinition$new(
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
) -> a
a$.str()


"
input InputType {
  key: String!
  answer: Int = 42
}
"
InputObjectTypeDefinition$new(
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
) -> a
a$.str()

"
input AnnotatedInput @onInputObjectType {
  annotatedField: Type @onField
}
"
InputObjectTypeDefinition$new(
  name = Name$new(value = "AnnotatedInput"),
  directives = list(
    Directive$new(name = Name$new(value = "onInputObjectType"))
  ),
  fields = list(
    InputValueDefinition$new(
      name = Name$new(value = "annotatedField"),
      type = Type$new(),
      directives = list(
        Directive$new(name = Name$new(value = "onField"))
      )
    )
  )
) -> a
a$.str()


"
extend type Foo {
  seven(argument: [String]): Type
}
"
TypeExtensionDefinition$new(
  definition = ObjectTypeDefinition$new(
    name = Name$new(value = "Foo"),
    interfaces = list(
      NameType$new(name = Name$new(value = "Foo"))
    ),
    fields = list(
      FieldDefinition$new(
        name = Name$new(value = "seven"),
        type = Type$new(),
        arguments = list(
          InputValueDefinition$new(
            name = Name$new(value = "argument"),
            type = ListType$new(type = NamedType$new(name = Name$new(value = "String")))
          )
        )
      )
    )
  )
) -> a
a$.str()

"
extend type Foo @onType {}
"
TypeExtensionDefinition$new(
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
) -> a
a$.str()


"
type NoFields {}
"
ObjectTypeDefinition$new(
  name = Name$new(value = "NoFields"),
  fields = NULL
) -> a
a$.str()

"
directive @skip(if: Boolean!) on FIELD | FRAGMENT_SPREAD | INLINE_FRAGMENT
"
DirectiveDefinition$new(
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
  )
) -> a
a$.str()


"
directive @include(if: Boolean!)
  on FIELD
   | FRAGMENT_SPREAD
   | INLINE_FRAGMENT
"
DirectiveDefinition$new(
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
  )
) -> a
a$.str()















# # Uptopia definition
#
#
# filmSchemaTxt = "\nscalar Date\n\n  type Person {\n    name: String\n    films: [Film]\n  }\n\n  type Film {\n    title: String,\n    producers: [String]\n    characters(limit: Int): [Person]\n    release_date: Date\n  }\n\n  type Query {\n    film(id: Int): Film\n    person(id: Int): Person\n  }\n"
# filmFnList = list(
#   Date = list(
#     serialize = function(dateObj, args) {
#       format(dateObj, "%a %b %d %H:%M:%S %Y")
#     }
#   ),
#   Person = list(
#     films = function(personObj, args) {
#       loaders.film.loadMany(person.films)
#     }
#   ),
#   Film = list(
#     producers = function(filmObj, args) {
#       filmObj$producer %>%
#         strsplit(",")[[1]]
#     },
#     characters = function(film, args) {
#       ret <- film$characters
#       if (!is.null(args$limit)) {
#         limit <- args$limit
#         if ((length(ret) > limit) & (limit > 0)) {
#           ret <- ret[1:floor(limit)]
#         }
#       }
#       loaders.person.loadMany(ret)
#     }
#   ),
#   Query = list(
#     film = function(queryObj, args) {
#       loaders.film.load(args$id)
#     },
#     person = function(queryObj, args) {
#       loaders.person.load(args.id)
#     }
#   )
# )
#
# load_all(); filmSchemaTxt %>% eval_json() %>% r6_from_list() %>% gqlr_str()
#
# schemaObj <- SchemaObj$new(text = filmSchemaTxt, fnList = filmFnList)
#
# schemaObj <- Schema$new(documentObj = filmSchemaTxt, fnList = filmFnList)





} # end FALSE
