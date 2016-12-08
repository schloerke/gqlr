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

if (FALSE) {

context('Star Wars Introspection Tests - Basic Introspection')

check_if_equal <- function(query, expected, ...) {
  result = graphql(StarWarsSchema, query)
  expect_equal(result, expected, ...)
}

test_that('Allows querying the schema for types', {
  query <- "
    query IntrospectionTypeQuery {
      __schema {
        types {
          name
        }
      }
    }
  "
  expected <- list(
    "__schema" = list(
      types = list(
        list(name = 'Query'),
        list(name = 'Episode'),
        list(name = 'Character'),
        list(name = 'Human'),
        list(name = 'String'),
        list(name = 'Droid'),
        list(name = '__Schema'),
        list(name = '__Type'),
        list(name = '__TypeKind'),
        list(name = 'Boolean'),
        list(name = '__Field'),
        list(name = '__InputValue'),
        list(name = '__EnumValue'),
        list(name = '__Directive')
      )
    )
  )

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for query type', {
  query <- "
    query IntrospectionQueryTypeQuery {
      __schema {
        queryType {
          name
        }
      }
    }
  "
  expected <- list("__schema" = list(queryType = list(name = 'Query')))

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for a specific type', {
  query <- "
    query IntrospectionDroidTypeQuery {
      __type(name: \"Droid\") {
        name
      }
    }
  "
  expected <- list("__type" = list(name = 'Droid'))

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for an object kind', {
  query <- "
    query IntrospectionDroidKindQuery {
      __type(name: \"Droid\") {
        name
        kind
      }
    }
  "
  expected <- list("__type" = list(name = 'Droid', kind = 'OBJECT'))

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for an interface kind', {
  query <- "
    query IntrospectionCharacterKindQuery {
      __type(name: \"Character\") {
        name
        kind
      }
    }
  "
  expected <- list("__type" = list(name = 'Character', kind = 'INTERFACE'))

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for object fields', {
  query <- "
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
  "

  expected <- list(
    "__type" = list(
      name = 'Droid',
      fields = list(
        list(name = 'id', type = list(name = NULL, kind = 'NON_NULL')),
        list(name = 'name', type = list(name = 'String', kind = 'SCALAR')),
        list(name = 'friends', type = list(name = NULL, kind = 'LIST')),
        list(name = 'appearsIn', type = list(name = NULL, kind = 'LIST')),
        list(name = 'primaryFunction', type = list(name = 'String', kind = 'SCALAR'))
      )
    )
  )

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for nested object fields', {
  query <- "
    query IntrospectionDroidNestedFieldsQuery {
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
  "

  expected <- list(
    "__type" = list(
      name = 'Droid',
      fields = list(
        list(
          name = 'id',
          type = list(
            name = NULL,
            kind = 'NON_NULL',
            ofType = list(name = 'String', kind = 'SCALAR')
          )
        ),
        list(
          name = 'name',
          type = list(name = 'String', kind = 'SCALAR', ofType = NULL
          )
        ),
        list(
          name = 'friends',
          type = list(
            name = NULL,
            kind = 'LIST',
            ofType = list(name = 'Character', kind = 'INTERFACE')
          )
        ),
        list(
          name = 'appearsIn',
          type = list(
            name = NULL,
            kind = 'LIST',
            ofType = list(name = 'Episode', kind = 'ENUM')
          )
        ),
        list(
          name = 'primaryFunction',
          type = list(name = 'String', kind = 'SCALAR', ofType = NULL)
        )
      )
    )
  )

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for field args', {
  query <- "
    query IntrospectionQueryTypeQuery {
      __schema {
        queryType {
          fields {
            name
            args {
              name
              description
              type {
                name
                kind
                ofType {
                  name
                  kind
                }
              }
              defaultValue
            }
          }
        }
      }
    }
  "

  expected <- list(
    "__schema" = list(
      queryType = list(
        fields = list(
          list(
            name = 'hero',
            args = list(
              list(
                defaultValue = NULL,
                description = paste0('If omitted, returns the hero of the whole ',
                             'saga. If provided, returns the hero of ',
                             'that particular episode.'),
                name = 'episode',
                type = list(
                  kind = 'ENUM',
                  name = 'Episode',
                  ofType = NULL
                )
              )
            )
          ),
          list(
            name = 'human',
            args = list(
              list(
                name = 'id',
                description = 'id of the human',
                type = list(
                  kind = 'NON_NULL',
                  name = NULL,
                  ofType = list(kind = 'SCALAR', name = 'String')
                ),
                defaultValue = NULL
              )
            )
          ),
          list(
            name = 'droid',
            args = list(
              list(
                name = 'id',
                description = 'id of the droid',
                type = list(
                  kind = 'NON_NULL',
                  name = NULL,
                  ofType = list(kind = 'SCALAR', name = 'String')
                ),
                defaultValue = NULL
              )
            )
          )
        )
      )
    )
  )

  check_if_equal(query, expected)
})

test_that('Allows querying the schema for documentation', {
  query <- "
    query IntrospectionDroidDescriptionQuery {
      __type(name: \"Droid\") {
        name
        description
      }
    }
  "

  expected <- list(
    "__type" = list(
      name = 'Droid',
      description = 'A mechanical creature in the Star Wars universe.'
    )
  )

  check_if_equal(query, expected)
})


}
