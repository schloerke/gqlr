


get_def_fn <- (function(){
  graphqlrNamespace <- asNamespace("graphqlr")
  function(definition) {
    get(paste0("parse_", definition), mode = "function", envir = graphqlrNamespace)
  }
})()

parse_Document <- function(obj) {
  lapply(obj$definition, function(defObj) {

    switch(defObj$kind,
      OperationDefinition = parse_OperationDefinition(defObj),
      stop0("unknown document definition kind:", defObj$kind)
    )
  })
}

parse_OperationDefinition <- function(obj) {
  if (obj$operation != "query") {
    stop("not a query operation definition")
  }

  parse_SelectionSet(obj$selectionSet, parse_Name(obj$name))
}

parse_SelectionSet <- function(obj, parentName) {
  ans <- lapply(obj$selections, function(selectionObj) {
    switch(selectionObj$kind,
      Field = parse_Field(selectionObj, parentName),
      InlineFragment = parse_InlineFragment(selectionObj, parentName),
      FragmentSpread = parse_FragmentSpread(selectionObj, parentName),
      print(selectionObj) & stop0("unknown SelectionSet kind: ", selectionObj$kind)
    )
  })
  list(parentName = parentName, value = ans)
}

parse_Name <- function(obj) {
  if (is.null(obj)) {
    return(NULL)
  }

  if (obj$kind != "Name") {
    stop("Name unknown")
  }

  obj$value
}

parse_InlineFragment <- function(obj, parentName) {
  stop("InlineFragment not implemented yet")
}

parse_FragmentSpread <- function(obj, parentName) {
  # stop("InlineFragment not implemented yet")
  "InlineFragment not implemented yet"
}

parse_Field <- function(obj, parentName) {
  objName <- parse_Name(obj$name)
  if (is.null(obj$selectionSet)) {
    # return(list(name = objName, parentName = parentName))
    return(objName)
  }

  parse_SelectionSet(obj$selectionSet, objName)
}
