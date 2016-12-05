# 3.1.2.3 Object type validation
#
# Object types have the potential to be invalid if incorrectly defined. This set of rules must be
# adhered to by every Object type in a GraphQL schema.
#
#   *√ An Object type must define one or more fields.
#   *√ The fields of an Object type must have unique names within that Object type; no two fields
#     may share the same name.
#   * An object type must be a super‐set of all interfaces it implements:
#     *√ The object type must include a field of the same name for every field defined in
#       an interface.
#       * The object field must be of a type which is equal to or a sub‐type of the interface
#         field (covariant).
#         * An object field type is a valid sub‐type if it is equal to (the same type as) the
#           interface field type.
#         * An object field type is a valid sub‐type if it is an Object type and the interface
#           field type is either an Interface type or a Union type and the object field type is a
#           possible type of the interface field type.
#         * An object field type is a valid sub‐type if it is a List type and the interface field
#           type is also a List type and the list‐item type of the object field type is a valid
#           sub‐type of the list‐item type of the interface field type.
#         * An object field type is a valid sub‐type if it is a Non‐Null variant of a valid
#           sub‐type of the interface field type.
#       *√ The object field must include an argument of the same name for every argument defined in
#         the interface field.
#         *√ The object field argument must accept the same type (invariant) as the interface field
#           argument.
#       *√ The object field may include additional arguments not defined in the interface field,
#         but any additional argument must not be required.


validate.ObjectTypeDefinition <- function(x, schema_obj, ...) {

  get_name_values <- function(fields) {
    fields
      lapply("[[", "name") %>%
      lapply("[[", "value") %>%
      unlist()
  }

  # must have one or more fields
  object_fields <- x$fields
  if (length(object_fields) == 0) {
    stop("object definiiton: ", x$.title, " must have at least one field")
  }

  # fields must have unique names
  field_names <- get_name_values(object_fields)

  if (any(duplicated(field_names))) {
    stop("object defintion: ", x$.title, " must have unique field names")
  }

  interfaces <- x$interfaces
  if (is.null(interfaces)) {
    return(invisible(TRUE))
  }

  # check for interfaces
  lapply(interfaces, function(interface_named_type) {
    interface_obj <- schema_obj$get_interface(interface_named_type)

    interface_fields <- interface_obj$fields

    lapply(interface_fields, function(interface_field) {

      interface_field_name <- interface_field$name$value

      # object must implement every interface field name
      if (! (interface_field_name %in% field_names)) {
        stop("object definition: ", x$.title, " must implement all fields of interface: ", interface_obj$.title, ". Missing field: ", interface_field_name)
      }

      matching_obj_field <- objet_fields[[field_names == interface_field_name]]

      # check the type

      # TODO check the field type in the interface


      # check the args
      interface_field_args <- interface_field$arguments
      interface_field_arg_names <- get_name_values(interface_field_args)
      matching_obj_field_args <- matching_obj_field$arguments
      matching_obj_field_arg_names <- get_name_values(matching_obj_field_args)

      if (
        length(interface_field_arg_names) != lengths(matching_obj_field_arg_names)
      ) {
        stop(
          "object definition: ", x$.title,
          " must have the same arguments",
          " of interface: ", interface_obj$.title,
          " for field: ", interface_field_name
        )
      }

      # The object field may include additional arguments not defined in the interface field,
      #         but any additional argument must not be required.
      not_in_interface <- (interface_field_arg_names %in% matching_obj_field_arg_names)
      field_args_not_in_interface <- interface_field_args[[not_in_interface]]
      lapply(
        interface_field_args[[not_in_interface]],
        function(field_arg) {
          defaultVal <- field_arg$defaultValue
          if (!is.null(defaultVal)) {
            stop(
              "object definition: ", x$.title,
              " must have default values for non-interface argument: ", field_arg$name$value,
              " when looking at interface: ", interface_obj$.title,
              " for field: ", interface_field_name
            )
          }
        }
      )

      # all interface args must exist and have the same type
      lapply(interface_field_arg_names, function(interface_field_arg_name) {

        if (! (interface_field_arg_name %in% matching_obj_field_arg_names)) {
          stop(
            "object definition: ", x$.title,
            " must implement argument: ", interface_field_arg_name,
            " of interface: ", interface_obj$.title,
            " for field: ", interface_field_name
          )
        }

        interface_field_arg <- interface_field_args[[
          interface_field_arg_names == interface_field_arg_name
        ]]
        matching_obj_field_arg <- matching_obj_field_args[[
          matching_obj_field_arg_names == interface_field_arg_name
        ]]

        # produce string representation of the type object.  Similar to '[__Type!]!'
        matching_obj_field_arg_type <- graphql_string(matching_obj_field_arg$type)
        interface_field_arg_type <- graphql_string(interface_field_arg$type)

        if (matching_obj_field_arg_type != interface_field_arg_type) {
          stop(
            "object definition: ", x$.title,
            " of interface: ", interface_obj$.title,
            " for field: ", interface_field_name,
            " must input the same type: ", matching_obj_field_arg_type,
            " for argument: ", interface_field_arg_name
          )
        }

      })


    })

  })

  return(invisible(TRUE))

}
