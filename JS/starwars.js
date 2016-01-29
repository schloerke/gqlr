// # Taken directly from https://github.com/graphql/graphql-js/blob/master/src/__tests__/
// # and updated to be used within R.  'Promise's were removed
//
// # import { getFriends, getHero, getHuman, getDroid } from './starWarsData.js';

/**
* This is designed to be an end-to-end test, demonstrating
* the full GraphQL stack.
*
* We will create a GraphQL schema that describes the major
* characters in the original Star Wars trilogy.
*
* NOTE: This may contain spoilers for the original Star
* Wars trilogy.
*/
require("babel-polyfill");

var Schema = require('graph.ql');


var query_fn = Schema(`
  enum Episode { NEWHOPE, EMPIRE, JEDI }

  interface Character {
   id: String!
   name: String
   friends: [Character]
   appearsIn: [Episode]
  }

  type Human implements Character {
   id: String!
   name: String
   friends: [Character]
   appearsIn: [Episode]
   homePlanet: String
  }

  type Droid implements Character {
   id: String!
   name: String
   friends: [Character]
   appearsIn: [Episode]
   primaryFunction: String
  }

  type Query {
   hero(episode: Episode): Character
   human(id: String!): Human
   droid(id: String!): Droid
  }
`, {
  Character: {
    resolveType(character) {
      // if (getHuman(character$id)) {
      //   humanType
      // } else {
      //   droidType
      // }
      return console.r.call("gqlr_retrieve_star", {type: "Character", fn: "resolveType", obj: character, args: {}})
    }
  },
  Human: {
    friends(human) {
      // getFriends(human)
      return console.r.call("gqlr_retrieve_star", {type: "Human", fn: "friends", obj: human, args: {}})
    },
  },
  Droid: {
    friends(droid) {
      //  = droid => getFriends(droid)
      return console.r.call("gqlr_retrieve_star", {type: "Droid", fn: "resolve", obj: droid, args: {}})
    }
  },
  Query: {
    hero(base, args) {
      // resolve = (root, { episode }) => getHero(episode),
      return console.r.call("gqlr_retrieve_star", {type: "Query", fn: "hero", obj: base, args: args})
    },
    human(base, args) {
      // resolve = (root, { id }) => getHuman(id),
      return console.r.call("gqlr_retrieve_star", {type: "Query", fn: "human", obj: base, args: args})
    },
    droid(base, args) {
      // resolve = (root, { id }) => getDroid(id),
      return console.r.call("gqlr_retrieve_star", {type: "Query", fn: "droid", obj: base, args: args})
    }
  }
});

window.query_fn = query_fn;

var testQuery = `
    query HeroNameQuery {
      hero {
        name
      }
    }
  `
window.testQuery = testQuery;

// window.res = (async function() {
//   // .then(res => console.log(res.data))
//   let res = await query_fn(testQuery)
//   console.log("Yey, story successfully loaded!");
//   return res
// }());

window.res = query_fn(testQuery).then(
  function(res) {
    console.log("result data!")
    console.log(res.data)
  }
).catch(
  function(err) {
  console.log(err)
  }
)




import { Source, parse } from "graphql/language";
import { validate } from 'graphql/validation'; // ES6
import { execute } from 'graphql/execution'; // ES6


import {
  graphql,
  GraphQLSchema,
  GraphQLObjectType,
  GraphQLString
} from 'graphql';


var schema = new GraphQLSchema({
  query: new GraphQLObjectType({
    name: 'RootQueryType',
    fields: {
      hello: {
        type: GraphQLString,
        resolve() {
          return 'world';
        }
      }
    }
  })
});

var gql_test = function() {
  var query = '{ hello }';

  console.log("started")
  var res = graphql(schema, query).then(result => {
    // Prints
    // {
    //   data: { hello: "world" }
    // }
    console.log("returning")
    console.log(result);

  });
  console.log("started")
  return res;
}

window.schema = schema;
window.gql_test = gql_test;


window.gql_test_async = async function() {
  var query = '{ hello }';

  console.log("started")
  var result = await graphql(schema, query);
  console.log("ended")
  return result;
}

window.gql_test_fn = function() {

  const requestString = '{ hello }';
  const rootValue = undefined;
  const variableValues = undefined;
  const operationName = undefined;

  const source = new Source(requestString || '', 'GraphQL request');
  const documentAST = parse(source);
  const validationErrors = validate(schema, documentAST);

  if (validationErrors.length > 0) {
    throw JSON.stringify({ errors: validationErrors });
  }

  console.log("start execute")
  var res = execute(
    schema,
    documentAST,
    rootValue,
    variableValues,
    operationName
  )
  console.log("end execute")

  return res;

}



window.run_test_query = function() {

  var result = (async function() {
    // .then(res => console.log(res.data))
    console.log("calling query_fn!");
    let res = await query_fn(testQuery)
    console.log("Yey, story successfully loaded!");
    return res
  }());

  // var result = query_fn(testQuery).resolve();

  // const source = new Source(requestString || '', 'GraphQL request');
  //   const documentAST = parse(source);
  //   const validationErrors = validate(schema, documentAST);
  //   if (validationErrors.length > 0) {
  //     resolve({ errors: validationErrors });
  //   } else {
  //     resolve(
  //       execute(
  //         schema,
  //         documentAST,
  //         rootValue,
  //         variableValues,
  //         operationName
  //       )
  //     );
  //   }

  return result;
}

window.run_test_query_json = function() {
  JSON.stringify(window.run_test_query())
}




