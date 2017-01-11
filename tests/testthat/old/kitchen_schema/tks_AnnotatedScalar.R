"
scalar AnnotatedScalar @onScalar
"
tks_AnnotatedScalar <- ScalarTypeDefinition$new(
  name = Name$new(value = "AnnotatedScalar"),
  directives = list(
    Directive$new(
      name = Name$new(value = "onScalar")
    )
  ),
  parse_value = function(...) NULL,
  parse_literal = function(...) NULL,
  serialize = function(...) NULL
)
