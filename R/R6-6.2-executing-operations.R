# 6.2 - Executing Operations

# The type system, as described in the “Type System” section of the spec, must provide a query root object type. If mutations are supported, it must also provide a mutation root object type.
#
# If the operation is a query, the result of the operation is the result of executing the query’s top level selection set with the query root object type.

execute_query_mutation_helper <- function(root_type) {
  pryr_unenclose(function(operation_obj, initial_value, ..., oh) {

    root_type_object <- oh$schema_obj$get_object(root_type)
    if (is.null(root_type_object)) {
      oh$error_list$add(
        "6.2",
        "Can not find '", root_type, "' object definition in schema"
      )
    }

    selection_set <- operation_obj$selectionSet

    # could parallelize here if wanted
    data <- execute_selection_set(selection_set, root_type, initial_value, oh = oh)

    return(list(data = data, errors = oh$error_list))
  })
}




#
# An initial value may be provided when executing a query.
# ExecuteQuery(query, schema, variableValues, initialValue)
#   1. Let queryType be the root Query type in schema.
#   2. Assert: queryType is an Object type.
#   3. Let selectionSet be the top level Selection Set in query.
#   4. Let data be the result of running ExecuteSelectionSet(selectionSet, queryType, initialValue, variableValues) normally (allowing parallelization).
#   5. Let errors be any field errors produced while executing the selection set.
#   6. Return an unordered map containing data and errors.

#   oh <- ObjectHelpers$new(schema_obj, ErrorList$new())
# oh$set_variable_values(variable_values)
execute_query <- execute_query_mutation_helper("QueryRoot")



# If the operation is a mutation, the result of the operation is the result of executing the mutation’s top level selection set on the mutation root object type. This selection set should be executed serially.
#
# It is expected that the top level fields in a mutation operation perform side‐effects on the underlying data system. Serial execution of the provided mutations ensures against race conditions during these side‐effects.
#
# ExecuteMutation(mutation, schema, variableValues, initialValue)
#   1. Let mutationType be the root Mutation type in schema.
#   2. Assert: mutationType is an Object type.
#   3. Let selectionSet be the top level Selection Set in mutation.
#   4. Let data be the result of running ExecuteSelectionSet(selectionSet, mutationType, initialValue, variableValues) serially.
#   5. Let errors be any field errors produced while executing the selection set.
#   6. Return an unordered map containing data and errors.
execute_mutation <- execute_query_mutation_helper("MutationRoot")