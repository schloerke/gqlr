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

# import {
#   GraphQLEnumType,
#   GraphQLInterfaceType,
#   GraphQLObjectType,
#   GraphQLList,
#   GraphQLNonNull,
#   GraphQLSchema,
#   GraphQLString,
# } from '../type';

# import { getFriends, getHero, getHuman, getDroid } from './starWarsData.js';

# /**
#  * This is designed to be an end-to-end test, demonstrating
#  * the full GraphQL stack.
#  *
#  * We will create a GraphQL schema that describes the major
#  * characters in the original Star Wars trilogy.
#  *
#  * NOTE: This may contain spoilers for the original Star
#  * Wars trilogy.
#  */

# /**
#  * Using our shorthand to describe type systems, the type system for our
#  * Star Wars example is:
#  *
#  * enum Episode { NEWHOPE, EMPIRE, JEDI }
#  *
#  * interface Character {
#  *   id: String!
#  *   name: String
#  *   friends: [Character]
#  *   appearsIn: [Episode]
#  * }
#  *
#  * type Human : Character {
#  *   id: String!
#  *   name: String
#  *   friends: [Character]
#  *   appearsIn: [Episode]
#  *   homePlanet: String
#  * }
#  *
#  * type Droid : Character {
#  *   id: String!
#  *   name: String
#  *   friends: [Character]
#  *   appearsIn: [Episode]
#  *   primaryFunction: String
#  * }
#  *
#  * type Query {
#  *   hero(episode: Episode): Character
#  *   human(id: String!): Human
#  *   droid(id: String!): Droid
#  * }
#  *
#  * We begin by setting up our schema.
#  */

# /**
#  * The original trilogy consists of three movies.
#  *
#  * This implements the following type system shorthand:
#  *   enum Episode { NEWHOPE, EMPIRE, JEDI }
#  */
episodeEnum <- gql_enum_type(
  name = 'Episode',
  description = 'One of the films in the Star Wars Trilogy',
  values = list(
    NEWHOPE = list(
      value = 4,
      description = 'Released in 1977.'
    ),
    EMPIRE = list(
      value = 5,
      description = 'Released in 1980.'
    ),
    JEDI = list(
      value = 6,
      description = 'Released in 1983.'
    )
  )
);

# /**
#  * Characters in the Star Wars trilogy are either humans or droids.
#  *
#  * This implements the following type system shorthand:
#  *   interface Character {
#  *     id: String!
#  *     name: String
#  *     friends: [Character]
#  *     appearsIn: [Episode]
#  *   }
#  */
characterInterface = gql_interface_type(
  name = 'Character',
  description = 'A character in the Star Wars Trilogy',
  fields = list(
    id = list(
      type = new GraphQLNonNull(GraphQLString),
      description = 'The id of the character.'
    ),
    name = list(
      type = GraphQLString,
      description = 'The name of the character.'
    ),
    friends = list(
      type = new GraphQLList(characterInterface),
      description = 'The friends of the character, or an empty list if they ' +
                   'have none.'
    ),
    appearsIn = list(
      type = new GraphQLList(episodeEnum),
      description = 'Which movies they appear in.'
    ),
  ),
  resolveType = function(character) {
    if (getHuman(character$id)) {
      humanType
    } else {
      droidType
    }
  }
);

# /**
#  * We define our human type, which implements the character interface.
#  *
#  * This implements the following type system shorthand:
#  *   type Human : Character {
#  *     id: String!
#  *     name: String
#  *     friends: [Character]
#  *     appearsIn: [Episode]
#  *   }
#  */
humanType = gql_object_type(list(
  name = 'Human',
  description = 'A humanoid creature in the Star Wars universe.',
  fields = list(
    id = list(
      type = new GraphQLNonNull(GraphQLString),
      description = 'The id of the human.',
    },
    name = list(
      type = GraphQLString,
      description = 'The name of the human.',
    },
    friends = list(
      type = new GraphQLList(characterInterface),
      description = 'The friends of the human, or an empty list if they have none.',
      resolve = function(human){
        getFriends(human)
      }
    },
    appearsIn = list(
      type = new GraphQLList(episodeEnum),
      description = 'Which movies they appear in.',
    },
    homePlanet = list(
      type = GraphQLString,
      description = 'The home planet of the human, or null if unknown.',
    },
  }),
  interfaces = [ characterInterface ]
});

# /**
#  * The other type of character in Star Wars is a droid.
#  *
#  * This implements the following type system shorthand:
#  *   type Droid : Character {
#  *     id: String!
#  *     name: String
#  *     friends: [Character]
#  *     appearsIn: [Episode]
#  *     primaryFunction: String
#  *   }
#  */
var droidType = new GraphQLObjectType(list(
  name = 'Droid',
  description = 'A mechanical creature in the Star Wars universe.',
  fields = list(
    id: list(
      type = new GraphQLNonNull(GraphQLString),
      description = 'The id of the droid.',
    },
    name = list(
      type = GraphQLString,
      description = 'The name of the droid.',
    },
    friends = list(
      type = new GraphQLList(characterInterface),
      description = 'The friends of the droid, or an empty list if they ' +
                   'have none.',
      resolve = droid => getFriends(droid),
    },
    appearsIn = list(
      type = new GraphQLList(episodeEnum),
      description: 'Which movies they appear in.',
    },
    primaryFunction = list(
      type = GraphQLString,
      description = 'The primary function of the droid.',
    },
  }),
  interfaces = [ characterInterface ]
});

/**
 * This is the type that will be the root of our query, and the
 * entry point into our schema. It gives us the ability to fetch
 * objects by their IDs, as well as to fetch the undisputed hero
 * of the Star Wars trilogy, R2-D2, directly.
 *
 * This implements the following type system shorthand:
 *   type Query {
 *     hero(episode: Episode): Character
 *     human(id: String!): Human
 *     droid(id: String!): Droid
 *   }
 *
 */
var queryType = new GraphQLObjectType(list(
  name = 'Query',
  fields = list(
    hero: list(
      type = characterInterface,
      args = list(
        episode = list(
          description = 'If omitted, returns the hero of the whole saga. If ' +
                       'provided, returns the hero of that particular episode.',
          type = episodeEnum
        }
      },
      resolve = (root, { episode }) => getHero(episode),
    },
    human = list(
      type = humanType,
      args = list(
        id = list(
          description = 'id of the human',
          type = new GraphQLNonNull(GraphQLString)
        }
      },
      resolve = (root, { id }) => getHuman(id),
    },
    droid = list(
      type = droidType,
      args = list(
        id = list(
          description = 'id of the droid',
          type = new GraphQLNonNull(GraphQLString)
        }
      },
      resolve = (root, { id }) => getDroid(id),
    },
  })
});

# /**
#  * Finally, we construct our schema (whose starting query type is the query
#  * type we defined above) and export it.
#  */
StarWarsSchema = new GraphQLSchema(list(
  query = queryType
));
