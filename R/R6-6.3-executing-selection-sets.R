# 6.3 - Executing Selection Sets
#
# To execute a selection set, the object value being evaluated and the object type need to be known, as well as whether it must be executed serially, or may be executed in parallel.
#
# First, the selection set is turned into a grouped field set; then, each represented field in the grouped field set produces an entry into a response map.

# ExecuteSelectionSet(selectionSet, objectType, objectValue, variableValues)
#   1. Let groupedFieldSet be the result of CollectFields(objectType, selectionSet, variableValues).
#   2. Initialize resultMap to an empty ordered map.
#   3. For each groupedFieldSet as responseKey and fields:
#     a. Let fieldName be the name of the first entry in fields. Note: This value is unaffected if an alias is used.
#     b. Let fieldType be the return type defined for the field fieldName of objectType.
#     c. If fieldType is null:
#       i. Continue to the next iteration of groupedFieldSet.
#     d. Let responseValue be ExecuteField(objectType, objectValue, fields, fieldType, variableValues).
#     e. Set responseValue as the value for responseKey in resultMap.
#   4. Return resultMap.

  # NOTE: responseMap is ordered by which fields appear first in the query. This is explained in greater detail in the Field Collection section below.

execute_selection_set <- function(selection_set, object_type, object_value, ..., oh) {

  # 1. Let groupedFieldSet be the result of CollectFields(objectType, selectionSet, variableValues).
  grouped_field_set <- collect_fields(object_type, selection_set, oh = oh)

  # 2. Initialize resultMap to an empty ordered map.
  result_map <- list()

  object_obj <- oh$schema_obj$get_type(object_type)

  #  3. For each groupedFieldSet as responseKey and fields:
  for (field_set in grouped_field_set) {
    response_key <- field_set$key
    fields <- field_set$fields


    # a. Let fieldName be the name of the first entry in fields. Note: This value is unaffected if an alias is used.
    field_name <- fields[[1]]$name
    matching_field <- object_obj$.get_field(field_name)
    # b. Let fieldType be the return type defined for the field fieldName of objectType.
    matching_field_type <- matching_field$type

    # c. If fieldType is null:
    #   i. Continue to the next iteration of groupedFieldSet.
    if (is.null(matching_field_type)) {
      next
    }
    if (inherits(matching_field_type, "NullType")) {
      next
    }

    # d. Let responseValue be ExecuteField(objectType, objectValue, fields, fieldType, variableValues).
    response_value <- execute_field(object_type, object_value, matching_field_type, fields, oh = oh)

    # e. Set responseValue as the value for responseKey in resultMap.
    result_map[[response_key]] <- response_value
  }

  # 4. Return resultMap.
  result_map
}




# The depth‐first‐search order of the field groups produced by CollectFields() is maintained through execution, ensuring that fields appear in the executed response in a stable and predictable order.
#
# CollectFields(objectType, selectionSet, variableValues, visitedFragments)
#   1. If visitedFragments if not provided, initialize it to the empty set.
#   2. Initialize groupedFields to an empty ordered map of lists.
#   3. For each selection in selectionSet:
#     a. If selection provides the directive @skip, let skipDirective be that directive.
#       i. If skipDirective‘s if argument is true or is a variable in variableValues with the value true, continue with the next selection in selectionSet.
#     b. If selection provides the directive @include, let includeDirective be that directive.
#       i. If includeDirective‘s if argument is not true and is not a variable in variableValues with the value true, continue with the next selection in selectionSet.
#     c. If selection is a Field:
#       i. Let responseKey be the response key of selection.
#       ii. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
#       iii. Append selection to the groupForResponseKey.
#     d. If selection is a FragmentSpread:
#       i. Let fragmentSpreadName be the name of selection.
#       ii. If fragmentSpreadName is in visitedFragments, continue with the next selection in selectionSet.
#       iii. Add fragmentSpreadName to visitedFragments.
#       iv. Let fragment be the Fragment in the current Document whose name is fragmentSpreadName.
#       v. If no such fragment exists, continue with the next selection in selectionSet.
#       vi. Let fragmentType be the type condition on fragment.
#       vii. If DoesFragmentTypeApply(objectType, fragmentType) is false, continue with the next selection in selectionSet.
#       viii. Let fragmentSelectionSet be the top‐level selection set of fragment.
#       ix. Let fragmentGroupedFieldSet be the result of calling CollectFields(objectType, fragmentSelectionSet, visitedFragments).
#       x. For each fragmentGroup in fragmentGroupedFieldSet:
#         1. Let responseKey be the response key shared by all fields in fragmentGroup
#         2. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
#         3. Append all items in fragmentGroup to groupForResponseKey.
#     e. If selection is an InlineFragment:
#       i. Let fragmentType be the type condition on selection.
#       ii. If fragmentType is not null and DoesFragmentTypeApply(objectType, fragmentType) is false, continue with the next selection in selectionSet.
#       iii. Let fragmentSelectionSet be the top‐level selection set of selection.
#       iv. Let fragmentGroupedFieldSet be the result of calling CollectFields(objectType, fragmentSelectionSet, variableValues, visitedFragments).
#       v. For each fragmentGroup in fragmentGroupedFieldSet:
#         1. Let responseKey be the response key shared by all fields in fragmentGroup
#         2. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
#         3. Append all items in fragmentGroup to groupForResponseKey.
#   4. Return groupedFields.
collect_fields <- function(object_type, selection_set, ..., oh, visited_fragments = c()) {
  # 2. Initialize groupedFields to an empty ordered map of lists.
  grouped_fields <- list()

  # 3. For each selection in selectionSet:
  for (selection in selection_set) {


    if (!is.null(selection$directives)) {

      for (selection_directive in selection$directives) {
        directive_def <- oh$schema_obj$get_directive(selection_directive$name)
        # TODO
        directive_def$.resolve(selection_directive)
      }
      directive_answers <- lapply(selection$directives, function(x) x$.resolve())
    }
    # a. If selection provides the directive @skip, let skipDirective be that directive.
    #   i. If skipDirective‘s if argument is true or is a variable in variableValues with the value true, continue with the next selection in selectionSet.
    # TODO

    stop("FIX THIS")

    # b. If selection provides the directive @include, let includeDirective be that directive.
    #   i. If includeDirective‘s if argument is not true and is not a variable in variableValues with the value true, continue with the next selection in selectionSet.
    # c. If selection is a Field:
    #   i. Let responseKey be the response key of selection.
    #   ii. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
    #   iii. Append selection to the groupForResponseKey.
    # d. If selection is a FragmentSpread:
    #   i. Let fragmentSpreadName be the name of selection.
    #   ii. If fragmentSpreadName is in visitedFragments, continue with the next selection in selectionSet.
    #   iii. Add fragmentSpreadName to visitedFragments.
    #   iv. Let fragment be the Fragment in the current Document whose name is fragmentSpreadName.
    #   v. If no such fragment exists, continue with the next selection in selectionSet.
    #   vi. Let fragmentType be the type condition on fragment.
    #   vii. If DoesFragmentTypeApply(objectType, fragmentType) is false, continue with the next selection in selectionSet.
    #   viii. Let fragmentSelectionSet be the top‐level selection set of fragment.
    #   ix. Let fragmentGroupedFieldSet be the result of calling CollectFields(objectType, fragmentSelectionSet, visitedFragments).
    #   x. For each fragmentGroup in fragmentGroupedFieldSet:
    #     1. Let responseKey be the response key shared by all fields in fragmentGroup
    #     2. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
    #     3. Append all items in fragmentGroup to groupForResponseKey.
    # e. If selection is an InlineFragment:
    #   i. Let fragmentType be the type condition on selection.
    #   ii. If fragmentType is not null and DoesFragmentTypeApply(objectType, fragmentType) is false, continue with the next selection in selectionSet.
    #   iii. Let fragmentSelectionSet be the top‐level selection set of selection.
    #   iv. Let fragmentGroupedFieldSet be the result of calling CollectFields(objectType, fragmentSelectionSet, variableValues, visitedFragments).
    #   v. For each fragmentGroup in fragmentGroupedFieldSet:
    #     1. Let responseKey be the response key shared by all fields in fragmentGroup
    #     2. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
    #     3. Append all items in fragmentGroup to groupForResponseKey.
  }

  # 4. Return groupedFields.
  return(grouped_fields)
}









# DoesFragmentTypeApply(objectType, fragmentType)
#   1. If fragmentType is an Object Type:
#     a. if objectType and fragmentType are the same type, return true, otherwise return false.
#   2. If fragmentType is an Interface Type:
#     a. if objectType is an implementation of fragmentType, return true otherwise return false.
#   3. If fragmentType is a Union:
#     a. if objectType is a possible type of fragmentType, return true otherwise return false.
does_fragment_type_apply <- function(object_type, fragment_type, ..., oh) {

  fragment_type <- oh$schema_obj$inner_type(fragment_type)
  object_type <- oh$schema_obj$inner_type(object_type)

  #   1. If fragmentType is an Object Type:
  #     a. if objectType and fragmentType are the same type, return true, otherwise return false.
  if (
    oh$schema_obj$.is_object(fragment_type)
  ) {
    ret <- fragment_type$.matches(object_type)
    return(ret)
  }

  #   2. If fragmentType is an Interface Type:
  #     a. if objectType is an implementation of fragmentType, return true otherwise return false.
  if (
    oh$schema_obj$.is_interface(fragment_type)
  ) {
    object_obj <- oh$schema_obj$get_object(object_type)
    ret <- object_obj$.does_implement(fragment_type)
    return(ret)
  }

  #   3. If fragmentType is a Union:
  #     a. if objectType is a possible type of fragmentType, return true otherwise return false.
  if (
    oh$schema_obj$.is_union(fragment_type)
  ) {
    union_obj <- oh$schema_obj$get_union(object_type)
    ret <- union_obj$.does_implement(fragment_type)
    return(ret)
  }

}
