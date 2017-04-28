# Using our shorthand to describe type systems, the type system for our
# Star Wars example is:
"
enum Episode { NEWHOPE, EMPIRE, JEDI }

interface Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
}

type Human implements Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
  homePlanet: String
}

type Droid implements Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
  primaryFunction: String
}

union HumanOrDroid = Human | Droid

type Query {
  hero(episode: Episode): Character
  human(id: String!): Human
  droid(id: String!): Droid
  by_id(id: Int!): Character
  humanoid(id: String!): HumanOrDroid
}

directive @notskip on FIELD
 | FRAGMENT_SPREAD
 | INLINE_FRAGMENT

schema {
  query: Query
  # mutation: Mutation
}
" %>%
  graphql2obj(fn_list = list(
    HumanOrDroid = list(
      .resolve_type = function(obj, schema_obj) {
        if (is_droid(obj)) {
          "Droid"
        } else {
          "Human"
        }
      }
    ),
    Droid = list(
      description = "A mechanical creature in the Star Wars universe."
    ),
    Character = list(
      .resolve_type = function(obj, schema_obj) {
        # cat("\n\n")
        # str(obj)
        # cat("\n\n")
        if (is_droid(obj)) {
          "Droid"
        } else {
          "Human"
        }
      }
    )
  )) ->
star_wars_doc

star_wars_schema <- GQLRSchema$new(star_wars_doc)
