
#' @export
str.AST <- function(
  object, ..., max_level = -1, all_fields = FALSE, show_null = FALSE
) {
  cat(
    format_str(
      object,
      max_level = max_level,
      all_fields = all_fields,
      show_null = show_null,
      space_count = 0,
      is_first = TRUE
    )
  )
}


str_c_ret_spaces <- function(ret, spaces, ...) {
  dots <- collapse(...)
  if (spaces > 2) {
    second <- str_c(
      "\n", collapse(rep(". ", floor( (spaces - 2) / 2) )), ". ",
      dots
    )
  } else if (spaces == 2) {
    second <- str_c("\n", ". ", dots, sep = "")
  } else {
    second <- str_c("\n", dots, sep = "")
  }
  str_c(ret, second)
}

check_if_registered <- function(fieldObj) {
  key <- class(fieldObj)[1]
  if (is.null(key) ) {
    stop("Can not call format(object) on a unknown AST object")
  }
  if (!PkgObjs$is_registered(key)) {
    stop("'", key, "' is not registered. ")
  }
}


format_str <- function(
  object,
  max_level = -1,
  all_fields = FALSE,
  show_null = FALSE,
  space_count = 0,
  is_first = FALSE
) {
  # if no more levels to show, return
  if (max_level == 0) {
    return(character(0))
  }

  ret <- str_c("<", class(object)[1], ">", sep = "")
  if (max_level == 1) {
    ret <- str_c(ret, "...")
    return(ret)
  }

  field_names <- object$.argNames

  for (field_name in field_names) {
    field_val <- object[[field_name]]

    if (!isTRUE(all_fields)) {
      if (field_name %in% c("loc")) {
        next
      }
    }

    if (!inherits(field_val, "R6")) {
      if (is.list(field_val)) {
        # is list
        if (length(field_val) == 0) {
          ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ":")
          ret <- ret %>% str_c(" []")
        } else {
          ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ":")
          for (item_pos in seq_along(field_val)) {
            field_item <- field_val[[item_pos]]

            if (inherits(field_item, "FieldDefinition")) {
              if (!isTRUE(field_item$.show_in_format)) {
                if (!isTRUE(all_fields)) {
                  next
                }
              }
            }


            ret <- ret %>% str_c_ret_spaces(space_count + 4, item_pos, " - ")

            check_if_registered(field_item)
            ret <- str_c(ret,
              format_str(
                field_item,
                max_level = max_level - 1,
                space_count = space_count + 4,
                show_null = show_null,
                all_fields = all_fields
              )
            )
          }
        }

      } else {
        # is value
        if (is.null(field_val)) {
          field_val <- "NULL"
          if (isTRUE(show_null)) {
            ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ": ", field_val)
          }
        } else if (length(field_val) == 0) {
          if (isTRUE(show_null)) {
            ret <- ret %>%
              str_c_ret_spaces(space_count + 2, field_name, ": ", typeof(field_val), "(0)")
          }
        } else if (is.numeric(field_val)) {
          ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ": ", field_val)
        } else if (is.character(field_val)) {
          if (length(field_val) == 0) {
            print("this should not happen")
            browser()
          }
          ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ": '", field_val, "'")
        } else if (is.logical(field_val)) {
          ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ": ", field_val)
        } else if (is.function(field_val)) {
          ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ": ", "function")
        } else {
          print("type unknown (not char or number or bool). Fix this")
          browser()
          stop("type unknown (not char or number or bool). Fix this")
        }
      }

    } else {
      # recursive call to_string
      ret <- ret %>% str_c_ret_spaces(space_count + 2, field_name, ": ")

      check_if_registered(field_val)
      ret <- str_c(ret,
        format_str(
          field_val,
          max_level = max_level - 1,
          space_count = space_count + 2,
          show_null = show_null,
          all_fields = all_fields
        )
      )
    }
  }

  if (is_first) {
    ret <- ret %>% str_c("\n")
  }

  ret
}
