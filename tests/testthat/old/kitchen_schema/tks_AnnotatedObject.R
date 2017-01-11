"
type AnnotatedObject @onObject(arg: \"value\") {
  annotatedField(arg: Type = \"default\" @onArg): Type @onField
}
"
tks_AnnotatedObject <- ObjectTypeDefinition$new(
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
