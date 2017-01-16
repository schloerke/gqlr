
r6_from_list <- function(obj, fn_list = NULL, level = 0, keys = c(), objPos = NULL, verbose = FALSE) {
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
          # going through a list, such as 'Document$defintions' or 'ObjectTypeDefinition$fields'


          # str(objVal, max = 2)
          # print(activeKey)
          # browser()
          # lapply(objVal, r6_from_list, keys = keys, level = level)
          retList[[activeKey]] <- lapply(seq_along(objVal), function(i) {
            if (!is.null(fn_list)) {
              if (objClass == "Document" && activeKey == "definitions") {
                obj_name <- objVal[[i]]$name$value
                fn_list <- fn_list[[obj_name]]
                description <- fn_list$.description
                if (!is.null(description)) {
                  objVal[[i]][["description"]] <- description
                }
              } else if (objClass == "ObjectTypeDefinition" && activeKey == "fields") {
                obj_name <- objVal[[i]]$name$value
                resolve_fn <- ifnull(fn_list[[obj_name]], default_resolve_key_value)
                objVal[[i]][[".resolve"]] <- resolve_fn
                description <- attr(resolve_fn, "description")
                if (!is.null(description)) {
                  objVal[[i]][["description"]] <- description
                }
                fn_list <- NULL
              } else {
                # print(list(class = objClass, activeKey = activeKey))
                # browser()
                fn_list <- NULL
              }
            }

            r6_from_list(objVal[[i]], fn_list = fn_list, keys = keys, level = level, objPos = i, verbose = verbose)
          })
        } else {
          # going into another object, such as "Name" or "Location"
          retList[[activeKey]] <- r6_from_list(objVal, fn_list = fn_list, keys = keys, level = level, verbose = verbose)
        }
      }
    } else {
      retList[[activeKey]] <- objVal
    }
  }

  # browser()
  do.call(r6Obj$new, retList)
}


default_resolve_key_value <- function(obj, args, schema_obj, ...) {
  return(obj[[key]])
}
