"
directive @include(if: Boolean!)
  on FIELD
   | FRAGMENT_SPREAD
   | INLINE_FRAGMENT
"
tks_DirectiveInclude <- DirectiveDefinition$new(
  name = Name$new(value = "include"),
  arguments = list(
    InputValueDefinition$new(
      name = Name$new(value = "if"),
      type = NonNullType$new(type = NamedType$new(name = Name$new(value = "Boolean")))
    )
  ),
  locations = list(
    Name$new(value = "FIELD"),
    Name$new(value = "FRAGMENT_SPREAD"),
    Name$new(value = "INLINE_FRAGMENT")
  ),
  .resolve = function(...) TRUE
)
