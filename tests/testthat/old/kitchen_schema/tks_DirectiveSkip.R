"
directive @skip(if: Boolean!) on FIELD | FRAGMENT_SPREAD | INLINE_FRAGMENT
"
tks_DirectiveSkip <- DirectiveDefinition$new(
  name = Name$new(value = "skip"),
  arguments = list(
    InputValueDefinition$new(
      name = Name$new(value = "if"),
      type = NonNullType(type = NamedType$new(name = Name$new(value = "Boolean")))
    )
  ),
  locations = list(
    Name$new(value = "FIELD"),
    Name$new(value = "FRAGMENT_SPREAD"),
    Name$new(value = "INLINE_FRAGMENT")
  ),
  .resolve = function(...) TRUE
)
