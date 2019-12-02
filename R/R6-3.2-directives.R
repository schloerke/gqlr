#' @include R6--definition.R
#' @include graphql_json.R

for_onload(function() {

SkipDirective <- DirectiveDefinition$new(
  name = Name$new(value = "skip"),
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
    Name$new(value = "FIELD"),
    Name$new(value = "FRAGMENT_SPREAD"),
    Name$new(value = "INLINE_FRAGMENT")
  ),
  .resolve = function(if_val) {
    isTRUE(if_val)
  }
)


}) # end for_onload
