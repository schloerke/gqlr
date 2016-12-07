"
interface AnnotatedInterface @onInterface {
  annotatedField(arg: Type @onArg): Type @onField
}
"
tks_AnnotatedInterface <- InterfaceTypeDefinition$new(
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
