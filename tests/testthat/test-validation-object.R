

context("object validation")



test_that("valid", {

  source("dog_cat_schema.R")

  expect_validate <- function(name, obj_type, ...) {
    # obj <- dog_cat_schema$get_interface("Pet")
    obj <- dog_cat_schema[[paste("get_", obj_type, sep = "")]](name)
    expect_true({
      validate(obj, dog_cat_schema, ...)
    })
  }


  # basic Interface
  # Pet <- dog_cat_schema$get_interface("Pet")
  # expect_true({
  #   validate(Pet, dog_cat_schema)
  # })
  expect_validate("Pet", "interface")


  # Basic Union
  expect_validate("CatOrDog", "union")


  lapply(names(dog_cat_schema$get_interfaces()), expect_validate, "interface")
  lapply(names(dog_cat_schema$get_unions()), expect_validate, "union")
  lapply(names(dog_cat_schema$get_objects()), expect_validate, "object")

})
