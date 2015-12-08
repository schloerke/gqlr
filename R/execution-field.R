


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
  
}
