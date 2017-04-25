
context("validation-5.4-fragment")

source("validate_helper.R")

test_that("5.4.1.1 - Fragment Name Uniqueness", {


  # "
  # {
  #   dog {
  #     ... on Dog {
  #       name
  #     }
  #     ... on Dog {
  #       owner {
  #         name
  #       }
  #     }
  #   }
  # }
  # "

  "
  {
    dog {
      ...fragmentOne
      ...fragmentTwo
    }
  }
  fragment fragmentOne on Dog {
    name
  }
  fragment fragmentTwo on Dog {
    owner {
      name
    }
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ...fragmentOne
    }
  }
  fragment fragmentOne on Dog {
    name
  }
  fragment fragmentOne on Dog {
    owner {
      name
    }
  }
  " %>%
  expect_err("Found duplicate fragment: fragmentOne")


  })


test_that("5.4.1.2 - Fragment Spread Type Existence", {


  "
  {
    dog {
      ...correctType
      ...inlineFragment
      ...inlineFragment2
    }
  }
  fragment correctType on Dog {
    name
  }
  fragment inlineFragment on Dog {
    ... on Dog {
      name
    }
  }
  fragment inlineFragment2 on Dog {
    ... @include(if: true) {
      name
    }
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      ...notOnExistingType
    }
  }
  fragment notOnExistingType on NotInSchema {
    name
  }
  " %>%
  expect_err("Can not find match for typeCondition")

})



test_that("5.4.1.3 - Fragments On Composite Types", {

  "
  {
    dog {
      ...fragOnObject
      ...fragOnInterface
      ...fragOnUnion
    }
  }
  fragment fragOnObject on Dog {
    name
  }
  fragment fragOnInterface on Pet {
    name
  }
  fragment fragOnUnion on CatOrDog {
    ... on Dog {
      name
    }
  }
  " %>%
  expect_r6()

})


test_that("5.4.1.4 - Fragments Must Be Used", {

  "
  fragment nameFragment on Dog { # unused
    name
  }
  {
    dog {
      name
    }
  }
  " %>%
  expect_err("all fragments must be used")


})



test_that("5.4.2.1 - Fragment spread target defined", {

  "
  {
    dog {
      ...undefinedFragment
    }
  }
  " %>%
  expect_err("Can not find fragment named")
})



test_that("5.4.2.2 - Fragment spreads must not form cycles", {


  "
  {
    dog {
      ...nameFragment
    }
  }

  fragment nameFragment on Dog {
    name
    ...barkVolumeFragment
  }

  fragment barkVolumeFragment on Dog {
    barkVolume
    ...nameFragment
  }
  " %>%
  expect_err("fragments can not be circularly defined")



  "
  {
    dog {
      ...dogFragment
    }
  }

  fragment dogFragment on Dog {
    name
    owner {
      ...ownerFragment
    }
  }

  fragment ownerFragment on Human {
    name
    pet {
      ...dogFragment
    }
  }
  " %>%
  expect_err("fragments can not be circularly defined")

})



test_that("5.4.2.3.1 - Object Spreads In Object Scope", {

  "
  {
    dog {
      ...dogFragment
    }
  }
  fragment dogFragment on Dog {
    ... on Dog {
      barkVolume
    }
  }
  " %>%
  expect_r6()

  "
  {
    dog {
      ...catInDogFragmentInvalid
    }
  }
  fragment catInDogFragmentInvalid on Dog {
    ... on Cat {
      meowVolume
    }
  }
  " %>%
  expect_err("must be an intersection")

})



test_that("5.4.2.3.2 - Abstract Spreads In Object Scope", {

  "
  {
    dog {
      ...interfaceWithinObjectFragment
    }
  }
  fragment petNameFragment on Pet {
    name
  }
  fragment interfaceWithinObjectFragment on Dog {
    ...petNameFragment
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      ...unionWithObjectFragment
    }
  }
  fragment catOrDogNameFragment on CatOrDog {
    ... on Cat {
      meowVolume
    }
  }
  fragment unionWithObjectFragment on Dog {
    ...catOrDogNameFragment
  }
  " %>%
  expect_r6()

})


test_that("5.4.2.3.3 - Object Spreads In Abstract Scope", {

  "
  {
    dog {
      ...petFragment
      ...catOrDogFragment
    }
  }
  fragment petFragment on Pet {
    name
    ... on Dog {
      barkVolume
    }
  }
  fragment catOrDogFragment on CatOrDog {
    ... on Cat {
      meowVolume
    }
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      owner {
        ...sentientFragment
      }
    }
  }
  fragment sentientFragment on Sentient {
    ... on Dog {
      barkVolume
    }
  }
  " %>%
  expect_err("must be an intersection")

  "
  {
    dog {
      owner {
        ...humanOrAlienFragment
      }
    }
  }
  fragment humanOrAlienFragment on HumanOrAlien {
    ... on Cat {
      meowVolume
    }
  }
  " %>%
  expect_err("must be an intersection")

})


test_that("5.4.2.3.4 - Abstract Spreads In Abstract Scope", {

  "
  {
    dog {
      ...unionWithInterface
    }
  }
  fragment unionWithInterface on Pet {
    ...dogOrHumanFragment
  }
  fragment dogOrHumanFragment on DogOrHuman {
    ... on Dog {
      barkVolume
    }
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      ...nonIntersectingInterfaces
    }
  }
  fragment nonIntersectingInterfaces on Pet {
    ...sentientFragment
  }
  fragment sentientFragment on Sentient {
    name
  }
  " %>%
  expect_err("must be an intersection")

})
