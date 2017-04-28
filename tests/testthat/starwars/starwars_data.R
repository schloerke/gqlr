luke <- list(
  id = '1000',
  name = 'Luke Skywalker',
  friends = c('1002', '1003', '2000', '2001' ),
  # appearsIn = c(4, 5, 6),
  appearsIn = c("NEWHOPE", "EMPIRE", "JEDI"),
  homePlanet = 'Tatooine'
)

vader <- list(
  id = '1001',
  name = 'Darth Vader',
  friends = c('1004') ,
  # appearsIn = c(4, 5, 6),
  appearsIn = c("NEWHOPE", "EMPIRE", "JEDI"),
  homePlanet = 'Tatooine'
)

han <- list(
  id = '1002',
  name = 'Han Solo',
  friends = c('1000', '1003', '2001'),
  # appearsIn = c(4, 5, 6)
  appearsIn = c("NEWHOPE", "EMPIRE", "JEDI")
)

leia <- list(
  id = '1003',
  name = 'Leia Organa',
  friends = c('1000', '1002', '2000', '2001'),
  # appearsIn = c(4, 5, 6),
  appearsIn = c("NEWHOPE", "EMPIRE", "JEDI"),
  homePlanet = 'Alderaan'
)

tarkin = list(
  id = '1004',
  name = 'Wilhuff Tarkin',
  friends = c('1001'),
  # appearsIn = c(4)
  appearsIn = c("NEWHOPE")
)

human_data = list(
  "1000" = luke,
  "1001" = vader,
  "1002" = han,
  "1003" = leia,
  "1004" = tarkin
)

threepio <- list(
  id = '2000',
  name = 'C-3PO',
  friends = c('1000', '1002', '1003', '2001'),
  # appearsIn = c(4, 5, 6),
  appearsIn = c("NEWHOPE", "EMPIRE", "JEDI"),
  primaryFunction = 'Protocol'
)

artoo <- list(
  id = '2001',
  name = 'R2-D2',
  friends = c('1000', '1002', '1003'),
  # appearsIn = c(4, 5, 6),
  appearsIn = c("NEWHOPE", "EMPIRE", "JEDI"),
  primaryFunction = 'Astromech'
)

droid_data = list(
  "2000" = threepio,
  "2001" = artoo
)

all_characters = list() %>% append(human_data) %>% append(droid_data)

is_droid <- function(x) {
  id <- x$id
  if (is.null(id)) {
    str(x)
    stop("unknown object")
  }
  id %in% names(droid_data)
}

get_friends <- function(x) {
  function(obj, args, schema_obj) {
    lapply(x$friends, wrap_character_by_id)
  }
}

wrap_human <- function(x) {
  list(
    id = x$id,
    name = x$name,
    friends = get_friends(x),
    appearsIn = x$appearsIn,
    # starships = x$starships
    totalCredits = length(x$appearsIn),
    homePlanet = x$homePlanet
  )
}
wrap_droid <- function(x) {
  list(
    id = x$id,
    name = x$name,
    friends = get_friends(x),
    appearsIn = x$appearsIn,
    primaryFunction = x$primaryFunction
  )
}
wrap_character_by_id <- function(id) {
  obj <- all_characters[[id]]
  if (is_droid(obj)) {
    wrap_droid(obj)
  } else {
    wrap_human(obj)
  }
}


# hero(episode: Episode): Character
# human(id: String!): Human
# droid(id: String!): Droid
query_data = list(
  hero = function(obj, args, schema_obj) {
    episode = args$episode
    # str(episode)
    # if (is.null(episode)) return(wrap_droid(luke))
    if (identical(episode, 5) || identical(episode, "EMPIRE")) {
      wrap_human(luke)
    } else {
      wrap_droid(artoo)
    }
  },
  human = function(obj, args, schema_obj) {
    if (args$id %in% names(human_data)) {
      wrap_human(human_data[[args$id]])
    } else {
      NULL
    }
  },
  droid = function(obj, args, schema_obj) {
    if (args$id %in% names(droid_data)) {
      wrap_droid(droid_data[[args$id]])
    } else {
      NULL
    }
  },
  by_id = function(obj, args, schema_obj) {
    id_char <- as.character(args$id)
    if (id_char %in% names(all_characters)) {
      wrap_character_by_id(id_char)
    } else {
      NULL
    }
  },
  humanoid = function(obj, args, schema_obj) {
    id_char <- args$id
    if (id_char %in% names(all_characters)) {
      wrap_character_by_id(id_char)
    } else {
      NULL
    }
  }
)
