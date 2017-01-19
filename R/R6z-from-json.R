
r6_from_list <- function(obj, fn_list = NULL, fn_values = list(), level = 0, keys = c(), objPos = NULL, verbose = FALSE) {
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

            fn_values_i <- list()
            fn_list_i <- list()

            if (!is.null(fn_list)) {
              # print(obj_name)
              # print(fn_list)
              # print(objClass)
              # browser()

              if (objClass == "Document" && activeKey == "definitions") {
                # for each definition, get the description and pass on the fields as functions list
                obj_name <- objVal[[i]]$name$value
                info_i <- fn_list[[obj_name]]
                info_i <- get_resolve_and_description(info_i)

                if (objVal[[i]]$kind == "ObjectTypeDefinition") {
                  fn_list_i <- lapply(info_i$fields, get_resolve_and_description)
                  fn_values_i <- info_i
                  fn_values_i$fields <- NULL

                } else {
                  fn_list_i <- lapply(info_i$fields, get_resolve_and_description)
                  fn_values_i <- info_i
                  fn_values_i$fields <- NULL
                }

              } else {

                if (
                  (objClass == "ObjectTypeDefinition" && activeKey == "fields") ||
                  (objClass == "EnumTypeDefinition" && activeKey == "values")
                ) {
                  # get the description or fields of an object or enum value
                  # pass them into the recursive definition so that they are added to the objects
                  obj_name <- objVal[[i]]$name$value
                  fn_values_i <- fn_list[[obj_name]]
                  fn_values_i <- get_resolve_and_description(fn_values_i)
                  fn_list_i <- list()

                } else {
                  # print(list(class = objClass, activeKey = activeKey))
                  # fn_list <- get_resolve_and_description(fn_list)
                }
              }

            }

            r6_from_list(objVal[[i]], fn_list = fn_list_i, fn_values = fn_values_i, keys = keys, level = level, objPos = i, verbose = verbose)
          })
        } else {
          # going into another object, such as "Name" or "Location"
          # print(list(objClass, activeKey, 1))
          # if (objClass == "DirectiveDefinition") browser()

          retList[[activeKey]] <- r6_from_list(objVal, fn_list = fn_list, keys = keys, level = level, verbose = verbose)
        }
      }
    } else {
      retList[[activeKey]] <- objVal
    }
  }

  # finally add description or resolve methods or any other methods
  # the information here should not exist in the first place, so stomping should not occur
  name_map <- list(
    "resolve" = ".resolve"
  )
  if (is.list(fn_values)) {
    if (length(fn_values) > 0) {
      for (name in names(fn_values)) {
        to_name <- ifnull(name_map[[name]], name)
        if (to_name %in% fieldNames) {
          val <- fn_values[[name]]
          if (!is.null(val)) {
            retList[[to_name]] <- val
          }
        }
      }
    }
  }

  # browser()
  do.call(r6Obj$new, retList)
}


default_resolve_key_value <- function(obj, args, schema_obj, ...) {
  return(obj[[key]])
}




get_resolve_and_description <- function(fn_list) {
  if (is.null(fn_list)) {
    return(NULL)
  }

  if (is.list(fn_list)) {
    return(fn_list)
  }

  if (is.character(fn_list)) {
    description <- fn_list
    resolve_fn <- NULL

  } else if (is.function(fn_list)) {
    description <- NULL
    resolve_fn <- fn_list
  }

  resolve_fn <- ifnull(resolve_fn, default_resolve_key_value)

  list(fn_list = NULL, description = description, resolve_fn = resolve_fn)
}
