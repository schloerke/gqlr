# load_all(); testthat::test_file(file.path("tests", "testthat", "test-util.R"))

context("expect_subset() works")

source("validate_helper.R")

test_that("chai tests", {
  tested_object <- list(
    a = 'b',
    c = 'd'
  )

  # expect_subset(tested_object, list(a = 'b'))
  # expect_subset(tested_object, list(a = 'b', c = 'd'))
  expect_false(sub_rec(tested_object, list(a = 'notB')))


  tested_object <- list(
    a = 'b',
    c = 'd',
    e = list(
      list(
        foo = "a"
      ),
      list(
        foo = 'bar',
        baz = list(
          qux = 'quux'
        )
      )
    )
  )

  expect_subset(
    tested_object,
    list(a = 'b', e = list(list(foo = "a"), list(foo = 'bar')))
  )
  expect_subset(
    tested_object,
    list(e = list(list(foo = "a"), list(foo = 'bar', baz = list(qux = 'quux'))))
  )
  expect_subset(
    tested_object,
    list(a = 'b', c = 'd', e = list(list(foo = "a"), list(foo = 'bar', baz = list(qux = 'quux'))))
  )

  expect_false(sub_rec(
    tested_object,
    list(e = list(list(foo = "a"), list(foo = 'bar', baz = list(qux = 'notAQuux'))))
  ))

  expect_false(sub_rec(
    tested_object,
    list(e = 5)
  ))

  expect_false(sub_rec(NULL, list(a = 1)))
  expect_subset(list(a = 1), NULL)
  expect_subset(5, 5)
  expect_subset("hi", "hi")

  child = list()
  parent = list(children = list(child))
  expect_subset(
    list(a = 1, b = 'two', c = parent),
    list(c = parent)
  )

})
