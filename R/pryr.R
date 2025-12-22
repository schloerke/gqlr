# Functions copied from pryr package (https://github.com/hadley/pryr)
# pryr is being archived, so these functions have been copied here to maintain functionality
# Original author: Hadley Wickham
# License: GPL-2

# Helper functions --------------------------------------------------------

all_named <- function(x) {
  if (length(x) == 0) {
    return(TRUE)
  }
  !is.null(names(x)) && all(names(x) != "")
}

to_env <- function(x, quiet = FALSE) {
  if (is.environment(x)) {
    x
  } else if (is.list(x)) {
    list2env(x)
  } else if (is.function(x)) {
    environment(x)
  } else if (length(x) == 1 && is.character(x)) {
    if (!quiet) {
      message("Using environment ", x)
    }
    as.environment(x)
  } else if (length(x) == 1 && is.numeric(x) && x > 0) {
    if (!quiet) {
      message("Using environment ", search()[x])
    }
    as.environment(x)
  } else {
    stop("Input can not be coerced to an environment", call. = FALSE)
  }
}

# Main functions ----------------------------------------------------------

#' Recursively modify a language object
#'
#' Copied from pryr package. Recursively modifies a language object by applying
#' a function to all leaves.
#'
#' @param x object to modify: should be a call, expression, function or
#'   list of the above.
#' @param f function to apply to leaves
#' @param ... other arguments passed to `f`
#' @return Modified language object
#' @keywords internal
#' @noRd
modify_lang <- function(x, f, ...) {
  recurse <- function(y) {
    lapply(y, modify_lang, f = f, ...)
  }

  if (is.atomic(x) || is.name(x)) {
    # Leaf
    f(x, ...)
  } else if (is.call(x)) {
    as.call(recurse(x))
  } else if (is.function(x)) {
    formals(x) <- modify_lang(formals(x), f, ...)
    body(x) <- modify_lang(body(x), f, ...)
    x
  } else if (is.pairlist(x)) {
    # Formal argument lists (when creating functions)
    as.pairlist(recurse(x))
  } else if (is.expression(x)) {
    # shouldn't occur inside tree, but might be useful top-level
    as.expression(recurse(x))
  } else if (is.list(x)) {
    # shouldn't occur inside tree, but might be useful top-level
    recurse(x)
  } else {
    stop(
      "Unknown language class: ",
      paste(class(x), collapse = "/"),
      call. = FALSE
    )
  }
}

#' Make a function from its components
#'
#' Copied from pryr package. This constructs a new function given its three
#' components: list of arguments, body code and parent environment.
#'
#' @param args A named list of default arguments.  Note that if you want
#'  arguments that don't have defaults, you'll need to use the special function
#'  [alist()], e.g. `alist(a = , b = 1)`
#' @param body A language object representing the code inside the function.
#'   Usually this will be most easily generated with [quote()]
#' @param env The parent environment of the function, defaults to the calling
#'  environment of `make_function`
#' @return A function
#' @noRd
make_function <- function(args, body, env = parent.frame()) {
  args <- as.pairlist(args)
  stopifnot(
    all_named(args),
    is.language(body)
  )
  env <- to_env(env)

  eval(call("function", args, body), env)
}

#' A version of substitute that evaluates its first argument
#'
#' Copied from pryr package. This version of substitute is needed because
#' `substitute` does not evaluate its first argument, and it's often
#' useful to be able to modify a quoted call.
#'
#' @param x a quoted call
#' @param env an environment, or something that behaves like an environment
#'   (like a list or data frame), or a reference to an environment (like a
#'   positive integer or name, see [as.environment()] for more
#'   details)
#' @return Modified call with substitutions applied
#' @noRd
substitute_q <- function(x, env) {
  stopifnot(is.language(x))
  env <- to_env(env)

  call <- substitute(substitute(x, env), list(x = x))
  eval(call)
}

#' Unenclose a closure
#'
#' Copied from pryr package. Unenclose a closure by substituting names for
#' values found in the enclosing environment.
#'
#' @param f a closure
#' @return A function with values from the enclosing environment substituted
#' @noRd
unenclose <- function(f) {
  stopifnot(is.function(f))

  env <- environment(f)
  make_function(formals(f), substitute_q(body(f), env), parent.env(env))
}
