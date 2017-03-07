

get_document_operations <- function(documentObj) {

  lapply(documentObj$definitions, "[[", "kind") %>%
    magrittr::equals("OperationDefinition") %>%
    which() ->
    opLocations

  if (length(opLocations) == 0) {
    stop("No OperationDefinition found in documentObj")
  }

  operations <- documentObj$definitions[opLocations]

  names(operations) <- get_names(
    operations,
    stopName = "operation",
    allowNull = TRUE
  )

  operations
}


get_document_fragments <- function(documentObj) {
  check_if_document(documentObj)

  fragmentLocations <- lapply(documentObj$definitions, "[[", "kind") %>%
    magrittr::equals("FragmentDefinition") %>%
    which()

  if (length(fragmentLocations) == 0) {
    return(list())
  }

  fragments <- documentObj$definitions[fragmentLocations]

  names(fragments) <- get_names(
    fragments,
    stopName = "operation",
    allowNull = FALSE
  )

  fragments
}



# Evaluating requests
#
# To evaluate a request, the executor must have a parsed Document (as defined in the “Query Language” part of this spec) and a selected operation name to run if the document defines multiple operations.
#
#' @export
evaluate_request <- function(documentObj, operationName) {

  # The executor should find the Operation in the Document with the given operation name.
  documentObj$definitions %>%
    lapply("[[", "kind") %>%
    magrittr::equals("OperationDefinition") ->
    operationLocations

  documentObj$definitions %>%
    lapply("[[", "name") %>%
    lapply("[[", "value") %>%
    magrittr::equals(operationName) ->
    definitionNames

  # If no such operation exists, the executor should throw an error.
  matchesOperationName <- which(operationName == definitionNames[operationLocations])
  if (! any(matchesOperationName) ) {
    stop0("No OperationDefinition with name of '", operationName, "' found in documentObj")
  }
  if (sum(matchesOperationName) > 1) {
    stop0("OperationDefinition with name of '", operationName, "' found more than once in documentObj")
  }

  # If the operation is found, then the result of evaluating the request should be the result of evaluating the operation according to the "Evaluating operations" section.
  operationObj <- documentObj$definitions[[matchesOperationName]]

  # TODO eval according to evalating operations
  operationObj

}


# Evaluating Operations
# The type system, as described in the “Type System” part of the spec, must provide a “Query Root” and a “Mutation Root” object.
evaluate_operation <- function() {

# If the operation is a mutation, the result of the operation is the result of evaluating the mutation’s top level selection set on the “Mutation Root” object. This selection set should be evaluated serially.

# If the operation is a query, the result of the operation is the result of evaluating the query’s top level selection set on the “Query Root” object.
}


#' Parse a Selection Set
#' @seealso https://github.com/facebook/graphql/blob/master/spec/Section%206%20--%20Execution.md#evaluating-selection-sets
parse_selection_set <- function(selectionSetObj, fragmentList, contextObj) {

  # If the selection set is being evaluated on the null object, then the result of evaluating the selection set is null.
  if (is.null(contextObj)) {
    return(NULL)
  }

  # Otherwise, the selection set is turned into a grouped field set; each entry in the grouped field set is a list of fields that share a responseKey.

  # The selection set is converted to a grouped field set by calling CollectFields, initializing visitedFragments to an empty list.
  ret <- CollectFields()


}


CollectFields <- function(objectType, selectionSet, visitedFragments, fragmentList) {
  # Initialize {groupedFields} to an empty list of lists.
  groupFields <- list()

  visitedFragments <- list()


  # For each {selection} in {selectionSet};
  lapply(selectionSet, function(selection) {

    # If {selection} provides the directive @skip, let {skipDirective} be that directive.
    # TODO get proper skip
    skipDirective <- selection$directives$skip
    # If {skipDirective}'s {if} argument is {true}, continue with the next {selection} in {selectionSet}.
    if (identical(skipDirective, TRUE)) {
      return()
    }


    # If {selection} provides the directive @include, let {includeDirective} be that directive.
    # TODO get proper include
    includeDirective <- selection$directives$include
    # If {includeDirective}'s {if} argument is {false}, continue with the next {selection} in {selectionSet}.
    if (identical(includeDirective, TRUE)) {
      stop("implement!")
    }

    # If {selection} is a Field:
    if (selection$kind == "Fragment") {
      # TODO IMPLEMENT
      # Let {responseKey} be the response key of {selection}.
      responseKey = get_name_val(selection$name)

      # Let {groupForResponseKey} be the list in {groupedFields} for {responseKey}; if no such list exists, create it as an empty list.
      # Append {selection} to the {groupForResponseKey}.
      groupFields[[responseKey]] <- stop("GET FIELD")

    # If {selection} is a FragmentSpread:
    } else if (selection$kind == "FragmentSpread") {
      # Let {fragmentSpreadName} be the name of {selection}.
      fragmentSpreadName <- get_name_val(selection$name)

      # If {fragmentSpreadName} is in {visitedFragments}, continue with the next {selection} in {selectionSet}.
      if (identical(visitedFragments[[fragmentSpreadName]], TRUE)) {
        return()
      } else {
        visitedFragments[[fragmentSpreadName]] <- TRUE
      }

      # Let {fragment} be the Fragment in the current Document whose name is {fragmentSpreadName}.
      fragment <- fragmentList[[fragmentSpreadName]]

      # If no such {fragment} exists, continue with the next {selection} in {selectionSet}.
      if (is.null(fragment)) {
        return()
      }

      # Let {fragmentType} be the type condition on {fragment}.
      fragmentType <- fragment$typeCondition

      # If {doesFragmentTypeApply(objectType, fragmentType)} is false, continue with the next {selection} in {selectionSet}.
      typeVal <- get_namedtype_name_value(fragmentType)
      if (! identical(objectType, typeVal)) {
        return()
      }

      # Let {fragmentSelectionSet} be the top-level selection set of {fragment}.
      fragmentSelectionSet <- fragment$selectionSet

      # Let {fragmentGroupedFields} be the result of calling {CollectFields(objectType, fragmentSelectionSet)}.
      fragmentGroupFields <- CollectFields(objectType, fragmentSelectionSet)

      # For each {fragmentGroup} in {fragmentGroupedFields}:
        # Let {responseKey} be the response key shared by all fields in {fragmentGroup}
        # Let {groupForResponseKey} be the list in {groupedFields} for {responseKey}; if no such list exists, create it as an empty list.
        # Append all items in {fragmentGroup} to {groupForResponseKey}.
      groupFields <<- append(groupFields, fragmentGroupFields)

    # If {selection} is an inline fragment:
    } else if (selection$kind == "InlineFragment") {

      # Let {fragmentType} be the type condition on {selection}.
      fragmentType <- selection$typeCondition

      # If {fragmentType} is not {null} and {doesFragmentTypeApply(objectType, fragmentType)} is false, continue with the next {selection} in {selectionSet}.
      if (is.null(fragmentType)) {
        return()
      }
      typeVal <- get_namedtype_name_value(fragmentType)
      if (! identical(objectType, typeVal)) {
        return()
      }

      # Let {fragmentSelectionSet} be the top-level selection set of {selection}.
      fragmentSelectionSet <- selection$selectionSet

      # Let {fragmentGroupedFields} be the result of calling {CollectFields(objectType, fragmentSelectionSet)}.
      fragmentGroupedFields <- CollectFields(objectType, fragmentSelectionSet)

      # For each {fragmentGroup} in {fragmentGroupedFields}:
        # Let {responseKey} be the response key shared by all fields in {fragmentGroup}
        # Let {groupForResponseKey} be the list in {groupedFields} for {responseKey}; if no such list exists, create it as an empty list.
        # Append all items in {fragmentGroup} to {groupForResponseKey}.
      groupFields <<- append(groupFields, fragmentGroupFields)

    } else {
      print(selectionSetObj)
      stop("unknown selectionSet object type")
    }

    invisible(NULL)
  })

  groupFields
}


doesFragmentTypeApply <- function(objectType, fragmentType) {
  # If fragmentType is an Object Type:
  if (identical(fragmentType, "Object")) {
    # if objectType and fragmentType are the same type, return true, otherwise return false.
    return(identical(objectType, fragmentType))
  }

  # If fragmentType is an Interface Type:
  if (identical(fragmentType, "Interface")) {
    # if objectType is an implementation of fragmentType, return true otherwise return false.
    stop("TODO")
    return(implements(objectType, fragmentType))
  }
  # If fragmentType is a Union:
  if (identical(fragmentType, "Union")) {
    # if objectType is a possible type of fragmentType, return true otherwise return false.
    stop("TODO")
    return(is_possible_type(objectType, fragmentType))

  }
}
