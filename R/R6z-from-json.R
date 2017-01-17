
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
                fn_list_and_desc <- document_defintion_fn_and_desc(objVal[[i]], fn_list)
                if (!is.null(fn_list_and_desc$description)) {
                  objVal[[i]][["description"]] <- fn_list_and_desc$description
                }

                fn_list <- fn_list_and_desc$fn_list

              } else {
                if (objClass == "ObjectTypeDefinition" && activeKey == "fields") {
                  fn_list_and_desc <- get_resolve_and_description(objVal[[i]], fn_list)
                  objVal[[i]][[".resolve"]] <- fn_list_and_desc$resolve_fn

                } else {

                  # print(list(class = objClass, activeKey = activeKey))
                  fn_list_and_desc <- get_resolve_and_description(objVal[[i]], fn_list)

                }

                fn_list <- fn_list_and_desc$fn_list

                # has a description field...
                if (!is.null(r6Obj$public_fields$.args$description)) {
                  description <- fn_list_and_desc$description
                  if (!is.null(description)) {
                    objVal[[i]][["description"]] <- description
                  }
                }
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




document_defintion_fn_and_desc <- function(obj_val_i, fn_list) {
  obj_name <- obj_val_i$name$value
  fn_list <- fn_list[[obj_name]]
  description <- fn_list$.description

  list(fn_list = fn_list, description = description)
}


get_resolve_and_description <- function(obj_val_i, fn_list) {
  obj_name <- obj_val_i$name$value

  resolve_fn <- fn_list[[obj_name]]
  if (is.character(resolve_fn)) {
    description <- resolve_fn
    resolve_fn <- NULL

  } else {
    description <- attr(resolve_fn, "description")

  }

  resolve_fn <- ifnull(resolve_fn, default_resolve_key_value)

  list(fn_list = NULL, description = description, resolve_fn = resolve_fn)
}
