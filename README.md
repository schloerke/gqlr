#  gqlr: A GraphQL Implementation in R
[![Travis-CI Build Status](https://travis-ci.org/schloerke/gqlr.svg?branch=master)](https://travis-ci.org/schloerke/gqlr)
[![Coverage Status](https://codecov.io/github/schloerke/gqlr/coverage.svg?branch=master)](https://codecov.io/github/schloerke/gqlr?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/gqlr)](https://cran.r-project.org/package=gqlr)



## Overview

GraphQL is a data "query language created by Facebook in 2015 for describing the capabilities and requirements of data models for client‐server applications".  The [GraphQL specification can be read on their hosted github](http://facebook.github.io/graphql/). A [cliff notes version is described on Facebook's github](https://github.com/facebook/graphql). To learn more about the GraphQL language, I highly recommend [Facebook's public GraphQL website](http://graphql.org/learn/).

This package pulls inspiration from [Facebook's graphql-js](https://github.com/graphql/graphql-js) and [Mathew Mueller's graph.ql](https://github.com/matthewmueller/graph.ql). I wanted the full functionality of GraphQL, but I didn't want to force users to write full object definitions when can already be defined with GraphQL syntax.

`gqlr` merges R's rapid development speed with the consistent query language of GraphQL.


## Installation

```r
# The development version from GitHub:
# install.packages("devtools")
devtools::install_github("schloerke/gqlr")
```

If you encounter a clear bug, please file a minimal reproducible example on [github](https://github.com/schloerke/gqlr/issues).


## Usage

### Hello World

```{r, message = FALSE}

library(magrittr)
library(gqlr)

schema <- "
  type Hello {
    world: String
  }
  schema {
    query: Hello
  }
" %>%
  gqlr_schema()

execute_request("{world}", schema, initial_value = list(world = "Hi!"))
# {
#   "data": {
#     "world": "Hi!"
#   }
# }
```

### Star Wars

#### Star Wars Data

```r
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

all_characters <- list() %>% append(human_data) %>% append(droid_data)
all_characters[[1]]
# $id
# [1] "1000"
#
# $name
# [1] "Luke Skywalker"
#
# $appearsIn
# [1] 4 5 6
#
# $friends
# [1] "Tatooine"
#
# $homePlanet
# [1] "1002" "1003" "2000" "2001"
#
# $totalCredits
# function (obj, args, schema)
# {
#     length(human$appearsIn)
# }
# <environment: 0x7fadd8ca2038>
```


#### Star Wars Schema
```r
"
enum Episode { NEWHOPE, EMPIRE, JEDI }

interface Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
}

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
    Episode = list(
      resolve = function(episode_id, schema) {
        switch(as.character(episode_id),
          "4" = "NEWHOPE",
          "5" = "EMPIRE",
          "6" = "JEDI",
          "UNKNOWN_EPISODE"
        )
      }
    ),
    Character = list(
      resolve_type = function(id, schema) {
        ifelse(id %in% names(droid_data), "Droid", "Human")
      }
    ),
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
    ),
    Query = function(null, schema) {
      list(
        # return a function for key 'hero'
        # the id will be resolved by the appropriate resolve() method of Droid or Human
        hero = function(obj, args, schema) {
          episode <- args$episode
          if (identical(episode, 5) || identical(episode, "EMPIRE")) {
            "1000" # Luke
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
star_wars_schema
```

#### Star Wars Execution

```r
# Use the resolve method to initialize the data
"
{
  hero {
    id
    name
    friends {
      id
      name
    }
  }
}
" %>%
  execute_request(star_wars_schema)
# {
#   "data": {
#     "hero": {
#       "id": "2001",
#       "name": "R2-D2",
#       "friends": [
#         {
#           "id": "1000",
#           "name": "Luke Skywalker"
#         },
#         {
#           "id": "1002",
#           "name": "Han Solo"
#         },
#         {
#           "id": "1003",
#           "name": "Leia Organa"
#         }
#       ]
#     }
#   }
# }


# Use variables...
"
query FetchSomeIDQuery($someId: String!) {
  human(id: $someId) {
    name
  }
}
" %>%
  execute_request(star_wars_schema, variables = list(someId = "1000"))
# {
#   "data": {
#     "human": {
#       "name": "Luke Skywalker"
#     }
#   }
# }


# Introspection
"
query IntrospectionTypeQuery {
  __type(name: \"Droid\") {
    kind
    name
    fields {
      name
    }
  }
}
" %>%
  execute_request(star_wars_schema)
# {
#   "data": {
#     "__type": {
#       "kind": "OBJECT",
#       "name": "Droid",
#       "fields": [
#         {
#           "name": "id"
#         },
#         {
#           "name": "name"
#         },
#         {
#           "name": "friends"
#         },
#         {
#           "name": "appearsIn"
#         },
#         {
#           "name": "primaryFunction"
#         },
#         {
#           "name": "__typename"
#         }
#       ]
#     }
#   }
# }
```


#### Star Wars Server
```r
# R
gqlr:::server(star_wars_schema, log = TRUE) # forgot to export
```

Explore with `curl`
```bash

# GET R2-D2 and his friends' names
curl '127.0.0.1:8000/graphql?query=%7Bhero%7Bname%7D%7D&pretty=TRUE'
# {
#   "data": {
#     "hero": {
#       "name": "R2-D2"
#     }
#   }
# }

# POST for R2-D2 and his friends' names (no need to url escape the query)
curl --data '{"query":"{hero{name}}"}' '127.0.0.1:8000/graphql' # defaults to parse as JSON
# {"data":{"hero":{"name":"R2-D2"}}}

curl --data '{"query":"{hero{name}}"}' '127.0.0.1:8000/graphql' --header "Content-Type:application/json"
# {"data":{"hero":{"name":"R2-D2"}}}

curl --data '{hero{name}}' '127.0.0.1:8000/graphql' --header "Content-Type:application/graphql"
# {"data":{"hero":{"name":"R2-D2"}}}


# GET Schema definition
curl '127.0.0.1:8000/'
# enum Episode {
#   NEWHOPE
#   EMPIRE
#   JEDI
# }
#
# type Droid implements Character {
#   id: String!
#   name: String
#   friends: [Character]
#   appearsIn: [Episode]
#   primaryFunction: String
# }
#
# type Human implements Character {
#   id: String!
#   name: String
#   friends: [Character]
#   appearsIn: [Episode]
#   homePlanet: String
# }
#
# type Query {
#   hero(episode: Episode): Character
#   human(id: String!): Human
#   droid(id: String!): Droid
# }
#
# interface Character {
#   id: String!
#   name: String
#   friends: [Character]
#   appearsIn: [Episode]
# }
#
# schema {
#   query: Query
# }
```


## Presentations

[WOMBAT2016 in Melbourne, Australia; Feb 2016](https://github.com/schloerke/presentation-2016_02_18-graphql/blob/master/GraphQL-Wombat-2016-Barret.pdf).


## Other R GraphQL related packages

* [graphql](https://github.com/ropensci/graphql)
    * Bindings to libgraphqlparser for R.
    * `gqlr` uses this package to parse all requests strings and schema strings into json
* [ghql](https://github.com/ropensci/ghql)
    * General purpose GraphQL client
    * The `ghql` client could be used to submit requests to `gqlr` server to be executed
