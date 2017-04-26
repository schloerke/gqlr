


# 5.2.2 - Field Selection Merging - DONE
# assuming only inline fragments exist at this point
validate_fields_can_merge <- function(
  selection_set_obj, matching_obj,
  ...,
  oh,
  same_response_shape_only = FALSE
) {

  selection_set <- selection_set_obj$selections

  field_information_list <- list()
  add_all_fields <- function(selection_set_, matching_obj_) {
    for (field in selection_set_) {
      if (inherits(field, "Field")) {
        if (field$name$value == "__typename") {
          item <- list(
            to_name = ifnull(field$alias$value, field$name$value),
            name = field$name$value,
            parent_type = matching_obj_$name$value,
            field = field,
            # return_field = return_field,
            return_type = "String"
          )
        } else {
          return_field <- matching_obj_$.get_field(field)
          item <- list(
            to_name = ifnull(field$alias$value, field$name$value),
            name = field$name$value,
            parent_type = matching_obj_$name$value,
            field = field,
            # return_field = return_field,
            return_type = return_field$type
          )
        }
        field_information_list[[length(field_information_list) + 1]] <<- item

      } else if (inherits(field, "InlineFragment")) {
        if (is.null(field$typeCondition)) {
          # inline fragment with no type. get parent type
          item_matching_obj <- matching_obj_
        } else {
          item_matching_obj <- oh$schema_obj$get_object_interface_or_union(field$typeCondition)
        }
        add_all_fields(field$selectionSet$selections, item_matching_obj)
      }
    }
  }
  add_all_fields(selection_set, matching_obj)

  to_names <- lapply(field_information_list, "[[", "to_name") %>% unlist()
  if (!any(duplicated(to_names))) {
    return(TRUE)
  }

  dup_field_names <- unique(to_names[duplicated(to_names)])

  for (dup_field_name in dup_field_names) {
    field_list_sub <- field_information_list[to_names == dup_field_name]

    for (i in seq_along(field_list_sub)) {
      field_i_info <- field_list_sub[[i]]

      for (j in seq_along(field_list_sub)) {
        if (i < j) {
          field_j_info <- field_list_sub[[j]]

          # SameResponseShape(fieldA, fieldB) must be true.
          validate_fields_have_same_response_shape(field_i_info, field_j_info, oh = oh)

          if (same_response_shape_only) {
            next
          }

          # If the parent types of fieldA and fieldB are equal or if either is not an Object Type:
          if (
            identical(
              field_i_info$parent_type,
              field_j_info$parent_type
            ) ||
            (! oh$schema_obj$is_object(field_i_info$parent_type)) ||
            (! oh$schema_obj$is_object(field_j_info$parent_type))
          ) {
            # fieldA and fieldB must have identical field names.
            if (field_i_info$name != field_j_info$name) {
              oh$error_list$add(
                "5.2.2",
                "Two matching return fields must have the same original field name\n",
                "Current fields: ", field_string(field_i_info), ", ", field_string(field_j_info)
              )
              next
            }

            # fieldA and fieldB must have identical sets of arguments.
            if (any(
              !is.null(field_i_info$field$arguments),
              !is.null(field_j_info$field$arguments)
            )) {
              if (!identical(
                capture.output(str(field_i_info$field$arguments)),
                capture.output(str(field_j_info$field$arguments))
              )) {
                oh$error_list$add(
                  "5.2.2",
                  "Two matching return fields must have identical arguments\n",
                  "Current fields: ", field_string(field_i_info), ", ", field_string(field_j_info)
                )
                next
              }
            }

            # Let mergedSet be the result of adding the selection set of fieldA and the selection set of fieldB.
            # FieldsInSetCanMerge(mergedSet) must be true.
            if (!is.null(field_i_info$field$selectionSet) || !is.null(field_j_info$field$selectionSet)) {
              # Let mergedSet be the result of adding the selection set of fieldA and the selection set of fieldB.
              merged_set <- SelectionSet$new(
                selections = append(
                  InlineFragment$new(
                    typeCondition = field_i_info$return_type,
                    selectionSet = field_i_info$field$selectionSet$selections
                  ),
                  InlineFragment$new(
                    typeCondition = field_j_info$return_type,
                    selectionSet = field_j_info$field$selectionSet$selections
                  )
                )
              )
              return_type_obj <- oh$schema_obj$get_type(field_i_info$return_type_obj)
              validate_fields_can_merge(merged_set, return_type_obj, oh = oh)
            }
          }


        }
      }
    }

  }

  invisible(selection_set)
}

field_string <- function(field_info) {
  if (field_info$to_name == field_info$name) {
    field_info$name
  } else {
    str_c(field_info$to_name, ": ", field_info$name)
  }
}

validate_fields_have_same_response_shape <- function(field_i_info, field_j_info, ..., oh) {
  # Let typeA be the return type of fieldA.
  type_i <- field_i_info$return_type
  # Let typeB be the return type of fieldB.
  type_j <- field_j_info$return_type

  do_again <- TRUE
  while(do_again) {
    do_again <- FALSE
    # If typeA or typeB is Non‐Null.
    if (inherits(type_i, "NonNullType") || inherits(type_j, "NonNullType")) {
      # typeA and typeB must both be Non‐Null.
      if (
        (!inherits(type_i, "NonNullType")) ||
        (!inherits(type_j, "NonNullType"))
      ) {
        oh$error_list$add(
          "5.2.2",
          "Two matching return fields must both be NonNullType if one value is NonNullType. ",
          "Current fields: ", field_string(field_i_info), ", ", field_string(field_j_info), "\n",
          "Currently returning: ", format(type_i), " and ", format(type_j)
        )
        return(FALSE)
      }
      # Let typeA be the nullable type of typeA
      type_i <- type_i$type
      # Let typeB be the nullable type of typeB
      type_j <- type_j$type
    }

    # If typeA or typeB is List.
    if (inherits(type_i, "ListType") || inherits(type_j, "ListType")) {
      # typeA and typeB must both be List.
      if (
        (!inherits(type_i, "ListType")) ||
        (!inherits(type_j, "ListType"))
      ) {
        oh$error_list$add(
          "5.2.2",
          "Two matching return fields must both be ListType if one value is ListType. ",
          "Current fields: ", field_string(field_i_info), ", ", field_string(field_j_info), "\n",
          "Currently returning: ", format(type_i), " and ", format(type_j)
        )
        return(FALSE)
      }
      # Let typeA be the item type of typeA
      type_i <- type_i$type
      # Let typeB be the item type of typeB
      type_j <- type_j$type
      # Repeat from step 3.
      do_again <- TRUE
    }
  }

  type_i_str <- format(type_i)
  type_j_str <- format(type_j)

  # If typeA or typeB is Scalar or Enum.
  if (
    (!is.null(oh$schema_obj$get_scalar_or_enum(type_i))) ||
    (!is.null(oh$schema_obj$get_scalar_or_enum(type_j)))
  ) {
    # typeA and typeB must be the same type.
    if (!identical(type_i_str, type_j_str)) {
      oh$error_list$add(
        "5.2.2",
        "Two matching return names must return the same types. \n",
        "Current fields: ", field_string(field_i_info), ", ", field_string(field_j_info), "\n",
        "Currently returning: ", type_i_str, " and ", type_j_str
      )
      return(FALSE)
    }
    return(TRUE)

  }

  # Assert: typeA and typeB are both composite types.
  composite_i <- oh$schema_obj$get_object_interface_or_union(type_i)
  composite_j <- oh$schema_obj$get_object_interface_or_union(type_j)
  if (
    is.null(composite_i) ||
    is.null(composite_j)
  ) {
    oh$error_list$add(
      "5.2.2",
      "Two matching return names must return an Object, Interface, or Union ",
      "if they do not return a Scalar or Enum.  \n",
      "Currently returning: ", type_i_str, " and ", type_j_str
    )
    return(FALSE)
  }

  # Let mergedSet be the result of adding the selection set of fieldA and the selection set of fieldB.
  # Let fieldsForName be the set of selections with a given response name in mergedSet including visiting fragments and inline fragments.
  # Given each pair of members subfieldA and subfieldB in fieldsForName:
    # SameResponseShape(subfieldA, subfieldB) must be true.
  merged_set <- SelectionSet$new(
    selections = append(
      InlineFragment$new(
        typeCondition = field_i_info$return_type,
        selectionSet = field_i_info$field$selectionSet$selections
      ),
      InlineFragment$new(
        typeCondition = field_j_info$return_type,
        selectionSet = field_j_info$field$selectionSet$selections
      )
    )
  )
  return_type_obj <- oh$schema_obj$get_type(field_i_info$return_type_obj)
  # TODO double check logic here.
  validate_fields_can_merge(
    merged_set, return_type_obj,
    oh = oh
  )
  # validate_fields_can_merge(
  #   selection_set, matching_obj,
  #   oh = oh,
  #   same_response_shape_only = TRUE
  # )

  TRUE
}
