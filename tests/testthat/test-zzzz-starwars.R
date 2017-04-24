

# testthat::test_file(file.path("tests", "testthat", "test-kitchen.R"))

context("starwars")


test_that("works", {


  # Using our shorthand to describe type systems, the type system for our
  # Star Wars example is:
  "
  enum Episode {
    NEWHOPE
    EMPIRE
    JEDI
  }

  interface Character {
    id: ID!
    name: String!
    friends: [Character]
    appearsIn: [Episode]!
  }

  type Human implements Character {
    id: ID!
    name: String!
    friends: [Character]
    appearsIn: [Episode]!
    starships: [Starship]
    totalCredits: Int
  }

  type Droid implements Character {
    id: ID!
    name: String!
    friends: [Character]
    appearsIn: [Episode]!
    primaryFunction: String
  }

  type Starship {
    id: ID!
    name: String!
    length(unit: LengthUnit = METER): Float
  }

  type Query {
    hero(episode: Episode): Character
    droid(id: ID!): Droid
  }

  union SearchResult = Human | Droid | Starship

  input ReviewInput {
    stars: Int!
    commentary: String
  }

  schema {
    query: Query
    mutation: Mutation
  }
  " %>%
    graphql2obj() ->
  star_wars_doc

  star_wars_schema <- GQLRSchema$new(star_wars_doc)





  luke <- list(
    id = '1000',
    name = 'Luke Skywalker',
    friends = c('1002', '1003', '2000', '2001' ),
    appearsIn = c(4, 5, 6),
    homePlanet = 'Tatooine',
  )

  vader <- list(
    id = '1001',
    name = 'Darth Vader',
    friends = c('1004') ,
    appearsIn = c(4, 5, 6),
    homePlanet = 'Tatooine',
  )

  han <- list(
    id = '1002',
    name = 'Han Solo',
    friends = c('1000', '1003', '2001'),
    appearsIn = c(4, 5, 6),
  };

  leia <- list(
    id = '1003',
    name = 'Leia Organa',
    friends = c('1000', '1002', '2000', '2001'),
    appearsIn = c(4, 5, 6),
    homePlanet = 'Alderaan',
  )

  tarkin = list(
    id = '1004',
    name = 'Wilhuff Tarkin',
    friends = c('1001'),
    appearsIn = c(4),
  )

  human_data = list(
    1000 = luke,
    1001 = vader,
    1002 = han,
    1003 = leia,
    1004 = tarkin,
  )

  threepio <- list(
    id = '2000',
    name = 'C-3PO',
    friends = c('1000', '1002', '1003', '2001'),
    appearsIn = c(4, 5, 6),
    primaryFunction = 'Protocol',
  )

  artoo <- list(
    id = '2001',
    name = 'R2-D2',
    friends = c('1000', '1002', '1003'),
    appearsIn = c(4, 5, 6),
    primaryFunction = 'Astromech',
  )

  droid_data = list(
    2000 = threepio,
    2001 = artoo,
  )

  all_characters = list() %>% append(human_data) %>% append(droid_data) %>% unname()

  get_friends <- function(x) {
    function(obj, args, schema_obj) {
      lapply(x$friends, wrap_character)
    }
  }

  wrap_human <- function(x) {
    list(
      id = x$id,
      name = x$name,
      friends = get_friends(x),
      appearsIn = x$appearsIn,
      # starships = x$starships
      totalCredits = length(x$appearsIn)
    )
  }
  wrap_droid <- function(x) {
    list(
      id = x$id,
      name = x$name,
      friends = get_friends(x),
      appearsIn = x$appearsIn,
      primaryFunction = x$primaryFunction
    )
  }
  wrap_character <- function(x) {
    if (x$id %in% names(droid_data)) {
      wrap_droid(x)
    } else {
      wrap_human(x)
    }
  }


  # hero(episode: Episode): Character
  # droid(id: ID!): Droid
  data = list(
    hero = function(obj, args, schema_obj) {
      episode = args$episode

      if (is.null(episode)) {
        return(wrap_character(luke))
      }

      str(episode)
      if (identical(episode, 5)) {
        return(wrap_character(luke))
      }

      return(wrap_character(artoo))
    },
    droid = function(obj, args, schema_obj) {
      if (args$id %in% names(droid_data)) {
        wrap_droid(droid_data[[args$id]])
      } else {
        NULL
      }
    }
  )

  

})
