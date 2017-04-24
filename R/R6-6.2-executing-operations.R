# 6.2 - Executing Operations

# The type system, as described in the “Type System” section of the spec, must provide a query root object type. If mutations are supported, it must also provide a mutation root object type.
#
# If the operation is a query, the result of the operation is the result of executing the query’s top level selection set with the query root object type.

execute_query_mutation_helper <- function(root_def_name) {
  pryr_unenclose(function(operation_obj, initial_value, ..., oh) {

    root_type <- oh$schema_obj$get_schema_definition(root_def_name)
    root_type_object <- oh$schema_obj$get_type(root_type)
    if (is.null(root_type_object)) {
      oh$error_list$add(
        "6.2",
        "Can not find definition '", root_type, "' in schema definition"
      )
      return(list(data = NULL, errors = oh$error_list))
    }

    # add some default value so that the functinos will execute.  Otherwise they are 'NULL' values
    initial_value[["__schema"]] <- function(z1, z2, schema_obj) {
      return__schema(schema_obj)
    }
    initial_value[["__type"]] <- function(z1, args, schema_obj) {
      type_obj <- schema_obj$as_type(args$name)
      return__type(type_obj, schema_obj)
    }


    selection_set <- operation_obj$selectionSet

    # could parallelize here if wanted
    data <- execute_selection_set(selection_set, root_type, initial_value, oh = oh)

    return(list(data = data, error_list = oh$error_list))
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
execute_query <- execute_query_mutation_helper("query")
# DONE



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
execute_mutation <- execute_query_mutation_helper("mutation")
# DONE
