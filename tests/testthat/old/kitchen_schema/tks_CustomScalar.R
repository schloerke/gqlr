"
scalar CustomScalar
"
tks_CustomScalar <- ScalarTypeDefinition$new(
  name = Name$new(value = "CustomScalar"),
  parse_value = function(...) NULL,
  parse_literal = function(...) NULL,
  serialize = function(...) NULL
)
