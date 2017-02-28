#' @include validation-selection-set-can-merge.R
#' @include validation-arguments.R
#' @include upgrade_query_remove_fragments.R
#' @include validation-input-coercion.R

# TODO reduce fields to unique names
# should be done at execution stage


## Major Sections
# 5.1 Operations - DONE
# 5.2 Fields     - DONE
# 5.3 Arguments  - DONE
# 5.4 Fragments  - DONE (TODO Mutatation)
# 5.5 Values     - DONE
# 5.6 Directives - DONE
# 5.7 Variables  -
  # 5.7.6 - All Variable Usages are Allowed - TODO need type coercion






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
      matching_obj <- schema_obj$get_object_interface_or_union(matching_obj_field$type$name)
      if (is.null(matching_obj)) {
        # 5.2.3 - if is leaf, can not dig deeper
        stop(
          "unknown object definition for field: '", selection_obj$name$value, "'.",
          " Not allowed to query deeper into leaf field selections."
        )
      }
      validate_fields_in_selection_set(
        selection_obj$selectionSet,
        matching_obj,
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

  # must be done after union check in forloop above
  validate_fields_can_merge(selection_set_obj, schema_obj, object)



}







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


# √5.7.1 - Variable Uniqueness
# √5.7.2 - Variable Default Values Are Correctly Typed
# √5.7.3 - Variables Are Input Types
# √5.7.4 - All Variable Uses Defined
# √5.7.5 - All Variables Used
# 5.7.6 - All Variable Usages are Allowed - TODO need type coercion
validate_variables <- function(operation_variables, schema_obj, ...) {
  var_validator <- VariableValdationHelper$new(operation_variables, schema_obj)

  var_validator
}


VariableValdationHelper <- R6Class("VariableValdationHelper",
  public = list(
    names = character(0),
    has_been_seen = list(),
    type = list(),
    variables = list(),
    schema_obj = NULL,

    check_variable = function(var) {
      if (is.null(var)) {
        return(invisible(TRUE))
      }

      var_name <- graphql_string(var$name)

      matching_var <- self$variables[[var_name]]

      # 5.7.4 - All Variable Uses Defined
      if (is.null(matching_var)) {
        stop("Matching variable definition can not be found for variable: ", var_name)
      }

      self$has_been_seen[[var_name]] <- TRUE

      invisible(TRUE)
    },


    finally = function() {

      # 5.7.5 - All Variables Used
      has_been_seen <- unlist(self$has_been_seen)
      if (!all(has_been_seen)) {
        stop(
          "Not all variable definitions have been seen.",
          " Unused variables: ", names(has_been_seen)[!has_been_seen]
        )
      }

      invisible(TRUE)
    },


    default_value_can_be_coerced = function(from_input, to_type) {
      validate_value_can_be_coerced(from_input, to_type, self$schema_obj)
    },


    initialize = function(vars, schema_obj) {
      if (is.null(vars)) {
        return(invisible(self))
      }

      if (!is.list(vars)) stop("vars must be a list")

      self$variables <- list()
      self$schema_obj = schema_obj

      vars %>%
        lapply(function(var) {
          name <- graphql_string(var$variable$name)

          self$variables[[name]] <- var
          self$has_been_seen[[name]] <- FALSE

          self$type[[name]] <- var$type

          # 5.7.2
          default_value_obj <- var$defaultValue
          if (!is.null(default_value_obj)) {
            if (inherits(var$type, "NonNullType")) {
              stop(
                "Non-Null Variables are not allowed to have default values. ",
                " Found a default value for variable: ", name
              )
            }

            default_val <- var$defaultValue$value
            if (!is.null(default_val)) {
              type_obj <- schema_obj$get_type(schema_obj$name_helper(var$type))

              self$default_value_can_be_coerced(
                from_input = var$defaultValue,
                to_type = var$type
              )
            }
          }


          # 5.7.3 - Variables Are Input Types
          core_var_type <- var$type
          while(
            inherits(core_var_type, "ListType") ||
            inherits(core_var_type, "NonNullType")
          ) {
            core_var_type <- core_var_type$type
          }
          matching_core_type_object <- ifnull(
            schema_obj$get_scalar(core_var_type), ifnull(
            schema_obj$get_enum(core_var_type),
            schema_obj$get_input_object(core_var_type)
          ))

          if (is.null(matching_core_type_object)) {
            stop(
              "Can not find matching Scalar, Enum, or Input Object with type: ",
              schema_obj$name_helper(var$type),
              " for variable: ", name
            )
          }


          name
        }) %>%
        unlist() ->
      names

      self$names <- names

      # 5.7.1 - Variable Uniqueness
      if (length(names) != length(unique(names))) {
        name_count <- table(names)
        name_count <- name_count[name_count > 1]
        duplicate_names <- names(name_count)
        stop(
          "All defined variables must be unique.",
          " Found duplicates of name: ", str_c(duplicate_names, collapse = ", ")
        )
      }

      self$names <- names



    }
  )


)
