# Taken directly from https://github.com/graphql/graphql-js/blob/master/src/__tests__/
# and updated to be used within R.  'Promise's were removed


# /**
#  *  Copyright (c) 2015, Facebook, Inc.
#  *  All rights reserved.
#  *
#  *  This source code is licensed under the BSD-style license found in the
#  *  LICENSE file in the root directory of this source tree. An additional grant
#  *  of patent rights can be found in the PATENTS file in the same directory.
#  */

# import { expect } from 'chai';
# import { describe, it } from 'mocha';
# import { StarWarsSchema } from './starWarsSchema.js';
# import { graphql } from '../graphql';

# // 80+ char lines are useful in describe/it, so ignore in this file.
# /* eslint-disable max-len */

check_if_equal <- function(query, expected, ...) {
  result = graphql(StarWarsSchema, query, ...)
  expect_equal(result, expected)
}


context("Star Wars Query Tests - Basic Queries")

test_that('Correctly identifies R2-D2 as the hero of the Star Wars Saga', {
  query <- "query HeroNameQuery {
      hero {
        name
      }
    }
  "
  expected <- list(
    hero = list(name = 'R2-D2')
  )
  check_if_equal(query, expected)
});

test_that('Allows us to query for the ID and friends of R2-D2', {
  query <- "
    query HeroNameAndFriendsQuery {
      hero {
        id
        name
        friends {
          name
        }
      }
    }"

  expected <- list(
    hero = list(
      id = '2001',
      name = 'R2-D2',
      friends = list(
        list(name = 'Luke Skywalker'),
        list(name = 'Han Solo'),
        list(name = 'Leia Organa')
      )
    )
  )
  check_if_equal(query, expected)
});

context("Star Wars Query Tests - Nested Queries")
test_that('Allows us to query for the friends of friends of R2-D2', {
  query <- "
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
  "

  expected <- list(
    hero = list(
      name = 'R2-D2',
      friends = list(
        list(
          name = 'Luke Skywalker',
          appearsIn = list( 'NEWHOPE', 'EMPIRE', 'JEDI'),
          friends = list(
            list(name = 'Han Solo'),
            list(name = 'Leia Organa'),
            list(name = 'C-3PO'),
            list(name = 'R2-D2')
          )
        ),
        list(
          name = 'Han Solo',
          appearsIn = list('NEWHOPE', 'EMPIRE', 'JEDI'),
          friends = list(
            list(name = 'Luke Skywalker'),
            list(name = 'Leia Organa'),
            list(name = 'R2-D2')
          )
        ),
        list(
          name = 'Leia Organa',
          appearsIn = list('NEWHOPE', 'EMPIRE', 'JEDI'),
          friends = list(
            list(name = 'Luke Skywalker'),
            list(name = 'Han Solo'),
            list(name = 'C-3PO'),
            list(name = 'R2-D2')
          )
        )
      )
    )
  )

  check_if_equal(query, expected)
})

context('Star Wars Query Tests - Using IDs and query parameters to refetch objects')

test_that('Allows us to query for Luke Skywalker directly, using his ID', {
  query <- "
    query FetchLukeQuery {
      human(id: \"1000\") {
        name
      }
    }
  ";
  expected <- list(human = list(name = 'Luke Skywalker'))
  check_if_equal(query, expected)
});

test_that('Allows us to create a generic query, then use it to fetch Luke Skywalker using his ID', {
  query <- "
    query FetchSomeIDQuery($someId: String!) {
      human(id: $someId) {
        name
      }
    }
  "
  params <- list(someId = '1000')
  expected <- list(human = list(name = 'Luke Skywalker'))
  check_if_equal(query, expected, params = params)
});

test_that('Allows us to create a generic query, then use it to fetch Han Solo using his ID', {
  query <- "
    query FetchSomeIDQuery($someId: String!) {
      human(id: $someId) {
        name
      }
    }
  "
  params <- list(someId = '1002')
  expected <- list(human = list(name = 'Han Solo'))
  check_if_equal(query, expected, params = params)
});

test_that('Allows us to create a generic query, then pass an invalid ID to get null back', {
  query <- "
    query humanQuery($id: String!) {
      human(id: $id) {
        name
      }
    }
  ";
  params <- list(id = 'not a valid id')
  expected <- list(human = NULL)
  check_if_equal(query, expected, params = params)
});

context('Star Wars Query Tests - Using aliases to change the key in the response')
test_that('Allows us to query for Luke, changing his key with an alias', {
  query <- "
    query FetchLukeAliased {
      luke: human(id: \"1000\") {
        name
      }
    }
  "
  expected <- list(luke = list(name = 'Luke Skywalker'))
  check_if_equal(query, expected)
});

test_that('Allows us to query for both Luke and Leia, using two root fields and an alias', {
  query <- "
    query FetchLukeAndLeiaAliased {
      luke: human(id: \"1000\") {
        name
      }
      leia: human(id: \"1003\") {
        name
      }
    }
  ";
  expected <- list(
    luke = list(name = 'Luke Skywalker'),
    leia = list(name = 'Leia Organa')
  )
  check_if_equal(query, expected)
});

context('Star Wars Query Tests - Uses fragments to express more complex queries')
test_that('Allows us to query using duplicated content', {
  query <- "
    query DuplicateFields {
      luke: human(id: \"1000\") {
        name
        homePlanet
      }
      leia: human(id: \"1003\") {
        name
        homePlanet
      }
    }
  "
  expected <- list(
    luke = list(name = 'Luke Skywalker', homePlanet = 'Tatooine'),
    leia = list(name = 'Leia Organa', homePlanet = 'Alderaan')
  )
  check_if_equal(query, expected)
})

test_that('Allows us to use a fragment to avoid duplicating content', {
  query <- "
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
  "
  expected <- list(
    luke = list(name = 'Luke Skywalker', homePlanet = 'Tatooine'),
    leia = list(name = 'Leia Organa', homePlanet = 'Alderaan')
  )
  check_if_equal(query, expected)
})


context('Star Wars Query Tests - Using __typename to find the type of an object')
test_that('Allows us to verify that R2-D2 is a droid', {
  query <- "
    query CheckTypeOfR2 {
      hero {
        __typename
        name
      }
    }
  ";
  expected <- list(
    hero = list("__typename" = 'Droid', name = 'R2-D2')
  )
  check_if_equal(query, expected)
})

test_that('Allows us to verify that Luke is a human', {
  query <- "
    query CheckTypeOfLuke {
      hero(episode: EMPIRE) {
        __typename
        name
      }
    }
  ";
  expected <- list(
    hero = list("__typename" = 'Human', name = 'Luke Skywalker')
  )
  check_if_equal(query, expected)
});
