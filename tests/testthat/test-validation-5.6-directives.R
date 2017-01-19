
context("validation-5.6-directives")


source("validate_helper.R")

test_that("5.6.1 - Directives Are Defined", {

  "
  {
    dog {
      name @skip(if: false)
      name2:name @include(if: false)
      barkVolume
    }
  }
  " %>%
  expect_r6()


  "
  {
    dog {
      name @directiveNotMade(if: false)
      barkVolume
    }
  }
  " %>%
  expect_err("Missing defintion for directive")

})


test_that("5.6.2 - Directives Are In Valid Locations", {

  "
  {
    dog {
      name
      barkVolume @skip(if: true)
    }
  }
  " %>%
  expect_r6()

  "
  query @skip(if: true) {
    dog {
      name
    }
  }
  " %>%
  expect_err("directive: 'skip' is being used in a 'QUERY' situation.")

})

test_that("5.6.3 - Directives Are Unique Per Location", {

  "
  query {
    dog {
      name
      barkVolume @skip(if: $foo) @skip(if: $bar)
    }
  }
  " %>%
  expect_err("found the following directives: 'skip', 'skip'")

})
