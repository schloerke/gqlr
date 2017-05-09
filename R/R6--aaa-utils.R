

coerce_helper <- function(as_fn, is_fn) {
  fn <- function(value) {
    val <- as_fn(value)
    if (is_fn(val)) {
      if (length(val) > 0) {
        return(val)
      }
    }
    return(NULL)
  }
  pryr_unenclose(fn)
}


# nocov start
PkgObjsGen <- R6Class(
  "PkgObjs",
  public = list(
    list = list(),
    is_registered = function(key) {
      !is.null(self$list[[key]])
    },
    add = function(key, value) {
      self$list[[key]] <- value
    },
    get_class_obj = function(key) {
      obj <- self$list[[key]]
      if (is.null(obj)) {
        stop("Could not find object with class: ", key)
      }
      obj
    }
  ),
  active = list(
    names = function() {
      names(self$list)
    }
  )
)
PkgObjs <- PkgObjsGen$new()
# nocov end




parse_args <- function(txt) {
  if (is.null(txt)) {
    return(list())
  }
  # txt = "kind: 'Document';
  # loc?: ?Location;
  # definitions: Array<Definition>;"

  kvPairs <- strsplit(txt, ";")[[1]] %>%
    lapply(function(txtItem) {
      keyValue <- strsplit(txtItem, ":")[[1]]
      key <- str_trim(keyValue[1]) %>%
        str_replace("\\?$", "")

      value <- str_trim(keyValue[2]) %>%
        str_replace(";", "")

      if (str_detect(value, "^'") && str_detect(value, "'$")) {
        # is literal value
        values <- strsplit(value, "\\|")[[1]] %>%
          str_replace("'", "") %>%
          str_replace("'", "") %>%
          str_trim()

        retItem <- list(
          type = "string",
          is_array = FALSE,
          can_be_null = FALSE,
          possible_values = values
        )
      } else {
        can_be_null <- FALSE
        is_array <- FALSE
        if (str_detect(value, "^\\?")) {
          can_be_null <- TRUE
          value <- str_replace(value, "^\\?", "")
        }
        if (str_detect(value, "^Array<")) {
          is_array <- TRUE
          value <- str_replace(value, "^Array<", "") %>% str_replace(">$", "")
        }

        retItem <- list(
          type = value,
          is_array = is_array,
          can_be_null = can_be_null,
          value = NULL
        )
      }

      list(key = key, value = retItem)
    })


  keys <- lapply(kvPairs, "[[", "key") %>% unlist()
  ret <- lapply(kvPairs, "[[", "value")
  if (keys[length(keys)] == "") {
    # nocov start
    remove_bad_pos <- -1 * length(keys)
    keys <- keys[remove_bad_pos]
    ret <- ret[remove_bad_pos]
    # nocov end
  }
  names(ret) <- keys
  ret
}




R6_from_args <- function(
  type, txt = NULL, inherit = NULL, public = list(), private = list(), active = list()
) {

  self_value_wrapper <- function(key, classVal) {
    possibleClassValues <- strsplit(classVal, "\\|")[[1]] %>% lapply(str_trim) %>% unlist()
    function(value) {
      if (missing(value)) {
        return(self$.args[[key]]$value)
      }


      if (is.null(value)) {
        if (! self$.args[[key]]$can_be_null) {
          stop("Can not set value to NULL for ", classVal, "$", key)
        }
        self$.args[[key]]$value <- value
        return(value)
      }

      bad_inherits <- function() {
        stop(
          "Attempting to set ", class(self)[1], ".", key, ".\n",
          "Expected value with class of |", classVal, "|.\n",
          "Received ", paste(class(value), collapse = ", ")
        )
      }

      posClassValues <- possibleClassValues
      if (length(posClassValues) == 1) {
        if (!inherits(value, posClassValues[1])) {
          bad_inherits()
        }
      } else {
        mayInherit <- length(posClassValues)
        while (mayInherit > 0) {
          if (inherits(value, posClassValues[mayInherit])) {
            # found it
            break
          }
          mayInherit <- mayInherit - 1
        }
        if (mayInherit == 0) {
          bad_inherits()
        }
      }

      self$.args[[key]]$value <- value
      value
    }
  }


  self_array_wrapper <- function(key, classVal) {
    function(value) {
      if (missing(value)) {
        return(self$.args[[key]]$value)
      }

      if (inherits(value, "R6")) {
        obj_out <- capture.output(str(value, 3))
        stop(
          "Attempting to set ", class(self)[1], ".", key, ".\n",
          "Expected value should be an array of ", classVal, " objects.\n",
          "Received ", paste(class(value), collapse = ", "), "\n",
          "Received object below.\n",
          paste(obj_out, sep = "\n")
        )
      }

      lapply(value, function(valItem) {
        if (!inherits(valItem, classVal)) {
          obj_out <- capture.output(str(value, 3))
          stop(
            "Attempting to set ", class(self)[1], ".", key, ".\n",
            "Expected value with class of |", classVal, "|.\n",
            "Received ", paste(class(valItem), collapse = ", "), "\n",
            "Received object below.\n",
            paste(obj_out, sep = "\n")
          )
        }
      })

      self$.args[[key]]$value <- value
      value
    }
  }

  self_base_wrapper <- function(key, parse_fn) {
    fn <- function(value) {
      if (missing(value)) {
        return(self$.args[[key]]$value)
      }
      value <- parse_fn(value)
      self$.args[[key]]$value <- value
      value
    }
    fn
  }
  self_base_values_wrapper <- function(key, parse_fn, values) {
    fn <- function(value) {
      if (missing(value)) {
        return(self$.args[[key]]$value)
      }
      value <- parse_fn(value)
      if (! (value %in% values)) {
        stop(
          "Value supplied to key '", key, "' not in accepted values: ",
          str_c(values, collapse = ", "), "."
        )
      }
      self$.args[[key]]$value <- value
      value
    }
    fn
  }


  args <- parse_args(txt)
  args$kind <- NULL

  activeList <- list()

  for (argName in names(args)) {
    argItem <- args[[argName]]
    argType <- argItem$type

    if (argType %in% c("any", "string", "number", "boolean", "fn")) {
      type_fn <- switch(argType,
        string = coerce_helper(as.character, is.character),
        number = coerce_helper(as.numeric, is.numeric),
        any = identity,
        boolean = coerce_helper(as.logical, is.logical),
        fn = pryr_unenclose(function(x) {
          if (!is.null(x)) {
            if (!is.function(x)) {
              stop("can not set ", argName, " to a non function value.")
            }
          }
          x
        })
      )

      possible_values <- argItem$possible_values
      if (! is.null(possible_values)) {
        fn <- self_base_values_wrapper(argName, type_fn, possible_values)
      } else {
        fn <- self_base_wrapper(argName, type_fn)
      }

    } else {
      if (argItem$is_array) {
        fn <- self_array_wrapper(argName, argType)
      } else {
        fn <- self_value_wrapper(argName, argType)
      }
    }

    # replace all "argName" and "type_fn" or "argType" with the actual values
    # this allows R6 to work with functions that should be closures,
    # after unenclose'ing the function, it is no long a closure
    fn <- pryr_unenclose(fn)

    activeList[[argName]] <- fn
  }

  publicList <- list()
  publicList$.args <- args


  can_be_null <- lapply(args, "[[", "can_be_null") %>% unlist()
  can_be_null_txt <- rep("", length(can_be_null))
  can_be_null_txt[can_be_null] <- "NULL"
  initTxt <- str_c(
    "alist(",
      str_c(names(args), can_be_null_txt, sep = " = ", collapse = ", "),
    ")"
  )

  initArgs <- eval(parse(text = initTxt))

  publicList[["initialize"]] <- make_function(
    args = initArgs,
    env = environment(),
    body = quote({

      # all vars msut start with a "." to avoid stomp arg values
      for (.argName in self$.argNames) {
        # values that may be not supplied, will default to NULL from function def

        # all the active bindings will validate the object being set
        self[[.argName]] <- tryCatch(
          get(.argName, inherit = FALSE),
          error = (
            if (self$.args[[.argName]]$can_be_null) {
              function(e) {
                NULL
              }
            } else {
              function(e) {
                stop(
                  "Did not receive: '", .argName, "'. ",
                  "'", .argName, "' must be supplied an object of class: ", class(self)[1]
                )
              }
            }
          )
        )

      }

      return(invisible(self))
    })
  )


  upgrade_and_overwrite <- function(x, y) {
    if (is.null(y)) {
      return(x)
    }
    x[names(y)] <- y
    x
  }


  publicList <- upgrade_and_overwrite(publicList, public)
  activeList <- upgrade_and_overwrite(activeList, active)

  privateList <- list()
  privateList <- upgrade_and_overwrite(privateList, private)

  r6Class <- R6Class(
    type,
    public = publicList,
    private = privateList,
    active = activeList
  )
  r6Class$inherit <- substitute(inherit)

  PkgObjs$add(type, r6Class)

  r6Class
}
