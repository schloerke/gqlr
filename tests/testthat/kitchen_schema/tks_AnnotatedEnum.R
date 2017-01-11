"
enum AnnotatedEnum @onEnum {
  ANNOTATED_VALUE @onEnumValue
  OTHER_VALUE
}
"
#  %>%
#   graphql2obj() %>%
#   extract2("definitions") %>% extract2(1) ->
# tks_AnnotatedEnum
tks_AnnotatedEnum <- EnumTypeDefinition$new(
  name = Name$new(value = "AnnotatedEnum"),
  directives = list(
    Directive$new(name = Name$new(value = "onEnum"))
  ),
  values = list(
    EnumValueDefinition$new(
      name = Name$new(value = "ANNOTATED_VALUE"),
      directives = list(
        Directive$new(name = Name$new(value = "onEnumValue"))
      )
    ),
    EnumValueDefinition$new(name = Name$new(value = "OTHER_VALUE"))
  )
)
