"
extend type Foo {
  seven(argument: [String]): Type
}
"
tks_ExtendedFoo <- TypeExtensionDefinition$new(
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
