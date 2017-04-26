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
# 5.7 Variables  - DONE





# oh <- ObjectHelpers$new(schema_obj, error_list)
#' @export
validate_query <- function(document_obj, ..., oh) {

  validate_operation_names(document_obj, oh = oh)
  if (oh$error_list$has_any_errors()) return(document_obj)

  document_obj <- upgrade_query_remove_fragments(document_obj, oh = oh)
  if (oh$error_list$has_any_errors()) return(document_obj)

  validate_field_selections(document_obj, oh = oh)
  document_obj
}



# √5.1.1.1 - Operation Name Uniqueness
# √5.1.2.1 - Lone Anonymous Operation
validate_operation_names <- function(document_obj, ..., oh) {
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

    # is query or mutation
    if (!is.null(definition$operation)) {
      if (definition$operation %in% c("query", "mutation")) {
        query_mutation_count <- query_mutation_count + 1

        name_val <- definition$name$value
        if (is.null(name_val)) {
          missing_count <- missing_count + 1
        } else {
          if (isTRUE(seen_names[[name_val]])) {
            oh$error_list$add(
              "5.1.1.1",
              "document definition has duplicate return name: ", name_val
            )
          }
          seen_names[[name_val]] <- TRUE
        }

      }
    }


  }

  # 5.1.2.1 - Lone Anonymous Operation
    # if there is a missing name and a provided name, throw error
  if (missing_count > 0 & query_mutation_count > 1) {
    oh$error_list$add(
      "5.1.2.1",
      "document definition: ", document_obj$.title,
      " has an anonymous and defined definition.",
      " This is not allowed."
    )
    return()
  }

}










# 5.2.1 - Field Selections on Objects, Interfaces, and Unions Types
validate_field_selections <- function(document_obj, ..., oh) {

  for (operation in document_obj$definitions) {

    if (!is.null(operation$operation)) {
      # is operation

      var_validator <- VariableValdationHelper$new(operation$variableDefinitions, oh = oh)
      oh$set_variable_validator(var_validator)

      validate_directives(
        operation$directives, parent_obj = operation,
        oh = oh
      )

      if (operation$operation == "query") {
        validate_fields_in_selection_set(
          operation$selectionSet, oh$schema_obj$get_query_object(),
          oh = oh
        )
      } else if (operation$operation == "mutation") {
        stop("TODO. not implemented")
      }

      oh$variable_validator$finally()
      oh$unset_variable_validator()

    } else {
      stop("this shouldn't happen. there should be no more fragments")
    }

  }
}


# selection_set_obj should only be comprised of fields and inline fragments
validate_fields_in_selection_set <- function(selection_set_obj, object, ..., oh) {
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

      matching_obj <- oh$schema_obj$get_object_interface_or_union(type_condition)

      # get the object that it's looking at, then validate those fields
      validate_fields_in_selection_set(
        selection_obj$selectionSet,
        matching_obj,
        oh = oh
      )
      # since validation is done within a "new" context, call next to avoid complications
      next

    } else if (inherits(selection_obj, "Field")) {
      # make sure all request names exist in return obj
      if (! (selection_obj$name$value %in% obj_field_names)) {
        if (selection_obj$name$value == "__typename") {
          next
        }
        if (inherits(object, "UnionTypeDefinition")) {
          # 5.2.1 - can't query fields directly on a union object
          bad_field_names <- selection_names[! (selection_names %in% c("__typename"))]
          oh$error_list$add(
            "5.2.1",
            "fields may not be queried directly on a union object, except for '__typename'.  ",
            "Not allowed to ask for fields: ", str_c(bad_field_names, collapse = ", ")
          )
          next

        } else {
          oh$error_list$add(
            "5.2.1",
            "not all requested names are found.",
            " missing field: '", selection_obj$name$value, "'",
            " for object: '", object$.title, "'"
          )
          next
        }
      }

    } else {
      str(selection_obj)
      stop("unknown field type")
    }

    field_name <- selection_obj$name$value
    matching_obj_field <- object_field_list[[which(field_name == obj_field_names)]]

    validate_arguments(
      selection_obj$arguments, matching_obj_field,
      oh = oh
    )

    if (!is.null(selection_obj$selectionSet)) {
      matching_type <- oh$schema_obj$get_inner_type(matching_obj_field$type)
      matching_obj <- oh$schema_obj$get_object_interface_or_union(matching_type$name)
      if (is.null(matching_obj)) {
        # 5.2.3 - if is leaf, can not dig deeper
        oh$error_list$add(
          "5.2.3",
          "unknown object definition for field: '", selection_obj$name$value, "'.",
          " Not allowed to query deeper into leaf field selections."
        )
        next
      }
      validate_fields_in_selection_set(
        selection_obj$selectionSet,
        matching_obj,
        oh = oh
      )
    } else {
      # no sub selection set, make sure this is ok
      if (inherits(selection_obj, "Field")) {
        matching_obj <- oh$schema_obj$get_object_interface_or_union(matching_obj_field$type)
        if (!is.null(matching_obj)) {
          oh$error_list$add(
            "5.2.3",
            "non leaf selection does not have any children.",
            " Missing children fields for field: '", selection_obj$name$value, "'."
          )
        }
      }
    }
  }

  if (oh$error_list$has_no_errors()) {
    # must be done after union check in forloop above
    validate_fields_can_merge(selection_set_obj, object, oh = oh)
  }
}







# 5.4 - Fragments. In upgrade_query_remove_fragments.R


# 5.5.1 - Input Object Field Uniqueness
validate_input_object_field_uniqueness <- function(object_value, ..., oh) {
  validate_field_names(object_value, "input object value", "5.5.1", oh = oh)
}


# √5.6.1 - Directives Are Defined - Must be done in execution stage
# √5.6.2 - Directives Are In Valid Locations - Must be done in execution stage
# √5.6.3 - Directives Are Unique Per Location - Must be done in execution stage
# √must also call validate_arguments on all directive args
validate_directives <- function(directive_objs, parent_obj, ..., oh, skip_variables = FALSE) {
  if (is.null(directive_objs)) {
    return(directive_objs)
  }
  if (length(directive_objs) == 0) {
    return(directive_objs)
  }

  directives <- lapply(directive_objs, validate_directive, parent_obj = parent_obj, oh = oh, skip_variables = skip_variables)

  if (length(directives) > 0) {
    directive_names <- lapply(directives, `[[`, "name") %>% lapply(`[[`, "value") %>% unlist()
    # 5.6.3
    if (length(unique(directive_names)) != length(directives)) {
      oh$error_list$add(
        "5.6.3",
        "All directives must be unique when used in on the same object.",
        "  Currently found the following directives: '", str_c(directive_names, collapse = "', '"), "'"
      )
    }
  }

  directives
}
validate_directive <- function(directive_obj, parent_obj, ..., oh, skip_variables = FALSE) {
  if (is.null(directive_obj)) {
    return(directive_obj)
  }

  directive_definition <- oh$schema_obj$get_directive(directive_obj$name)

  # 5.6.1 - must be difined
  if (is.null(directive_definition)) {
    oh$error_list$add(
      "5.6.1",
      "all directives must be defined. Missing defintion for directive: ",
      "'", directive_obj$name$value, "'"
    )
  }

  validate_arguments(directive_obj$arguments, directive_definition, oh = oh, skip_variables = skip_variables)

  # [Name]
  directive_definition$locations %>%
    lapply(`[[`, "value") %>%
    unlist() ->
  directive_possible_locations

  # 5.6.2
  parent_cur_location <- directive_current_location(parent_obj)

  if (!(parent_cur_location %in% directive_possible_locations)) {
    oh$error_list$add(
      "5.6.2",
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
VariableValdationHelper <- R6Class("VariableValdationHelper",
  public = list(
    names = character(0),
    has_been_seen = list(),
    type = list(),
    variables = list(),
    oh = NULL,

    check_variable = function(var, argument_type) {
      if (is.null(var)) {
        return(invisible(TRUE))
      }

      var_name <- format(var$name)

      var_obj <- self$variables[[var_name]]

      # 5.7.4 - All Variable Uses Defined
      if (is.null(var_obj)) {
        self$oh$error_list$add(
          "5.7.4",
          "Matching variable definition can not be found for variable: ", var_name
        )
        return(invisible(FALSE))
      }

      self$has_been_seen[[var_name]] <- TRUE

      # 5.7.6
      # AreTypesCompatible
      variable_type <- var_obj$type
      # If hasDefault is true, treat the variableType as non‐null.
      if (!is.null(var_obj$defaultValue)) {
        if (!inherits(variable_type, "NonNullType")) {
          variable_type <- NonNullType$new(type = variable_type)
        }
      }

      # If argumentType and variableType have different list dimensions, return false
      # If any list level of variableType is not non‐null, and the corresponding level in argument is non‐null, the types are not compatible.
      cur_var_type <- variable_type
      cur_arg_type <- argument_type
      while(
        inherits(cur_var_type, "NonNullType") ||
        inherits(cur_var_type, "ListType") ||
        inherits(cur_arg_type, "NonNullType") ||
        inherits(cur_arg_type, "ListType")
      ) {
        if (
          inherits(cur_var_type, "NonNullType") ||
          inherits(cur_arg_type, "NonNullType")
        ) {
          if (!inherits(cur_var_type, "NonNullType")) {
            self$oh$error_list$add(
              "5.7.6",
              "Variable can not provide a nullible argument to a non-nullible definition"
            )
            return(invisible(FALSE))
          } else {
            cur_var_type <- cur_var_type$type
          }
          if (inherits(cur_arg_type, "NonNullType")) {
            cur_arg_type <- cur_arg_type$type
          }

        } else {
          if (
            !inherits(cur_var_type, "ListType") ||
            !inherits(cur_arg_type, "ListType")
          ) {
            # if either is not a list
            self$oh$error_list$add(
              "5.7.6",
              "Variable list dimensions do not match argument's list dimensions"
            )
            return(invisible(FALSE))
          } else {
            # must both be lists at this point
            cur_var_type <- cur_var_type$type
            cur_arg_type <- cur_arg_type$type
          }
        }
      }

      # If inner type of argumentType and variableType are different, return false
      if (!identical(
        format(cur_var_type),
        format(cur_arg_type)
      )) {
        self$oh$error_list$add(
          "5.7.6",
          "Argument and variable inner types do not match. Found: ",
          format(cur_arg_type), " and ", format(cur_var_type)
        )
        return(invisible(FALSE))
      }

      invisible(TRUE)
    },


    finally = function() {

      # 5.7.5 - All Variables Used
      has_been_seen <- unlist(self$has_been_seen)
      if (!all(has_been_seen)) {
        self$oh$error_list$add(
          "5.7.5",
          "Not all variable definitions have been seen.",
          " Unused variables: ", names(has_been_seen)[!has_been_seen]
        )
        invisible(FALSE)
      } else {
        invisible(TRUE)
      }
    },


    default_value_can_be_coerced = function(from_input, to_type) {
      validate_value_can_be_coerced(
        from_input, to_type,
        oh = self$oh,
        rule_code = "5.7.2"
      )
    },


    initialize = function(vars, oh) {
      self$variables <- list()
      self$oh = oh

      if (is.null(vars)) {
        return(invisible(self))
      }

      if (!is.list(vars)) stop("vars must be a list")

      vars %>%
        lapply(function(var) {
          name <- format(var$variable$name)

          self$variables[[name]] <- var
          self$has_been_seen[[name]] <- FALSE

          self$type[[name]] <- var$type

          # 5.7.2
          default_value_obj <- var$defaultValue
          if (!is.null(default_value_obj)) {
            if (inherits(var$type, "NonNullType")) {
              self$oh$error_list$add(
                "5.7.2",
                "Non-Null Variables are not allowed to have default values. ",
                " Found a default value for variable: ", name
              )
              return(name)
            }

            default_val <- var$defaultValue$value
            if (!is.null(default_val)) {
              type_obj <- self$oh$schema_obj$get_type(self$oh$schema_obj$name_helper(var$type))

              self$default_value_can_be_coerced(
                from_input = var$defaultValue,
                to_type = var$type
              )
            }
          }


          # 5.7.3 - Variables Are Input Types
          core_var_type <- self$oh$schema_obj$get_inner_type(var$type)
          matching_core_type_object <- ifnull(
            self$oh$schema_obj$get_scalar(core_var_type), ifnull(
            self$oh$schema_obj$get_enum(core_var_type),
            self$oh$schema_obj$get_input_object(core_var_type)
          ))

          if (is.null(matching_core_type_object)) {
            self$oh$error_list$add(
              "5.7.3",
              "Can not find matching Scalar, Enum, or Input Object with type: ",
              self$oh$schema_obj$name_helper(var$type),
              " for variable: ", name
            )
            return(name)
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
        self$oh$error_list$add(
          "5.7.1",
          "All defined variables must be unique.",
          " Found duplicates of name: ", str_c(duplicate_names, collapse = ", ")
        )
      }

      self$names <- names

      invisible(self)
    }
  )


)




#' @export
ErrorList <- R6Class("ErrorList",
  private = list(
    # http://facebook.github.io/graphql/
    # document.querySelectorAll("#sec-Validation section").forEach(function(x,i){console.log(x.firstChild.innerText)} )
    rule_names = list(

      "3.1.1" = "Scalars",
      "3.1.1.1" = "Int",
      "3.1.1.2" = "Float",
      "3.1.1.3" = "String",
      "3.1.1.4" = "Boolean",
      "3.1.1.5" = "ID",
      "3.1.2" = "Objects",
      "3.1.2.1" = "Object Field Arguments",
      "3.1.2.2" = "Object Field deprecation",
      "3.1.2.3" = "Object type validation",
      "3.1.3" = "Interfaces",
      "3.1.3.1" = "Interface type validation",
      "3.1.4" = "Unions",
      "3.1.4.1" = "Union type validation",
      "3.1.5" = "Enums",
      "3.1.6" = "Input Objects",
      "3.1.6.1" = "Input Object type validation",
      "3.1.7" = "Lists",
      "3.1.8" = "Non-Null",

      "5.1" = "Operations",
      "5.1.1" = "Named Operation Definitions",
      "5.1.1.1" = "Operation Name Uniqueness",
      "5.1.2" = "Anonymous Operation Definitions",
      "5.1.2.1" = "Lone Anonymous Operation",

      "5.2" = "Fields",
      "5.2.1" = "Field Selections on Objects, Interfaces, and Unions Types",
      "5.2.2" = "Field Selection Merging",
      "5.2.3" = "Leaf Field Selections",

      "5.3" = "Arguments",
      "5.3.1" = "Argument Names",
      "5.3.2" = "Argument Uniqueness",
      "5.3.3" = "Argument Values Type Correctness",
      "5.3.3.1" = "Compatible Values",
      "5.3.3.2" = "Required Non-Null Arguments",

      "5.4" = "Fragments",
      "5.4.1" = "Fragment Declarations",
      "5.4.1.1" = "Fragment Name Uniqueness",
      "5.4.1.2" = "Fragment Spread Type Existence",
      "5.4.1.3" = "Fragments On Composite Types",
      "5.4.1.4" = "Fragments Must Be Used",
      "5.4.2" = "Fragment Spreads",
      "5.4.2.1" = "Fragment spread target defined",
      "5.4.2.2" = "Fragment spreads must not form cycles",
      "5.4.2.3" = "Fragment spread is possible",
      "5.4.2.3.1" = "Object Spreads In Object Scope",
      "5.4.2.3.2" = "Abstract Spreads in Object Scope",
      "5.4.2.3.3" = "Object Spreads In Abstract Scope",
      "5.4.2.3.4" = "Abstract Spreads in Abstract Scope",

      "5.5" = "Values",
      "5.5.1" = "Input Object Field Uniqueness",

      "5.6" = "Directives",
      "5.6.1" = "Directives Are Defined",
      "5.6.2" = "Directives Are In Valid Locations",
      "5.6.3" = "Directives Are Unique Per Location",

      "5.7" = "Variables",
      "5.7.1" = "Variable Uniqueness",
      "5.7.2" = "Variable Default Values Are Correctly Typed",
      "5.7.3" = "Variables Are Input Types",
      "5.7.4" = "All Variable Uses Defined",
      "5.7.5" = "All Variables Used",
      "5.7.6" = "All Variable Usages are Allowed",

      "6.1" = "Executing Requests",
      "6.1.1" = "Validating Requests",
      "6.1.2" = "Coercing Variable Values",

      "6.2" = "Executing Operations",

      "6.3" = "Executing Selection Sets",
      "6.3.1" = "Normal and Serial Execution",
      "6.3.2" = "Field Collection",

      "6.4" = "Executing Fields",
      "6.4.1" = "Coercing Field Arguments",
      "6.4.2" = "Value Resolution",
      "6.4.3" = "Value Completion",
      "6.4.4" = "Errors and Non-Nullability"
    )
  ),
  public = list(
    n = 0,
    errors = list(),
    verbose = TRUE,

    initialize = function(verbose = TRUE) {
      self$verbose <- verbose
      invisible(self)
    },

    has_no_errors = function() {
      self$n == 0
    },
    has_any_errors = function() {
      self$n > 0
    },

    add = function(rule_code, ...) {

      rule_name <- private$rule_names[[rule_code]]
      if (is.null(rule_name)) {
        stop("Name not found for rule: '", rule_code, "'")
      }

      err <- str_c(
        rule_code, ": ", rule_name, "\n",
        ...,
        sep = ""
      )

      if (isTRUE(self$verbose))
        message("Error: ", err)

      self$n <- self$n + 1
      self$errors[[length(self$errors) + 1]] <- err
      invisible(self)
    },

    .format = function(...) {
      if (self$has_any_errors()) {
        str_c(
          "<ErrorList>\n",
          "Errors: \n",
          str_c(self$errors, collapse = ",\n")
        )
      } else {
        "<ErrorList> No errors"
      }
    },
    print = function(...) {
      cat(self$.format(...))
    }
  )
)
format.ErrorList <- function(x, ...) {
  x$.format(...)
}
str.ErrorList <- function(x, ...) {
  print(x)
}



#' @export
ObjectHelpers <- R6Class(
  "ObjectHelpers",
  private = list(
    schema_obj_val = NULL,
    error_list_val = NULL
  ),
  public = list(

    variable_validator = NULL,
    unset_variable_validator = function() {
      self$variable_validator <- NULL
    },
    set_variable_validator = function(variable_validator) {
      self$variable_validator <- variable_validator
    },

    variable_values = NULL,
    unset_coerced_variables = function() {
      self$variable_values <- NULL
    },
    set_coerced_variables = function(variable_values) {
      self$variable_values <- variable_values
    },
    has_variable_value = function(variable_obj) {
      variable_name <- format(variable_obj$name)
      variable_name %in% names(self$variable_values)
    },
    get_variable_value = function(variable_obj) {
      variable_name <- format(variable_obj$name)
      self$variable_values[[variable_name]]
    },

    # get_argument_value = function(arg_value) {
    #   if (inherits(arg_value, "Variable")) {
    #
    #   }
    # },

    initialize = function(schema_obj, error_list = ErrorList$new()) {
      self$schema_obj <- schema_obj
      self$error_list <- error_list

      invisible(self)
    }
  ),
  active = list(
    error_list = function(value) {
      if (missing(value)) {
        return(private$error_list_val)
      }

      if (!inherits(value, "ErrorList")) {
        stop("must supply a object of class 'ErrorList'")
      }

      private$error_list_val <- value

      invisible(self)
    },

    schema_obj = function(value) {
      if (missing(value)) {
        return(private$schema_obj_val)
      }

      if (inherits(value, "character")) {
        value <- GQLRSchema$new(value)
      }
      if (inherits(value, "Document")) {
        value <- GQLRSchema$new(value)
      }

      if (!inherits(value, "GQLRSchema")) {
        stop("must supply a object of class 'Schema'")
      }

      private$schema_obj_val <- value

      invisible(self)
    }
  )


)
