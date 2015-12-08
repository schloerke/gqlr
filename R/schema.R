# _queryType: GraphQLObjectType;
# _mutationType: ?GraphQLObjectType;
# _subscriptionType: ?GraphQLObjectType;
# _directives: Array<GraphQLDirective>;




gql_schema <- function(queryType, mutationType = NULL, subscriptionType = NULL, directives = NULL) {

  stop("TODO implement schema")
}






gql_type_scalar <- function(type = c("int", "float", "string", "boolean", "id"), serialize = I) {

}

gql_type_enum <- function() {

}

gql_type_object <- function() {

}

gql_type_interface <- function() {

}

gql_type_union <- function() {

}

gql_type_list <- function() {

}

gql_type_non_null <- function() {

}

gql_type_input_obect <- function() {

}
