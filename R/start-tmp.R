

luke <- list(
  id = '1000',
  name = 'Luke Skywalker',
  friends = c('1002', '1003', '2000', '2001' ),
  appearsIn = c(4, 5, 6),
  homePlanet = 'Tatooine'
)

vader <- list(
  id = '1001',
  name = 'Darth Vader',
  friends = c('1004') ,
  appearsIn = c(4, 5, 6),
  homePlanet = 'Tatooine'
)

han <- list(
  id = '1002',
  name = 'Han Solo',
  friends = c('1000', '1003', '2001'),
  appearsIn = c(4, 5, 6)
)

leia <- list(
  id = '1003',
  name = 'Leia Organa',
  friends = c('1000', '1002', '2000', '2001'),
  appearsIn = c(4, 5, 6),
  homePlanet = 'Alderaan'
)

tarkin <- list(
  id = '1004',
  name = 'Wilhuff Tarkin',
  friends = c('1001'),
  appearsIn = c(4)
)

humanData <- list(
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
  appearsIn = c(4, 5, 6),
  primaryFunction = 'Protocol'
)

artoo <- list(
  id = '2001',
  name = 'R2-D2',
  friends = c('1000', '1002', '1003'),
  appearsIn = c(4, 5, 6),
  primaryFunction = 'Astromech'
)

droidData = list(
  "2000" = threepio,
  "2001" = artoo
)

# /**
#  * Helper function to get a character by ID.
#  */
getCharacter <- function (id) {
  ret <- getHuman(id)
  if (is.null(ret)) {
    getDroid(id)
  } else {
    ret
  }
}

# /**
#  * Allows us to query for a character's friends.
#  */
getFriends <- function(character) {
  lapply(character$friends, getCharacter)
}

# /**
#  * Allows us to fetch the undisputed hero of the Star Wars trilogy, R2-D2.
#  */
getHero <- function(episode) {
  if (identical(episode, 5)) {
    # // Luke is the hero of Episode V.
    luke
  } else {
    # // Artoo is the hero otherwise.
    artoo
  }
}

# /**
#  * Allows us to query for the human with the given id.
#  */
getHuman <- function(id) {
  humanData[[id]];
}

# /**
#  * Allows us to query for the droid with the given id.
#  */
getDroid <- function(id) {
  droidData[[id]];
}



# load_all(); system("./node_modules/.bin/browserify ./JS/starwars.js -g [ babelify --presets [ es2015 ] ] -o ./JS/starwars_bundle.js"); ct <- V8::new_context(global = "window"); ct$source("./JS/starwars_bundle.js")


gqlr_retrieve_star <- function(type, fn, obj, args) {
  print(list(type = type, fn = fn, obj = obj, args = args))
  cat("processing")
  for (i in 1:4) {
    System.sleep(".25")
    cat(".")
  }
  cat("\n")

  if (type == "Character") {
    if (fn == "resolveType") {
      humanObj = getHuman(character$id)
      if (!is.null(humanObj)) {
        return("Human")
      } else {
        return("Droid")
      }
    }

  } else if (type == "Human") {
    if (fn == "friends") {
      return(getFriends(obj))
    }

  } else if (type == "Droid") {
    if (fn == "friends") {
      return(getFriends(obj))
    }

  } else if (type == "Query") {
    if (fn == "hero") {
      return(getHero(args$episode))
    } else if (fn == "human") {
      return(getHuman(args$id))
    } else if (fn == "droid") {
      return(getDroid(args$id))
    }
  }

  stop("unknown fn asked for")
}
