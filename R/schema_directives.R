

SkipDirective <- DirectiveDefinition$new(
  name = Name$new(value = "skip"),
  arguments = list(
    InputValueDefinition$new(
      name = Name$new(value = "if"),
      type = NonNullType(type = NamedType$new(name = Name$new(value = "Boolean")))
    )
  ),
  locations = list(
    DirectiveLocationNames$FIELD,
    DirectiveLocationNames$FRAGMENT_SPREAD,
    DirectiveLocationNames$INLINE_FRAGMENT
  ),
  .resolve = function(if_val) {
    !isTRUE(if_val)
  }
)


IncludeDirective <- DirectiveDefinition$new(
  name = Name$new(value = "include"),
  arguments = list(
    InputValueDefinition$new(
      name = Name$new(value = "if"),
      type = NonNullType$new(type = NamedType$new(name = Name$new(value = "Boolean")))
    )
  ),
  locations = list(
    DirectiveLocationNames$FIELD,
    DirectiveLocationNames$FRAGMENT_SPREAD,
    DirectiveLocationNames$INLINE_FRAGMENT
  ),
  .resolve = function(if_val) {
    isTRUE(if_val)
  }
)
