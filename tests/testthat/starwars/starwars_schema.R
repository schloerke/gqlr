# Using our shorthand to describe type systems, the type system for our
# Star Wars example is:
"
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

schema {
  query: Query
  # mutation: Mutation
}
" %>%
  graphql2obj(fn_list = list(
    Droid = list(
      description = "A mechanical creature in the Star Wars universe."
    ),
    Character = list(
      .resolve_type = function(obj, schema_obj) {
        # cat("\n\n")
        # str(obj)
        # cat("\n\n")
        if (is_droid(obj)) {
          "Droid"
        } else {
          "Human"
        }
      }
    )
  )) ->
star_wars_doc

star_wars_schema <- GQLRSchema$new(star_wars_doc)


expect_starwars_match <- function(query_txt, expected_json, variable_values = list()) {
  expected_result <- to_json(list(data = from_json(expected_json)))

  oh <- ObjectHelpers$new(star_wars_schema)

  query_doc <- query_txt %>%
    graphql2obj() %>%
    validate_query(vh = oh)

  ans <- execute_request(
    query_doc,
    operation_name = NULL,
    variable_values = variable_values,
    initial_value = query_data,
    oh = oh
  )

   ans_json <- result2json(ans)

   ans_txt <- strsplit(ans_json, "\n")[[1]]
   expected_txt <- strsplit(expected_result, "\n")[[1]]

   if (length(ans_txt) != length(expected_txt)) {
     cat("\n\nans: \n")
     cat(ans_txt, sep = "\n")
     cat("\n\nexpected: \n")
     cat(expected_txt, sep = "\n")
    #  browser()
   }

   expect_equal(ans_txt, expected_txt)
}
