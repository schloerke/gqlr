# 6.4 Executing Fields
#
# Each field requested in the grouped field set that is defined on the selected objectType will result in an entry in the response map. Field execution first coerces any provided argument values, then resolves a value for the field, and finally completes that value either by recursively executing another selection set or coercing a scalar value.
#
# ExecuteField(objectType, objectValue, fieldType, fields, variableValues)
# * Let field be the first entry in fields.
# * Let argumentValues be the result of CoerceArgumentValues(objectType, field, variableValues)
# * Let resolvedValue be ResolveFieldValue(objectType, objectValue, fieldName, argumentValues).
# * Return the result of CompleteValue(fieldType, fields, resolvedValue, variableValues).





# 6.4.1 Coercing Field Arguments
#
# Fields may include arguments which are provided to the underlying runtime in order to correctly produce a value. These arguments are defined by the field in the type system to have a specific input type: Scalars, Enum, Input Object, or List or Non‐Null wrapped variations of these three.
#
# At each argument position in a query may be a literal value or a variable to be provided at runtime.
#
# CoerceArgumentValues(objectType, field, variableValues)
# * Let coercedValues be an empty unordered Map.
# * Let argumentValues be the argument values provided in field.
# * Let fieldName be the name of field.
# * Let argumentDefinitions be the arguments defined by objectType for the field named fieldName.
# * For each argumentDefinition in argumentDefinitions:
#   * Let argumentName be the name of argumentDefinition.
#   * Let argumentType be the expected type of argumentDefinition.
#   * Let defaultValue be the default value for argumentDefinition.
#   * Let value be the value provided in argumentValues for the name argumentName.
#   * If value is a Variable:
#     * Let variableName be the name of Variable value.
#     * Let variableValue be the value provided in variableValues for the name variableName.
#     * If variableValue exists (including null):
#       * Add an entry to coercedValues named argName with the value variableValue.
#     * Otherwise, if defaultValue exists (including null):
#       * Add an entry to coercedValues named argName with the value defaultValue.
#     * Otherwise, if argumentType is a Non‐Nullable type, throw a field error.
#     * Otherwise, continue to the next argument definition.
#     * Otherwise, if value does not exist (was not provided in argumentValues:
#       * If defaultValue exists (including null):
#         * Add an entry to coercedValues named argName with the value defaultValue.
#       * Otherwise, if argumentType is a Non‐Nullable type, throw a field error.
#       * Otherwise, continue to the next argument definition.
#     * Otherwise, if value cannot be coerced according to the input coercion rules of argType, throw a field error.
#     * Let coercedValue be the result of coercing value according to the input coercion rules of argType.
#     * Add an entry to coercedValues named argName with the value coercedValue.
#   * Return coercedValues.
#
# NOTE: Variable values are not coerced because they are expected to be coerced before executing the operation in * CoerceVariableValues(), and valid queries must only allow usage of variables of appropriate types.





# 6.4.2 Value Resolution
#
# While nearly all of GraphQL execution can be described generically, ultimately the internal system exposing the GraphQL interface must provide values. This is exposed via ResolveFieldValue, which produces a value for a given field on a type for a real value.
#
# As an example, this might accept the objectType Person, the field "soulMate", and the objectValue representing John Lennon. It would be expected to yield the value representing Yoko Ono.
#
# ResolveFieldValue(objectType, objectValue, fieldName, argumentValues)
#   * Let resolver be the internal function provided by objectType for determining the resolved value of a field named fieldName.
#   * Return the result of calling resolver, providing objectValue and argumentValues.
#   * It is common for resolver to be asynchronous due to relying on reading an underlying database or networked service to produce a value. This necessitates the rest of a GraphQL executor to handle an asynchronous execution flow.





# 6.4.3
#
# Value Completion
#
# After resolving the value for a field, it is completed by ensuring it adheres to the expected return type. If the return type is another Object type, then the field execution process continues recursively.
#
# CompleteValue(fieldType, fields, result, variableValues)
#
#   * If the fieldType is a Non‐Null type:
#     * Let innerType be the inner type of fieldType.
#     * Let completedResult be the result of calling CompleteValue(innerType, fields, result, variableValues).
#     * If completedResult is null, throw a field error.
#     * Return completedResult.
#   * If result is null (or another internal value similar to null such as undefined or NaN), return null.
#   * If fieldType is a List type:
#     * If result is not a collection of values, throw a field error.
#     * Let innerType be the inner type of fieldType.
#     * Return a list where each list item is the result of calling CompleteValue(innerType, fields, resultItem, variableValues), where resultItem is each item in result.
#   * If fieldType is a Scalar or Enum type:
#     * Return the result of “coercing” result, ensuring it is a legal value of fieldType, otherwise null.
#   * If fieldType is an Object, Interface, or Union type:
#     * If fieldType is an Object type.
#       * Let objectType be fieldType.
#     * Otherwise if fieldType is an Interface or Union type.
#       * Let objectType be ResolveAbstractType(fieldType, result).
#     * Let subSelectionSet be the result of calling MergeSelectionSets(fields).
#     * Return the result of evaluating ExecuteSelectionSet(subSelectionSet, objectType, result, variableValues) normally (allowing for parallelization).






# Resolving Abstract Types
#
# When completing a field with an abstract return type, that is an Interface or Union return type, first the abstract type must be resolved to a relevant Object type. This determination is made by the internal system using whatever means appropriate.
#
# NOTE: A common method of determining the Object type for an objectValue in object‐oriented environments, such as Java or C#, is to use the class name of the objectValue.
#
# ResolveAbstractType(abstractType, objectValue)
#   * Return the result of calling the internal method provided by the type system for determining the Object type of abstractType given the value objectValue.


# Merging Selection Sets
#
# When more than one fields of the same name are executed in parallel, their selection sets are merged together when completing the value in order to continue execution of the sub‐selection sets.
#
# An example query illustrating parallel fields with the same name with sub‐selections.
#
# {
#   me {
#     firstName
#   }
#   me {
#     lastName
#   }
# }
# After resolving the value for me, the selection sets are merged together so firstName and lastName can be resolved for one value.
#
# MergeSelectionSets(fields)
#   * Let selectionSet be an empty list.
#   * For each field in fields:
#     * Let fieldSelectionSet be the selection set of field.
#     * If fieldSelectionSet is null or empty, continue to the next field.
#     * Append all selections in fieldSelectionSet to selectionSet.
#   * Return selectionSet.



# 6.4.4 Errors and Non-Nullability
#
# If an error is thrown while resolving a field, it should be treated as though the field returned null, and an error must be added to the "errors" list in the response.
#
# If the result of resolving a field is null (either because the function to resolve the field returned null or because an error occurred), and that field is of a Non-Null type, then a field error is thrown. The error must be added to the "errors" list in the response.
#
# If the field returns null because of an error which has already been added to the "errors" list in the response, the "errors" list must not be further affected. That is, only one error should be added to the errors list per field.
#
# Since Non-Null type fields cannot be null, field errors are propagated to be handled by the parent field. If the parent field may be null then it resolves to null, otherwise if it is a Non-Null type, the field error is further propagated to it’s parent field.
#
# If all fields from the root of the request to the source of the error return Non-Null types, then the "data" entry in the response should be null.



##############################################################################
##############################################################################
##############################################################################
##############################################################################
##############################################################################
##############################################################################
##############################################################################
##############################################################################





#' Get Field Entry
#'
#' Each item in the grouped field set can potentially create an entry in the result map. That entry in the result map is the result is the result of calling GetFieldEntry on the corresponding item in the grouped field set. GetFieldEntry can return null, which indicates that there should be no entry in the result map for this item. Note that this is distinct from returning an entry with a string key and a null value, which indicates that an entry in the result should be added for that key, and its value should be null.
#'
#' GetFieldEntry assumes the existence of two functions that are not defined in this section of the spec. It is expected that the type system provides these methods:
#'
#' ResolveFieldOnObject, which takes an object type, a field, and an object, and returns the result of resolving that field on the object.
#'
#' GetFieldTypeFromObjectType, which takes an object type and a field, and returns that field’s type on the object type, or null if the field is not valid on the object type.'
GetFieldEntry <- function(objectType, object, fields) {
  # Let firstField be the first entry in the ordered list fields. Note that fields is never empty, as the entry in the grouped field set would not exist if there were no fields.
  firstField <- fields[[1]]

  # Let responseKey be the response key of firstField.
  responseKey <- get_name_val(firstField$name)

  # Let fieldType be the result of calling GetFieldTypeFromObjectType(objectType, firstField).
  fieldType <- GetFieldTypeFromObjectType(objectType, firstField)

  # If fieldType is null, return null, indicating that no entry exists in the result map.
  if (is.null(fieldType)) {
    return(NULL)
  }

  # Let resolvedObject be ResolveFieldOnObject(objectType, object, fieldEntry).
  resolvedObject <- ResolveFieldOnObject(objectType, object, fieldEntry)

  # If resolvedObject is null, return tuple(responseKey, null), indicating that an entry exists in the result map whose value is null.
  if (is.null(resolvedObject)) {
    return(list(responseKey = NULL))
  }

  # Let subSelectionSet be the result of calling MergeSelectionSets(fields).
  subSelectionSet <- MergeSelectionSets(fields)

  # Let responseValue be the result of calling CompleteValue(fieldType, resolvedObject, subSelectionSet).
  responseValue <- CompleteValue(fieldType, resolvedObject, subSelectionSet)

  # Return tuple(responseKey, responseValue).
  return(list(responseKey, responseValue))
}


GetFieldTypeFromObjectType <- function(objectType, firstField) {
  # Call the method provided by the type system for determining the field type on a given object type.

}


ResolveFieldOnObject <- function(objectType, object, firstField) {
  # Call the method provided by the type system for determining the resolution of a field on a given object.
}

MergeSelectionSets <- function(fields) {
  # Let {selectionSet} be an empty list.

  # For each {field} in {fields}:
  selectionSet <- lapply(fields, function(field) {
    # Let {fieldSelectionSet} be the selection set of {field}.
    fieldSelectionSet <- field$selectionSet
    # If {fieldSelectionSet} is null or empty, continue to the next field.
    if (is.null(fieldSelectionSet)) { return(NULL) }
    if (length(fieldSelectionSet) == 0) { return(NULL) }
    # Append all selections in {fieldSelectionSet} to {selectionSet}.
    fieldSelectionSet
  })

  # TODO flatten selectionSet properly

  # Return {selectionSet}.
  return(selectionSet)
}


is_non_null_type <- function(fieldType) {
  stop("TODO implement")
}
is_list_type <- function(fieldType) {
  stop("TODO implement")
}

CompleteValue <- function(fieldType, result, subSelectionSet) {
  # If the {fieldType} is a Non-Null type:
  if (is_non_null_type(fieldType)) {
    # Let {innerType} be the inner type of {fieldType}.
    # TODO make this work
    innterType <- fieldType$innerType

    # Let {completedResult} be the result of calling {CompleteValue(innerType, result)}.
    completedResult <- CompleteValue(innerType, result)

    # If {completedResult} is {null}, throw a field error.
    if (is.null(completedResult)) {
      stop("Non-Null element returned as NULL")
    }

    # Return {completedResult}.
    return(completedResult)
  }

  # If {result} is {null} or a value similar to {null} such as {undefined} or {NaN}, return {null}.
  if (is.null(result) || is.na(result) || length(result) == 0) {
    return(NULL)
  }

  # If {fieldType} is a List type:
  if (is_list_type(fieldType)) {
    # If {result} is not a collection of values, throw a field error.
    if (!is.list(result)) {
      stop("List Type element returned as non list")
    }
    # Let {innerType} be the inner type of {fieldType}.
    # TODO make this work
    innerType <- fieldType$innerType

    # Return a list where each item is the result of calling {CompleteValue(innerType, resultItem)}, where {resultItem} is each item in {result}.
    res <- lapply(result, function(resultItem){
      CompleteValue(innerType, resultItem)
    })
    return(res)
  }

  # If {fieldType} is a Scalar or Enum type:
  if (is_enum_or_scalar_type(fieldType)) {
    # Return the result of "coercing" {result}, ensuring it is a legal value of {fieldType}, otherwise {null}.
    # TODO implement
    return(stop("TODO implement"))
  }

  # If {fieldType} is an Object, Interface, or Union type:
  if (is_object_interface_or_union_type(fieldType)) {
    # If {fieldType} is an Object type.
    if (is_object_type(fieldType)) {
      # Let {objectType} be {fieldType}.
      objectType <- fieldType

    # Otherwise if {fieldType} is an Interface or Union type.
    } else if (is_interface_or_union_type(fieldType)) {
      # Let {objectType} be ResolveAbstractType(fieldType, result).
      objectType <- ResolveAbstractType(fieldType, result)
    }

    # Return the result of evaluating {subSelectionSet} on {objectType} normally.
    res <- eval_on_object_type(objectType, subSelectionSet)
    return(stop("TODO implement"))
  }

  stop("Unknown field type reached!")
}


ResolveAbstractType <- function(abstractType, objectValue) {
  # Return the result of calling the internal method provided by the type system for determining the Object type of {abstractType} given the value { objectValue }.
  stop("TODO implement")
}
