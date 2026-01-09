# Create Schema definitions

Creates a Schema object from the defined GraphQL string and inserts the
provided descriptions, resolve methods, resolve_type methods into the
appropriate place.

## Usage

``` r
gqlr_schema(schema, ...)
```

## Arguments

- schema:

  GraphQL schema string or Schema object

- ...:

  named lists of information to help produce the schema definition. See
  Details

## Details

The ... should be named arguments whose values are lists of information.
What information is needed for each type is described below.

ScalarTypeDefinition:

- resolve:

  function with two parameters: `x` (the raw to be parsed, such as 5.0)
  and `schema` (the full Schema definition). Should return a parsed
  value

- description:

  (optional) single character value that describes the Scalar definition

- parse_ast:

  (optional) function with two parameters: `obj` (a GraphQL wrapped raw
  value, such as an object of class IntValue with value 5) and `schema`
  (the full Schema definition). If the function returns `NULL` then the
  AST could not be parsed.

EnumTypeDefinition:

- resolve:

  (optional) function with two parameters: `x` and `schema` (the full
  Schema definition). Should return the value `x` represents, such as
  the Star Wars Episode enum value "4" could represent Episode
  "NEWHOPE". By default, EnumTypeDefinitions will return the current
  value.

- description:

  (optional) single character value that describes the Enum definition

- values:

  (optional) named list of enum value descriptions. Such as
  `values = list(ENUMA = "description for ENUMA", ENUMZ = "description for ENUMZ")`

ObjectTypeDefinition:

- resolve:

  function with two parameters: `x` (place holder value to be expanded
  into a named list) and `schema` (the full Schema definition). By using
  the resolve method, recursive relationships, such as friends, can
  easily be handled. The resolve function should return a fully named
  list of all the fields the definition defines. Missing fields are
  automatically interpreted as `NULL`.

  Values in the returned list may be a function of the form
  `function(obj, args, schema) {...}`. This allows for fields to be
  determined dynamically and lazily. See how `add_human` makes a field
  for `totalCredits`, while the `add_droid` pre computes the
  information.

- description:

  (optional) single character value that describes the object

- fields:

  (optional) named list of field descriptions. Such as
  `fields = list(fieldA = "description for field A", fieldB = "description for field B")`

InterfaceTypeDefinition and UnionTypeDefinition:

- resolve_type:

  function with two parameters: `x` (a pre-resolved object value) and
  `schema` (the full Schema definition). This function is required to
  determine which object type is being used. `resolve_type` is called
  before any ObjectTypeDefinition `resolve` methods are called.

- description:

  (optional) single character value that describes the object

## Examples

``` r
# \donttest{
library(magrittr)

## Set up data
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
  add_human("1000", "Luke Skywalker", c(4, 5, 6), "Tatooine", c("1002", "1003", "2000", "2001")) %>%
  add_human("1002", "Han Solo",       c(4, 5, 6), "Corellia", c("1000", "1003", "2001")) %>%
  add_human("1003", "Leia Organa",    c(4, 5, 6), "Alderaan", c("1000", "1002", "2000", "2001"))

droid_data <- list() %>%
  add_droid("2000", "C-3PO", c(4, 5, 6), "Protocol", c("1000", "1002", "1003", "2001")) %>%
  add_droid("2001", "R2-D2", c(4, 5, 6), "Astromech", c("1000", "1002", "1003"))

all_characters <- list() %>% append(human_data) %>% append(droid_data) %>% print()
#> $`1000`
#> $`1000`$id
#> [1] "1000"
#> 
#> $`1000`$name
#> [1] "Luke Skywalker"
#> 
#> $`1000`$appearsIn
#> [1] 4 5 6
#> 
#> $`1000`$friends
#> [1] "1002" "1003" "2000" "2001"
#> 
#> $`1000`$homePlanet
#> [1] "Tatooine"
#> 
#> $`1000`$totalCredits
#> function (obj, args, schema) 
#> {
#>     length(human$appearsIn)
#> }
#> <environment: 0x5609642fdf00>
#> 
#> 
#> $`1002`
#> $`1002`$id
#> [1] "1002"
#> 
#> $`1002`$name
#> [1] "Han Solo"
#> 
#> $`1002`$appearsIn
#> [1] 4 5 6
#> 
#> $`1002`$friends
#> [1] "1000" "1003" "2001"
#> 
#> $`1002`$homePlanet
#> [1] "Corellia"
#> 
#> $`1002`$totalCredits
#> function (obj, args, schema) 
#> {
#>     length(human$appearsIn)
#> }
#> <environment: 0x5609642fea98>
#> 
#> 
#> $`1003`
#> $`1003`$id
#> [1] "1003"
#> 
#> $`1003`$name
#> [1] "Leia Organa"
#> 
#> $`1003`$appearsIn
#> [1] 4 5 6
#> 
#> $`1003`$friends
#> [1] "1000" "1002" "2000" "2001"
#> 
#> $`1003`$homePlanet
#> [1] "Alderaan"
#> 
#> $`1003`$totalCredits
#> function (obj, args, schema) 
#> {
#>     length(human$appearsIn)
#> }
#> <environment: 0x5609642f9918>
#> 
#> 
#> $`2000`
#> $`2000`$id
#> [1] "2000"
#> 
#> $`2000`$name
#> [1] "C-3PO"
#> 
#> $`2000`$appearsIn
#> [1] 4 5 6
#> 
#> $`2000`$friends
#> [1] "1000" "1002" "1003" "2001"
#> 
#> $`2000`$primaryFunction
#> [1] "Protocol"
#> 
#> $`2000`$totalCredits
#> [1] 3
#> 
#> 
#> $`2001`
#> $`2001`$id
#> [1] "2001"
#> 
#> $`2001`$name
#> [1] "R2-D2"
#> 
#> $`2001`$appearsIn
#> [1] 4 5 6
#> 
#> $`2001`$friends
#> [1] "1000" "1002" "1003"
#> 
#> $`2001`$primaryFunction
#> [1] "Astromech"
#> 
#> $`2001`$totalCredits
#> [1] 3
#> 
#> 
## End data set up



# Define the schema using GraphQL code
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
  ) ->
episode_schema
# display the schema
episode_schema$get_schema()
#> <graphql definition>
#>   | enum Episode {
#>   |   NEWHOPE
#>   |   EMPIRE
#>   |   JEDI
#>   | }
# add the episode definitions to the Star Wars schema
star_wars_schema$add(episode_schema)


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
        if (id %in% names(droid_data)) {
          "Droid"
        } else {
          "Human"
        }
      }
    )
  ) ->
character_schema
# print the Character schema with no extra formatting
character_schema$get_schema() %>% format() %>% cat("\n")
#> interface Character {
#>   id: String!
#>   name: String
#>   friends: [Character]
#>   appearsIn: [Episode]
#> } 
star_wars_schema$add(character_schema)


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
      # Add a resolve method for type Human that takes in an id and returns the human data
      resolve = function(id, args, schema) {
        human_data[[id]]
      }
    ),
    Droid = list(
      # description for Droid
      description = "A mechanical creature in the Star Wars universe.",
      # Add a resolve method for type Droid that takes in an id and returns the droid data
      resolve = function(id, schema) {
        droid_data[[id]]
      }
    )
  ) ->
human_and_droid_schema
human_and_droid_schema$get_schema()
#> <graphql definition>
#>   | type Droid implements Character {
#>   |   id: String!
#>   |   name: String
#>   |   friends: [Character]
#>   |   appearsIn: [Episode]
#>   |   primaryFunction: String
#>   | }
#>   | 
#>   | type Human implements Character {
#>   |   id: String!
#>   |   name: String
#>   |   friends: [Character]
#>   |   appearsIn: [Episode]
#>   |   homePlanet: String
#>   | }
star_wars_schema$add(human_and_droid_schema)


"
type Query {
  hero(episode: Episode): Character
  human(id: String!): Human
  droid(id: String!): Droid
}
# the schema type must be provided if a query or mutation is to be executed
schema {
  query: Query
}
" %>%
  gqlr_schema(
    Query = function(null, schema) {
      list(
        # return a function for key 'hero'
        # the id will be resolved by the appropriate resolve() method of Droid or Human
        hero = function(obj, args, schema) {
          episode <- args$episode
          if (identical(episode, 5) || identical(episode, "EMPIRE")) {
            "1000" # Luke Skywalker
          } else {
            "2001" # R2-D2
          }
        },
        # the id will be resolved by the Human resolve() method
        human = function(obj, args, schema) {
          args$id
        },
        # the id will be resolved by the Droid resolve() method
        droid = function(obj, args, schema) {
          args$id
        }
      )
    }
  ) ->
schema_def
# print Schema with no extra formatting
schema_def$get_schema() %>% format() %>% cat("\n")
#> type Query {
#>   hero(episode: Episode): Character
#>   human(id: String!): Human
#>   droid(id: String!): Droid
#> }
#> 
#> schema {
#>   query: Query
#> } 
star_wars_schema$add(schema_def)


# view the final schema definitiion
star_wars_schema$get_schema()
#> <graphql definition>
#>   | enum Episode {
#>   |   NEWHOPE
#>   |   EMPIRE
#>   |   JEDI
#>   | }
#>   | 
#>   | type Droid implements Character {
#>   |   id: String!
#>   |   name: String
#>   |   friends: [Character]
#>   |   appearsIn: [Episode]
#>   |   primaryFunction: String
#>   | }
#>   | 
#>   | type Human implements Character {
#>   |   id: String!
#>   |   name: String
#>   |   friends: [Character]
#>   |   appearsIn: [Episode]
#>   |   homePlanet: String
#>   | }
#>   | 
#>   | type Query {
#>   |   hero(episode: Episode): Character
#>   |   human(id: String!): Human
#>   |   droid(id: String!): Droid
#>   | }
#>   | 
#>   | interface Character {
#>   |   id: String!
#>   |   name: String
#>   |   friends: [Character]
#>   |   appearsIn: [Episode]
#>   | }
#>   | 
#>   | schema {
#>   |   query: Query
#>   | }
# }
```
