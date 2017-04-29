# Using our shorthand to describe type systems, the type system for our
# Star Wars example is:


star_wars_schema <- GQLRSchema$new()

"
enum Episode { NEWHOPE, EMPIRE, JEDI }
" %>%
  graphql2obj() %>%
  star_wars_schema$add()


"
interface Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
}
" %>%
  graphql2obj(
    Character = list(
      .resolve_type = function(id, schema_obj) {
        if (is_droid(id)) {
          "Droid"
        } else {
          "Human"
        }
      }
    )
  ) %>%
  star_wars_schema$add()


"
type Droid implements Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
  primaryFunction: String
}
type Human implements Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
  homePlanet: String
}
" %>%
  graphql2obj(
    Human = list(
      .resolve = function(id, args, schema_obj) {
        get_human_by_id(id)
      }
    ),
    Droid = list(
      description = "A mechanical creature in the Star Wars universe.",
      .resolve = function(id, schema_obj) {
        get_droid_by_id(id)
      }
    )
  ) %>%
  star_wars_schema$add()


"
type Query {
  hero(episode: Episode): Character
  human(id: String!): Human
  droid(id: String!): Droid
  by_id(id: Int!): Character
  humanoid(id: String!): HumanOrDroid
}
schema {
  query: Query
  # mutation: Mutation
}
" %>%
  graphql2obj(
    Query = function(null, schema_obj) {
      list(
        hero = function(obj, args, schema_obj) {
          episode = args$episode
          if (identical(episode, 5) || identical(episode, "EMPIRE")) {
            luke$id
          } else {
            artoo$id
          }
        },
        human = function(obj, args, schema_obj) {
          args$id
        },
        droid = function(obj, args, schema_obj) {
          args$id
        },
        by_id = function(obj, args, schema_obj) {
          args$id
        },
        humanoid = function(obj, args, schema_obj) {
          args$id
        }
      )
    }
  ) %>%
  star_wars_schema$add()



# extra testing defintions
"
union HumanOrDroid = Human | Droid

directive @notskip on FIELD
 | FRAGMENT_SPREAD
 | INLINE_FRAGMENT
" %>%
  graphql2obj(
    HumanOrDroid = list(
      .resolve_type = function(id, schema_obj) {
        if (is_droid(id)) {
          "Droid"
        } else {
          "Human"
        }
      }
    )
  ) %>%
  star_wars_schema$add()
