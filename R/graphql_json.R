#' @include R6z-from-json.R
#' @include R6-Schema.R

#' @import jsonlite
to_json <- function(..., pretty = TRUE) {
  jsonlite::toJSON(
    ...,
    pretty = pretty,
    auto_unbox = TRUE,
    null = "null"
  )
}
from_json <- function(..., simplifyDataFrame = FALSE, simplifyVector = FALSE) {
  jsonlite::fromJSON(..., simplifyDataFrame = simplifyDataFrame, simplifyVector = simplifyVector)
}

clean_json <- function(obj, ...) {
  UseMethod("clean_json")
}

clean_json.list <- function(obj, ...) {
  if (!is.null(obj$loc)) {
    obj$loc$kind <- "Location"
    class(obj$loc) <- "Location"
  }
  kind <- obj$kind
  ret <- lapply(obj, function(x) clean_json(x))
  if (! is.null(kind)) {
    class(ret) <- kind
  }
  ret
}
clean_json.default <- function(obj, ...) {
  obj
}

#' @import graphql
graphql2list <- function(txt) {
  graphql::graphql2json(txt) %>%
    from_json() %>%
    clean_json()
}

graphql2obj <- function(txt) {
  graphql2list(txt) %>%
    r6_from_list()
}


is_named_list <- function(obj, err) {
  if (length(obj) > 0) {
    obj_names <- names(obj)
    if (
      is.null(obj_names) ||
      length(unique(obj_names)) != length(obj) ||
      any(nchar(obj_names) == 0)
    ) {
      stop(err)
    }
  }
}

#' @export
graphql2schema <- function(txt, ...) {
  schema_obj <- Schema$new(txt)

  info_list <- list(...)

  if (length(info_list) > 0) {
    is_named_list(info_list, "graphql2schema() extra arguments must be uniquely named arguments")

    for (item_name in names(info_list)) {
      item <- info_list[[item_name]]

      obj <- schema_obj$get_type(item_name)
      item_type <- class(obj)[1]

      info_names <- names(item)

      if (item_type == "ScalarTypeDefinition") {
        is_ok <- all(
          info_names %in% c("description", "serialize", "parse_value", "parse_literal")
        )
        if (!is_ok) {
          stop(
            "graphql2schema() argument: ", item_name,
            " of type: ScalarTypeDefinition,",
            " should be a list possibly containing these elements:\n",
            "\tdescription: String\n",
            "\tserialize: function(obj)\n",
            "\tparse_value: function(obj, schema)\n",
            "\tparse_literal: function(obj, schema)\n"
          )
        }

      } else if (item_type == "ObjectTypeDefinition") {
        if (is.function(item)) {
          item <- list(resolve = item)
        } else {
          is_ok <- all(info_names %in% c("description", "fields", "resolve"))
          if (!is_ok) {
            stop(
              "graphql2schema() argument: ", item_name,
              " of type: ObjectTypeDefinition,",
              " should be a 'resolve' function or a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tfields: list(fieldA = descriptionA, fieldB = descriptionB...)\n",
              "\tresolve: function(obj, schema)\n"
            )
          }
        }

      } else if (item_type == "EnumTypeDefinition") {
        if (is.function(item)) {
          item <- list(resolve = item)
        } else {
          is_ok <- all(
            info_names %in% c("description", "values", "serialize", "parse_value", "parse_literal")
          )
          if (!is_ok) {
            stop(
              "graphql2schema() argument: ", item_name,
              " of type: EnumTypeDefinition,",
              " should be a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tvalues: list(enumA = descriptionA, enumB = descriptionB...)\n",
              "\tserialize: function(obj)\n",
              "\tparse_value: function(obj, schema)\n",
              "\tparse_literal: function(obj, schema)\n"
            )
          }
        }

      } else if (item_type == "InterfaceTypeDefinition" || item_type == "UnionTypeDefinition") {
        if (is.function(item)) {
          item <- list(resolve_type = item)
        } else {
          is_ok <- all(info_names %in% c("description", "resolve_type"))
          if (!is_ok) {
            stop(
              "graphql2schema() argument: ", item_name,
              " of type: ,", item_type,
              " should be a 'resolve_type' function or",
              " a list possibly containing these elements:\n",
              "\tdescription: String\n",
              "\tresolve_type: function(obj, schema)\n"
            )
          }
        }

      } else {
        str(obj)
        stop("unknown object provided to graphql2schema()")
      }

      is_named_list(
        item,
        str_c("graphql2schema() argument: '", item_name, "' must be uniquely named arguments")
      )

      for (info_name in names(item)) {
        store_name <- switch(info_name,
          "resolve" = ".resolve",
          "resolve_type" = ".resolve_type",
          "serialize" = ".serialize",
          "parse_value" = ".parse_value",
          "parse_literal" = ".parse_literal",
          "serialize" = ".serialize",
          "values" = "values",
          "fields" = "fields",
          "description" = "description"
        )

        if (store_name == "fields") {
          for (field_name in names(item$fields)) {
            field_name_obj <- schema_obj$as_type(field_name)
            obj_field <- obj$.get_field(field_name_obj)
            if (is.null(obj_field)) {
              stop("Could not find field for Object: ", item_name)
            }
            obj_field$description <- item$fields[[field_name]]
          }

        } else if (store_name == "values") {
          for (value_name in names(item$values)) {
            found <- FALSE
            for (enum_val in obj$values) {
              if (format(enum_val$name) == value_name) {
                enum_val$description <- item$values[[value_name]]
                found <- TRUE
                break
              }
            }
            if (!found) {
              stop("Could not find value for Enum: ", item_name)
            }
          }

        } else {
          obj[[store_name]] <- item[[info_name]]
        }
      } # for each obj value
    } # for each item
  } # if items

  schema_obj
}
