







validate_query <- function(document_obj, schema_obj, ...) {

  validate_operation_names(document_obj, schema_obj)


}



# 5.1.1.1 - Operation Name Uniqueness
# 5.1.2.1 - Lone Anonymous Operation
validate_operation_names <- function(document_obj, schema_obj, ...) {
  # 5.1.1.1 - Operation Name Uniqueness
    # All operation names must be unique.
      # A single missing name is unique
  missing_count <- 0
  seen_names <- list()

  for (definition in x$definitions) {
    if (is.null(definition$.args$name)) {
      # doens't have name object, such as TypeSystemDefinition
      next
    }
    name_val <- definition$name$value
    if (is.null(name_val)) {
      missing_count <- missing_count + 1
    } else {
      if (seen_names[[name_val]]) {
        stop(
          "document definition: ", definition$.title,
          " has duplicate name: ", name_val
        )
      }
      seen_names[[name_val]] <- TRUE
    }

    invisible(TRUE)
  }

  # 5.1.2.1 - Lone Anonymous Operation
    # if there is a missing name and a provided name, throw error
  if (missing_count > 0 & length(seen_names) > 0) {
    stop(
      "document definition: ", defintion$.title,
      " has an anonymous and defined definition.",
      " This is not allowed."
    )
  }

}










# TODO
# 5.2.1 - Field Selections on Objects, Interfaces, and Unions Types
validate_field_selections <- function(document_obj, schema_obj, ...) {
  for (operation in document_obj$defintions) {
    if (operation$operation != "query") {
      next
    }

    validate_selection_set(operation$selectionSet, schema_obj$get_object("QueryRoot"), schema_obj, ...)
  }
}


validate_selection_set <- function(selection_set_obj, object, schema_obj, ...) {
  for (selection in selection_set_obj) {
    if (is.null(selection$selectionSet)) {
      # only name appears
      object$contains_field(selection$name)
    }
  }
}


# TODO
# 5.2.2 - Field Selection Merging

# TODO
# 5.2.3 - Leaf Field Selections




# TODO
# 5.3.1 - Argument Names
# 5.3.2 - Argument Uniqueness
# 5.3.3.1 - Compatible Values
# 5.3.3.2 - Required Non-Null Arguments
validate_argument <- function(argument_obj, schema_obj, object, ...) {

  object_val <- schema_obj$get_object
}


# TODO
# 5.4.1.1 - Fragment Name Uniqueness
# 5.4.1.2 - Fragment Spread Type Existence
# 5.4.1.3 - Fragments On Composite Types
# 5.4.1.4 - Fragments Must Be Used
# 5.4.2.1 - Fragment spread target defined
# 5.4.2.2 - Fragment spreads must not form cycles
# 5.4.2.3 - Fragment spread is possible
# 5.4.2.3.1 - Object Spreads In Object Scope
# 5.4.2.3.2 - Abstract Spreads in Object Scope
# 5.4.2.3.3 - Object Spreads In Abstract Scope
# 5.4.2.3.4 - Abstract Spreads in Abstract Scope




# TODO
# 5.5.1 - Input Object Field Uniqueness


# TODO
# 5.6.1 - Directives Are Defined
# 5.6.2 - Directives Are In Valid Locations
# 5.6.3 - Directives Are Unique Per Location



# TODO
# 5.7.1 - Variable Uniqueness
# 5.7.2 - Variable Default Values Are Correctly Typed
# 5.7.3 - Variables Are Input Types
# 5.7.4 - All Variable Uses Defined
# 5.7.5 - All Variables Used
# 5.7.6 - All Variable Usages are Allowed
