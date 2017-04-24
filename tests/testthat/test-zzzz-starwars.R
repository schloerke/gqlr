

# testthat::test_file(file.path("tests", "testthat", "test-zzzz-starwars.R"))

context("star wars")

source(file.path("starwars", "starwars_schema.R"))
source(file.path("starwars", "starwars_data.R"))


test_that("star wars test suite", {

  "
  query HeroNameQuery {
    hero {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "hero": {
          "name": "R2-D2"
        }
      }'
    )


  "
  {
    hero {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "hero": {
          "name": "R2-D2"
        }
      }'
    )


  "
  query HeroNameAndFriendsQuery {
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
    expect_starwars_match(
      '{
        "hero": {
          "id": "2001",
          "name": "R2-D2",
          "friends": [
            {
              "id": "1000",
              "name": "Luke Skywalker"
            },
            {
              "id": "1002",
              "name": "Han Solo"
            },
            {
              "id": "1003",
              "name": "Leia Organa"
            }
          ]
        }
      }'
    )


  "
  query NestedQuery {
    hero {
      name
      friends {
        name
        appearsIn
        friends {
          name
        }
      }
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "hero": {
          "name": "R2-D2",
          "friends": [
            {
              "name": "Luke Skywalker",
              "appearsIn": [ "NEWHOPE", "EMPIRE", "JEDI" ],
              "friends": [
                { "name": "Han Solo" },
                { "name": "Leia Organa" },
                { "name": "C-3PO" },
                { "name": "R2-D2" }
              ]
            },
            {
              "name": "Han Solo",
              "appearsIn": [ "NEWHOPE", "EMPIRE", "JEDI" ],
              "friends": [
                { "name": "Luke Skywalker" },
                { "name": "Leia Organa" },
                { "name": "R2-D2" }
              ]
            },
            {
              "name": "Leia Organa",
              "appearsIn": [ "NEWHOPE", "EMPIRE", "JEDI" ],
              "friends": [
                { "name": "Luke Skywalker" },
                { "name": "Han Solo" },
                { "name": "C-3PO" },
                { "name": "R2-D2" }
              ]
            }
          ]
        }
      }'
    )


  "
  query FetchLukeQuery {
    human(id: \"1000\") {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "human": {
          "name": "Luke Skywalker"
        }
      }'
    )

  "
  query FetchSomeIDQuery($someId: String!) {
    human(id: $someId) {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "human": {
          "name": "Luke Skywalker"
        }
      }',
      variable_values = list(
        someId = "1000"
      )
    )


  "
  query FetchLukeAliased {
    luke: human(id: \"1000\") {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "luke": {
          "name": "Luke Skywalker"
        }
      }'
    )


  "
  query FetchLukeAndLeiaAliased {
    luke: human(id: \"1000\") {
      name
    }
    leia: human(id: \"1003\") {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "luke": {
          "name": "Luke Skywalker"
        },
        "leia": {
          "name": "Leia Organa"
        }
      }'
    )


  "
  query UseFragment {
    luke: human(id: \"1000\") {
      ...HumanFragment
    }
    leia: human(id: \"1003\") {
      ...HumanFragment
    }
  }
  fragment HumanFragment on Human {
    name
    homePlanet
  }
  " %>%
    expect_starwars_match(
      '{
        "luke": {
          "name": "Luke Skywalker",
          "homePlanet": "Tatooine"
        },
        "leia": {
          "name": "Leia Organa",
          "homePlanet": "Alderaan"
        }
      }'
    )


  "
  query CheckTypeOfR2 {
    hero {
      __typename
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "hero": {
          "__typename": "Droid",
          "name": "R2-D2"
        }
      }'
    )


  "
  query CheckTypeOfLuke {
    hero(episode: EMPIRE) {
      __typename
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "hero": {
          "__typename": "Human",
          "name": "Luke Skywalker"
        }
      }'
    )


})
