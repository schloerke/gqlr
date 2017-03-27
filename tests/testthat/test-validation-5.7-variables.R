
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
  fragment HouseTrainedFragment on SearchRoot {
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


  "
  query houseTrainedQuery($atOtherHomes: Boolean = \"true\") {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }
  " %>%
  expect_err("found StringValue")


  "
  query intToFloatQuery($floatVar: Float = 1) {
    arguments {
      floatArgField(floatArg: $floatVar)
    }
  }
  " %>%
  expect_r6()

})




test_that("5.7.3 - Variables are Input Types", {

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


test_that("5.7.4 - All Variable Uses Defined", {

  "
  query variableIsDefined($atOtherHomes: Boolean) {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }
  " %>%
  expect_r6()


  "
  query variableIsNotDefined {
    dog {
      isHousetrained(atOtherHomes: $atOtherHomes)
    }
  }
  " %>%
  expect_err("variable definition can not be found")


  "
  query variableIsDefinedUsedInSingleFragment($atOtherHomes: Boolean) {
    dog {
      ...isHousetrainedFragment
    }
  }
  fragment isHousetrainedFragment on Dog {
    isHousetrained(atOtherHomes: $atOtherHomes)
  }
  " %>%
  expect_r6()


  "
  query variableIsNotDefinedUsedInSingleFragment {
    dog {
      ...isHousetrainedFragment
    }
  }
  fragment isHousetrainedFragment on Dog {
    isHousetrained(atOtherHomes: $atOtherHomes)
  }
  " %>%
  expect_err("variable definition can not be found")



  "
  query variableIsNotDefinedUsedInNestedFragment {
    dog {
      ...outerHousetrainedFragment
    }
  }
  fragment outerHousetrainedFragment on Dog {
    ...isHousetrainedFragment
  }
  fragment isHousetrainedFragment on Dog {
    isHousetrained(atOtherHomes: $atOtherHomes)
  }
  " %>%
  expect_err("variable definition can not be found")

  "
  query housetrainedQueryOne($atOtherHomes: Boolean) {
    dog {
      ...isHousetrainedFragment
    }
  }
  query housetrainedQueryTwo($atOtherHomes: Boolean) {
    dog {
      ...isHousetrainedFragment
    }
  }
  fragment isHousetrainedFragment on Dog {
    isHousetrained(atOtherHomes: $atOtherHomes)
  }
  " %>%
  expect_r6()


  "
  query housetrainedQueryOne($atOtherHomes: Boolean) {
    dog {
      ...isHousetrainedFragment
    }
  }
  query housetrainedQueryTwoNotDefined {
    dog {
      ...isHousetrainedFragment
    }
  }
  fragment isHousetrainedFragment on Dog {
    isHousetrained(atOtherHomes: $atOtherHomes)
  }
  " %>%
  expect_err("variable definition can not be found")

})



test_that("5.7.5 - All Variables Used", {

  "
  query variableUsedInFragment($atOtherHomes: Boolean) {
    dog {
      ...isHousetrainedFragment
    }
  }
  fragment isHousetrainedFragment on Dog {
    isHousetrained(atOtherHomes: $atOtherHomes)
  }
  " %>%
  expect_r6()


  "
  query variableUnused($atOtherHomes: Boolean) {
    dog {
      isHousetrained
    }
  }
  " %>%
  expect_err("Unused variables")


  "
  query variableNotUsedWithinFragment($atOtherHomes: Boolean) {
    dog {
      ...isHousetrainedWithoutVariableFragment
    }
  }
  fragment isHousetrainedWithoutVariableFragment on Dog {
    isHousetrained
  }
  " %>%
  expect_err("Unused variables")


  "
  query queryWithUsedVar($atOtherHomes: Boolean) {
    dog {
      ...isHousetrainedFragment
    }
  }
  query queryWithExtraVar($atOtherHomes: Boolean, $extra: Int) {
    dog {
      ...isHousetrainedFragment
    }
  }
  fragment isHousetrainedFragment on Dog {
    isHousetrained(atOtherHomes: $atOtherHomes)
  }
  " %>%
  expect_err("Unused variables")

})



test_that("5.7.6 - All Variables Usages are Allowed", {

  "
  query intCannotGoIntoBoolean($intArg: Int) {
    arguments {
      booleanArgField(booleanArg: $intArg)
    }
  }
  " %>%
  expect_err("inner types do not match")


  "
  query booleanListCannotGoIntoBoolean($booleanListArg: [Boolean]) {
    arguments {
      booleanArgField(booleanArg: $booleanListArg)
    }
  }
  " %>%
  expect_err("Variable list dimensions")


  "
  query booleanArgQuery($booleanArg: Boolean) {
    arguments {
      nonNullBooleanArgField(nonNullBooleanArg: $booleanArg)
    }
  }
  " %>%
  expect_err("nullible argument to a non-nullible")

  "
  query booleanArgQueryWithDefault($booleanArg: Boolean = true) {
    arguments {
      nonNullBooleanArgField(nonNullBooleanArg: $booleanArg)
    }
  }
  " %>%
  expect_r6()

  "
  query nonNullListToList($nonNullBooleanList: [Boolean!]) {
    arguments {
      booleanListArgField(booleanListArg: $nonNullBooleanList)
    }
  }
  query nonNullListToNonNullList($nonNullBooleanList: [Boolean!]) {
    arguments {
      nonNullBooleanListArgField(nonNullBooleanListArg: $nonNullBooleanList)
    }
  }
  " %>%
  expect_r6()


  "
  query listToNonNullList($booleanList: [Boolean]) {
    arguments {
      booleanNonNullListArgField(booleanNonNullListArg: $booleanList)
    }
  }
  " %>%
  expect_err("nullible argument to a non-nullible definition")

  "
  query listToNonNullList($booleanList: [Boolean]) {
    arguments {
      nonNullBooleanListArgField(nonNullBooleanListArg: $booleanList)
    }
  }
  " %>%
  expect_err("nullible argument to a non-nullible definition")

})
