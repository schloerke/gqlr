# TODO reduce fields to unique names
# should be done at execution stage


## Major Sections
# 5.1 Operations - DONE
# 5.2 Fields     - TODO
  # 5.2.1 - Field selections on objects - DONE
  # 5.2.2 - Field Selection Merging     - TODO
  # 5.2.3 - Leaf Field Selections       - TODO
# 5.3 Arguments  - DONE
# 5.4 Fragments  - DONE
# 5.5 Values     - TODO
# 5.6 Directives - TODO
# 5.7 Variables  - TODO






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
      if (operation$operation == "query") {
        validate_fields_in_selection_set(operation$selectionSet, schema_obj$get_object("QueryRoot"), schema_obj, ...)
      } else if (operation$operation == "mutation") {
        stop("TODO. not implemented")
      }
    } else {
      stop("this shouldn't happen. there should be no more fragments")
    }

  }
}


# selection_set_obj should only be comprised of fields and inline fragments
validate_fields_in_selection_set <- function(selection_set_obj, object, schema_obj, ...) {
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
        ...
      )
      # since validation is done within a "new" context, call next to avoid complications
      next

    } else if (inherits(selection_obj, "Field")) {
      # make sure all request names exist in return obj
      if (! (selection_obj$name$value %in% obj_field_names)) {
        stop(
          "not all requested names are found.",
          " missing field: ", selection_obj$name$value,
          " for object: ", object$.title
        )
      }

    } else {
      str(selection_obj)
      stop("unknown field type")
    }

    field_name <- selection_obj$name$value
    matching_obj_field <- object_field_list[[which(field_name == obj_field_names)]]

    if (
      !is.null(selection_obj$arguments) ||
      !is.null(matching_obj_field$arguments)
    ) {
      validate_arguments(selection_obj$arguments, matching_obj_field, schema_obj, ...)
    }


    if (!is.null(selection_obj$selectionSet)) {
      validate_fields_in_selection_set(
        selection_obj$selectionSet,
        schema_obj$get_object(matching_obj_field$type$name),
        schema_obj,
        ...
      )
    }
  }

}


# TODO
# 5.2.2 - Field Selection Merging

# TODO
# 5.2.3 - Leaf Field Selections






# 5.4 - Fragments. In upgrade_query_remove_fragments.R


# 5.5.1 - Input Object Field Uniqueness
# TODO TESTS
validate_input_object_field_uniqueness <- function(object_value, schema_obj, ...) {
  print("found!")
  validate_field_names(object_value, "object value")
}


# TODO
# 5.6.1 - Directives Are Defined - Must be done in execution stage
# 5.6.2 - Directives Are In Valid Locations - Must be done in execution stage
# 5.6.3 - Directives Are Unique Per Location - Must be done in execution stage
# must also call validate_arguments on all directive args



# TODO - Must be done in execution stage
# 5.7.1 - Variable Uniqueness
# 5.7.2 - Variable Default Values Are Correctly Typed
# 5.7.3 - Variables Are Input Types
# 5.7.4 - All Variable Uses Defined
# 5.7.5 - All Variables Used
# 5.7.6 - All Variable Usages are Allowed
