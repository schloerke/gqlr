
context("validation-5.7-variables")


source("validate_helper.R")

test_that("5.7.1 - Variable Uniqueness", {

  "
  query houseTrainedQuery($atOtherHomes: Boolean, $atOtherHomes: Boolean) {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }
  " %>%
  expect_err("All defined variables must be unique")


  "
  query A($atOtherHomes: Boolean) {
    ...HouseTrainedFragment
  }

  query B($atOtherHomes: Boolean) {
    ...HouseTrainedFragment
  }

  fragment HouseTrainedFragment on QueryRoot {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }
  " %>%
  expect_r6()

})



test_that("5.7.2 - Default Values Are Correctly Typed", {

  "
  query houseTrainedQuery($atOtherHomes: Boolean = true) {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }
  " %>%
  expect_r6()


  "
  query houseTrainedQuery($atOtherHomes: Boolean! = true) {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }
  " %>%
  expect_err("Non-Null Variables are not allowed to have default values")


  # TODO - unlock with type is coercible
  # "
  # query houseTrainedQuery($atOtherHomes: Boolean = \"true\") {
  #   dog {
  #     isHousetrained(atOtherHomes: $atOtherHomes)
  #   }
  # }
  # " %>%
  # expect_err("asdf")


  "
  query intToFloatQuery($floatVar: Float = 1) {
    arguments {
      floatArgField(floatArg: $floatVar)
    }
  }
  " %>%
  expect_r6()

})




test_that("Variables are Input Types", {

  "
  query takesBoolean($atOtherHomes: Boolean) {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }

  query takesComplexInput($complexInput: ComplexInput) {
    findDog(complex: $complexInput) {
      name
    }
  }

  query TakesListOfBooleanBang($booleans: [Boolean!]) {
    booleanList(booleanListArg: $booleans)
  }
  " %>%
  expect_r6()


  "
  query takesCat($cat: Cat) {
    dog { name }
  }
  " %>%
  expect_err("Can not find matching")
  "
  query takesDogBang($dog: Dog!) {
    dog { name }
  }
  " %>%
  expect_err("Can not find matching")
  "
  query takesListOfPet($pets: [Pet]) {
    dog { name }
  }
  " %>%
  expect_err("Can not find matching")
  "
  query takesCatOrDog($catOrDog: CatOrDog) {
    dog { name }
  }
  " %>%
  expect_err("Can not find matching")



})
