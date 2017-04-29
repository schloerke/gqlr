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

  # print(grouped_field_set)
  # browser()

  # 2. Initialize resultMap to an empty ordered map.
  result_map <- list()

  object_obj <- oh$schema_obj$get_type(object_type)

  #  3. For each groupedFieldSet as responseKey and fields:
  for (response_key in names(grouped_field_set)) {
    fields <- grouped_field_set[[response_key]]

    # a. Let fieldName be the name of the first entry in fields. Note: This value is unaffected if an alias is used.
    first_field <- fields[[1]]
    # field_name <- first_field$name
    matching_field <- object_obj$.get_field(first_field)
    # b. Let fieldType be the return type defined for the field fieldName of objectType.
    matching_field_type <- matching_field$type

    # cat('\n')
    # str(fields)
    # str(matching_field)
    # cat('\n')
    # browser()

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
    result_map[response_key] <- list(response_value)
    # result_map[[response_key]] <- response_value
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

  # print(selection_set)
  # print(object_type)
  # browser()

  # 2. Initialize groupedFields to an empty ordered map of lists.
  grouped_fields <- list()

  # 3. For each selection in selectionSet:
  for (selection in selection_set$selections) {

    # a. If selection provides the directive @skip, let skipDirective be that directive.
      # i. If skipDirective‘s if argument is true or is a variable in variableValues with the value true, continue with the next selection in selectionSet.
    # b. If selection provides the directive @include, let includeDirective be that directive.
      # i. If includeDirective‘s if argument is not true and is not a variable in variableValues with the value true, continue with the next selection in selectionSet.
    # if there any directives, solve them as they could be user defined
    if (!is.null(selection$directives)) {
      should_skip <- FALSE
      for (selection_directive in selection$directives) {
        directive_name <- format(selection_directive$name)
        if (directive_name == "skip" || directive_name == "include") {
          directive_def <- oh$schema_obj$get_directive(selection_directive$name)
          if_arg <- selection_directive$arguments[[1]]
          if_val <- Boolean$.parse_literal(if_arg$value, oh$schema_obj)
          directive_response <- directive_def$.resolve(if_val)
          if (!isTRUE(directive_response)) {
            should_skip <- TRUE
            break
          }
        } else {
          oh$error_list$add(
            "6.3.2",
            "Non skip or include directive found. Extra directives are not allowed."
          )
          next
        }
      } # end for loop
      if (isTRUE(should_skip)) {
        next # go to next field
      }
    } # end directives

    # c. If selection is a Field:
    if (inherits(selection, "Field")) {
      # i. Let responseKey be the response key of selection.
      response_key <- ifnull(selection$alias, selection$name)
      response_key_txt <- format(response_key)

      # ii. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
      # iii. Append selection to the groupForResponseKey.
      group_for_response_key <- append(grouped_fields[[response_key_txt]], selection)
      grouped_fields[[response_key_txt]] <- group_for_response_key
      next
    }

    # d. If selection is a FragmentSpread:
      # i. Let fragmentSpreadName be the name of selection.
      # ii. If fragmentSpreadName is in visitedFragments, continue with the next selection in selectionSet.
      # iii. Add fragmentSpreadName to visitedFragments.
      # iv. Let fragment be the Fragment in the current Document whose name is fragmentSpreadName.
      # v. If no such fragment exists, continue with the next selection in selectionSet.
      # vi. Let fragmentType be the type condition on fragment.
      # vii. If DoesFragmentTypeApply(objectType, fragmentType) is false, continue with the next selection in selectionSet.
      # viii. Let fragmentSelectionSet be the top‐level selection set of fragment.
      # ix. Let fragmentGroupedFieldSet be the result of calling CollectFields(objectType, fragmentSelectionSet, visitedFragments).
      # x. For each fragmentGroup in fragmentGroupedFieldSet:
        # 1. Let responseKey be the response key shared by all fields in fragmentGroup
        # 2. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
        # 3. Append all items in fragmentGroup to groupForResponseKey.
    if (inherits(selection, "FragmentSpread")) {
      stop("this should not occur, only inline fragments should be supplied")
    }


    # e. If selection is an InlineFragment:
    if (inherits(selection, "InlineFragment")) {
      # i. Let fragmentType be the type condition on selection.
      fragment_type <- selection$typeCondition

      # ii. If fragmentType is not null and DoesFragmentTypeApply(objectType, fragmentType) is false, continue with the next selection in selectionSet.
      if (!is.null(fragment_type)) {
        if (!does_fragment_type_apply(object_type, fragment_type, oh = oh)) {
          next
        }
      }

      # iii. Let fragmentSelectionSet be the top‐level selection set of selection.
      fragment_selection_set <- selection$selectionSet

      # iv. Let fragmentGroupedFieldSet be the result of calling CollectFields(objectType, fragmentSelectionSet, variableValues, visitedFragments).
      fragment_grouped_field_set <- collect_fields(object_type, fragment_selection_set, oh = oh)

      # v. For each fragmentGroup in fragmentGroupedFieldSet:
        # 1. Let responseKey be the response key shared by all fields in fragmentGroup
      for (response_key_txt in names(fragment_grouped_field_set)) {
        fragment_group <- fragment_grouped_field_set[[response_key_txt]]

        # 2. Let groupForResponseKey be the list in groupedFields for responseKey; if no such list exists, create it as an empty list.
        # 3. Append all items in fragmentGroup to groupForResponseKey.
        group_for_response_key <- append(grouped_fields[[response_key_txt]], fragment_group)
        grouped_fields[[response_key_txt]] <- group_for_response_key
      }

      # continue to next selection
      next
    }

    str(selection)
    stop("this should not occur")
  }

  # 4. Return groupedFields.
  # str(grouped_fields)
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

  fragment_type <- oh$schema_obj$get_inner_type(fragment_type)
  object_type <- oh$schema_obj$get_inner_type(object_type)

  #   1. If fragmentType is an Object Type:
  #     a. if objectType and fragmentType are the same type, return true, otherwise return false.
  if (
    oh$schema_obj$is_object(fragment_type)
  ) {
    ret <- fragment_type$.matches(object_type)
    return(ret)
  }

  #   2. If fragmentType is an Interface Type:
  #     a. if objectType is an implementation of fragmentType, return true otherwise return false.
  if (
    oh$schema_obj$is_interface(fragment_type)
  ) {
    obj <- oh$schema_obj$get_object(object_type)
    ret <- obj$.has_interface(fragment_type)
    # interface_obj <- oh$schema_obj$get_interface(fragment_type, oh$schema_obj)
    # ret <- interface_obj$.resolve_type(object_type, oh$schema_obj)
    # object_obj <- oh$schema_obj$get_object(object_type)
    # ret <- object_obj$.does_implement(fragment_type)
    return(ret)
  }

  #   3. If fragmentType is a Union:
  #     a. if objectType is a possible type of fragmentType, return true otherwise return false.
  if (
    oh$schema_obj$is_union(fragment_type)
  ) {
    union_obj <- oh$schema_obj$get_union(fragment_type)
    ret <- union_obj$.has_type(object_type)
    return(ret)
  }

  str(fragment_type)
  stop("this should not be reached")

}
