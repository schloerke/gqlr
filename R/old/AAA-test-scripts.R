
if (FALSE) {

  # load_all(); source("tests/testthat/dog_cat_schema.R"); query %>% graphql2obj() %>% validate_query(dog_cat_schema) %>% str()

  load_all(); test_obj("simple-query") %>% str()

  load_all(); test_obj("kitchen-query") %>% str()

  load_all(); test_obj("kitchen-query") %>% str(maxLevel = 2)

  # load_all(); test_obj("simple-schema") %>% str()
  # load_all(); test_obj("kitchen-schema") %>% str()

  # load_all(); test_obj("film-schema") %>% str()
  load_all(); test_obj("film-query") %>% str()



  # a <- SchemaDefinition$new(
  #   operationTypes = list(
  #     OperationTypeDefinition$new(operation = )
  # )






# # Uptopia definition
#
#
# filmSchemaTxt = "\nscalar Date\n\n  type Person {\n    name: String\n    films: [Film]\n  }\n\n  type Film {\n    title: String,\n    producers: [String]\n    characters(limit: Int): [Person]\n    release_date: Date\n  }\n\n  type Query {\n    film(id: Int): Film\n    person(id: Int): Person\n  }\n"
# filmFnList = list(
#   Date = list(
#     serialize = function(dateObj, args) {
#       format(dateObj, "%a %b %d %H:%M:%S %Y")
#     }
#   ),
#   Person = list(
#     films = function(personObj, args) {
#       loaders.film.loadMany(person.films)
#     }
#   ),
#   Film = list(
#     producers = function(filmObj, args) {
#       filmObj$producer %>%
#         strsplit(",")[[1]]
#     },
#     characters = function(film, args) {
#       ret <- film$characters
#       if (!is.null(args$limit)) {
#         limit <- args$limit
#         if ((length(ret) > limit) & (limit > 0)) {
#           ret <- ret[1:floor(limit)]
#         }
#       }
#       loaders.person.loadMany(ret)
#     }
#   ),
#   Query = list(
#     film = function(queryObj, args) {
#       loaders.film.load(args$id)
#     },
#     person = function(queryObj, args) {
#       loaders.person.load(args.id)
#     }
#   )
# )
#
# load_all(); filmSchemaTxt %>% graphql2obj() %>% str()
#
# schemaObj <- SchemaObj$new(text = filmSchemaTxt, fnList = filmFnList)
#
# schemaObj <- Schema$new(documentObj = filmSchemaTxt, fnList = filmFnList)





} # end FALSE
