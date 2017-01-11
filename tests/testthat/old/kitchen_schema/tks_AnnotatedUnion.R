"
union AnnotatedUnion @onUnion = A | B
"
tks_AnnotatedUnion <- UnionTypeDefinition$new(
  name = Name$new(value = "AnnotatedUnion"),
  directives = list(
    Directive$new(name = Name$new(value = "onUnion"))
  ),
  types = list(
    NamedType$new(name = Name$new(value = "A")),
    NamedType$new(name = Name$new(value = "B"))
  )
)
