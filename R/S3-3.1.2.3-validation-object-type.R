get_name_values <- function(list_obj) {
  name_objs <- lapply(list_obj, "[[", "name")
  name_vals <- lapply(name_objs, "[[", "value")
  unlist(name_vals)
}


# helper to check for more than one field and unique field names
validate_field_names <- function(x, error_title, error_code, ..., oh) {
  # must have one or more fields
  object_fields <- x$fields
  if (length(object_fields) == 0) {
    oh$error_list$add(
      error_code,
      error_title, " definiiton: ", x$.title, " must have at least one field"
      # no loc
    )
    return(FALSE)
  }

  # fields must have unique names
  field_names <- get_name_values(object_fields)

  if (any(duplicated(field_names))) {
    oh$error_list$add(
      error_code,
      error_title, " defintion: ", x$.title, " must have unique field names"
      # no loc
    )
    return(FALSE)
  }
  return(TRUE)
}


# 3.1.3.1 - Interface type validation
#
# Interface types have the potential to be invalid if incorrectly defined.
#
#   * An Interface type must define one or more fields.
#   * The fields of an Interface type must have unique names within that Interface type;
#     no two fields may share the same name.
validate_interface_type <- function(x, ..., oh) {

  validate_field_names(x, "interface", "3.1.3.1", oh = oh)

  return(invisible(TRUE))
}




# 3.1.4.1 - Union type validation
#
# Union types have the potential to be invalid if incorrectly defined.
#
# * The member types of a Union type must all be Object base types; Scalar, Interface and
#   Union types may not be member types of a Union. Similarly, wrapping types may not be member
#   types of a Union.
# * A Union type must define one or more member types.

validate_union_type <- function(x, ..., oh) {

  types <- x$types
  if (length(types) == 0) {
    oh$error_list$add(
      "3.1.4.1",
      "union definition: ", x$.title, " must have at least one type."
      # no loc
    )
    return(FALSE)
  }

  lapply(types, function(type) {
    type_object <- oh$schema$get_object(type)

    if (is.null(type_object)) {
      oh$error_list$add(
        "3.1.4.1",
        "union definition: ", x$.title,
        " types can only be objects.",
        " Scalar, Interface, and Union types may not be member types of a Union."
        # no loc
      )
      return(FALSE)
    }
  })

  invisible(TRUE)
}





# 3.1.6.1 - Input Object type validation
#
# * An Input Object type must define one or more fields.
# * The fields of an Input Object type must have unique names within that Input Object type;
#   no two fields may share the same name.
# * The return types of each defined field must be an Input type.

validate_input_object_type <- function(x, ..., oh) {
  validate_field_names(x, "input object", "3.1.6.1", oh = oh)

  lapply(x$fields, function(field) {
    type_obj <- oh$schema$get_type(field$type)

    if (is.null(type_obj)) {
      oh$error_list$add(
        "3.1.6.1",
        "input object: ", x$.title,
        " must return a InputType",
        " for field: ", field$.title
        # no loc
      )
      return(FALSE)
    }
  })
}




# 3.1.2.3 Object type validation
#
# Object types have the potential to be invalid if incorrectly defined. This set of rules must be
# adhered to by every Object type in a GraphQL schema.
#
#   1. An Object type must define one or more fields.
#   2. The fields of an Object type must have unique names within that Object type; no two fields may share the same name.
#   3. Each field of an Object type must not have a name which begins with the characters "__" (two underscores).
#   4. An object type must be a super‐set of all interfaces it implements:
#     1. The object type must include a field of the same name for every field defined in
#       an interface.
#       1. The object field must be of a type which is equal to or a sub‐type of the interface
#         field (covariant).
#         1. An object field type is a valid sub‐type if it is equal to (the same type as) the
#           interface field type.
#         2. An object field type is a valid sub‐type if it is an Object type and the interface
#           field type is either an Interface type or a Union type and the object field type is a
#           possible type of the interface field type.
#         3. An object field type is a valid sub‐type if it is a List type and the interface field
#           type is also a List type and the list‐item type of the object field type is a valid
#           sub‐type of the list‐item type of the interface field type.
#         4. An object field type is a valid sub‐type if it is a Non‐Null variant of a valid
#           sub‐type of the interface field type.
#       2. The object field must include an argument of the same name for every argument defined in
#         the interface field.
#         1. The object field argument must accept the same type (invariant) as the interface field
#           argument.
#       3. The object field may include additional arguments not defined in the interface field,
#         but any additional argument must not be required.
validate_object_type <- function(x, ..., oh) {

  # 1. An Object type must define one or more fields.
  # 2. The fields of an Object type must have unique names within that Object type;
  #    no two fields may share the same name.
  if (!validate_field_names(x, "object", "3.1.2.3", oh = oh)) {
    return(FALSE)
  }
  object_fields <- x$fields
  field_names <- get_name_values(object_fields)

  # 3. Each field of an Object type must not have a name which begins
  #    with the characters "__" (two underscores).
  stars_with_double_underscore <- str_detect(field_names, "^__")
  can_not_have_double_underscore <- lapply(object_fields, `[[`, ".allow_double_underscore") %>%
    unlist() %>%
    magrittr::not()

  if (any(stars_with_double_underscore & can_not_have_double_underscore)) {
    oh$error_list$add(
      "3.1.2.3",
      "object definition: ", format(x$name), " can not have any fields starting with '__'"
      # no loc
    )
  }

  interfaces <- x$interfaces
  if (is.null(interfaces)) {
    return(invisible(TRUE))
  }

  # check for interfaces
  #  4. An object type must be a super‐set of all interfaces it implements:
  lapply(interfaces, function(interface_named_type) {
    interface_obj <- oh$schema$get_interface(interface_named_type)

    interface_fields <- interface_obj$fields

    lapply(interface_fields, function(interface_field) {

      interface_field_name <- interface_field$name$value


      # 1. An object field type is a valid sub‐type if it is equal to (the same type as)
      #    the interface field type.
      # 2. An object field type is a valid sub‐type if it is an Object type and the interface
      #    field type is either an Interface type or a Union type and the object field type is a
      #    possible type of the interface field type.
      # 3. An object field type is a valid sub‐type if it is a List type and the interface field
      #    type is also a List type and the list‐item type of the object field type is a valid
      #    sub‐type of the list‐item type of the interface field type.
      # 4. An object field type is a valid sub‐type if it is a Non‐Null variant of a valid
      #    sub‐type of the interface field type.

      # 1. The object type must include a field of the same name for every field defined in an
      #    interface.
      if (! (interface_field_name %in% field_names)) {
        oh$error_list$add(
          "3.1.2.3",
          "object definition: ", x$.title, " must implement all fields of interface: ",
          interface_obj$.title, ". Missing field: ", interface_field_name
          # no loc
        )
        return(FALSE)
      }

      matching_obj_field <- object_fields[[which(field_names == interface_field_name)]]
      # check the type

      # TODO check the field type in the interface
      # 1. The object field must be of a type which is equal to or a sub‐type of the interface
      #    field (covariant).



      # check the args
      interface_field_args <- interface_field$arguments
      interface_field_arg_names <- get_name_values(interface_field_args)
      matching_obj_field_args <- matching_obj_field$arguments
      matching_obj_field_arg_names <- get_name_values(matching_obj_field_args)

      # 2. The object field must include an argument of the same name for every argument defined
      #    in the interface field.
      if (
        (! all(interface_field_arg_names %in% matching_obj_field_arg_names))
      ) {
        oh$error_list$add(
          "3.1.2.3",
          "object definition: ", format(x$name),
          " must have at least the same argument names",
          " of interface: ", format(interface_obj$name),
          " for field: ", interface_field_name
          # no loc
        )
        return(FALSE)
      }

      # 3. The object field may include additional arguments not defined in the interface field,
      #    but any additional argument must not be required.
      not_in_interface <- !(matching_obj_field_arg_names %in% interface_field_arg_names)
      field_args_not_in_interface <- matching_obj_field_args[not_in_interface]
      lapply(
        field_args_not_in_interface,
        function(extra_field_arg) {
          if (inherits(extra_field_arg$type, "NonNullType")) {
            oh$error_list$add(
              "3.1.2.3",
              "object definition: ", format(x$name),
              " when looking at interface: ", format(interface_obj$name),
              " for field: ", interface_field_name,
              " all additional arguments (", format(extra_field_arg$name), ") must not be required"
              # no loc
            )
            return(FALSE)
          }
        }
      )

      # all interface args must exist and have the same type
      lapply(interface_field_arg_names, function(interface_field_arg_name) {

        interface_field_arg <- interface_field_args[[which(
          interface_field_arg_names == interface_field_arg_name
        )]]
        matching_obj_field_arg <- matching_obj_field_args[[which(
          matching_obj_field_arg_names == interface_field_arg_name
        )]]

        # produce string representation of the type object.  Similar to '[__Type!]!'
        matching_txt <- format(matching_obj_field_arg$type)
        int_txt <- format(interface_field_arg$type)

        # 1. The object field argument must accept the same type (invariant) as the interface
        #    field argument.
        if (matching_txt != int_txt) {
          oh$error_list$add(
            "3.1.2.3",
            "object definition: ", format(x$name),
            " of interface: ", format(interface_obj$name),
            " for field: ", interface_field_name,
            " must input the same type: ", matching_txt,
            " for argument: ", interface_field_arg_name
            # no loc
          )
          return(FALSE)
        }

      })


    })

  })

  return(invisible(oh$error_list$has_no_errors()))

}





validate_schema <- function(..., oh) {
  if (isTRUE(oh$schema$is_valid)) {
    return(TRUE)
  }

  interfaces <- oh$schema$get_interfaces()
  lapply(interfaces, validate_interface_type, oh = oh)

  unions <- oh$schema$get_unions()
  lapply(unions, validate_union_type, oh = oh)

  input_objects <- oh$schema$get_input_objects()
  lapply(input_objects, validate_input_object_type, oh = oh)

  objects <- oh$schema$get_objects()
  lapply(objects, validate_object_type, oh = oh)

  oh$schema$is_valid <- oh$error_list$has_no_errors()

  oh$error_list$has_no_errors()
}
