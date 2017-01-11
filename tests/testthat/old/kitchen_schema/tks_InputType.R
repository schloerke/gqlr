"
input InputType {
  key: String!
  answer: Int = 42
}
"
tks_InputType <- InputObjectTypeDefinition$new(
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
