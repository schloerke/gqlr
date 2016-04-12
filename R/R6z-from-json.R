r6_from_list <- function(obj, level = 0, keys = c(), objPos = NULL) {
  objClass <- obj$kind
  if (is.null(objPos)) {
    keys <- append(keys, objClass)
  } else {
    keys <- append(keys, str_c(objPos, "-", objClass))
  }
  level <- level + 1


  r6Obj <- get_class_obj(objClass)

  retList <- list()

  # fieldNames <- ret$"_argNames"
  fieldNames <- names(r6Obj$public_fields$"_args")

  for (activeKey in fieldNames) {
    cat(level, "-", paste(keys, collapse = ","), "-", activeKey, "\n")
    objVal <- obj[[activeKey]]

    if (is.list(objVal)) {
      if (length(objVal) == 0) {
        retList[[activeKey]] <- list()
      } else {
        if (identical(class(objVal), "list")) {
          # lapply(objVal, r6_from_list, keys = keys, level = level)
          retList[[activeKey]] <- lapply(seq_along(objVal), function(i) {
            r6_from_list(objVal[[i]], keys = keys, level = level, objPos = i)
          })
        } else {
          retList[[activeKey]] <- r6_from_list(objVal, keys = keys, level = level)
        }
      }
    } else {
      retList[[activeKey]] <- objVal
    }
  }

  do.call(r6Obj$new, retList)
}


get_class_obj <- (function(){
  classList <- list(
    AST = AST,
    Location = Location,
    Node = Node,
    Name = Name,
    Document = Document,
    Definition = Definition,
    OperationDefinition = OperationDefinition,
    VariableDefinition = VariableDefinition,
    Variable = Variable,
    SelectionSet = SelectionSet,
    Selection = Selection,
    Field = Field,
    Argument = Argument,
    FragmentSpread = FragmentSpread,
    InlineFragment = InlineFragment,
    FragmentDefinition = FragmentDefinition,
    Value = Value,
    IntValue = IntValue,
    FloatValue = FloatValue,
    StringValue = StringValue,
    BooleanValue = BooleanValue,
    EnumValue = EnumValue,
    ListValue = ListValue,
    ObjectValue = ObjectValue,
    ObjectField = ObjectField,
    Directive = Directive,
    Type = Type,
    NamedType = NamedType,
    ListType = ListType,
    NonNullType = NonNullType,
    TypeDefinition = TypeDefinition,
    ObjectTypeDefinition = ObjectTypeDefinition,
    FieldDefinition = FieldDefinition,
    InputValueDefinition = InputValueDefinition,
    InterfaceTypeDefinition = InterfaceTypeDefinition,
    UnionTypeDefinition = UnionTypeDefinition,
    ScalarTypeDefinition = ScalarTypeDefinition,
    EnumTypeDefinition = EnumTypeDefinition,
    EnumValueDefinition = EnumValueDefinition,
    InputObjectTypeDefinition = InputObjectTypeDefinition,
    TypeExtensionDefinition = TypeExtensionDefinition
  )

  function(classVal) {
    obj = classList[[classVal]]
    if (is.null(obj)) {
      stop0("Could not find object with class: ", classVal)
    }
    obj
  }
})()
