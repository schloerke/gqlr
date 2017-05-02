# Using our shorthand to describe type systems, the type system for our
# Star Wars example is:


star_wars_schema <- Schema$new()

"
enum Episode { NEWHOPE, EMPIRE, JEDI }
" %>%
  gqlr_schema(
    Episode = list(
      parse_value = function(episode_id, schema) {
        switch(as.character(episode_id),
          "4" = "NEWHOPE",
          "5" = "EMPIRE",
          "6" = "JEDI",
          "UNKNOWN_EPISODE"
        )
      }
    )
  ) %>%
  star_wars_schema$add()


"
interface Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
}
" %>%
  gqlr_schema(
    Character = list(
      resolve_type = function(id, schema) {
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
  gqlr_schema(
    Human = list(
      resolve = function(id, args, schema) {
        get_human_by_id(id)
      }
    ),
    Droid = list(
      description = "A mechanical creature in the Star Wars universe.",
      resolve = function(id, schema) {
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
  gqlr_schema(
    Query = function(null, schema) {
      list(
        hero = function(obj, args, schema) {
          episode <- args$episode
          if (identical(episode, 5) || identical(episode, "EMPIRE")) {
            luke$id
          } else {
            artoo$id
          }
        },
        human = function(obj, args, schema) {
          args$id
        },
        droid = function(obj, args, schema) {
          args$id
        },
        by_id = function(obj, args, schema) {
          args$id
        },
        humanoid = function(obj, args, schema) {
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
  gqlr_schema(
    HumanOrDroid = list(
      resolve_type = function(id, schema) {
        if (is_droid(id)) {
          "Droid"
        } else {
          "Human"
        }
      }
    )
  ) %>%
  star_wars_schema$add()
