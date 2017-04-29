

"
enum DogCommand { SIT, DOWN, HEEL }

type Dog implements Pet {
  name: String!
  nickname: String
  barkVolume: Int
  doesKnowCommand(dogCommand: DogCommand!): Boolean!
  isHousetrained(atOtherHomes: Boolean): Boolean!
  owner: Human
}

interface Sentient {
  name: String!
}

interface Pet {
  name: String!
}

type Alien implements Sentient {
  name: String!
  homePlanet: String
}

type Human implements Sentient {
  name: String!
  pet: Pet
}

enum CatCommand { JUMP }

type Cat implements Pet {
  name: String!
  nickname: String
  doesKnowCommand(catCommand: CatCommand!): Boolean!
  meowVolume: Int
}

union CatOrDog = Cat | Dog

union DogOrHuman = Dog | Human

union HumanOrAlien = Human | Alien

type Arguments {
  multipleReqs(x: Int!, y: Int!): Int!
  booleanArgField(booleanArg: Boolean): Boolean
  floatArgField(floatArg: Float): Float
  intArgField(intArg: Int): Int
  stringArgField(stringArg: String): String
  nonNullBooleanArgField(nonNullBooleanArg: Boolean!): Boolean!
  booleanListArgField(booleanListArg: [Boolean]): [Boolean]
  booleanNonNullListArgField(booleanNonNullListArg: [Boolean]!): [Boolean]!
  nonNullBooleanListArgField(nonNullBooleanListArg: [Boolean!]): [Boolean!]
}

input ComplexInput { name: String, owner: String }

type SearchRoot {
  dog: Dog
  cat: Cat
  human: Human
  pet: Pet
  catOrDog: CatOrDog
  arguments: Arguments
  findDog(complex: ComplexInput): Dog
  booleanList(booleanListArg: [Boolean!]): Boolean
}

schema {
  query: SearchRoot
}
" %>%
  graphql2obj() ->
dog_cat_doc

dog_cat_schema <- Schema$new(dog_cat_doc)
