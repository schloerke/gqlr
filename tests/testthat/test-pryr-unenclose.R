

context("pryr unenclose")


test_that("pryr fails", {
  # plays bad memory tricks
  run <- function() {
    myList <- list()

    for (item in c("A", "B", "C")) {
      my_fn <- function() { item }
      # cat("my_fn: "); print(my_fn)
      # cat("my_fn: "); print(pryr::unenclose(my_fn))
      myList[[item]] <- pryr::unenclose(my_fn)
      # cat("myList:\n"); print(myList)
    }

    myList
  }

  ans <- run()

  expect_equal(names(ans), c("A", "B", "C"))

  expect_false(ans$A() == "A")
  expect_false(ans$B() == "B")
  expect_true(ans$C() == "C")

})



test_that("lapply works", {
  # works as expected
  run2 <- function() {
    myVec <- c("A", "B", "C")
    names(myVec) <- myVec
    myList <- lapply(myVec, function(item) {
      myItem <- force(item)
      my_fn <- function() { myItem }
      # cat("my_fn: "); print(my_fn)
      my_fn <- pryr::unenclose(my_fn)
      environment(my_fn) <- globalenv()
      # cat("my_fn: "); print(my_fn)
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



# unenclose_lapply <- function(x, fn, ..., .parent_frame = parent.frame()) {
#   lapply(x, function(item) {
#     forced_item <- force(item)
#     result_fn <- fn(forced_item, ...)
#     browser()
#     result_fn <- pryr::unenclose(result_fn)
#     environment(result_fn) <- .parent_frame
#     result_fn
#   })
# }
# setNames(unenclose_lapply(void_tags, void_tag), void_tags)


# run2 <- function() {
#   myVec <- c("A", "B", "C")
#   names(myVec) <- myVec
#   myList <- lapply(myVec, function(item) {
#     myItem <- force(item)
#     my_fn <- function() { myItem }
#     cat("my_fn: "); print(my_fn)
#     my_fn <- pryr::unenclose(my_fn)
#     environment(my_fn) <- globalenv()
#     cat("my_fn: "); print(my_fn)
#     my_fn
#   })
#
#   myList
# }



# run3 <- function() {
#   myVec <- c("A", "B", "C")
#   names(myVec) <- myVec
#   lapply(myVec, function(item) {
#     my_fn <- function() { item }
#     my_fn <- pryr::unenclose(my_fn)
#     my_fn
#   })
# }
#
#
# my_list <- (function() {
#   ret_fn <- function(item) {
#     function() {
#       item
#     }
#   }
#   lapply(c("A", "B", "C"), ret_fn)
# })()
#
#
# pryr::unenclose(my_list[[1]])




# my_unenclose <- function(f) {
#   stopifnot(is.function(f))
#
#   env <- environment(f)
#   ls_env <- ls(envir = env)
#
#   a_to_b <- function(x) {
#     if (is.name(x)) {
#       dep_x <- deparse(x)
#       if (dep_x %in% ls_env) {
#         return(get(dep_x, envir = env))
#       }
#     }
#     x
#   }
#
#   body <- modify_lang(body(f), a_to_b)
#   pryr::make_function(formals(f), body, parent.env(env))
# }
# pryr_unenclose(my_list[[1]])

# modify_lang(body(my_list[[1]]), a_to_b(environment(my_list[[1]])))


test_that("pryr_unenclose works", {
  run <- function() {
    myList <- list()

    for (item in c("A", "B", "C")) {
      my_fn <- function() { item }
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




# tag <- function(tag) {
#   force(tag)
#   function(...) {
#     args <- list(...)
#     attribs <- html_attributes(named(args))
#     children <- unlist(escape(unnamed(args)))
#
#     html(paste0(
#       "<", tag, attribs, ">",
#       paste(children, collapse = ""),
#       "</", tag, ">"
#     ))
#   }
# }
# void_tag <- function(tag) {
#   force(tag)
#   function(...) {
#     args <- list(...)
#     if (length(unnamed(args)) > 0) {
#       stop("Tag ", tag, " can not have children", call. = FALSE)
#     }
#     attribs <- html_attributes(named(args))
#
#     html(paste0("<", tag, attribs, " />"))
#   }
# }
# tags <- c("a", "abbr", "address", "article", "aside", "audio",
#   "b","bdi", "bdo", "blockquote", "body", "button", "canvas",
#   "caption","cite", "code", "colgroup", "data", "datalist",
#   "dd", "del","details", "dfn", "div", "dl", "dt", "em",
#   "eventsource","fieldset", "figcaption", "figure", "footer",
#   "form", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header",
#   "hgroup", "html", "i","iframe", "ins", "kbd", "label",
#   "legend", "li", "mark", "map","menu", "meter", "nav",
#   "noscript", "object", "ol", "optgroup", "option", "output",
#   "p", "pre", "progress", "q", "ruby", "rp","rt", "s", "samp",
#   "script", "section", "select", "small", "span", "strong",
#   "style", "sub", "summary", "sup", "table", "tbody", "td",
#   "textarea", "tfoot", "th", "thead", "time", "title", "tr",
#   "u", "ul", "var", "video")
#
# void_tags <- c("area", "base", "br", "col", "command", "embed",
#   "hr", "img", "input", "keygen", "link", "meta", "param",
#   "source", "track", "wbr")
#
# tag_fs <- c(
#   setNames(lapply(tags, tag), tags),
#   setNames(lapply(void_tags, void_tag), void_tags)
# )
#
# my_unenclose(tag_fs$command)
