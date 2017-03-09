#
# GraphQL generates a response from a request via execution.
#
# A request for execution consists of a few pieces of information:
#
# The schema to use, typically solely provided by the GraphQL service.
# A Document containing GraphQL Operations and Fragments to execute.
# Optionally: The name of the Operation in the Document to execute.
# Optionally: Values for any Variables defined by the Operation.
# An initial value corresponding to the root type being executed. Conceptually, an initial value represents the “universe” of data available via a GraphQL Service. It is common for a GraphQL Service to always use the same initial value for every request.
# Given this information, the result of ExecuteRequest() produces the response, to be formatted according to the Response section below.





# 6.1 - Executing Requests - TODO

# To execute a request, the executor must have a parsed Document (as defined in the “Query Language” part of this spec) and a selected operation name to run if the document defines multiple operations, otherwise the document is expected to only contain a single operation. The result of the request is determined by the result of executing this operation according to the “Executing Operations” section below.
#

# ExecuteRequest(schema, document, operationName, variableValues, initialValue)
#   1. Let operation be the result of GetOperation(document, operationName).
#   2. Let coercedVariableValues be the result of CoerceVariableValues(schema, operation, variableValues).
#   3. If operation is a query operation:
#     a. Return ExecuteQuery(operation, schema, coercedVariableValues, initialValue).
#   4. Otherwise if operation is a mutation operation:
#     a. Return ExecuteMutation(operation, schema, coercedVariableValues, initialValue).

execute_request <- function(
  document_obj,
  operation_name = NULL,
  variable_values = list(),
  initial_value,
  ...,
  oh
) {

  operation <- get_operation(document_obj, operation_name)
  if (oh$error_list$has_any_errors()) return(NULL)

  coerced_variable_values <- coerce_variable_values(schema_obj, operation, variable_values)
  if (oh$error_list$has_any_errors()) return(NULL)
  oh$set_coerced_variables(coerced_variable_values)

  operation_type <- operation$operation
  if (identical(operation_type, "query")) {
    return(
      execute_query(operation, initial_value, oh = oh)
    )

  } else if (identical(operation_type, "mutation")) {
    stop("TODO - mutation not implemented")
    return(
      execute_mutation(operation, initial_value, oh = oh)
    )

  }

  stop("Operation type not implemented: ", operation_type)
}


# GetOperation(document, operationName)
#   1. If operationName is null:
#     a. If document contains exactly one operation.
#       i. Return the Operation contained in the document.
#     b. Otherwise produce a query error requiring operationName.
#   2. Otherwise:
#     a. Let operation be the Operation named operationName in document.
#     b. If operation was not found, produce a query error.
#     c. Return operation.
get_operation <- function(document_obj, operation_name = NULL, ..., oh) {
  operations <- document_obj$.get_operations()

  if (is.null(operation_name)) {
    if (length(operations) != 1) {
      oh$error_list$add(
        "6.1",
        "If operation name is null, the document may only contain one operation"
      )
      return(NULL)
    }
    return(operations[[1]])
  }

  for (operation in operations) {
    operation_name_val <- operation$name$value

    if (identical(operation_name, operation_name_val)) {
      return(operation)
    }
  }

  oh$error_list$add(
    "6.1",
    "Operation: ", operation_name, " can't be found in the document object"
  )
  return(NULL)
}



# CoerceVariableValues(schema, operation, variableValues)
#   1. Let coercedValues be an empty unordered Map.
#   2. Let variableDefinitions be the variables defined by operation.
#   3. For each variableDefinition in variableDefinitions:
#     a. Let variableName be the name of variableDefinition.
#     b. Let variableType be the expected type of variableDefinition.
#     c. Let defaultValue be the default value for variableDefinition.
#     d. Let value be the value provided in variableValues for the name variableName.
#     e. If value does not exist (was not provided in variableValues):
#       i. If defaultValue exists (including null):
#         1. Add an entry to coercedValues named variableName with the value defaultValue.
#       ii. Otherwise if variableType is a Non‐Nullable type, throw a query error.
#       iii. Otherwise, continue to the next variable definition.
#     f. Otherwise, if value cannot be coerced according to the input coercion rules of variableType, throw a query error.
#     g. Let coercedValue be the result of coercing value according to the input coercion rules of variableType.
#     h. Add an entry to coercedValues named variableName with the value coercedValue.
#   4. Return coercedValues.

# variable_values is a named list according to the variable name
# TODO- similar to CoerceArgumentValues
coerce_variable_values <- function(operation, variable_values, ..., oh) {

  coerced_values <- list()

  variable_definitions <- operation$variableDefinitions

  for (variable_definition in variableDefinitions) {
    variable_name <- variable_definition$.get_name()
    variable_type <- variable_definition$type
    default_value <- variable_definition$defaultValue
    value <- variable_values[[variable_name]]

    if (is.null(value)) {
      if (!is.null(default_value)) {
        coerced_values[[variable_name]] <- default_value
      }

      if (inherits(variable_type, "NonNullType")) {
        stop("6.1.2", "Non nullible type variable did not have value or default value")
      }
    } else {

      if (inherits(value, "NullValue")) {
        coerced_value <- NULL
      } else {
        coerced_value <- coerce_value(value, variable_type)
        if (is.null(coerced_value)) {
          stop("6.1.2", "Value cannot be coerced according to the input coercion rules")
        }
      }

      coerced_values[[variable_name]] <- coerced_value
    }
  }

  coerced_values
}
