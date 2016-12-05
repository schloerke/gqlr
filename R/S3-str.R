
str.AST <- (function() {

  cat_ret_spaces = function(spaces, ...) {
    if (spaces > 2) {
      cat("\n", rep(". ", floor((spaces - 2) / 2)), ". ", ..., sep = "")
    } else if (spaces == 2) {
      cat("\n", ". ", ..., sep = "")
    } else {
      cat("\n", ..., sep = "")
    }
    # cat("\n", rep(" ", spaces), ..., sep = "")
  }

  check_if_registered = function(fieldObj) {
    key = fieldObj$.kind
    if (is.null(key) ) {
      stop0("Can not call str(object) on a unknown AST object")
    }
    if (!RegisterClassObj$is_registered(key)) {
      stop0("'", key, "' is not registered. ")
    }
  }


  function(
    object,
    maxLevel = -1,
    showNull = FALSE,
    showLoc = FALSE,
    spaceCount = 0,
    isFirst = TRUE,
    ...
  ) {
    # if no more levels to show, return
    if (maxLevel == 0) {
      return()
    }

    cat("<", object$.kind, ">", sep = "")
    if (maxLevel == 1) {
      cat("...")
      return()
    }

    fieldNames <- object$.argNames

    for (fieldName in fieldNames) {
      if (fieldName %in% c("loc")) {
        if (! isTRUE(showLoc)) {
          next
        }
      }

      fieldVal <- object[[fieldName]]

      if (!inherits(fieldVal, "R6")) {
        if (is.list(fieldVal)) {
          # is list
          if (length(fieldVal) == 0) {
            if (showNull) {
              cat_ret_spaces(spaceCount + 2, fieldName, ":")
              cat(" []")
            }
          } else {
            cat_ret_spaces(spaceCount + 2, fieldName, ":")
            for (itemPos in seq_along(fieldVal)) {
              fieldItem <- fieldVal[[itemPos]]
              cat_ret_spaces(spaceCount + 2, itemPos, " - ")

              check_if_registered(fieldItem)
              str(
                fieldItem,
                maxLevel = maxLevel - 1,
                spaceCount = spaceCount + 2,
                showNull = showNull,
                showLoc = showLoc,
                isFirst = FALSE
              )
            }
          }

        } else {
          # is value
          if (is.null(fieldVal)) {
            fieldVal <- "NULL"
            if (showNull) {
              cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
            }
          } else if (length(fieldVal) == 0) {
            if (showNull) {
              cat_ret_spaces(spaceCount + 2, fieldName, ": ", typeof(fieldVal), "(0)")
            }
          } else if (is.numeric(fieldVal)) {
            cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
          } else if (is.character(fieldVal)) {
            if (length(fieldVal) == 0) {
              print("this should not happen")
              browser()
            }
            cat_ret_spaces(spaceCount + 2, fieldName, ": '", fieldVal, "'")
          } else if (is.logical(fieldVal)) {
            cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
          } else if (is.function(fieldVal)) {
            cat_ret_spaces(spaceCount + 2, fieldName, ": ", "fn")
          } else {
            print("type unknown (not char or number or bool). Fix this")
            browser()
            stop("type unknown (not char or number or bool). Fix this")
          }
        }

      } else {
        # recursive call to_string
        cat_ret_spaces(spaceCount + 2, fieldName, ": ")

        check_if_registered(fieldVal)
        str(
          fieldVal,
          maxLevel = maxLevel - 1,
          spaceCount = spaceCount + 2,
          showNull = showNull,
          showLoc = showLoc,
          isFirst = FALSE
        )
      }
    }

    if (isFirst) {
      cat("\n")
    }
    invisible(object)
  }

})()






str.Type = function(object, maxLevel = -1, ...) {
  if (maxLevel != 0) {
    cat(graphql_string(object))
  }
}
