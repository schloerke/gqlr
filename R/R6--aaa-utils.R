

with_description <- function(fn, description = NULL) {
  attr(fn, "description") <- description
  fn
}

coerce_helper = function(as_fn, is_fn) {
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


RegisterClassObj <- R6Class(
  "RegisterdR6Classes",
  public = list(
    list = list(),
    is_registered = function(key) {
      !is.null(self$list[[key]])
    },
    add = function(key, value) {
      self$list[[key]] <- value
    },
    get_class_obj = function(key) {
      obj = self$list[[key]]
      if (is.null(obj)) {
        stop0("Could not find object with class: ", classVal)
      }
      obj
    }
  ),
  active = list(
    names = function() {
      names(self$list)
    }
  )
  # private = privateList,
  # active = activeList
)$new()




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

        retItem <- list(type = "string", isArray = FALSE, canBeNull = FALSE, possibleValues = values)
      } else {
        canBeNull <- FALSE
        isArray <- FALSE
        isNamedArray <- FALSE
        if (str_detect(value, "^\\?")) {
          canBeNull <- TRUE
          value <- str_replace(value, "^\\?", "")
        }
        if (str_detect(value, "^Array<")) {
          isArray <- TRUE
          value <- str_replace(value, "^Array<", "") %>% str_replace(">$", "")
        } else if (str_detect(value, "^Dict<")) {
          isArray <- TRUE
          isNamedArray <- TRUE
          value <- str_replace(value, "^Dict<", "") %>% str_replace(">$", "")
        }

        retItem <- list(type = value, isArray = isArray, isNamedArray = isNamedArray, canBeNull = canBeNull, value = NULL)
      }

      list(key = key, value = retItem)
    })


  keys <- lapply(kvPairs, "[[", "key") %>% unlist()
  ret <- lapply(kvPairs, "[[", "value")
  if (keys[length(keys)] == "") {
    removeBadPos <- -1 * length(keys)
    keys <- keys[removeBadPos]
    ret <- ret[removeBadPos]
  }
  names(ret) <- keys
  ret
}




R6_from_args <- function(type, txt = NULL, inherit = NULL, public = list(), private = list(), active = list()) {
  # R6_from_args("Document", "kind: 'Document'; loc?: ?Location; definitions: Array<Definition>;", inherit = AST)

  self_value_wrapper <- function(key, classVal) {
    possibleClassValues <- strsplit(classVal, "\\|")[[1]] %>% lapply(str_trim) %>% unlist()
    function(value) {
      if (missing(value)) {
        return(self$.args[[key]]$value)
      }


      if (is.null(value)) {
        if (! self$.args[[key]]$canBeNull) {
          stop0("Can not set value to NULL for ", classVal, "$", key)
        }
        self$.args[[key]]$value <- value
        return(value)
      }

      bad_inherits <- function() {
        stop0(
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
        while(mayInherit > 0) {
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


  self_array_wrapper <- function(key, classVal, hasNames = FALSE) {
    function(value) {
      if (missing(value)) {
        return(self$.args[[key]]$value)
      }

      if (inherits(value, "R6")) {
        str(value, 3)
        stop0(
          "Attempting to set ", class(self)[1], ".", key, ".\n",
          "Expected value should be an array of ", classVal, " objects.\n",
          "Received ", paste(class(value), collapse = ", "),
          "Received object above."
        )
      }
      if (hasNames) {
        valueNames <- names(value)
        bad_name <- function() {
          str(value, 3)
          stop0(
            "Attempting to set ", class(self)[1], ".", key, ".\n",
            "Expected value should be a named array of ",
              length(value), classVal, " objects.\n",
            "Received object above which does not have the correct length of unique names."
          )
        }
        if (is.null(valueNames)) {
          bad_name()
        }
        if (any(is.na(valueNames) || is.null(valueNames))) {
          bad_name()
        }
        if (length(unique(valueNames)) != length(value)) {
          bad_name()
        }
      }

      lapply(value, function(valItem) {
        if (!inherits(valItem, classVal)) {
          str(value, 3)
          stop0(
            "Attempting to set ", class(self)[1], ".", key, ".\n",
            "Expected value with class of |", classVal, "|.\n",
            "Received ", paste(class(valItem), collapse = ", "),
            "Received object above.",
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
        stop0("Value supplied to key '", key, "' not in accepted values: ", str_c(values, collapse = ", "), ".")
      }
      self$.args[[key]]$value <- value
      value
    }
    fn
  }


  args <- parse_args(txt)
  args$kind <- NULL
  args$.kind <- NULL

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
              stop0("can not set ", argName, " to a non function value.")
            }
          }
          x
        })
      )

      possibleValues <- argItem$possibleValues
      if (! is.null(possibleValues)) {
        fn <- self_base_values_wrapper(argName, type_fn, possibleValues)
      } else {
        fn <- self_base_wrapper(argName, type_fn)
      }

    } else {
      if (argItem$isArray) {
        fn <- self_array_wrapper(argName, argType, argItem$isNamedArray)
      } else {
        fn <- self_value_wrapper(argName, argType)
      }
    }

    # replace all "argName" and "type_fn" or "argType" with the actual values
    # this allows R6 to work with functions that should be closures,
    # after unenclose'ing the function, it is no long a closure
    # if (type == "Name") browser()

    # fn <- pryr::unenclose(pryr::unenclose(fn))
    fn <- pryr_unenclose(fn)

    activeList[[argName]] <- fn
  }

  publicList <- list()
  publicList$.args <- args


  canBeNull <- lapply(args, "[[", "canBeNull") %>% unlist()
  canBeNullTxt <- rep("", length(canBeNull))
  canBeNullTxt[canBeNull] <- "NULL"
  initTxt <- str_c(
    "alist(",
      str_c(names(args), canBeNullTxt, sep = " = ", collapse = ", "),
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
            if(self$.args[[.argName]]$canBeNull)
              function(e) { NULL }
            else
              function(e) {
                stop0("Did not receive: '", .argName, "'. '", .argName, "' must be supplied to object of class: ", self$.kind)
              }
          )
        )

      }
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

  RegisterClassObj$add(type, r6Class)

  r6Class
}


gqlr_str <- function(x, ...) {
  x$.str(...)
}
# gqlr_str <- (function() {
#   cat_ret_spaces <- function(spaces, ...) {
#     cat("\n", rep(" ", spaces), ..., sep = "")
#   }
#
#   str_obj <- function(x, maxLevel = -1, spaceCount = 0, showNull) {
#     if (maxLevel == 0) {
#       return()
#     }
#
#     r6ObjClass <- class(x)[1]
#
#     cat("<", r6ObjClass, ">", sep = "")
#     if (maxLevel == 1) {
#       cat("...")
#       return()
#     }
#
#     fieldNames <- x$.argNames
#
#     for (fieldName in fieldNames) {
#       if (fieldName %in% c("loc")) {
#         next
#       }
#
#       fieldVal <- x[[fieldName]]
#
#       if (!inherits(fieldVal, "R6")) {
#         if (is.list(fieldVal)) {
#           # is list
#           if (length(fieldVal) == 0) {
#             if (showNull) {
#               cat_ret_spaces(spaceCount + 2, fieldName, ":")
#               cat(" []")
#             }
#           } else {
#             cat_ret_spaces(spaceCount + 2, fieldName, ":")
#             for (itemPos in seq_along(fieldVal)) {
#               fieldItem <- fieldVal[[itemPos]]
#               cat_ret_spaces(spaceCount + 4, itemPos, " - ")
#               str_obj(fieldItem, maxLevel - 1, spaceCount + 4, showNull)
#             }
#           }
#
#         } else {
#           # is value
#           if (is.null(fieldVal)) {
#             fieldVal <- "NULL"
#             if (showNull) {
#               cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
#             }
#           } else if (is.numeric(fieldVal)) {
#             cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
#           } else if (is.character(fieldVal)) {
#             cat_ret_spaces(spaceCount + 2, fieldName, ": '", fieldVal, "'")
#           }
#         }
#
#       } else {
#         # recursive call to_string
#         cat_ret_spaces(spaceCount + 2, fieldName, ": ")
#         str_obj(fieldVal, maxLevel - 1, spaceCount + 2, showNull)
#       }
#
#     }
#   }
#
#   function(x, maxLevel = -1, showNull = FALSE) {
#     str_obj(x, maxLevel, 0, showNull)
#     cat("\n")
#     invisible(x)
#   }
# })()
