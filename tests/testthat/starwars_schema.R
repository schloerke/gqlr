


add_human <- function(human_data, id, name, appear, home, friend) {
  human <- list(id = id, name = name, appearsIn = appear, friends = friend, homePlanet = home)
  # set up a function to be calculated if the field totalCredits is required
  human$totalCredits <- function(obj, args, schema) {
    length(human$appearsIn)
  }
  human_data[[id]] <- human
  human_data
}
add_droid <- function(droid_data, id, name, appear, pf, friend) {
  droid <- list(id = id, name = name, appearsIn = appear, friends = friend, primaryFunction = pf)
  # set extra fields manually
  droid$totalCredits <- length(droid$appearsIn)
  droid_data[[id]] <- droid
  droid_data
}

human_data <- list() %>%
  add_human("1000", "Luke Skywalker", c(4, 5, 6), "Tatooine",  c("1002", "1003", "2000", "2001")) %>%
  add_human("1002", "Han Solo",       c(4, 5, 6), "Corellia",  c("1000", "1003", "2001")) %>%
  add_human("1003", "Leia Organa",    c(4, 5, 6), "Alderaan",   c("1000", "1002", "2000", "2001"))

droid_data <- list() %>%
  add_droid("2000", "C-3PO", c(4, 5, 6), "Protocol", c("1000", "1002", "1003", "2001")) %>%
  add_droid("2001", "R2-D2", c(4, 5, 6), "Astromech", c("1000", "1002", "1003"))

all_characters <- list() %>% append(human_data) %>% append(droid_data)

is_droid <- function(id) {
  if (is.null(id)) {
    stop("NULL id supplied")
  }
  id %in% names(droid_data) # nolint
}

# Using our shorthand to describe type systems, the type system for our
# Star Wars example is:

star_wars_schema <- Schema$new()

"
enum Episode { NEWHOPE, EMPIRE, JEDI }
" %>%
  gqlr_schema(
    Episode = list(
      resolve = function(episode_id, schema) {
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
        human_data[[id]]
      }
    ),
    Droid = list(
      description = "A mechanical creature in the Star Wars universe.",
      resolve = function(id, schema) {
        droid_data[[id]]
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
            "1000"
          } else {
            "2001"
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
