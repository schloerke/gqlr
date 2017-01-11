
dog_cat_schema <- GQLRSchema$new()

"
enum DogCommand { SIT, DOWN, HEEL }
"
DogCommand <- EnumTypeDefinition$new(
  name = name_from_txt("DogCommand"),
  values = list(
    EnumValueDefinition$new(name = name_from_txt("SIT")),
    EnumValueDefinition$new(name = name_from_txt("DOWN")),
    EnumValueDefinition$new(name = name_from_txt("HEEL"))
  )
)
dog_cat_schema$add(DogCommand)


"
type Dog implements Pet {
  name: String!
  nickname: String
  barkVolume: Int
  doesKnowCommand(dogCommand: DogCommand!): Boolean!
  isHousetrained(atOtherHomes: Boolean): Boolean!
  owner: Human
}
"
Dog <- ObjectTypeDefinition$new(
  name = name_from_txt("Dog"),
  interfaces = list(
    namedtype_from_txt("Pet")
  ),
  fields = list(
    field_type_obj_from_txt("name", "String!"),
    field_type_obj_from_txt("nickname", "String"),
    field_type_obj_from_txt("barkVolume", "Int"),
    field_type_obj_from_txt("doesKnowCommand", "Boolean!", arguments = list(
      input_value_from_txt("dogCommand", "DogCommand!")
    )),
    field_type_obj_from_txt("isHousetrained", "Boolean!", arguments = list(
      input_value_from_txt("atOtherHomes", "Boolean")
    )),
    field_type_obj_from_txt("owner", "Human")
  )
)

dog_cat_schema$add(Dog)


"
interface Sentient {
  name: String!
}
"
Sentient <- InterfaceTypeDefinition$new(
  name = name_from_txt("Sentient"),
  fields = list(
    field_type_obj_from_txt("name", "String!")
  )
)
dog_cat_schema$add(Sentient)


"
interface Pet {
  name: String!
}
"
Pet <- InterfaceTypeDefinition$new(
  name = name_from_txt("Pet"),
  fields = list(
    field_type_obj_from_txt("name", "String!")
  )
)
dog_cat_schema$add(Pet)


"
type Alien implements Sentient {
  name: String!
  homePlanet: String
}
"
Alien <- ObjectTypeDefinition$new(
  name = name_from_txt("Alien"),
  interfaces = list(
    namedtype_from_txt("Sentient")
  ),
  fields = list(
    field_type_obj_from_txt("name", "String!"),
    field_type_obj_from_txt("homePlanet", "String")
  )
)
dog_cat_schema$add(Alien)


# added pets field for implementation
"
type Human implements Sentient {
  name: String!
  pet: Pet
}
"
Human <- ObjectTypeDefinition$new(
  name = name_from_txt("Human"),
  interfaces = list(
    namedtype_from_txt("Sentient")
  ),
  fields = list(
    field_type_obj_from_txt("name", "String!"),
    field_type_obj_from_txt("pet", "Pet")
  )
)
dog_cat_schema$add(Human)


"
enum CatCommand { JUMP }
"
CatCommand <- EnumTypeDefinition$new(
  name = name_from_txt("CatCommand"),
  values = list(
    EnumValueDefinition$new(name = name_from_txt("JUMP"))
  )
)
dog_cat_schema$add(CatCommand)


"
type Cat implements Pet {
  name: String!
  nickname: String
  doesKnowCommand(catCommand: CatCommand!): Boolean!
  meowVolume: Int
}
"
Cat <- ObjectTypeDefinition$new(
  name = name_from_txt("Cat"),
  interfaces = list(
    namedtype_from_txt("Pet")
  ),
  fields = list(
    field_type_obj_from_txt("name", "String!"),
    field_type_obj_from_txt("nickname", "String"),
    field_type_obj_from_txt("doesKnowCommand", "Boolean!", arguments = list(
      input_value_from_txt("catCommand", "CatCommand!")
    )),
    field_type_obj_from_txt("meowVolume", "Int")
  )
)
dog_cat_schema$add(Cat)


"
union CatOrDog = Cat | Dog
"
CatOrDog <- UnionTypeDefinition$new(
  name = name_from_txt("CatOrDog"),
  types = list(
    namedtype_from_txt("Cat"),
    namedtype_from_txt("Dog")
  )
)
dog_cat_schema$add(CatOrDog)


"
union DogOrHuman = Dog | Human
"
DogOrHuman <- UnionTypeDefinition$new(
  name = name_from_txt("DogOrHuman"),
  types = list(
    namedtype_from_txt("Dog"),
    namedtype_from_txt("Human")
  )
)
dog_cat_schema$add(DogOrHuman)


"
union HumanOrAlien = Human | Alien
"
HumanOrAlien <- UnionTypeDefinition$new(
  name = name_from_txt("HumanOrAlien"),
  types = list(
    namedtype_from_txt("Human"),
    namedtype_from_txt("Alien")
  )
)
dog_cat_schema$add(HumanOrAlien)


"
type Arguments {
  multipleReqs(x: Int!, y: Int!): Int!
  booleanArgField(booleanArg: Boolean): Boolean
  floatArgField(floatArg: Float): Float
  intArgField(intArg: Int): Int
  nonNullBooleanArgField(nonNullBooleanArg: Boolean!): Boolean!
  booleanListArgField(booleanListArg: [Boolean]!): [Boolean]
}
"
Arguments <- ObjectTypeDefinition$new(
  name = name_from_txt("Arguments"),
  fields = list(
    field_type_obj_from_txt("multipleReqs", "Int!", arguments = list(
      input_value_from_txt("x", "Int!"),
      input_value_from_txt("y", "Int!")
    )),
    field_type_obj_from_txt("booleanArgField", "Boolean", arguments = list(
      input_value_from_txt("booleanArg", "Boolean")
    )),
    field_type_obj_from_txt("floatArgField", "Float", arguments = list(
      input_value_from_txt("floatArg", "Float")
    )),
    field_type_obj_from_txt("intArgField", "Int", arguments = list(
      input_value_from_txt("intArg", "Int")
    )),
    field_type_obj_from_txt("nonNullBooleanArgField", "Boolean!", arguments = list(
      input_value_from_txt("nonNullBooleanArg", "Boolean!")
    )),
    field_type_obj_from_txt("booleanListArgField", "[Boolean]", arguments = list(
      input_value_from_txt("booleanListArg", "[Boolean]!")
    ))
  )
)
dog_cat_schema$add(Arguments)
# extend type QueryRoot {
#   arguments: Arguments
# }


"
type QueryRoot {
  dog: Dog
  cat: Cat
  arguments: Arguments
}
"
QueryRoot <- ObjectTypeDefinition$new(
  name = name_from_txt("QueryRoot"),
  fields = list(
    field_type_obj_from_txt("dog", "Dog"),
    field_type_obj_from_txt("cat", "Cat"),
    field_type_obj_from_txt("arguments", "Arguments")
  )
)
dog_cat_schema$add(QueryRoot)
