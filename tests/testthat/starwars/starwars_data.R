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

is_droid <- function(id) {
  if (is.null(id)) {
    str(x)
    stop("unknown object")
  }
  id %in% names(droid_data)
}

get_human_by_id <- function(id) {
  human <- human_data[[id]]
  if (is.null(human)) return(NULL)
  human$totalCredits <- function(obj, args, schema_obj) {
    length(human$appearsIn)
  }
  human
}
get_droid_by_id <- function(id) {
  droid <- droid_data[[id]]
  if (is.null(droid)) return(NULL)
  droid
}


# hero(episode: Episode): Character
# human(id: String!): Human
# droid(id: String!): Droid
query_data = list(
  hero = function(obj, args, schema_obj) {
    episode = args$episode
    if (identical(episode, 5) || identical(episode, "EMPIRE")) {
      luke$id
    } else {
      artoo$id
    }
  },
  human = function(obj, args, schema_obj) {
    args$id
  },
  droid = function(obj, args, schema_obj) {
    args$id
  },
  by_id = function(obj, args, schema_obj) {
    args$id
  },
  humanoid = function(obj, args, schema_obj) {
    args$id
  }
)
