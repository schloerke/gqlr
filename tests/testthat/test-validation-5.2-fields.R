# load_all(); testthat::test_file(file.path("tests", "testthat", "test-validation-5.2-fields.R")); # nolint





test_that("5.2.1 - Field Selections On Objects, Interfaces, and Union Types", {

  "
  {
    dog {
      ...interfaceFieldSelection
    }
  }
  fragment interfaceFieldSelection on Pet {
    name
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ... on Dog {
        name
      }
      ...interfaceFieldSelection
    }
  }
  fragment interfaceFieldSelection on Pet {
    name
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      ...fieldNotDefined
    }
  }
  fragment fieldNotDefined on Dog {
    meowVolume
  }
  " %>%
  expect_err("not all requested names are found")


  "
  {
    dog {
      ...definedOnImplementorsButNotInterface
    }
  }
  fragment definedOnImplementorsButNotInterface on Pet {
    nickname
  }
  " %>%
  expect_err("not all requested names are found")


  "
  {
    dog {
      ...inDirectFieldSelectionOnUnion
    }
  }
  fragment inDirectFieldSelectionOnUnion on CatOrDog {
    __typename
    ... on Pet {
      name
    }
    ... on Dog {
      barkVolume
    }
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      ...directFieldSelectionOnUnion
    }
  }
  fragment directFieldSelectionOnUnion on CatOrDog {
    name
    barkVolume
  }
  " %>%
  expect_err("fields may not be queried directly on a union object")

})







test_that("5.2.2 - Field Selection Merging", {

  "
  {
    dog {
      ...mergeIdenticalFields
      ...mergeIdenticalAliasesAndFields
    }
  }
  fragment mergeIdenticalFields on Dog {
    name
    name
  }
  fragment mergeIdenticalAliasesAndFields on Dog {
    otherName: name
    otherName: name
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ...conflictingBecauseAlias
    }
  }
  fragment conflictingBecauseAlias on Dog {
    name: nickname
    name
  }
  " %>%
  expect_err("Two matching return fields must both be NonNullType")


  "
  query A {
    dog {
      ...mergeIdenticalFieldsWithIdenticalArgs
    }
  }
  fragment mergeIdenticalFieldsWithIdenticalArgs on Dog {
    doesKnowCommand(dogCommand: SIT)
    doesKnowCommand(dogCommand: SIT)
  }
  query B($dogCommand: DogCommand!) {
    dog {
      ...mergeIdenticalFieldsWithIdenticalValues
    }
  }
  fragment mergeIdenticalFieldsWithIdenticalValues on Dog {
    doesKnowCommand(dogCommand: $dogCommand)
    doesKnowCommand(dogCommand: $dogCommand)
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ...conflictingArgsOnValues
    }
  }
  fragment conflictingArgsOnValues on Dog {
    doesKnowCommand(dogCommand: SIT)
    doesKnowCommand(dogCommand: HEEL)
  }
  " %>%
  expect_err("Two matching return fields must have identical arguments")

  "
  query A($dogCommand: DogCommand = SIT) {
    dog {
      ...conflictingArgsValueAndVar
    }
  }
  fragment conflictingArgsValueAndVar on Dog {
    doesKnowCommand(dogCommand: SIT)
    doesKnowCommand(dogCommand: $dogCommand)
  }
  " %>%
  expect_err("Two matching return fields must have identical arguments")

  "
  query A($varOne: DogCommand = SIT, $varTwo: DogCommand = SIT) {
    dog {
      ...conflictingArgsWithVars
    }
  }
  fragment conflictingArgsWithVars on Dog {
    doesKnowCommand(dogCommand: $varOne)
    doesKnowCommand(dogCommand: $varTwo)
  }
  " %>%
  expect_err("Two matching return fields must have identical arguments")

  "
  # validate fields can merge
  query MyQuery {
    dog {
      name
    }
    dog {
      name
    }
  }
  " %>%
  expect_r6()

  "
  # validate lists can merge
  query MyQuery {
    human {
      pet {
        name
      }
    }
    human {
      pet {
        name
      }
    }
  }
  " %>%
  expect_r6()

  "
  # validate lists can merge
  query MyQuery {
    human {
      pet {
        name
      }
    }
    human {
      pet {
        ... on Dog {
          nickname
        }
      }
    }
  }
  " %>%
  expect_r6()


  "
  {
    pet {
      ...safeDifferingFields
      ...safeDifferingArgs
    }
  }
  fragment safeDifferingFields on Pet {
    ... on Dog {
      volume: barkVolume
    }
    ... on Cat {
      volume: meowVolume
    }
  }
  fragment safeDifferingArgs on Pet {
    ... on Dog {
      doesKnowCommand(dogCommand: SIT)
    }
    ... on Cat {
      doesKnowCommand(catCommand: JUMP)
    }
  }
  " %>%
  expect_r6()


  "
  {
    human {
      pet {
        ...conflictingDifferingResponses
      }
    }
  }
  fragment conflictingDifferingResponses on Pet {
    ... on Dog {
      someValue: nickname
    }
    ... on Cat {
      someValue: meowVolume
    }
  }
  " %>%
  expect_err("Two matching return names must return the same types")


})




test_that("5.2.3 - Leaf Field Selections", {


  "
  {
    dog {
      ...scalarSelection
    }
  }
  fragment scalarSelection on Dog {
    barkVolume
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ...scalarSelectionsNotAllowedOnBoolean
    }
  }
  fragment scalarSelectionsNotAllowedOnBoolean on Dog {
    barkVolume {
      sinceWhen
    }
  }
  " %>%
  expect_err("Not allowed to query deeper into leaf")


  "
  query directQueryOnObjectWithoutSubFields {
    human
  }
  " %>%
  expect_err("non leaf selection does not have any children")

  "
  query directQueryOnInterfaceWithoutSubFields {
    pet
  }
  " %>%
  expect_err("non leaf selection does not have any children")

  "
  query directQueryOnUnionWithoutSubFields {
    catOrDog
  }
  " %>%
  expect_err("non leaf selection does not have any children")

})
