"
extend type Foo @onType {}
"
tks_DirectiveExtendedFoo <- TypeExtensionDefinition$new(
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
