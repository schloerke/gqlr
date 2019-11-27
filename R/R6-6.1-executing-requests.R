

# nolint start

# 6.1 - Execute request     - DONE
#   get_operation           - DONE
#   coerce_variable_values  - DONE

# 6.2 - Execute Query    - DONE
#       Execute Mutation - DONE

# 6.3 - Executing Selection Sets - DONE
#   collect_fields - Test
#   does_fragment_type_apply - Test

# 6.4 - Executing Fields
#   execute_field - DONE
#   coerce_argument_values - DONE
#   resolve_field_value - DONE
#   complete_value - DONE
#   resolve_abstract_type - DONE
#   merge_selection_sets - test

# nolint end







# 6.1 - Executing Requests

# To execute a request, the executor must have a parsed Document (as defined in
# the “Query Language” part of this spec) and a selected operation name to run
# if the document defines multiple operations, otherwise the document is
# expected to only contain a single operation. The result of the request is
# determined by the result of executing this operation according to the
# “Executing Operations” section below.
#

# nolint start
# ExecuteRequest(schema, document, operationName, variableValues, initialValue)
#   1. Let operation be the result of GetOperation(document, operationName).
#   2. Let coercedVariableValues be the result of CoerceVariableValues(schema, operation, variableValues).
#   3. If operation is a query operation:
#     a. Return ExecuteQuery(operation, schema, coercedVariableValues, initialValue).
#   4. Otherwise if operation is a mutation operation:
#     a. Return ExecuteMutation(operation, schema, coercedVariableValues, initialValue).
# nolint end


#' Execute GraphQL server response
#'
#' Executes a GraphQL server request with the provided request.
#'
#' @param request a valid GraphQL string
#' @param schema a character string (to be used along side \code{initial_value})
#'   or a schema object created from \code{\link{gqlr_schema}}
#' @param operation_name name of request operation to execute. If not value is
#'   provided it will use the operation in the request string. If more than one
#'   operations exist, an error will be produced.  See
#'   \url{https://graphql.github.io/graphql-spec/October2016/#GetOperation()}
#' @param variables a named list containing variable values.
#'   \url{https://graphql.github.io/graphql-spec/October2016/#sec-Language.Variables}
#' @param initial_value default value for executing requests.  This value can
#'   either be provided and/or combined with the resolve method of the query
#'   root type or mutation root type.  The value provided should be a named list
#'   of the field name (key) and a value matching that field name type.  The
#'   value may be a function that returns a value of the field name type.
#' @references \url{https://graphql.github.io/graphql-spec/October2016/#sec-Execution}
#' @export
#' @examples
#' \donttest{
#' # bare bones
#' schema <- gqlr_schema("
#'   type Person {
#'     name: String
#'     friends: [Person]
#'   }
#'   schema {
#'     query: Person
#'   }
#' ")
#'
#' data <- list(
#'   name = "Barret",
#'   friends = list(
#'     list(name = "Ryan", friends = list(list(name = "Bill"), list(name = "Barret"))),
#'     list(name = "Bill", friends = list(list(name = "Ryan")))
#'   )
#' )
#'
#' ans <- execute_request("{ name }", schema, initial_value = data)
#' ans$as_json()
#'
#' execute_request("
#'   {
#'     name
#'     friends {
#'       name
#'       friends {
#'         name
#'         friends {
#'           name
#'         }
#'       }
#'     }
#'   }",
#'   schema,
#'   initial_value = data
#' )$as_json()
#'
#'
#'
#'
#'
#'
#' # Using resolve method to help with recursion
#' people <- list(
#'   "id_Barret" = list(name = "Barret", friends = list("id_Ryan", "id_Bill")),
#'   "id_Ryan" = list(name = "Ryan", friends = list("id_Barret", "id_Bill")),
#'   "id_Bill" = list(name = "Bill", friends = list("id_Ryan"))
#' )
#' schema <- gqlr_schema("
#'     type Person {
#'       name: String
#'       friends: [Person]
#'     }
#'     schema {
#'       query: Person
#'     }
#'   ",
#'   Person = list(
#'     resolve = function(name, schema, ...) {
#'       if (name %in% names(people)) {
#'         people[[name]]
#'       } else {
#'         NULL
#'       }
#'     }
#'   )
#' )
#'
#' ans <- execute_request("{ name }", schema, initial_value = "id_Barret")
#' ans$as_json()
#'
#' execute_request("
#'   {
#'     name
#'     friends {
#'       name
#'       friends {
#'         name
#'         friends {
#'           name
#'         }
#'       }
#'     }
#'   }",
#'   schema,
#'   initial_value = "id_Barret"
#' )$as_json()
#' }
execute_request <- function(
  request,
  schema,
  operation_name = NULL,
  variables = list(),
  initial_value = NULL
) {
  oh <- ObjectHelpers$new(schema, source = request)
  ret <- Result$new(oh$error_list)

  validate_schema(oh = oh)
  if (oh$error_list$has_any_errors()) return(ret)

  document_obj <- validate_document(request, oh = oh)
  if (oh$error_list$has_any_errors()) return(ret)

  operation <- get_operation(document_obj, operation_name, oh = oh)
  if (oh$error_list$has_any_errors()) return(ret)

  coerced_variables <- coerce_variable_values(operation, variables, oh = oh)
  if (oh$error_list$has_any_errors()) return(ret)
  oh$set_coerced_variables(coerced_variables)

  operation_type <- operation$operation
  if (identical(operation_type, "query")) {
    data <- execute_query(operation, initial_value, oh = oh)

  } else if (identical(operation_type, "mutation")) {
    data <- execute_mutation(operation, initial_value, oh = oh)
  }

  ret$data <- data
  return(ret)
}



validate_document <- function(document_obj, ..., oh) {
  if (is.character(document_obj)) {
    document_obj <- graphql2obj(document_obj)
  }
  document_obj <- validate_query(document_obj, oh = oh)
  document_obj
}

# nolint start
# GetOperation(document, operationName)
#   1. If operationName is null:
#     a. If document contains exactly one operation.
#       i. Return the Operation contained in the document.
#     b. Otherwise produce a query error requiring operationName.
#   2. Otherwise:
#     a. Let operation be the Operation named operationName in document.
#     b. If operation was not found, produce a query error.
#     c. Return operation.
# nolint end

get_operation <- function(document_obj, operation_name = NULL, ..., oh) {
  operations <- document_obj$.get_operations()

  if (is.null(operation_name)) {
    if (length(operations) != 1) {
      oh$error_list$add(
        "6.1",
        "If operation name is null, the document may only contain one operation"
        # no loc
      )
      return(NULL)
    }
    return(operations[[1]])
  }

  for (operation in operations) {
    operation_name_val <- format(operation$name)

    if (identical(operation_name, operation_name_val)) {
      return(operation)
    }
  }

  oh$error_list$add(
    "6.1",
    "Operation: ", operation_name, " can't be found in the document object"
    # no loc
  )
  return(NULL)
}



# nolint start
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
# nolint end

# variable_values is a named list according to the variable name
coerce_variable_values <- function(operation, variable_values, ..., oh) {

  coerced_values <- list()

  variable_definitions <- operation$variableDefinitions

  for (variable_definition in variable_definitions) {
    variable_name <- variable_definition$.get_name()
    variable_type <- variable_definition$type
    default_value <- variable_definition$defaultValue
    value <- variable_values[[variable_name]]

    if (is.null(value)) {
      if (!is.null(default_value)) {
        coerced_values[[variable_name]] <- default_value
      }

      if (inherits(variable_type, "NonNullType")) {
        oh$error_list$add(
          "6.1.2",
          "Non nullible type variable did not have value or default value",
          loc = variable_definition$loc
        )
        next
      }
    } else {

      if (inherits(value, "NullValue")) {
        coerced_value <- NULL
      } else {
        variable_obj <- oh$schema$get_type(variable_type)
        coerced_value <- variable_obj$.resolve(value, oh$schema)
        if (is.null(coerced_value)) {
          oh$error_list$add(
            "6.1.2",
            "Value cannot be coerced according to the input coercion rules",
            loc = variable_definition$loc
          )
          next
        }
      }

      coerced_values[[variable_name]] <- coerced_value
    }
  }

  coerced_values
}
