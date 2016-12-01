#' @include R6--definition.R


DirectiveLocationNames <- (function() {
  ret <- list()
  for (name in c(
    # operations
    "QUERY",
    "MUTATION",
    "SUBSCRIPTION",
    "FIELD",
    "FRAGMENT_DEFINITION",
    "FRAGMENT_SPREAD",
    "INLINE_FRAGMENT",
    # Schema Definitions
    "SCHEMA",
    "SCALAR",
    "OBJECT",
    "FIELD_DEFINITION",
    "ARGUMENT_DEFINITION",
    "INTERFACE",
    "UNION",
    "ENUM",
    "ENUM_VALUE",
    "INPUT_OBJECT",
    "INPUT_FIELD_DEFINITION"
  )) {
    ret[[name]] <- Name$new(value = name)
  }
  ret
})()


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
