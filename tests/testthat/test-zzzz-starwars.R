

# testthat::test_file(file.path("tests", "testthat", "test-zzzz-starwars.R"))

context("star wars")

source(file.path("starwars", "starwars_schema.R"))
source(file.path("starwars", "starwars_data.R"))

expect_sw_err <- function(...) {
  expect_err(..., schema_obj = star_wars_schema)
}
expect_sw_r6 <- function(...) {
  expect_r6(..., schema_obj = star_wars_schema)
}


source("validate_helper.R")


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


  "
  query NestedQueryWithFragment {
    hero {
      ...NameAndAppearances
      friends {
        ...NameAndAppearances
        friends {
          ...NameAndAppearances
        }
      }
    }
  }
  fragment NameAndAppearances on Character {
    name
    appearsIn
  }
  " %>%
    expect_starwars_match(
      '{"hero":
        {"name": "R2-D2","appearsIn": ["NEWHOPE","EMPIRE","JEDI"],"friends":[
          {"name":"Luke Skywalker","appearsIn":["NEWHOPE","EMPIRE","JEDI"],"friends":[
            {"name":"Han Solo","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"Leia Organa","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"C-3PO","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"R2-D2","appearsIn":["NEWHOPE","EMPIRE","JEDI"]}
          ]},
          {"name":"Han Solo","appearsIn":["NEWHOPE","EMPIRE","JEDI"],"friends":[
            {"name":"Luke Skywalker","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"Leia Organa","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"R2-D2","appearsIn":["NEWHOPE","EMPIRE","JEDI"]}
          ]},
          {"name":"Leia Organa","appearsIn":["NEWHOPE","EMPIRE","JEDI"],"friends":[
            {"name":"Luke Skywalker","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"Han Solo","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"C-3PO","appearsIn":["NEWHOPE","EMPIRE","JEDI"]},
            {"name":"R2-D2","appearsIn":["NEWHOPE","EMPIRE","JEDI"]}
          ]}
        ]}
      }'
    )

  "
  query humanQuery($id: String!) {
    human(id: $id) {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "human": null
      }',
      variable_values = list(id = "not valid id")
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

})


test_that("validation", {


  "
  # INVALID: favoriteSpaceship does not exist on Character
  query HeroSpaceshipQuery {
    hero {
      favoriteSpaceship
    }
  }
  " %>%
    expect_sw_err("missing field: 'favoriteSpaceship' for object: 'Character'")

  "
  # INVALID: hero is not a scalar, so fields are needed
  query HeroNoFieldsQuery {
    hero
  }
  " %>%
    expect_sw_err("Missing children fields for field: 'hero'")

  "
  # INVALID: name is a scalar, so fields are not permitted
  query HeroFieldsOnScalarQuery {
    hero {
      name {
        firstCharacterOfName
      }
    }
  }
  " %>%
    expect_sw_err("Not allowed to query deeper into leaf field selections")

  "
  # INVALID: primaryFunction does not exist on Character
  query DroidFieldOnCharacter {
    hero {
      name
      primaryFunction
    }
  }
  " %>%
    expect_sw_err("missing field: 'primaryFunction' for object: 'Character'")

  "
  query DroidFieldInFragment {
    hero {
      name
      ...DroidFields
    }
  }
  fragment DroidFields on Droid {
    primaryFunction
  }
  " %>%
    expect_sw_r6()

  "
  query DroidFieldInInlineFragment {
    hero {
      name
      ... on Droid {
        primaryFunction
      }
    }
  }
  " %>%
    expect_sw_r6()
})




test_that("introspection", {

  "
  query IntrospectionTypeQuery {
    __schema {
      types {
        name
      }
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__schema": {
          "types": [
            {"name": "Int"},
            {"name": "Float"},
            {"name": "String"},
            {"name": "Boolean"},
            {"name": "__Schema"},
            {"name": "__Type"},
            {"name": "__Field"},
            {"name": "__InputValue"},
            {"name": "__EnumValue"},
            {"name": "__Directive"},
            {"name": "Human"},
            {"name": "Droid"},
            {"name": "Query"},
            {"name": "Character"},
            {"name": "__TypeKind"},
            {"name": "__DirectiveLocation"},
            {"name": "Episode"}
          ]
        }
      }'
    )

  "
  query IntrospectionQueryTypeQuery {
    __schema {
      queryType {
        name
      }
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__schema": {
          "queryType": {"name": "Query"}
        }
      }'
    )

  "
  query IntrospectionDroidTypeQuery {
    __type(name: \"Droid\") {
      name
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__type": {
          "name": "Droid"
        }
      }'
    )

  "
  query IntrospectionDroidKindQuery {
    __type(name: \"Droid\") {
      name
      kind
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__type": {
          "name": "Droid",
          "kind": "OBJECT"
        }
      }'
    )

  "
  query IntrospectionCharacterKindQuery {
    __type(name: \"Character\") {
      name
      kind
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__type": {
          "name": "Character",
          "kind": "INTERFACE"
        }
      }'
    )

  "
  query IntrospectionDroidFieldsQuery {
    __type(name: \"Droid\") {
      name
      fields {
        name
        type {
          name
          kind
        }
      }
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__type": {
          "name": "Droid",
          "fields": [
            {"name": "id","type": {"name": null,"kind": "NON_NULL"}},
            {"name": "name","type": {"name": "String","kind": "SCALAR"}},
            {"name": "friends","type": {"name": null,"kind": "LIST"}},
            {"name": "appearsIn","type": {"name": null,"kind": "LIST"}},
            {"name": "primaryFunction","type": {"name": "String","kind": "SCALAR"}},
            {"name": "__typename","type": {"name": "String","kind": "SCALAR"}}
          ]
        }
      }'
    )

  "
  query IntrospectionDroidWrappedFieldsQuery {
    __type(name: \"Droid\") {
      name
      fields {
        name
        type {
          name
          kind
          ofType {
            name
            kind
          }
        }
      }
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__type": {
          "name": "Droid",
          "fields": [
            {
              "name": "id",
              "type": {"name": null,"kind": "NON_NULL","ofType": {"name": "String","kind": "SCALAR"}}
            },
            {
              "name": "name",
              "type": {"name": "String","kind": "SCALAR","ofType": null}
            },
            {
              "name": "friends",
              "type": {"name": null,"kind": "LIST","ofType": {"name": "Character","kind": "INTERFACE"}}
            },
            {
              "name": "appearsIn",
              "type": {"name": null,"kind": "LIST","ofType": {"name": "Episode","kind": "ENUM"}}
            },
            {
              "name": "primaryFunction",
              "type": {"name": "String","kind": "SCALAR","ofType": null}
            },
            {
              "name": "__typename",
              "type": {"name": "String","kind": "SCALAR","ofType": null}
            }
          ]
        }
      }'
    )

  "
  query IntrospectionDroidDescriptionQuery {
    __type(name: \"Droid\") {
      name
      description
    }
  }
  " %>%
    expect_starwars_match(
      '{
        "__type": {
          "name": "Droid",
          "description": "A mechanical creature in the Star Wars universe."
        }
      }'
    )


})
