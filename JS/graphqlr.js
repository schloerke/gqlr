
// (function() {
//   graphqlLanguage = require('graphql/language');
//
//   var stringify = function(str) {
//     obj = graphqlLanguage.parse(str, {noLocation: true, noSource: true});
//     // obj.loc.source.body = "__body_removed__"
//     return JSON.stringify(obj);
//   }
//
//   var test_R = function() {
//     return R.parseEval("rnorm(10)");
//   }
//
//
//   window.graphqlLanguage = graphqlLanguage;
//   window.stringify = stringify;
// })()

(function() {

  var Schema = require('graph.ql')

  // an object of promises that fetch actual data
  var loaders = require('./loaders')

  // create the schema
  var schema = Schema(`
    scalar Date

    type Person {
      name: String
      films: [Film]
    }

    type Film {
      title: String,
      producers(): [String]
      characters(limit: Int): [Person]
      release_date: Date
    }

    type Query {
      film(id: Int): Film
      person(id: Int): Person
    }
  `, {
    Date: {
      serialize(date) {
        return console.r.call("gqlr_retrieve", {type: "Date", fn: "serialize", obj: date, args: {}})
        // return new Date(date)
      }
    },
    Person: {
      films(person) {
        return console.r.call("gqlr_retrieve", {type: "Person", fn: "films", obj: person, args: {}})
        // return loaders.film.loadMany(person.films)
      }
    },
    Film: {
      producers(film) {
        return console.r.call("gqlr_retrieve", {type: "Film", fn: "producers", obj: film, args: {}})
        // return film.producer.split(',')
      },
      characters(film, args) {
        return console.r.call("gqlr_retrieve", {type: "Film", fn: "characters", obj: film, args: args})
        // var characters = args.limit
        //   ? film.characters.slice(0, args.limit)
        //   : film.characters
        //
        // return loaders.person.loadMany(characters)
      }
    },
    Query: {
      film(query, args) {
        return console.r.call("gqlr_retrieve", {type: "Query", fn: "film", obj: query, args: args})
        // return loaders.film.load(args.id)
      },
      person(query, args) {
        return console.r.call("gqlr_retrieve", {type: "Query", fn: "person", obj: query, args: args})
        // return loaders.person.load(args.id)
      }
    },
  })

  // use the schema
  schema(`
    query fetch_film($id: Int) {
      film(id: $id) {
        title
        producers
        release_date
        characters {
          name
          films {
            title
          }
        }
      }
    }
  `, {
    id: 1
  }).then(res => console.log(res.data))

})()
