"
interface Bar {
  one: Type
  four(argument: String = \"string\"): String
}
"
tks_Bar <- InterfaceTypeDefinition$new(
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
