
if (FALSE) {

  load_all(); test_json("simple-query") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("kitchen-query") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("kitchen-query") %>% r6_from_list() %>% gqlr_str(maxLevel = 2)

  load_all(); test_json("simple-schema") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("kitchen-schema") %>% r6_from_list() %>% gqlr_str()

  load_all(); test_json("film-schema") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("film-query") %>% r6_from_list() %>% gqlr_str()


filmSchemaTxt = "\nscalar Date\n\n  type Person {\n    name: String\n    films: [Film]\n  }\n\n  type Film {\n    title: String,\n    producers: [String]\n    characters(limit: Int): [Person]\n    release_date: Date\n  }\n\n  type Query {\n    film(id: Int): Film\n    person(id: Int): Person\n  }\n"
filmFnList = list(
  Date = list(
    serialize = function(dateObj, args) {
      format(dateObj, "%a %b %d %H:%M:%S %Y")
    }
  ),
  Person = list(
    films = function(personObj, args) {
      loaders.film.loadMany(person.films)
    }
  ),
  Film = list(
    producers = function(filmObj, args) {
      filmObj$producer %>%
        strsplit(",")[[1]]
    },
    characters = function(film, args) {
      ret <- film$characters
      if (!is.null(args$limit)) {
        limit <- args$limit
        if ((length(ret) > limit) & (limit > 0)) {
          ret <- ret[1:floor(limit)]
        }
      }
      loaders.person.loadMany(ret)
    }
  ),
  Query = list(
    film = function(queryObj, args) {
      loaders.film.load(args$id)
    },
    person = function(queryObj, args) {
      loaders.person.load(args.id)
    }
  )
)

load_all(); filmSchemaTxt %>% eval_json() %>% r6_from_list() %>% gqlr_str()

schemaObj <- SchemaObj$new(text = filmSchemaTxt, fnList = filmFnList)

schemaObj <- Schema$new(documentObj = filmSchemaTxt, fnList = filmFnList)


} # end FALSE
