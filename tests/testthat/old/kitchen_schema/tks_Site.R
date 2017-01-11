"
enum Site {
  DESKTOP
  MOBILE
}
"
tks_Site <- EnumTypeDefinition$new(
  name = Name$new(value = "Site"),
  values = list(
    EnumValueDefinition$new(name = Name$new(value = "DESKTOP")),
    EnumValueDefinition$new(name = Name$new(value = "MOBILE"))
  )
)
