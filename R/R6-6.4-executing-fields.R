# 6.4 - Executing Fields
#
# Each field requested in the grouped field set that is defined on the selected objectType will result in an entry in the response map. Field execution first coerces any provided argument values, then resolves a value for the field, and finally completes that value either by recursively executing another selection set or coercing a scalar value.
#
# ExecuteField(objectType, objectValue, fieldType, fields, variableValues)
#   1. Let field be the first entry in fields.
#   2. Let argumentValues be the result of CoerceArgumentValues(objectType, field, variableValues)
#   3. Let resolvedValue be ResolveFieldValue(objectType, objectValue, fieldName, argumentValues).
#   4. Return the result of CompleteValue(fieldType, fields, resolvedValue, variableValues).
execute_field <- function(object_type, object_value, field_type, fields, ..., oh) {

  # 1. Let field be the first entry in fields.
  field <- fields[[1]]

  if (identical(format(field$name), "__typename")) {
    completed_value <- resolve__typename(object_type, object_value, oh = oh)
    return(completed_value)
  }

  # 2. Let argumentValues be the result of CoerceArgumentValues(objectType, field, variableValues)
  argument_values <- coerce_argument_values(object_type, field, ..., oh = oh)

  # 3. Let resolvedValue be ResolveFieldValue(objectType, objectValue, fieldName, argumentValues).
  resolved_value <- resolve_field_value(object_type, object_value, field_obj = field, argument_values, oh = oh)

  # str(object_value)

  # 4. Return the result of CompleteValue(fieldType, fields, resolvedValue, variableValues).
  completed_value <- complete_value(field_type, fields, resolved_value, oh = oh)
  # cat('\n\n')
  # str(completed_value)
  completed_value
}

resolve__typename <- function(object_type, object_value, ..., oh) {
  if (oh$schema_obj$is_object(object_type)) {
    ret <- format(object_type)
    return(ret)
  }

  obj <- ifnull(oh$schema_obj$get_interface(object_type), oh$schema_obj$get_union(object_type))
  ret <- obj$.resolve_type(object_value, oh$schema_obj)
  ret
}




# 6.4.1 - Coercing Field Arguments
#
# Fields may include arguments which are provided to the underlying runtime in order to correctly produce a value. These arguments are defined by the field in the type system to have a specific input type: Scalars, Enum, Input Object, or List or Non‐Null wrapped variations of these three.
#
# At each argument position in a query may be a literal value or a variable to be provided at runtime.
#
# CoerceArgumentValues(objectType, field, variableValues)
#   1. Let coercedValues be an empty unordered Map.
#   2. Let argumentValues be the argument values provided in field.
#   3. Let fieldName be the name of field.
#   4. Let argumentDefinitions be the arguments defined by objectType for the field named fieldName.
#   5. For each argumentDefinition in argumentDefinitions:
#     a. Let argumentName be the name of argumentDefinition.
#     b. Let argumentType be the expected type of argumentDefinition.
#     c. Let defaultValue be the default value for argumentDefinition.
#     d. Let value be the value provided in argumentValues for the name argumentName.
#     e. If value is a Variable:
#       i. Let variableName be the name of Variable value.
#       ii. Let variableValue be the value provided in variableValues for the name variableName.
#       iii. If variableValue exists (including null):
#         1. Add an entry to coercedValues named argName with the value variableValue.
#       iv. Otherwise, if defaultValue exists (including null):
#         1. Add an entry to coercedValues named argName with the value defaultValue.
#       v. Otherwise, if argumentType is a Non‐Nullable type, throw a field error.
#       vi. Otherwise, continue to the next argument definition.
#     f. Otherwise, if value does not exist (was not provided in argumentValues:
#       i. If defaultValue exists (including null):
#         1. Add an entry to coercedValues named argName with the value defaultValue.
#       ii. Otherwise, if argumentType is a Non‐Nullable type, throw a field error.
#       iii. Otherwise, continue to the next argument definition.
#     g. Otherwise, if value cannot be coerced according to the input coercion rules of argType, throw a field error.
#     h. Let coercedValue be the result of coercing value according to the input coercion rules of argType.
#     i. Add an entry to coercedValues named argName with the value coercedValue.
#   6. Return coercedValues.
# Note: Variable values are not coerced because they are expected to be coerced before executing the operation in CoerceVariableValues(), and valid queries must only allow usage of variables of appropriate types.
coerce_argument_values <- function(object_type, field, ..., oh) {
  # 1. Let coercedValues be an empty unordered Map.
  coerced_values <- list()

  # 2. Let argumentValues be the argument values provided in field.
  argument_values <- field$arguments

  # if there are no arguments, return a list
  if (is.null(argument_values)) return(coerced_values)
  if (length(argument_values) == 0) return(coerced_values)

  # 3. Let fieldName be the name of field.
  field_name <- field$name

  # 4. Let argumentDefinitions be the arguments defined by objectType for the field named fieldName.
  field_parent_obj <- oh$schema_obj$get_object(object_type)
  matching_field_obj <- field_parent_obj$.get_field(field)
  argument_definitions <- matching_field_obj$arguments




  # 5. For each argumentDefinition in argumentDefinitions:
  for (argument_definition in argument_definitions) {
    # a. Let argumentName be the name of argumentDefinition.
    argument_name <- argument_definition$.get_name()
    # b. Let argumentType be the expected type of argumentDefinition.
    argument_type <- argument_definition$type
    # c. Let defaultValue be the default value for argumentDefinition.
    default_value <- argument_definition$defaultValue

    # d. Let value be the value provided in argumentValues for the name argumentName.
    matching_arg <- field$.get_matching_argument(argument_definition)

    # f. Otherwise, if value does not exist (was not provided in argumentValues:
    if (is.null(matching_arg)) {
      # i. If defaultValue exists (including null):
      if (!is.null(default_value)) {
        # 1. Add an entry to coercedValues named argName with the value defaultValue.
        coerced_values[[argument_name]] <- default_value
        next
      }
      # ii. Otherwise, if argumentType is a Non‐Nullable type, throw a field error.
      if (inherits(argument_type, "NonNullType")) {
        oh$error_list$add(
          "6.4.1",
          "non nullable type argument did not argument definition"
        )
        next
      }

      # iii. Otherwise, continue to the next argument definition.
      next
    }

    value <- matching_arg$value
    # e. If value is a Variable:
    if (inherits(value, "Variable")) {
      # i. Let variableName be the name of Variable value.
      variable_name <- format(value$name)
      variable_to_name <- format(matching_arg$name)

      # ii. Let variableValue be the value provided in variableValues for the name variableName.
      # iii. If variableValue exists (including null):
      if (oh$has_variable_value(value)) {
        # 1. Add an entry to coercedValues named argName with the value variableValue.
        variable_value <- oh$get_variable_value(value)
        coerced_values[[variable_to_name]] <- variable_value
        next
      }

      # iv. Otherwise, if defaultValue exists (including null):
      if (!is.null(default_value)) {
        # 1. Add an entry to coercedValues named argName with the value defaultValue.
        coerced_values[[variable_to_name]] <- argument_definition$defaultValue$value
        next
      }

      # v. Otherwise, if argumentType is a Non‐Nullable type, throw a field error.
      if (inherits(argument_type, "NonNullType")) {
        oh$error_list$add(
          "6.4.1",
          "non nullable type argument did not find variable definition"
        )
        next
      }
      # vi. Otherwise, continue to the next argument definition.
      next

    }


    type_obj <- oh$schema_obj$get_type(argument_type)

    # h. Let coercedValue be the result of coercing value according to the input coercion rules of argType.
    coerced_value <- type_obj$.parse_literal(value)
    if (!is.null(value) && is.null(coerced_value)) {
      oh$error_list$add(
        "6.4.1",
        "Value cannot be coerced according to the input coercion rules"
      )
      next
    }

    # i. Add an entry to coercedValues named argName with the value coercedValue.
    coerced_values[[argument_name]] <- coerced_value

  }

  # str(coerced_values)
  # browser()
  coerced_values
}



# 6.4.2 - Value Resolution
#
# While nearly all of GraphQL execution can be described generically, ultimately the internal system exposing the GraphQL interface must provide values. This is exposed via ResolveFieldValue, which produces a value for a given field on a type for a real value.
#
# As an example, this might accept the objectType Person, the field "soulMate", and the objectValue representing John Lennon. It would be expected to yield the value representing Yoko Ono.
#
# ResolveFieldValue(objectType, objectValue, fieldName, argumentValues)
#   1. Let resolver be the internal function provided by objectType for determining the resolved value of a field named fieldName.
#   2. Return the result of calling resolver, providing objectValue and argumentValues.
# Note: It is common for resolver to be asynchronous due to relying on reading an underlying database or networked service to produce a value. This necessitates the rest of a GraphQL executor to handle an asynchronous execution flow.
resolve_field_value <- function(object_type, object_value, field_obj, argument_values, ..., oh) {

  object_obj <- oh$schema_obj$get_type(object_type)

  resolver_fn <- object_obj$.get_field(field_obj)$.resolve
  resolver_fn <- NULL

  # cat("\n\n")
  # print(list(
  #   obj = object_obj,
  #   value = object_value,
  #   name = format(field_obj$name),
  #   resolver = resolver_fn
  # ))
  # browser()

  field_name_txt <- format(field_obj$name)
  if (is.null(resolver_fn)) {
    if (! (field_name_txt %in% names(object_value))) {
      message(
        "Error: No .resolve(obj, args, schema, ...) found for field: ", field_name_txt,
        " for object of type: ", format(object_type), ".",
        "  Could not find field in resolved object either.",
        "  Returning NULL."
      )
      return(NULL)
    }

    val <- object_value[[field_name_txt]]
    if (is.function(val)) {
      val_fn <- val
      ans <- val_fn(object_value, argument_values, oh$schema_obj)
      return(ans)
    }
    return(val)
  }

  ret_val <- resolver_fn(object_value, argument_values, oh$schema_obj)
  return(ret_val)
}



# 6.4.3 - Value Completion
#
# After resolving the value for a field, it is completed by ensuring it adheres to the expected return type. If the return type is another Object type, then the field execution process continues recursively.
#
# CompleteValue(fieldType, fields, result, variableValues)
#   1. If the fieldType is a Non‐Null type:
#     a. Let innerType be the inner type of fieldType.
#     b. Let completedResult be the result of calling CompleteValue(innerType, fields, result, variableValues).
#     c. If completedResult is null, throw a field error.
#     d. Return completedResult.
#   2. If result is null (or another internal value similar to null such as undefined or NaN), return null.
#   3. If fieldType is a List type:
#     a. If result is not a collection of values, throw a field error.
#     b. Let innerType be the inner type of fieldType.
#     c. Return a list where each list item is the result of calling CompleteValue(innerType, fields, resultItem, variableValues), where resultItem is each item in result.
#   4. If fieldType is a Scalar or Enum type:
#     a. Return the result of “coercing” result, ensuring it is a legal value of fieldType, otherwise null.
#   5. If fieldType is an Object, Interface, or Union type:
#     a. If fieldType is an Object type.
#       i. Let objectType be fieldType.
#     b. Otherwise if fieldType is an Interface or Union type.
#       i. Let objectType be ResolveAbstractType(fieldType, result).
#     c. Let subSelectionSet be the result of calling MergeSelectionSets(fields).
#     d. Return the result of evaluating ExecuteSelectionSet(subSelectionSet, objectType, result, variableValues) normally (allowing for parallelization).
complete_value <- function(field_type, fields, result, ..., oh) {
  # 1. If the fieldType is a Non‐Null type:
  if (inherits(field_type, "NonNullType")) {
    # a. Let innerType be the inner type of fieldType.
    inner_type <- field_type$type
    # b. Let completedResult be the result of calling CompleteValue(innerType, fields, result, variableValues).
    completed_result <- complete_value(inner_type, fields, result, oh = oh)
    # c. If completedResult is null, throw a field error.
    if (is.null(completed_result)) {
      oh$error_list$add(
        "6.4.3",
        "non null type: ", format(field_type), " returned a null value"
      )
      return(NULL)
    }
    # d. Return completedResult.
    return(completed_result)
  }

  # 2. If result is null (or another internal value similar to null such as undefined or NaN), return null.
  if (is_nullish(result)) {
    return(NULL)
  }

  # 3. If fieldType is a List type:
  if (inherits(field_type, "ListType")) {
    # lightly coerce to a list
    if (is.vector(result)) {
      result <- as.list(result)
    }
    # a. If result is not a collection of values, throw a field error.
    if (!is.list(result)) {
      oh$error_list$add(
        "6.4.3",
        "list type returned a non list type"
      )
      return(NULL)
    }
    # b. Let innerType be the inner type of fieldType.
    inner_type <- field_type$type
    # c. Return a list where each list item is the result of calling CompleteValue(innerType, fields, resultItem, variableValues), where resultItem is each item in result.
    completed_result <- lapply(result, function(result_item) {
      complete_value(inner_type, fields, result_item, oh = oh)
    })
    completed_result <- unname(completed_result)
    return(completed_result)
  }

  # 4. If fieldType is a Scalar or Enum type:
  if (
    oh$schema_obj$is_scalar(field_type) ||
    oh$schema_obj$is_enum(field_type)
  ) {
    # a. Return the result of “coercing” result, ensuring it is a legal value of fieldType, otherwise null.
    type_obj <- ifnull(
      oh$schema_obj$get_scalar(field_type),
      oh$schema_obj$get_enum(field_type)
    )
    resolved_result <- type_obj$.parse_value(result)
    if (length(resolved_result) == 0) {
      return(NULL)
    }
    return(resolved_result)
  }

  # 5. If fieldType is an Object, Interface, or Union type:
  if (
    oh$schema_obj$is_object_interface_or_union(field_type)
  ) {
    # a. If fieldType is an Object type.
    if (oh$schema_obj$is_object(field_type)) {
      # i. Let objectType be fieldType.
      object_type <- field_type

    } else {
      # b. Otherwise if fieldType is an Interface or Union type.
        # i. Let objectType be ResolveAbstractType(fieldType, result).
      field_obj <- ifnull(
        oh$schema_obj$get_interface(field_type),
        oh$schema_obj$get_union(field_type)
      )
      object_type <- resolve_abstract_type(field_type, result, field_obj, oh = oh)
    }

    object_obj <- oh$schema_obj$get_object(object_type)
    # if the object has it's own resolver function, call it.
    # ex: all friends are stored as id values.  should return full object
    if (is.function(object_obj$.resolve)) {
      result <- object_obj$.resolve(result, schema_obj = oh$schema_obj)
      # if a nullish result is returned, return null
      if (is_nullish(result)) {
        return(NULL)
      }
    }

    # c. Let subSelectionSet be the result of calling MergeSelectionSets(fields).
    sub_selection_set <- merge_selection_sets(fields, oh = oh)

    # d. Return the result of evaluating ExecuteSelectionSet(subSelectionSet, objectType, result, variableValues) normally (allowing for parallelization).
    ret <- execute_selection_set(sub_selection_set, object_type, result, oh = oh)
    return(ret)
  }

  stop("this should not be reached")
}


# ResolveAbstractType(abstractType, objectValue)
#   1. Return the result of calling the internal method provided by the type system for determining the Object type of abstractType given the value objectValue.
resolve_abstract_type <- function(abstract_type, object_value, abstract_obj, ..., oh) {

  if (inherits(abstract_obj, "InterfaceTypeDefinition")) {
    type <- abstract_obj$.resolve_type(object_value, oh$schema_obj)
    type <- oh$schema_obj$as_type(type)
    return(type)

  } else if (inherits(abstract_obj, "UnionTypeDefinition")) {
    type <- abstract_obj$.resolve_type(object_value, oh$schema_obj)
    type <- oh$schema_obj$as_type(type)
    return(type)
  }

  stop("Interface or Union objects can only resolve an abstract type")
}



# MergeSelectionSets(fields)
#   1. Let selectionSet be an empty list.
#   2. For each field in fields:
#     a. Let fieldSelectionSet be the selection set of field.
#     b. If fieldSelectionSet is null or empty, continue to the next field.
#     c. Append all selections in fieldSelectionSet to selectionSet.
#   3. Return selectionSet.
merge_selection_sets <- function(fields, ..., oh) {
  # 1. Let selectionSet be an empty list.
  selections <- list()

  # 2. For each field in fields:
  for (field in fields) {
    # a. Let fieldSelectionSet be the selection set of field.
    field_selection_set <- field$selectionSet

    # b. If fieldSelectionSet is null or empty, continue to the next field.
    if (is.null(field_selection_set)) next
    if (length(field_selection_set) == 0) next

    # c. Append all selections in fieldSelectionSet to selectionSet.
    selections <- append(selections, field_selection_set$selections)
  }
  # 3. Return selectionSet.
  ret <- SelectionSet$new(selections = selections)
  return(ret)
}




# 6.4.4 - Errors and Non-Nullability
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
is_nullish <- function(x) {
  if (is.list(x) || is.vector(x)) {
    return(FALSE)
  }
  if (is.null(x)) return(TRUE)
  if (is.na(x)) return(TRUE)
  if (is.nan(x)) return(TRUE)
  return(FALSE)
}
