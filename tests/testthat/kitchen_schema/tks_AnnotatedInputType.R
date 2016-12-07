"
input AnnotatedInput @onInputObjectType {
  annotatedField: Type @onField
}
"
tks_AnnotatedInputType <- InputObjectTypeDefinition$new(
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
