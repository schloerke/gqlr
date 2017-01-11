"
schema {
  query: QueryType
  mutation: MutationType
}
"

tks_Schema <- SchemaDefinition$new(
  operationTypes = list(
    OperationTypeDefinition$new(
      operation = "query",
      type = NamedType$new(name = Name$new(value = "QueryType"))
    ),
    OperationTypeDefinition$new(
      operation = "mutation",
      type = NamedType$new(name = Name$new(value = "MutationType"))
    )
  ),
  directives = NULL
)
