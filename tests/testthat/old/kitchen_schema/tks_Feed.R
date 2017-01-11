"
union Feed = Story | Article | Advert
"
tks_Feed <- UnionTypeDefinition$new(
  name = Name$new(value = "Feed"),
  types = list(
    NamedType$new(name = Name$new(value = "Story")),
    NamedType$new(name = Name$new(value = "Article")),
    NamedType$new(name = Name$new(value = "Advert"))
  )
)
