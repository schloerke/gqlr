


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
