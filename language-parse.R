# /* @flow */
# /**
#  *  Copyright (c) 2015, Facebook, Inc.
#  *  All rights reserved.
#  *
#  *  This source code is licensed under the BSD-style license found in the
#  *  LICENSE file in the root directory of this source tree. An additional grant
#  *  of patent rights can be found in the PATENTS file in the same directory.
#  */

# /**
#  * Contains a range of UTF-8 character offsets that identify
#  * the region of the source from which the AST derived.
#  */







ignore <- (function() {
  lat <- language_ast_type

  cat_spaces <- function(spaces, ...) {
    cat(rep(" ", spaces), ..., "\n", sep = "")
  }

  gql_parse <<- function(obj, kind = obj$kind, name = "", spaces = 0, s2 = spaces + 2) {
    typeObj <- lat(kind)

    if (kind == "Location") {
      return()
    }
    # if (stringr::str_length(name) > 0) {
    #   cat_spaces(spaces, name, ": {")
    # } else {
    #   cat_spaces(spaces, "{")
    # }
    # cat_spaces(s2, "kind: ", kind)

    if (typeObj$isOrType) {
      print("Is OR TYPE")
      browser()
    }

    # print(typeObj$items)
    lapply(names(typeObj$items), function(typeItemName) {

      # print(typeItemName)
      if (typeItemName == "kind") {
        return()
      }
      # print(typeItemName)
      # browser()
      typeItemInfo <- typeObj$items[[typeItemName]]

      if (kind == "Value") {
        browser()
      }


      objItem <- obj[[typeItemName]]

      if (is.null(objItem)) {
        if (typeItemInfo$isRequired) {
          print(obj)
          stop(paste0(typeItemName, " not supplied to ", kind))
        } else {
          # nothing to print.  return
          return()
        }
      }

      if (typeItemInfo$isArray) {
        cat_spaces(s2, typeItemName, ": [")
        lapply(objItem, function(objArrItem) {
          to_string(objArrItem, kind = objArrItem$kind, name = "", spaces = s2 + 2)
          cat_spaces(s2, ",")
        })
        cat_spaces(s2, "]")
      } else {
        if (typeItemInfo$isPrimitive) {
          cat_spaces(s2, typeItemName, ": ", objItem)
        } else {
          to_string(objItem, kind = typeItemInfo$kind, name = typeItemName, spaces = s2)
          # cat(rep(" ", s2), objItem$kind, "\n")
        }
      }

    })
    cat_spaces(spaces, "}")
  }


  language_ast_type
})()
