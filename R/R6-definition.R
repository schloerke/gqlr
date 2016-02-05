
#' @include z_utils.R
NULL


parse_args <- function(txt) {
  # txt = "kind: 'Document';
  # loc?: ?Location;
  # definitions: Array<Definition>;"

  kvPairs <- strsplit(txt, ";")[[1]] %>%
    lapply(function(txtItem) {
      keyValue <- strsplit(txtItem, ":")[[1]]
      key <- str_trim(keyValue[1]) %>%
        str_replace("\\?$", "")

      value <- str_trim(keyValue[2]) %>%
        str_replace(";", "")

      if (str_detect(value, "^'") && str_detect(value, "'$")) {
        # is literal value
        values <- strsplit(value, "\\|")[[1]] %>%
          str_replace("'", "") %>%
          str_replace("'", "") %>%
          str_trim()

        retItem <- list(type = "string", isArray = FALSE, canBeNull = FALSE, possibleValues = values)
      } else {
        canBeNull <- FALSE
        isArray <- FALSE
        if (str_detect(value, "^\\?")) {
          canBeNull <- TRUE
          value <- str_replace(value, "^\\?", "")
        }
        if (str_detect(value, "^Array<")) {
          isArray <- TRUE
          value <- str_replace(value, "^Array<", "") %>% str_replace(">$", "")
        }

        retItem <- list(type = value, isArray = isArray, canBeNull = canBeNull, value = NULL)
      }

      list(key = key, value = retItem)
    })


  keys <- lapply(kvPairs, "[[", "key") %>% unlist()
  ret <- lapply(kvPairs, "[[", "value")
  if (keys[length(keys)] == "") {
    removeBadPos <- -1 * length(keys)
    keys <- keys[removeBadPos]
    ret <- ret[removeBadPos]
  }
  names(ret) <- keys
  ret
}




R6_from_args <- function(type, txt, inherit = NULL, public = list(), private = list(), active = list()) {
  # R6_from_args("Document", "kind: 'Document'; loc?: ?Location; definitions: Array<Definition>;", inherit = AST)

  self_value_wrapper <- function(key, classVal) {
    function(value) {
      if (missing(value)) {
        return(self[["_args"]][[key]]$value)
      }

      if (is.null(value)) {
        if (! self[["_args"]][[key]]$canBeNull) {
          stop0("Can not set value to NULL for ", classVal, "$", key)
        }
        self[["_args"]][[key]]$value <- value
        return(value)
      }

      if (!inherits(value, classVal)) {
        stop0(
          "Attempting to set ", class(self)[1], ".", key, ".\n",
          "Expected value with class of |", classVal, "|.\n",
          "Received ", paste(class(value), collapse = ", ")
        )
      }
      self[["_args"]][[key]]$value <- value
      value
    }
  }


  self_array_wrapper <- function(key, classVal) {
    function(value) {
      if (missing(value)) {
        return(self[["_args"]][[key]]$value)
      }

      if (inherits(value, "R6")) {
        print(value)
        stop0(
          "Attempting to set ", class(self)[1], ".", key, ".\n",
          "Expected value should be an array of ", classVal, " objects.\n",
          "Received ", paste(class(value), collapse = ", "),
          "Received object above."
        )
      }
      lapply(value, function(valItem) {
        if (!inherits(valItem, classVal)) {
          print(valItem)
          stop0(
            "Attempting to set ", class(self)[1], ".", key, ".\n",
            "Expected value with class of |", classVal, "|.\n",
            "Received ", paste(class(valItem), collapse = ", "),
            "Received object above.",
          )
        }
      })

      self[["_args"]][[key]]$value <- value
      value
    }
  }

  self_base_wrapper <- function(key, parse_fn) {
    fn <- function(value) {
      if (missing(value)) {
        return(self[["_args"]][[key]]$value)
      }
      value <- parse_fn(value)
      self[["_args"]][[key]]$value <- value
      value
    }
    fn
  }
  self_base_values_wrapper <- function(key, parse_fn, values) {
    fn <- function(value) {
      if (missing(value)) {
        return(self[["_args"]][[key]]$value)
      }
      value <- parse_fn(value)
      if (! (value %in% values)) {
        stop0("Value supplied to key '", key, "' not in accepted values: ", str_c(values, collapse = ", "), ".")
      }
      self[["_args"]][[key]]$value <- value
      value
    }
    fn
  }


  args <- parse_args(txt)
  args$kind <- NULL

  activeList <- list()

  for (argName in names(args)) {
    argItem <- args[[argName]]
    argType <- argItem$type
    if (argType %in% c("string", "number", "boolean")) {
      type_fn <- switch(argType,
        string = as.character,
        number = as.numeric,
        boolean = as.logical
      )

      possibleValues <- argItem$possibleValues
      if (! is.null(possibleValues)) {
        fn <- self_base_values_wrapper(argName, type_fn, possibleValues)
      } else {
        fn <- self_base_wrapper(argName, type_fn)
      }

    } else {
      if (argItem$isArray) {
        fn <- self_array_wrapper(argName, argType)

      } else {
        fn <- self_value_wrapper(argName, argType)

      }
    }

    # replace all "argName" and "type_fn" or "argType" with the actual values
    # this allows R6 to work with functions that should be closures,
    # after unenclose'ing the function, it is no long a closure
    fn <- pryr::unenclose(pryr::unenclose(fn))

    activeList[[argName]] <- fn
  }

  publicList <- list()
  publicList[["_args"]] <- args

  if (is.null(public)) {
    public <- list()
  }
  for (nameVal in names(public)) {
    publicList[[nameVal]] <- public[[nameVal]]
  }

  if (is.null(active)) {
    active <- list()
  }
  for (nameVal in names(active)) {
    activeList[[nameVal]] <- active[[nameVal]]
  }

  privateList <- list()
  if (is.null(private)) {
    private <- list()
  }
  for (nameVal in names(private)) {
    privateList[[nameVal]] <- private[[nameVal]]
  }

  r6Class <- R6Class(type,
    public = publicList,
    private = privateList,
    active = activeList
  )
  r6Class$inherit <- substitute(inherit)

  r6Class
}


r6_from_json <- function(obj, level = 0, keys = c(), objPos = NULL) {
  objClass <- obj$kind
  if (is.null(objPos)) {
    keys <- append(keys, objClass)
  } else {
    keys <- append(keys, str_c(objPos, "-", objClass))
  }
  level <- level + 1


  r6Obj <- get_class_obj(objClass)

  ret <- r6Obj$new()

  fieldNames <- ret$"_argNames"

  for (activeKey in fieldNames) {
    cat(level, "-", paste(keys, collapse = ","), "-", activeKey, "\n")
    objVal <- obj[[activeKey]]

    if (is.list(objVal)) {
      if (length(objVal) == 0) {
        ret[[activeKey]] <- NULL
      } else {
        if (identical(class(objVal), "list")) {
          # lapply(objVal, r6_from_json, keys = keys, level = level)
          ret[[activeKey]] <- lapply(seq_along(objVal), function(i) {
            r6_from_json(objVal[[i]], keys = keys, level = level, objPos = i)
          })
        } else {
          ret[[activeKey]] <- r6_from_json(objVal, keys = keys, level = level)
        }
      }
    } else {
      ret[[activeKey]] <- objVal
    }
  }
  ret
}


gqlr_str <- (function() {
  cat_ret_spaces <- function(spaces, ...) {
    cat("\n", rep(" ", spaces), ..., sep = "")
  }

  str_obj <- function(x, spaceCount = 0, showNull) {

    r6ObjClass <- class(x)[1]

    cat("<", r6ObjClass, ">", sep = "")

    fieldNames <- x$"_argNames"

    for (fieldName in fieldNames) {
      if (fieldName %in% c("loc")) {
        next
      }

      fieldVal <- x[[fieldName]]

      if (!inherits(fieldVal, "R6")) {
        if (is.list(fieldVal)) {
          # is list
          cat_ret_spaces(spaceCount + 2, fieldName, ":")
          for (itemPos in seq_along(fieldVal)) {
            fieldItem <- fieldVal[[itemPos]]
            cat_ret_spaces(spaceCount + 4, itemPos, " - ")
            str_obj(fieldItem, spaceCount + 4, showNull)
          }

        } else {
          # is value
          if (is.null(fieldVal)) {
            fieldVal <- "NULL"
            if (showNull) {
              cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
            }
          } else if (is.numeric(fieldVal)) {
            cat_ret_spaces(spaceCount + 2, fieldName, ": ", fieldVal)
          } else if (is.character(fieldVal)) {
            cat_ret_spaces(spaceCount + 2, fieldName, ": '", fieldVal, "'")
          }
        }

      } else {
        # recursive call to_string
        cat_ret_spaces(spaceCount + 2, fieldName, ": ")
        str_obj(fieldVal, spaceCount + 2, showNull)
      }

    }
  }

  function(x, showNull = FALSE) {
    str_obj(x, 0, showNull)
    cat("\n")
  }
})()





AST <- R6Class("AST",
  public = list(
  ),
  active = list(
    "_argNames" = function() {
      names(self$"_args")
    },
    kind = function() {
      class(self)[1]
    }
  )
)




# /**
#  * A representation of source input to GraphQL. The name is optional,
#  * but is mostly useful for clients who store GraphQL documents in
#  * source files; for example, if the GraphQL input is in a file Foo.graphql,
#  * it might be useful for name to be "Foo.graphql".
#  */
Source <- R6_from_args(
  inherit = AST,
  "Source",
  " name: string;
    body: string;",
  active = list(
    name = function(value) {
      if (missing(value)) {
        return(self[["_args"]]$name$value)
      }

      if (is.null(value)) {
        value <- "GraphQL"
      }
      self[["_args"]]$name$value <- value
      value
    }
  )
)



Location <- R6_from_args(
  inherit = AST,
  "Location",
  " start: number;
    end: number;
    source?: ?Source;"
)


# /**
#  * The list of all possible AST node types.
#  */
# export type Node = Name
#                  | Document
#                  | OperationDefinition
#                  | VariableDefinition
#                  | Variable
#                  | SelectionSet
#                  | Field
#                  | Argument
#                  | FragmentSpread
#                  | InlineFragment
#                  | FragmentDefinition
#                  | IntValue
#                  | FloatValue
#                  | StringValue
#                  | BooleanValue
#                  | EnumValue
#                  | ListValue
#                  | ObjectValue
#                  | ObjectField
#                  | Directive
#                  | NamedType
#                  | ListType
#                  | NonNullType
#                  | ObjectTypeDefinition
#                  | FieldDefinition
#                  | InputValueDefinition
#                  | InterfaceTypeDefinition
#                  | UnionTypeDefinition
#                  | ScalarTypeDefinition
#                  | EnumTypeDefinition
#                  | EnumValueDefinition
#                  | InputObjectTypeDefinition
#                  | TypeExtensionDefinition

# GQLR_HasLocation <- R6Class("GQLR_HasLocation",
#   inherit = AST,
#   public = list(
#     "_loc" = NULL
#   ),
#   active = list(
#     loc = function(v) { self_value("_loc", "Location", self, v, m(v)) }
#   )
# )
Node <- R6Class("Node", inherit = AST)



Name <- R6_from_args(
  inherit = Node,
  "Name",
  " loc?: ?Location;
    value: string;",
  active = list(
    value = function(value) {
      if (missing(value)) {
        return(self[["_args"]]$value$value)
      }
      if (!str_detect(value, "^[_A-Za-z][_0-9A-Za-z]*$")) {
        stop0("Name value must match the regex of: /[_A-Za-z][_0-9A-Za-z]*/. Received value: '", value, "'")
      }
      self[["_args"]]$value$value <- value
      value
    }
  )
)



Document <- R6_from_args(
  inherit = Node,
  "Document",
  " loc?: ?Location;
    definitions: Array<Definition>;"
)


# export type Definition = OperationDefinition
#                        | FragmentDefinition
#                        | TypeDefinition
#                        | TypeExtensionDefinition
Definition <- R6Class("Definition", inherit = Node)

OperationDefinition <- R6_from_args(
  inherit = Definition,
  "OperationDefinition",
  " loc?: ?Location;
    operation: 'query' | 'mutation' | 'subscription';
    name?: ?Name;
    variableDefinitions?: ?Array<VariableDefinition>;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;"
)


VariableDefinition <- R6_from_args(
  inherit = Node,
  "VariableDefinition",
  " loc?: ?Location;
    variable: Variable;
    type: Type;
    defaultValue?: ?Value;"
)

SelectionSet <- R6_from_args(
  inherit = Node,
  "SelectionSet",
  " loc?: ?Location;
    selections: Array<Selection>;"
)



# export type Selection = Field
#                       | FragmentSpread
#                       | InlineFragment
Selection = R6Class("Selection", inherit = Node)



Field = R6_from_args(
  inherit = Selection,
  "Field",
  " loc?: ?Location;
    alias?: ?Name;
    name: Name;
    arguments?: ?Array<Argument>;
    directives?: ?Array<Directive>;
    selectionSet?: ?SelectionSet;"
)


Argument = R6_from_args(
  inherit = Node,
  "Argument",
  " loc?: ?Location;
    name: Name;
    value: Value;"
)


FragmentSpread = R6_from_args(
  inherit = Selection,
  "FragmentSpread",
  " loc?: ?Location;
    name: Name;
    directives?: ?Array<Directive>;"
)


InlineFragment = R6_from_args(
  inherit = Selection,
  "InlineFragment",
  " loc?: ?Location;
    typeCondition?: ?NamedType;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;"
)



FragmentDefinition = R6_from_args(
  inherit = Definition,
  "FragmentDefinition",
  " loc?: ?Location;
    name: Name;
    typeCondition: NamedType;
    directives?: ?Array<Directive>;
    selectionSet: SelectionSet;"
)




# // Values

# export type Value = Variable
#                   | IntValue
#                   | FloatValue
#                   | StringValue
#                   | BooleanValue
#                   | EnumValue
#                   | ListValue
#                   | ObjectValue
Value <- R6Class("Value", inherit = Node)


Variable <- R6_from_args(
  inherit = Value,
  "Variable",
  " loc?: ?Location;
    name: Name; "
)


IntValue = R6_from_args(
  inherit = Value,
  "IntValue",
  " loc?: ?Location;
    value: string;"
)
FloatValue = R6_from_args(
  inherit = Value,
  "FloatValue",
  " loc?: ?Location;
    value: string;"
)
StringValue = R6_from_args(
  inherit = Value,
  "StringValue",
  " loc?: ?Location;
    value: string;"
)
BooleanValue = R6_from_args(
  inherit = Value,
  "BooleanValue",
  " loc?: ?Location;
    value: boolean;"
)
EnumValue = R6_from_args(
  inherit = Value,
  "EnumValue",
  " loc?: ?Location;
    value: string;"
)
ListValue = R6_from_args(
  inherit = Value,
  "ListValue",
  " loc?: ?Location;
    values: Array<Value>;"
)
ObjectValue = R6_from_args(
  inherit = Value,
  "ObjectValue",
  " loc?: ?Location;
    fields: Array<ObjectField>;"
)

ObjectField = R6_from_args(
  inherit = Node,
  "ObjectField",
  " loc?: ?Location;
    name: Name;
    value: Value;
  "
)



# // Directives

Directive = R6_from_args(
  inherit = Node,
  "Directive",
  " loc?: ?Location;
    name: Name;
    arguments?: ?Array<Argument>;"
)



# // Type Reference

# export type Type = NamedType
#                  | ListType
#                  | NonNullType
Type = R6Class("Type",inherit = Node)


NamedType = R6_from_args(
  inherit = Type,
  "NamedType",
  " loc?: ?Location;
    name: Name;"
)
ListType = R6_from_args(
  inherit = Type,
  "ListType",
  " loc?: ?Location;
    type: Type;"
)
NonNullType = R6_from_args(
  inherit = Type,
  "NonNullType",
  " loc?: ?Location;
    type: NamedType | ListType;",
  active = list(
    type = function(value) {
      if (missing(value)) {
        return(self[["_args"]]$type$value)
      }
      if (!(inherits(value, "NamedType") || inherits(value, "ListType"))) {
        stop0("expected value with class of NamedType or ListType. Received ", value$kind)
      }
      self[["_args"]]$type$value <- value
      value
    }
  )
)



# // Type Definition

# export type TypeDefinition = ObjectTypeDefinition
#                            | InterfaceTypeDefinition
#                            | UnionTypeDefinition
#                            | ScalarTypeDefinition
#                            | EnumTypeDefinition
#                            | InputObjectTypeDefinition
TypeDefinition = R6Class("TypeDefinition", inherit = Definition)


ObjectTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "ObjectTypeDefinition",
  " loc?: ?Location;
    name: Name;
    interfaces?: ?Array<NamedType>;
    fields: Array<FieldDefinition>;"
)



FieldDefinition = R6_from_args(
  inherit = TypeDefinition,
  "FieldDefinition",
  " loc?: ?Location;
    name: Name;
    arguments: Array<InputValueDefinition>;
    type: Type;"
)



InputValueDefinition = R6_from_args(
  inherit = Node,
  "InputValueDefinition",
  " loc?: ?Location;
    name: Name;
    type: Type;
    defaultValue?: ?Value;"
)

InterfaceTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "InputValueDefinition",
  " loc?: ?Location;
    name: Name;
    fields: Array<FieldDefinition>;"
)


UnionTypeDefinition = R6_from_args(
  "UnionTypeDefinition",
  inherit = TypeDefinition,
  " loc?: ?Location;
    name: Name;
    types: Array<NamedType>;"
)

ScalarTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "ScalarTypeDefinition",
  " loc?: ?Location;
    name: Name;"
)

EnumTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "EnumTypeDefinition",
  " loc?: ?Location;
    name: Name;
    values: Array<EnumValueDefinition>;"
)
EnumValueDefinition = R6_from_args(
  inherit = TypeDefinition,
  "EnumValueDefinition",
  " loc?: ?Location;
    name: Name;"
)

InputObjectTypeDefinition = R6_from_args(
  inherit = TypeDefinition,
  "InputObjectTypeDefinition",
  " loc?: ?Location;
    name: Name;
    fields: Array<InputValueDefinition>;"
)




TypeExtensionDefinition = R6_from_args(
  inherit = Definition,
  "TypeExtensionDefinition",
  " loc?: ?Location;
    definition: ObjectTypeDefinition;"
)








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
