
r6_from_list <- function(
  obj,
  fn_list = NULL,
  fn_values = list(),
  level = 0,
  keys = c(),
  objPos = NULL,
  verbose = FALSE
) {
  vcat <- function(...) {
    if (verbose) {
      cat(..., sep = "")
    }
  }
  if (typeof(obj) != "list") {
    return(obj)
  }
  objClass <- obj$kind
  if (is.null(objPos)) {
    keys <- append(keys, objClass)
  } else {
    keys <- append(keys, str_c(objPos, "-", objClass))
  }
  level <- level + 1


  r6Obj <- PkgObjs$get_class_obj(objClass)

  retList <- list()

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


          # # nolint start
          # str(objVal, max = 2)
          # print(activeKey)
          # browser()
          # # nolint end

          retList[[activeKey]] <- lapply(seq_along(objVal), function(i) {

            fn_values_i <- list()
            fn_list_i <- list()

            if (!is.null(fn_list) && length(fn_list) > 0) {
              # # nolint start
              # cat("\n\n")
              # print(fn_list)
              # print(objClass)
              # print(activeKey)
              # str(objVal[[i]])
              # browser()
              # # nolint end

              if (objClass == "Document" && activeKey == "definitions") {

                if (objVal[[i]]$kind == "SchemaDefinition") {
                  # do nothing for a SchemaDefinition
                } else {
                  # for each definition,
                  #   get the description and pass on the fields as functions list
                  obj_name <- objVal[[i]]$name$value
                  info_i <- fn_list[[obj_name]]
                  info_i <- get_resolve_and_description(info_i)

                  # if (length(info_i$fields) == 0) browser() # nolint
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
                  # if (obj_name == "__schema") browser() # nolint
                  fn_values_i <- fn_list[[obj_name]]
                  fn_values_i <- get_resolve_and_description(fn_values_i)
                  fn_list_i <- list()

                } else {
                  # # nolint start
                  # print(list(class = objClass, activeKey = activeKey))
                  # fn_list <- get_resolve_and_description(fn_list)
                  # # nolint end

                }
              }

            }

            r6_from_list(
              objVal[[i]],
              fn_list = fn_list_i, fn_values = fn_values_i,
              keys = keys, level = level,
              objPos = i,
              verbose = verbose
            )

          })
        } else {
          # going into another object, such as "Name" or "Location"
          retList[[activeKey]] <- r6_from_list(
            objVal,
            fn_list = fn_list,
            keys = keys,
            level = level,
            verbose = verbose
          )
        }
      }
    } else {
      retList[[activeKey]] <- objVal
    }
  }

  # finally add description or resolve methods or any other methods
  # the information here should not exist in the first place, so stomping should not occur
  name_map <- list(
    "resolve_fn" = ".resolve"
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

  do.call(r6Obj$new, retList)
}


default_resolve_key_value <- function(obj, args, schema, ...) {
  return(obj)
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
