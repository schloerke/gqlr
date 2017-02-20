# TODO reduce fields to unique names
# should be done at execution stage


## Major Sections
# 5.1 Operations - DONE
# 5.2 Fields     -
  # 5.2.1 - Field selections on objects - DONE
  # 5.2.2 - Field Selection Merging     - TODO
  # 5.2.3 - Leaf Field Selections       - DONE
# 5.3 Arguments  -
  # 5.3.3.1 - Compatible Values - TODO
# 5.4 Fragments  - DONE (TODO Mutatation)
# 5.5 Values     - DONE
# 5.6 Directives - DONE
# 5.7 Variables  -
  # 5.7.2 - Variable Default Values Are Correctly Typed - TODO type coersion
  # 5.7.6 - All Variable Usages are Allowed - TODO need type coersion






validate_query <- function(document_obj, schema_obj, ...) {

  validate_operation_names(document_obj, schema_obj, ...)

  document_obj <- upgrade_query_remove_fragments(document_obj, schema_obj)

  validate_field_selections(document_obj, schema_obj, ...)

  document_obj
}



# √5.1.1.1 - Operation Name Uniqueness
# √5.1.2.1 - Lone Anonymous Operation
validate_operation_names <- function(document_obj, ...) {
  # 5.1.1.1 - Operation Name Uniqueness
    # All operation names must be unique.
      # A single missing name is unique
  missing_count <- 0
  query_mutation_count <- 0
  seen_names <- list()

  for (definition in document_obj$definitions) {
    if (is.null(definition$.args$name)) {
      # doens't have name object, such as TypeSystemDefinition
      next
    }

    if (!is.null(definition$operation)) {
      if (definition$operation %in% c("query", "mutation")) {
        query_mutation_count <- query_mutation_count + 1
      }
    }

    name_val <- definition$name$value
    if (is.null(name_val)) {
      missing_count <- missing_count + 1
    } else {
      if (isTRUE(seen_names[[name_val]])) {
        stop(
          "document definition",
          " has duplicate return name: ", name_val
        )
      }
      seen_names[[name_val]] <- TRUE
    }

    invisible(TRUE)
  }

  # 5.1.2.1 - Lone Anonymous Operation
    # if there is a missing name and a provided name, throw error
  if (missing_count > 0 & query_mutation_count > 1) {
    stop(
      "document definition: ", document_obj$.title,
      " has an anonymous and defined definition.",
      " This is not allowed."
    )
  }

}










# 5.2.1 - Field Selections on Objects, Interfaces, and Unions Types
validate_field_selections <- function(document_obj, schema_obj, ...) {

  for (operation in document_obj$definitions) {

    if (!is.null(operation$operation)) {
      # is operation

      var_validator <- validate_variables(operation$variableDefinitions, schema_obj)

      validate_directives(operation$directives, schema_obj = schema_obj, parent_obj = operation, ..., variable_validator = var_validator)

      if (operation$operation == "query") {
        validate_fields_in_selection_set(operation$selectionSet, schema_obj$get_object("QueryRoot"), schema_obj, ..., variable_validator = var_validator)
      } else if (operation$operation == "mutation") {
        stop("TODO. not implemented")
      }

      var_validator$finally()

    } else {
      stop("this shouldn't happen. there should be no more fragments")
    }

  }
}


# selection_set_obj should only be comprised of fields and inline fragments
validate_fields_in_selection_set <- function(selection_set_obj, object, schema_obj, ..., variable_validator) {
  selection_obj_list <- selection_set_obj$selections
  selection_names <- get_name_values(selection_obj_list)

  object_field_list <- object$fields

  obj_field_names <- get_name_values(object_field_list)

  # recursively look into subfields
  for (selection_obj in selection_obj_list) {

    if (inherits(selection_obj, "FragmentSpread")) {
      stop("this should not occur")

    } else if (inherits(selection_obj, "InlineFragment")) {

      type_condition <- ifnull(selection_obj$typeCondition, object$name)

      matching_obj <- schema_obj$get_object_interface_or_union(type_condition)

      # get the object that it's looking at, then validate those fields
      validate_fields_in_selection_set(
        selection_obj$selectionSet,
        matching_obj,
        schema_obj,
        ...,
        variable_validator = variable_validator
      )
      # since validation is done within a "new" context, call next to avoid complications
      next

    } else if (inherits(selection_obj, "Field")) {
      # make sure all request names exist in return obj
      if (! (selection_obj$name$value %in% obj_field_names)) {
        if (inherits(object, "UnionTypeDefinition")) {
          # 5.2.1 - can't query fields directly on a union object
          bad_field_names <- selection_names[! (selection_names %in% c("__typename"))]
          stop(
            "fields may not be queried directly on a union object, except for '__typename'.  ",
            "Not allowed to ask for fields: ", str_c(bad_field_names, collapse = ", ")
          )
        } else {
          stop(
            "not all requested names are found.",
            " missing field: '", selection_obj$name$value, "'",
            " for object: '", object$.title, "'"
          )
        }
      }

    } else {
      str(selection_obj)
      stop("unknown field type")
    }

    field_name <- selection_obj$name$value
    matching_obj_field <- object_field_list[[which(field_name == obj_field_names)]]

    validate_arguments(selection_obj$arguments, matching_obj_field, schema_obj, ..., variable_validator = variable_validator)

    if (!is.null(selection_obj$selectionSet)) {
      matching_obj <- schema_obj$get_object(matching_obj_field$type$name)
      if (is.null(matching_obj)) {
        # 5.2.3 - if is leaf, can not dig deeper
        stop(
          "unknown object definition for field: '", selection_obj$name$value, "'.",
          " Not allowed to query deeper into leaf field selections."
        )
      }
      validate_fields_in_selection_set(
        selection_obj$selectionSet,
        schema_obj$get_object(matching_obj_field$type$name),
        schema_obj,
        ...,
        variable_validator = variable_validator
      )
    } else {
      # no sub selection set, make sure this is ok
      # browser()
      if (inherits(selection_obj, "Field")) {
        matching_obj <- schema_obj$get_object_interface_or_union(matching_obj_field$type)
        if (!is.null(matching_obj)) {
          stop(
            "non leaf selection does not have any children.",
            " Missing children fields for field: '", selection_obj$name$value, "'."
          )
        }
      }
    }
  }

}


# TODO
# 5.2.2 - Field Selection Merging







# 5.4 - Fragments. In upgrade_query_remove_fragments.R


# 5.5.1 - Input Object Field Uniqueness
validate_input_object_field_uniqueness <- function(object_value, schema_obj, ...) {
  validate_field_names(object_value, "input object value")
}


# √5.6.1 - Directives Are Defined - Must be done in execution stage
# √5.6.2 - Directives Are In Valid Locations - Must be done in execution stage
# √5.6.3 - Directives Are Unique Per Location - Must be done in execution stage
# √must also call validate_arguments on all directive args
validate_directives <- function(directive_objs, schema_obj, parent_obj, ...) {
  if (is.null(directive_objs)) {
    return(directive_objs)
  }
  if (length(directive_objs) == 0) {
    return(directive_objs)
  }

  directives <- lapply(directive_objs, validate_directive, schema_obj = schema_obj, parent_obj = parent_obj, ...)

  if (length(directives) > 0) {
    directive_names <- lapply(directives, `[[`, "name") %>% lapply(`[[`, "value") %>% unlist()
    # 5.6.3
    if (length(unique(directive_names)) != length(directives)) {
      stop(
        "All directives must be unique when used in on the same object.",
        "  Currently found the following directives: '", str_c(directive_names, collapse = "', '"), "'"
      )
    }
  }

  directives
}
validate_directive <- function(directive_obj, schema_obj, parent_obj, ...) {
  if (is.null(directive_obj)) {
    return(directive_obj)
  }

  directive_definition <- schema_obj$get_directive(directive_obj$name)

  # 5.6.1 - must be difined
  if (is.null(directive_definition)) {
    stop("all directives must be defined. Missing defintion for directive: '", directive_obj$name$value, "'")
  }

  validate_arguments(directive_obj$arguments, directive_definition, schema_obj, ...)

  # [Name]
  directive_definition$locations %>%
    lapply(`[[`, "value") %>%
    unlist() ->
  directive_possible_locations

  # 5.6.2
  parent_cur_location <- directive_current_location(parent_obj)

  if (!(parent_cur_location %in% directive_possible_locations)) {
    stop(
      "directive: '", directive_obj$name$value,
      "' is being used in a '", parent_cur_location, "' situation.",
      " Can only be used in: '", str_c(directive_possible_locations, collapse = "', '"), "'"
    )
  }

  directive_obj
}


directive_current_location <- function(parent_obj) {

  parent_kind <- parent_obj$.kind

  switch(parent_kind,
    # query
    "OperationDefinition" =
      switch(parent_obj$operation,
        query = "QUERY",
        mutation = "MUTATION"
      ),

    "Field" = "FIELD",
    "FragmentDefinition" = "FRAGMENT_DEFINITION",
    "FragmentSpread" = "FRAGMENT_SPREAD",
    "InlineFragment" = "INLINE_FRAGMENT",

    # Schema Definitions
    "SchemaDefinition" = "SCHEMA",
    "ScalarTypeDefinition" = "SCALAR",
    "ObjectTypeDefinition" = "OBJECT",
    "FieldDefinition" = "FIELD_DEFINITION",
    "Argument" = "ARGUMENT_DEFINITION",
    "InterfaceTypeDefinition" = "INTERFACE",
    "UnionTypeDefinition" = "UNION",
    "EnumTypeDefinition" = "ENUM",
    "EnumValueDefinition" = "ENUM_VALUE",
    "InputObjectTypeDefinition" = "INPUT_OBJECT",
    "InputValueDefinition" = "INPUT_FIELD_DEFINITION"
  )

}


# TODO - Must be done in execution stage










