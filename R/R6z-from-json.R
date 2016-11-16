
r6_from_list <- function(obj, fnList = list(), level = 0, keys = c(), objPos = NULL, verbose = FALSE) {
  vcat <- function(...) {
    if (verbose) {
      cat(..., sep = "")
    }
  }
  if (typeof(obj) != "list") {
    return(obj)
  }
  # browser()
  objClass <- obj$kind
  if (is.null(objPos)) {
    keys <- append(keys, objClass)
  } else {
    keys <- append(keys, str_c(objPos, "-", objClass))
  }
  level <- level + 1


  r6Obj <- RegisterClassObj$get_class_obj(objClass)

  retList <- list()

  # fieldNames <- ret$"_argNames"
  fieldNames <- names(r6Obj$public_fields$.args)

  for (activeKey in fieldNames) {
    vcat("(", level, ") - ", paste(keys, collapse = ","), "-", activeKey, "\n")
    objVal <- obj[[activeKey]]

    if (is.list(objVal)) {
      if (length(objVal) == 0) {
        retList[[activeKey]] <- list()
      } else {
        if (identical(class(objVal), "list")) {
          # browser()
          # lapply(objVal, r6_from_list, keys = keys, level = level)
          retList[[activeKey]] <- lapply(seq_along(objVal), function(i) {
            r6_from_list(objVal[[i]], fnList = fnList, keys = keys, level = level, objPos = i, verbose = verbose)
          })
        } else {
          retList[[activeKey]] <- r6_from_list(objVal, fnList = fnList, keys = keys, level = level, verbose = verbose)
        }
      }
    } else {
      retList[[activeKey]] <- objVal
    }
  }

  # browser()
  do.call(r6Obj$new, retList)
}
