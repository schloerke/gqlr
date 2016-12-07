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
tks_Foo <- ObjectTypeDefinition$new(
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
