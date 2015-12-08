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
#
# import { expect } from 'chai';
# import { describe, it } from 'mocha';
# import { StarWarsSchema } from './starWarsSchema.js';
# import { Source } from '../language/source';
# import { parse } from '../language/parser';
# import { validate } from '../validation/validate';



# /**
#  * Helper function to test a query and the expected response.
#  */
hasValidationErrors <- function(query) {
  source = Source(query, 'StarWars.graphql');
  ast = parse(source);
  is.null(validate(StarWarsSchema, ast)$error) == TRUE
}

context('Star Wars Validation Tests - Basic Queries')

test_that('Validates a complex but valid query', {
  query <- "
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
  ";
  expect_equal(hasValidationErrors(query), TRUE)
})

test_that('Notes that non-existent fields are invalid', {
  query <- "
    query HeroSpaceshipQuery {
      hero {
        favoriteSpaceship
      }
    }
  ";
  expect_equal(hasValidationErrors(query), FALSE)
})

test_that('Requires fields on objects', {
  query <- "
    query HeroNoFieldsQuery {
      hero
    }
  "
  expect_equal(hasValidationErrors(query), TRUE);
})

test_that('Disallows fields on scalars', {
  query <- "
    query HeroFieldsOnScalarQuery {
      hero {
        name {
          firstCharacterOfName
        }
      }
    }
  "
  expect_equal(hasValidationErrors(query), TRUE);
})

test_that('Disallows object fields on interfaces', {
  query <- "
    query DroidFieldOnCharacter {
      hero {
        name
        primaryFunction
      }
    }
  "
  expect_equal(hasValidationErrors(query), TRUE)
})

test_that('Allows object fields in fragments', {
  query <- "
    query DroidFieldInFragment {
      hero {
        name
        ...DroidFields
      }
    }
    fragment DroidFields on Droid {
      primaryFunction
    }
  "
  expect_equal(hasValidationErrors(query), FALSE)
});

expect_equal('Allows object fields in inline fragments', {
  query <- "
    query DroidFieldInFragment {
      hero {
        name
        ... on Droid {
          primaryFunction
        }
      }
    }
  "
  expect_equal(hasValidationErrors(query), FALSE);
});
