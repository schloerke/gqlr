














# TODO
  # implement mutation

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
upgrade_query_remove_fragments <- function(document_obj, schema_obj) {

  fragment_list <- list()
  query_list <- list()
  # mutation_list <- list()

  for (operation in document_obj$definitions) {
    if (!is.null(operation$operation)) {
      # is operation
      if (operation$operation == "query") {
        if (is.null(operation$name)) {
          query_list[[""]] <- operation
        } else {
          query_list[[graphql_string(operation$name)]] <- operation
        }
      } else {
        # TODO
        stop("TODO implement mutation")
      }
    } else {

      fragment <- operation
      fragment_name <- graphql_string(fragment$name)

      # 5.4.1.1
      if (!is.null(fragment_list[[fragment_name]])) {
        stop("fragments must have a unique name. Found extra fragment: ", fragment_name)
      }
      fragment_list[[fragment_name]] <- fragment
    }
  }


  fragment_names <- names(fragment_list)
  fragment_used_once <- rep(FALSE, length(fragment_names))
  names(fragment_used_once) <- fragment_names

  # pretend you can see "fragment_used_once" globally
  upgrade_fragments_in_field <- function(field_obj, matching_obj, seen_fragments = NULL) {

    # # help debug
    # str(field_obj)
    # browser()

    new_selections <- list()
    for (field in field_obj$selectionSet$selections) {

      if (inherits(field, "Field")) {
        # regular field object
        if (!is.null(field$selectionSet)) {

          # need to recurse in field objects
          matching_field <- matching_obj$.get_field(field)
          matching_field_obj <- schema_obj$get_object(matching_field$type)
          field <- upgrade_fragments_in_field(field, matching_field_obj, seen_fragments)
        }
        new_selections <- append(new_selections, field)

        validate_directives(field$directives, schema_obj, field, variable_validator = NULL)


      } else if (inherits(field, "FragmentSpread") || inherits(field, "InlineFragment")) {

        field_seen_fragments <- seen_fragments

        # turn all FragmentSpread into InlineFragment; removes lookup at run time
        if (inherits(field, "FragmentSpread")) {
          # is fragement spread

          fragment_spread_name <- graphql_string(field$name)
          fragment_obj <- fragment_list[[fragment_spread_name]]

          validate_directives(field$directives, schema_obj, field)

          # 5.4.2.1 - Fragment spread target defined
          if (is.null(fragment_obj)) {
            stop("fragment must be defined. Can not find fragment named: ", fragment_spread_name)
          }
          fragment_used_once[fragment_spread_name] <<- TRUE

          # 5.4.2.2 - Fragment spreads must not form cycles
          if (fragment_spread_name %in% field_seen_fragments) {
            stop(
              "fragments can not be circularly defined. ",
              " Start of cycle: ", str_c(field_seen_fragments, collapse = ", ")
            )
          }
          field_seen_fragments <- c(field_seen_fragments, fragment_spread_name)

          validate_directives(fragment_obj$directives, schema_obj, fragment_obj)

          # since the fragment was received, make it "inline fragment"
          fragment_obj <- InlineFragment$new(
            loc = fragment_obj$loc,
            typeCondition = fragment_obj$typeCondition,
            directivesfragment_obj$directives,
            selectionSet = fragment_obj$selectionSet
          )

        } else {
          # inline_fragment
          fragment_obj <- field

          validate_directives(fragment_obj$directives, schema_obj, fragment_obj)

        }

        # at this point the fragment_obj is either a inlinefragment or fragment definition
        # it can treated as a fragment spread

        if (is.null(fragment_obj$typeCondition)) {
          # there is no type condition "on Dog",
          # matching_frag_obj is of parent obj
          matching_frag_obj <- matching_obj
          matching_type_condition <- matching_obj$name
        } else {
          matching_frag_obj <- schema_obj$get_object_interface_or_union(fragment_obj$typeCondition)
          matching_type_condition <- fragment_obj$typeCondition
        }

        # 5.4.1.2 - Fragment Spread Type Existence - upgrade
        # 5.4.1.3 - Fragments On Composite Types
        if (is.null(matching_frag_obj)) {
          stop(
            "fragment must supply at object, interface, or union.",
            " Can not find match for typeCondition: ", graphql_string(matching_type_condition)
          )
        }

        fragment_possible_types <- schema_obj$get_possible_types(matching_type_condition)
        parent_possible_types <- schema_obj$get_possible_types(matching_obj$name)

        applicable_types <- intersect(fragment_possible_types, parent_possible_types)

        # 5.4.2.3 - Fragment spread is possible
        if (length(applicable_types) == 0) {
          stop(
            "there must be an intersection of \n",
            "\tfragment possible types: ", str_c(fragment_possible_types, collapse = ", "), "\n",
            " and \n",
            "\tparent possible types: ", str_c(parent_possible_types, collapse = ", ")
          )
        }

        upgraded_fragment <- upgrade_fragments_in_field(
          fragment_obj,
          matching_frag_obj,
          field_seen_fragments
        )

        # # add all fields to selection set
        # print("upgraded fragment")
        # str(upgraded_fragment)

        new_selections <- append(new_selections, upgraded_fragment)
      }

    }

    # upgrade the selectino set
    field_obj$selectionSet$selections <- new_selections
    field_obj
  }





  upgraded_operations <- list()

  for (query_obj in query_list) {
    query_obj <- upgrade_fragments_in_field(query_obj, schema_obj$get_object("QueryRoot"), NULL)
    upgraded_operations <- append(upgraded_operations, query_obj)
  }

  # 5.4.1.4 - Fragments Must Be Used
  if (!all(fragment_used_once)) {
    stop(
      "all fragments must be used.",
      " Fragments not used: ", names(fragment_used_once[!fragment_used_once])
    )
  }

  document_obj$definitions <- upgraded_operations

  document_obj
}
