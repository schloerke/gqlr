

test_that("lapply works", {
  # works as expected
  run2 <- function() {
    myVec <- c("A", "B", "C")
    names(myVec) <- myVec
    myList <- lapply(myVec, function(item) {
      myItem <- force(item)
      my_fn <- function() {
        myItem
      }
      my_fn <- pryr::unenclose(my_fn)
      environment(my_fn) <- globalenv()
      my_fn
    })

    myList
  }

  ans <- run2()

  expect_equal(names(ans), c("A", "B", "C"))

  expect_true(ans$A() == "A")
  expect_true(ans$B() == "B")
  expect_true(ans$C() == "C")

})



test_that("pryr_unenclose works", {
  run <- function() {
    myList <- list()

    for (item in c("A", "B", "C")) {
      my_fn <- function() {
        item
      }
      myList[[item]] <- pryr_unenclose(my_fn)
    }

    myList
  }
  ans <- run()

  expect_equal(names(ans), c("A", "B", "C"))

  expect_true(ans$A() == "A")
  expect_true(ans$B() == "B")
  expect_true(ans$C() == "C")



  ans <- (function() {
    ret_fn <- function(item) {
      function() {
        item
      }
    }
    lapply(c("A", "B", "C"), ret_fn) %>%
      magrittr::set_names(c("A", "B", "C"))
  })()

  expect_equal(names(ans), c("A", "B", "C"))

  expect_true(ans$A() == "A")
  expect_true(ans$B() == "B")
  expect_true(ans$C() == "C")


})
