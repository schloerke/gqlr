


# DONE
# 5.4.1
  # √5.4.1.1 - Fragment Name Uniqueness
  # √5.4.1.2 - Fragment Spread Type Existence
  # √5.4.1.3 - Fragments On Composite Types
  # √5.4.1.4 - Fragments Must Be Used
# 5.4.2
  # √5.4.2.1 - Fragment spread target defined
  # √5.4.2.2 - Fragment spreads must not form cycles
  # √5.4.2.3 - Fragment spread is possible
    # √5.4.2.3.1 - Object Spreads In Object Scope - covered in 5.4.2.3
    # √5.4.2.3.2 - Abstract Spreads in Object Scope - covered in 5.4.2.3
    # √5.4.2.3.3 - Object Spreads In Abstract Scope - covered in 5.4.2.3
    # √5.4.2.3.4 - Abstract Spreads in Abstract Scope - covered in 5.4.2.3
upgrade_query_remove_fragments <- function(document_obj, ..., oh) {

  fragment_list <- list()
  query_mutation_list <- list(
    query = list(),
    mutation = list()
  )

  for (operation in document_obj$definitions) {
    if (inherits(operation, "OperationDefinition")) {
      # is operation
      if (operation$operation == "query") {
        if (is.null(operation$name)) {
          query_mutation_list$query[[""]] <- operation
        } else {
          query_mutation_list$query[[format(operation$name)]] <- operation
        }
      } else {
        query_mutation_list$mutation[[format(operation$name)]] <- operation
      }
    } else {

      fragment <- operation
      fragment_name <- format(fragment$name)

      # 5.4.1.1
      if (!is.null(fragment_list[[fragment_name]])) {
        oh$error_list$add(
          "5.4.1.1",
          "fragments must have a unique name. Found duplicate fragment: ", fragment_name
        )
        next
      }
      fragment_list[[fragment_name]] <- fragment
    }
  }
  if (oh$error_list$has_any_errors()) {
    return(document_obj)
  }


  fragment_names <- names(fragment_list)
  fragment_used_once <- rep(FALSE, length(fragment_names))
  names(fragment_used_once) <- fragment_names

  # pretend you can see "fragment_used_once" globally
  upgrade_fragments_in_field <- function(
    field_obj,
    matching_obj,
    seen_fragments = NULL
  ) {

    new_selections <- list()
    for (field in field_obj$selectionSet$selections) {

      if (inherits(field, "Field")) {
        # regular field object
        if (!is.null(field$selectionSet)) {

          # need to recurse in field objects
          matching_field <- matching_obj$.get_field(field)
          if (is.null(matching_field)) {
            oh$error_list$add(
              "5.2.1",
              "Field: ", format(field$name), " can't be found for object of type: ",
              format(matching_obj$name)
            )
            next
          }

          matching_field_obj <- get_object_interface_or_union(matching_field$type, oh$schema)
          field <- upgrade_fragments_in_field(field, matching_field_obj, seen_fragments)
        }
        new_selections <- append(new_selections, field)


        validate_directives(field$directives, field, oh = oh, skip_variables = TRUE)


      } else if (inherits(field, "FragmentSpread") || inherits(field, "InlineFragment")) {

        field_seen_fragments <- seen_fragments

        # turn all FragmentSpread into InlineFragment; removes lookup at run time
        if (inherits(field, "FragmentSpread")) {
          # is fragement spread

          fragment_spread_name <- format(field$name)
          fragment_obj <- fragment_list[[fragment_spread_name]]

          validate_directives(field$directives, field, oh = oh)

          # 5.4.2.1 - Fragment spread target defined
          if (is.null(fragment_obj)) {
            oh$error_list$add(
              "5.4.2.1",
              "fragment must be defined. Can not find fragment named: ", fragment_spread_name
            )
            return(NULL)
          }
          fragment_used_once[fragment_spread_name] <<- TRUE

          # 5.4.2.2 - Fragment spreads must not form cycles
          if (fragment_spread_name %in% field_seen_fragments) {
            oh$error_list$add(
              "5.4.2.2",
              "fragments can not be circularly defined. ",
              " Start of cycle: ", str_c(field_seen_fragments, collapse = ", ")
            )
            return(NULL)
          }
          field_seen_fragments <- c(field_seen_fragments, fragment_spread_name)

          validate_directives(fragment_obj$directives, fragment_obj, oh = oh)

          # since the fragment was received, make it "inline fragment"
          fragment_obj <- InlineFragment$new(
            loc = fragment_obj$loc,
            typeCondition = fragment_obj$typeCondition,
            directives = fragment_obj$directives,
            selectionSet = fragment_obj$selectionSet
          )

        } else {
          # inline_fragment
          fragment_obj <- field

          validate_directives(fragment_obj$directives, fragment_obj, oh = oh)

        }

        # at this point the fragment_obj is either a inlinefragment or fragment definition
        # it can treated as a fragment spread

        if (is.null(fragment_obj$typeCondition)) {
          # there is no type condition "on Dog",
          # matching_frag_obj is of parent obj
          matching_frag_obj <- matching_obj
          matching_type_condition <- matching_obj$name
        } else {
          matching_frag_obj <- get_object_interface_or_union(fragment_obj$typeCondition, oh$schema)
          matching_type_condition <- fragment_obj$typeCondition
        }

        # 5.4.1.2 - Fragment Spread Type Existence - upgrade
        # 5.4.1.3 - Fragments On Composite Types
        if (is.null(matching_frag_obj)) {
          oh$error_list$add(
            "5.4.1.3",
            "fragment must supply at object, interface, or union.",
            " Can not find match for typeCondition: ", format(matching_type_condition)
          )
          return(NULL)
        }

        get_possible_types <- function(name_obj) {
          name_val <- name_value(name_obj)
          if (oh$schema$is_object(name_val)) {
            return(name_val)
          }
          if (oh$schema$is_interface(name_val)) {
            return(oh$schema$implements_interface(name_val))
          }
          union_obj <- oh$schema$get_union(name_val)
          if (!is.null(union_obj)) {
            union_names <- unlist(lapply(union_obj$types, name_value))
            return(union_names)
          }
          stop("type: ", name_val, " is not an object, interface, or union")
        }

        fragment_possible_types <- get_possible_types(matching_type_condition)
        parent_possible_types <- get_possible_types(matching_obj$name)

        applicable_types <- intersect(fragment_possible_types, parent_possible_types)

        # 5.4.2.3 - Fragment spread is possible
        if (length(applicable_types) == 0) {
          oh$error_list$add(
            "5.4.2.3",
            "there must be an intersection of \n",
            "\tfragment possible types: ", str_c(fragment_possible_types, collapse = ", "), "\n",
            " and \n",
            "\tparent possible types: ", str_c(parent_possible_types, collapse = ", ")
          )
          return(NULL)
        }

        upgraded_fragment <- upgrade_fragments_in_field(
          fragment_obj,
          matching_frag_obj,
          field_seen_fragments
        )

        # # add all fields to selection set
        new_selections <- append(new_selections, upgraded_fragment)
      }
    }

    # upgrade the selectino set
    field_obj$selectionSet$selections <- new_selections
    field_obj
  }


  # upgrade all mutation and query objects be full trees, not many fragment objects
  # (circular dependencies are not allowed by graphql definition)
  upgraded_operations <- list()

  if (length(query_mutation_list$mutation) > 0) {
    mutation_root <- oh$schema$get_mutation_object()
    if (is.null(mutation_root)) {
      oh$error_list$add(
        "3.3",
        "mutation type can not be found in schema definition"
      )
      return(NULL)
    }
    for (mutation_obj in query_mutation_list$mutation) {
      mutation_obj <- upgrade_fragments_in_field(mutation_obj, mutation_root, NULL)
      upgraded_operations <- append(upgraded_operations, mutation_obj)
    }
  }

  if (length(query_mutation_list$query) > 0) {
    query_root <- oh$schema$get_query_object()
    if (is.null(query_root)) {
      oh$error_list$add(
        "3.3",
        "query type can not be found in schema definition"
      )
      return(NULL)
    }
    for (query_obj in query_mutation_list$query) {
      query_obj <- upgrade_fragments_in_field(query_obj, query_root, NULL)
      upgraded_operations <- append(upgraded_operations, query_obj)
    }
  }

  # 5.4.1.4 - Fragments Must Be Used
  if (!all(fragment_used_once)) {
    oh$error_list$add(
      "5.4.1.4",
      "all fragments must be used.",
      " Fragments not used: ", names(fragment_used_once[!fragment_used_once])
    )
    return(document_obj)
  }

  document_obj$definitions <- upgraded_operations

  document_obj
}
