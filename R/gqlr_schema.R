#' @include graphql_json.R





#' @title Create Schema definitions
#'
#' @description Creates a Schema object from the defined GraphQL string and inserts the provided descriptions, resolve methods, resolve_type methods into the appropriate place.
#'
#' @param schema GraphQL schema string or Schema object
#' @param ... named lists of information to help produce the schema definition.  See Details
#' @section Details:
#' The ... should be named arguments whose values are lists of information.  What information is needed for each type is described below.
#'
#' ScalarTypeDefinition:
#' \describe{
#'   \item{resolve}{function with two parameters: \code{x} (the raw to be parsed, such as 5.0) and \code{schema} (the full Schema definition). Should return a parsed value}
#'   \item{description}{(optional) single character value that describes the Scalar definition}
#'   \item{parse_ast}{(optional) function with two parameters: \code{obj} (a GraphQL wrapped raw value, such as an object of class IntValue with value 5) and \code{schema} (the full Schema definition).  If the function returns \code{NULL} then the AST could not be parsed.}
#' }
#'
#' EnumTypeDefinition:
#' \describe{
#'   \item{resolve}{(optional) function with two parameters: \code{x} and \code{schema} (the full Schema definition). Should return the value \code{x} represents, such as the Star Wars Episode enum value "4" could represent Episode "NEWHOPE". By default, EnumTypeDefinitions will return the current value.}
#'   \item{description}{(optional) single character value that describes the Enum definition}
#'   \item{values}{(optional) named list of enum value descriptions. Such as \code{values = list(ENUMA = "description for ENUMA", ENUMZ = "description for ENUMZ")}}
#' }
#'
#' ObjectTypeDefinition:
#' \describe{
#'   \item{resolve}{function with two parameters: \code{x} (place holder value to be expanded into a named list) and \code{schema} (the full Schema definition). By using the resolve method, recursive relationships, such as friends, can easily be handled.  The resolve function should return a fully named list of all the fields the definition defines.  Missing fields are automatically interpreted as \code{NULL}.
#'
#'   Values in the returned list may be a function of the form \code{function(obj, args, schema){...}}.  This allows for fields to be determined dynamically and lazily. See how \code{add_human} makes a field for \code{totalCredits}, while the \code{add_droid} pre computes the information.}
#'   \item{description}{(optional) single character value that describes the object}
#'   \item{fields}{(optional) named list of field descriptions. Such as \code{fields = list(fieldA = "description for field A", fieldB = "description for field B")}}
#' }
#'
#' InterfaceTypeDefinition and UnionTypeDefinition:
#' \describe{
#'   \item{resolve_type}{function with two parameters: \code{x} (a pre-resolved object value) and \code{schema} (the full Schema definition). This function is required to determine which object type is being used. \code{resolve_type} is called before any ObjectTypeDefinition \code{resolve} methods are called.}
#'   \item{description}{(optional) single character value that describes the object}
#' }
#' @export
#' @examples
#' library(magrittr)
#'
#' ## Set up data
#' add_human <- function(human_data, id, name, appear, home, friend) {
#'   human <- list(id = id, name = name, appearsIn = appear, friends = friend, homePlanet = home)
#'   # set up a function to be calculated if the field totalCredits is required
#'   human$totalCredits <- function(obj, args, schema) {
#'     length(human$appearsIn)
#'   }
#'   human_data[[id]] <- human
#'   human_data
#' }
#' add_droid <- function(droid_data, id, name, appear, pf, friend) {
#'   droid <- list(id = id, name = name, appearsIn = appear, friends = friend, primaryFunction = pf)
#'   # set extra fields manually
#'   droid$totalCredits <- length(droid$appearsIn)
#'   droid_data[[id]] <- droid
#'   droid_data
#' }
#'
#' human_data <- list() %>%
#'   add_human("1000", "Luke Skywalker", c(4, 5, 6), "Tatooine", c("1002", "1003", "2000", "2001")) %>%
#'   add_human("1002", "Han Solo",       c(4, 5, 6), "Corellia", c("1000", "1003", "2001")) %>%
#'   add_human("1003", "Leia Organa",    c(4, 5, 6), "Alderaan", c("1000", "1002", "2000", "2001"))
#'
#' droid_data <- list() %>%
#'   add_droid("2000", "C-3PO", c(4, 5, 6), "Protocol", c("1000", "1002", "1003", "2001")) %>%
#'   add_droid("2001", "R2-D2", c(4, 5, 6), "Astromech", c("1000", "1002", "1003"))
#'
#' all_characters <- list() %>% append(human_data) %>% append(droid_data) %>% print()
#' ## End data set up
#'
#'
#'
#' # Define the schema using GraphQL code
#' star_wars_schema <- Schema$new()
#'
#' "
#' enum Episode { NEWHOPE, EMPIRE, JEDI }
#' " %>%
#'   gqlr_schema(
#'     Episode = list(
#'       resolve = function(episode_id, schema) {
#'         switch(as.character(episode_id),
#'           "4" = "NEWHOPE",
#'           "5" = "EMPIRE",
#'           "6" = "JEDI",
#'           "UNKNOWN_EPISODE"
#'         )
#'       }
#'     )
#'   ) ->
#' episode_schema
#' # display the schema
#' episode_schema$get_schema()
#' # add the episode definitions to the Star Wars schema
#' star_wars_schema$add(episode_schema)
#'
#'
#' "
#' interface Character {
#'   id: String!
#'   name: String
#'   friends: [Character]
#'   appearsIn: [Episode]
#' }
#' " %>%
#'   gqlr_schema(
#'     Character = list(
#'       resolve_type = function(id, schema) {
#'         if (id %in% names(droid_data)) {
#'           "Droid"
#'         } else {
#'           "Human"
#'         }
#'       }
#'     )
#'   ) ->
#' character_schema
#' # print the Character schema with no extra formatting
#' character_schema$get_schema() %>% format() %>% cat("\n")
#' star_wars_schema$add(character_schema)
#'
#'
#' "
#' type Droid implements Character {
#'   id: String!
#'   name: String
#'   friends: [Character]
#'   appearsIn: [Episode]
#'   primaryFunction: String
#' }
#' type Human implements Character {
#'   id: String!
#'   name: String
#'   friends: [Character]
#'   appearsIn: [Episode]
#'   homePlanet: String
#' }
#' " %>%
#'   gqlr_schema(
#'     Human = list(
#'       # Add a resolve method for type Human that takes in an id and returns the human data
#'       resolve = function(id, args, schema) {
#'         human_data[[id]]
#'       }
#'     ),
#'     Droid = list(
#'       # description for Droid
#'       description = "A mechanical creature in the Star Wars universe.",
#'       # Add a resolve method for type Droid that takes in an id and returns the droid data
#'       resolve = function(id, schema) {
#'         droid_data[[id]]
#'       }
#'     )
#'   ) ->
#' human_and_droid_schema
#' human_and_droid_schema$get_schema()
#' star_wars_schema$add(human_and_droid_schema)
#'
#'
#' "
#' type Query {
#'   hero(episode: Episode): Character
#'   human(id: String!): Human
#'   droid(id: String!): Droid
#' }
#' # the schema type must be provided if a query or mutation is to be executed
#' schema {
#'   query: Query
#' }
#' " %>%
#'   gqlr_schema(
#'     Query = function(null, schema) {
#'       list(
#'         # return a function for key 'hero'
#'         # the id will be resolved by the appropriate resolve() method of Droid or Human
#'         hero = function(obj, args, schema) {
#'           episode <- args$episode
#'           if (identical(episode, 5) || identical(episode, "EMPIRE")) {
#'             luke$id
#'           } else {
#'             artoo$id
#'           }
#'         },
#'         # the id will be resolved by the Human resolve() method
#'         human = function(obj, args, schema) {
#'           args$id
#'         },
#'         # the id will be resolved by the Droid resolve() method
#'         droid = function(obj, args, schema) {
#'           args$id
#'         }
#'       )
#'     }
#'   ) ->
#' schema_def
#' # print Schema with no extra formatting
#' schema_def$get_schema() %>% format() %>% cat("\n")
#' star_wars_schema$add(schema_def)
#'
#'
#' # view the final schema definitiion
#' star_wars_schema$get_schema()
gqlr_schema <- function(schema, ...) {
  schema <- Schema$new(schema)

  info_list <- list(...)

  if (length(info_list) > 0) {
    is_named_list(info_list, "gqlr_schema() extra arguments must be uniquely named arguments")

    for (item_name in names(info_list)) {
      item <- info_list[[item_name]]

      obj <- schema$get_type(item_name)
      if (is.null(obj)) {
        stop("gqlr_schema() could not find schema definition to match argument name: ", item_name)
      }
      item_type <- class(obj)[1]

      info_names <- names(item)
      if (!(
        is.function(item) ||
        is.list(item)
      )) {
        stop(
          "gqlr_schema() named arguments should either be a named list of information or a ",
          "function which will be set to the resolve function or resolve_type function accordingly"
        )
      }

      if (item_type == "ScalarTypeDefinition") {
        if (is.function(item)) {
          item <- list(resolve = item)
        } else {
          is_ok <- all(
            info_names %in% c("description", "resolve", "parse_ast")
          )
          if (!is_ok) {
            stop(
              "gqlr_schema() argument: ", item_name,
              " of type: ScalarTypeDefinition,",
              " should be a 'resolve' function or",
              " a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tresolve: function(obj, schema)\n",
              "\tparse_ast: function(obj, schema)\n"
            )
          }
        }

      } else if (item_type == "ObjectTypeDefinition") {
        if (is.function(item)) {
          item <- list(resolve = item)
        } else {
          is_ok <- all(info_names %in% c("description", "fields", "resolve"))
          if (!is_ok) {
            stop(
              "gqlr_schema() argument: ", item_name,
              " of type: ObjectTypeDefinition,",
              " should be a 'resolve' function or",
              " a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tfields: list(fieldA = descriptionA, fieldB = descriptionB...)\n",
              "\tresolve: function(obj, schema)\n"
            )
          }
        }

      } else if (item_type == "EnumTypeDefinition") {
        if (is.function(item)) {
          item <- list(resolve = item)
        } else {
          is_ok <- all(
            info_names %in% c("description", "values", "resolve")
          )
          if (!is_ok) {
            stop(
              "gqlr_schema() argument: ", item_name,
              " of type: EnumTypeDefinition,",
              " should be a 'resolve' function or",
              " a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tvalues: list(enumA = descriptionA, enumB = descriptionB...)\n",
              "\tresolve: function(obj, schema)\n"
            )
          }
        }

      } else if (item_type == "InterfaceTypeDefinition" || item_type == "UnionTypeDefinition") {
        if (is.function(item)) {
          item <- list(resolve_type = item)
        } else {
          is_ok <- all(info_names %in% c("description", "resolve_type"))
          if (!is_ok) {
            stop(
              "gqlr_schema() argument: ", item_name,
              " of type: ,", item_type,
              " should be a 'resolve_type' function or",
              " a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tresolve_type: function(obj, schema)\n"
            )
          }
        }

      } else if (item_type == "InputObjectTypeDefinition") {
        if (is.function(item)) {
          stop(
            "gqlr_schema() argument: ", item_name,
            " of type: ,", item_type,
            " should be a list possibly containing these elements:\n",
            "\tdescription: String\n"
          )
        } else {
          is_ok <- all(info_names %in% c("description"))
          if (!is_ok) {
            stop(
              "gqlr_schema() argument: ", item_name,
              " of type: ,", item_type,
              " should be a list possibly containing these elements:\n",
              "\tdescription: String\n"
            )
          }
        }

      } else if (item_type == "DirectiveDefinition") {
        if (is.function(item)) {
          item <- list(resolve = item)
        } else {
          is_ok <- all(
            info_names %in% c("description", "resolve")
          )
          if (!is_ok) {
            stop(
              "gqlr_schema() argument: ", item_name,
              " of type: DirectiveDefinition,",
              " should be a 'resolve' function or",
              " a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tresolve: function(obj, schema)\n"
            )
          }
        }

      } else {
        str(obj)
        stop("unknown schema defintion provided to gqlr_schema()")
      }

      is_named_list(
        item,
        str_c("gqlr_schema() argument: '", item_name, "' must be uniquely named arguments")
      )

      for (info_name in names(item)) {
        store_name <- switch(info_name,
          "resolve" = ".resolve",
          "resolve_type" = ".resolve_type",
          "parse_ast" = ".parse_ast",
          "values" = "values",
          "fields" = "fields",
          "description" = "description"
        )

        if (store_name == "fields") {
          for (field_name in names(item$fields)) {
            field_name_obj <- as_type(field_name)
            obj_field <- obj$.get_field(field_name_obj)
            if (is.null(obj_field)) {
              stop("Could not find field: '", field_name, "' for Object: ", item_name)
            }
            obj_field$description <- item$fields[[field_name]]
          }

        } else if (store_name == "values") {
          for (value_name in names(item$values)) {
            found <- FALSE
            for (enum_val in obj$values) {
              if (format(enum_val$name) == value_name) {
                enum_val$description <- item$values[[value_name]]
                found <- TRUE
                break
              }
            }
            if (!found) {
              stop("Could not find value for Enum: ", item_name)
            }
          }

        } else {
          obj[[store_name]] <- item[[info_name]]
        }
      } # for each obj value
    } # for each item
  } # if items

  schema
}
