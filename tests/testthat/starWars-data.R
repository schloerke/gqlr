# Taken directly from https =//github.com/graphql/graphql-js/blob/master/src/__tests__/
# and updated to be used within R.  'Promise's were removed

# /**
#  * This defines a basic set of data for our Star Wars Schema.
#  *
#  * This data is hard coded for the sake of the demo, but you could imagine
#  * fetching this data from a backend service rather than from hardcoded
#  * JSON objects in a more complex demo.
#  */

luke <- list(
  id = '1000',
  name = 'Luke Skywalker',
  friends = c('1002', '1003', '2000', '2001' ),
  appearsIn = c(4, 5, 6),
  homePlanet = 'Tatooine',
)

vader <- list(
  id = '1001',
  name = 'Darth Vader',
  friends = c('1004') ,
  appearsIn = c(4, 5, 6),
  homePlanet = 'Tatooine',
)

han <- list(
  id = '1002',
  name = 'Han Solo',
  friends = c('1000', '1003', '2001'),
  appearsIn = c(4, 5, 6),
};

leia <- list(
  id = '1003',
  name = 'Leia Organa',
  friends = c('1000', '1002', '2000', '2001'),
  appearsIn = c(4, 5, 6),
  homePlanet = 'Alderaan',
)

tarkin = list(
  id = '1004',
  name = 'Wilhuff Tarkin',
  friends = c('1001'),
  appearsIn = c(4),
)

humanData = list(
  1000 = luke,
  1001 = vader,
  1002 = han,
  1003 = leia,
  1004 = tarkin,
)

threepio <- list(
  id = '2000',
  name = 'C-3PO',
  friends = c('1000', '1002', '1003', '2001'),
  appearsIn = c(4, 5, 6),
  primaryFunction = 'Protocol',
)

artoo <- list(
  id = '2001',
  name = 'R2-D2',
  friends = c('1000', '1002', '1003'),
  appearsIn = c(4, 5, 6),
  primaryFunction = 'Astromech',
)

droidData = list(
  2000 = threepio,
  2001 = artoo,
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
