#' @include R6--definition.R
#' @include R6-3.2-directives.R
#' @include R6-3.1.1-types-scalars.R
#' @include R6-3.1.1-types-scalars.R
#' @include R6-6.1-executing-requests.R














# nolint start
#' @title GraphQL Schema object
#'
#' @description Manages a GraphQL schema definition.  A Schema can add more GraphQL type definitions, assist in determining definition types, retrieve particular definitions, and can combine with other schema definitions.
#'
#' Typically, Schema class objects are created using \code{\link{gqlr_schema}}.  Creating a \code{Schema$new()} object should be reserved for when multiple Schema objects are combined.
#'
#' @section Usage:
#' \preformatted{
#' ## using star_wars_schema from
#' # example(gqlr_schema)
#' star_wars_schema$get_schema()
#' star_wars_schema$is_enum("Episode") # TRUE
#' star_wars_schema$is_object("Episode") # FALSE
#' execute_request("{ hero { name } }", star_wars_schema)
#' }
#'
#' @section Initialize:
#' \describe{
#'   \item{schema}{Either a character GraphQL definition of a schema or another Schema object.  Extending methods and descriptions should be added with \code{gqlr_schema}}.
#' }
#'
#'  The initialize function will automatically add \itemize{
#'    \item{Scalars: Int, Float, String, Boolean}
#'    \item{Directives: @skip and @include}
#'    \item{Introspection Capabilities}
#'  }
#'
#' @section Details:
#' \code{$add(obj)}: function to add either another Schema's definitions or Document of defintions.  \code{obj} must inherit class of either \code{'Schema'} or \code{'Document'}
#'
#' \code{$is_scalar(name)}, \code{$is_enum(name)}, \code{$is_object(name)}, \code{$is_interface(name)}, \code{$is_union(name)}, \code{$is_input_object(name)}, \code{$is_directive(name)}, \code{$is_value(name)}: methods to determine if there is a definition of the corresponding definition type for the privided name.
#'
#' \code{$get_scalar(name)}, \code{$get_enum(name)}, \code{$get_object(name)}, \code{$get_interface(name)}, \code{$get_union(name)}, \code{$get_input_object(name)}, \code{$get_directive(name)}, \code{$get_value(name)}: methods to retrieve a definition of the corresponding definition type for the privided name. If the object can't be found, \code{NULL} is returned. When printed, it quickly conveys all known information of the definition.  Due to the nature of R6 objects, definitions may be retrieved and altered after retrieval.  This is helpful for adding descriptions or resolve after the initialization.
#'
#' \code{$get_scalars(name)}, \code{$get_enums(name)}, \code{$get_objects(name)}, \code{$get_interfaces(name)}, \code{$get_unions(name)}, \code{$get_input_objects(name)}, \code{$get_directives(name)}, \code{$get_values(name)}: methods to retrieve all definitions of the corresponding definition type.
#'
#' \code{$get_type(name)}: method to retrieve an object of unknown type. If the object can't be found, \code{NULL} is returned. When printed, it quickly conveys all known information of the definition.
#'
#' \code{$get_type(name)}: method to retrieve an object of unknown type. If the object can't be found, \code{NULL} is returned.
#'
#' \code{$get_schema()}: method to retrieve full definition of schema. When printed, it quickly conveys all types in the schema.
#'
#' \code{$get_query_object()}, \code{$get_mutation_object()}: helper method to retrieve the schema definition query or mutation object.
#'
#' \code{$implements_interface()}: helper method to retrieve all objects who implement a particular interface.
#'
#' \code{$is_valid}: boolean that determines if a Schema object has been validated.  All Schema objects are validated at the time of request execution.  The Schema will remain valid until new definitions are added.
#' @importFrom R6 R6Class
#' @name Schema
#' @examples
#' example(gqlr_schema)
#'
NULL
# nolint end














completed_introspection <- FALSE


is_object_interface_or_union <- function(name, schema) {
  return(
    schema$is_object(name) ||
    schema$is_interface(name) ||
    schema$is_union(name)
  )
}



as_type <- function(name_val) {
  if (inherits(name_val, "Type")) {
    return(name_val)
  }
  if (inherits(name_val, "Name")) {
    return(NamedType$new(name = name_val))
  }
  if (is.character(name_val)) {
    return(
      NamedType$new(name = Name$new(value = name_val))
    )
  }
  str(name_val)
  stop("as_type only understands a single character name or Type object")
}

# returns a NamedType
get_inner_type <- function(type_obj) {
  type_obj <- as_type(type_obj)

  while (
    inherits(type_obj, "NonNullType") ||
    inherits(type_obj, "ListType")
  ) {
    type_obj <- type_obj$type
  }
  type_obj
}

name_value <- function(name_obj) {
  if (is.character(name_obj)) {
    name_obj
  } else if (inherits(name_obj, "Name")) {
    name_obj$value
  } else if (inherits(name_obj, "Type")) {
    # non null, list, named
    name_obj <- get_inner_type(name_obj)
    name_obj$name$value
  } else {
    str(name_obj)
    stop("must supply a string, Name, or NamedType to name_value(name_obj)")
  }
}

get_object_interface_or_union <- function(name_obj, schema) {
  if (is.null(name_obj)) return(NULL)
  name_val <- name_value(name_obj)
  ifnull(
    schema$get_object(name_val),
    ifnull(
      schema$get_interface(name_val),
      schema$get_union(name_val)
    )
  )
}




#' @export
Schema <- R6Class(
  "Schema",
  private = list(
    schema_definition = NULL,

    scalars = list(),
    enums = list(),
    objects = list(),
    interfaces = list(),
    unions = list(),
    input_objects = list(),
    directives = list(),
    values = list(),

    # has_directive_list = list(),
    exists_by_name = function(name_obj, obj_list_txt) {
      name_val <- name_value(name_obj)
      name_val %in% names(private[[obj_list_txt]])
    },
    get_by_name = function(name_obj, obj_list_txt) {
      name_val <- name_value(name_obj)
      private[[obj_list_txt]][[name_val]]
    },

    implements_interface_list = list(),

    add_introspection_fields = function() {
      schema_def <- private$schema_definition
      if (is.null(schema_def)) return()

      query_obj <- self$get_query_object()
      if (is.null(query_obj)) return()

      for (intro_field in Introspection__QueryRootFields$fields) {
        matching_query_field <- query_obj$.get_field(intro_field)
        if (is.null(matching_query_field)) {
          query_obj$fields <- append(query_obj$fields, intro_field)
        }
      }

      return()
    },

    get_schema_definition = function(def_name) {
      schema_def <- private$schema_definition
      if (is.null(schema_def)) {
        stop("schema definition not found")
      }
      schema_def$.get_definition_type(def_name)
    },

    add_item = function(obj) {
      if (!inherits(obj, "TypeSystemDefinition")) {
        str(obj)
        stop("To add an object to a Schema, it must inherit TypeSystemDefinition.")
      }

      self$is_valid <- FALSE

      if (inherits(obj, "SchemaDefinition")) {
        if (!is.null(private$schema_definition)) {
          stop("Existing schema definition already found. Can not add a second definition")
        }
        private$schema_definition <- obj
        private$add_introspection_fields()

        return(invisible(self))
      }

      # extend a current object definition
      if (inherits(obj, "TypeExtensionDefinition")) {
        extend_def <- obj$definition
        cur_obj <- self$get_object(extend_def$name)
        if (is.null(cur_obj)) {
          stop(
            "Object of type: ", format(extend_def$name),
            " can not be extended as it can not be found."
          )
        }
        # since it is and R6 object, no need to re-store the cur_obj
        new_fields <- append(cur_obj$fields, extend_def$fields)

        field_names <- new_fields %>%
          lapply(function(x) {
            format(x$name)
          }) %>%
            unlist()
        cur_obj$fields <- new_fields[!duplicated(field_names, fromLast = TRUE)]


        if (is.function(extend_def$.resolve)) {
          if (is.function(cur_obj$.resolve)) {
            warning("Replacing .resolve() method for object of type: ", format(extend_def$name))
          }
          cur_obj$.resolve <- extend_def$.resolve
        }

        return(invisible(self))
      }

      groups <- list(
        "ObjectTypeDefinition" = "objects",
        "InterfaceTypeDefinition" = "interfaces",
        "UnionTypeDefinition" = "unions",
        "ScalarTypeDefinition" = "scalars",
        "EnumTypeDefinition" = "enums",
        "InputObjectTypeDefinition" = "input_objects",
        "DirectiveDefinition" = "directives"
      )

      obj_name <- format(obj$name)
      obj_kind <- class(obj)[1]
      obj_group <- groups[[obj_kind]]

      if (is.null(obj_group)) {
        str(obj)
        stop("Unknown object type requested to be added to schema. Type: ", obj_kind)
      }

      if (!is.null(private[[obj_group]][[obj_name]])) {
        str(private[[obj_group]][[obj_name]])
        stop(obj_name, " already defined in ", obj_kind)
      }

      private[[obj_group]][[obj_name]] <- obj

      # order the items by name
      group_names <- names(private[[obj_group]])
      sorted_group_names <- sort(group_names)
      if (!identical(sorted_group_names, group_names)) {
        private[[obj_group]] <- private[[obj_group]][group_names]
      }

      # add object name to list of objects that implement a particular interfaces
      if (obj_kind == "ObjectTypeDefinition") {
        if (!is.null(obj$interfaces)) {
          obj_name_val <- name_value(obj$name)
          for (interface_obj in obj$interfaces) {
            interface_obj_name <- name_value(interface_obj$name)
            if (
              is.null(
                private$implements_interface_list[[interface_obj_name]]
              )
            ) {
              private$implements_interface_list[[interface_obj_name]] <- list()
            }

            private$implements_interface_list[[
              interface_obj_name
            ]][[obj_name_val]] <- obj_name_val
          }
        }

        private$add_introspection_fields()
      }

      return(invisible(self))
    }

  ),
  public = list(

    initialize = function(schema = NULL) {

      private$add_item(Int)
      private$add_item(Float)
      private$add_item(String)
      private$add_item(Boolean)
      # private$add_item(ID) # nolint

      private$add_item(SkipDirective)
      private$add_item(IncludeDirective)

      if (completed_introspection) {
        private$add_item(Introspection__Schema)
        private$add_item(Introspection__Type)
        private$add_item(Introspection__Field)
        private$add_item(Introspection__InputValue)
        private$add_item(Introspection__EnumValue)
        private$add_item(Introspection__TypeKind)
        private$add_item(Introspection__Directive)
        private$add_item(Introspection__DirectiveLocation) # nolint
      }

      if (!missing(schema)) {
        if (inherits(schema, "character")) {
          schema <- graphql2obj(schema)
        }
        self$add(schema)
      }

      return(invisible(self))
    },

    get_mutation_object = function() {
      mutation_type <- private$get_schema_definition("mutation")
      get_object_interface_or_union(mutation_type, self)
    },
    get_query_object = function() {
      query_type <- private$get_schema_definition("query")
      get_object_interface_or_union(query_type, self)
    },

    is_scalar       = function(name) private$exists_by_name(name, "scalars"),
    is_enum         = function(name) private$exists_by_name(name, "enums"),
    is_object       = function(name) private$exists_by_name(name, "objects"),
    is_interface    = function(name) private$exists_by_name(name, "interfaces"),
    is_union        = function(name) private$exists_by_name(name, "unions"),
    is_input_object = function(name) private$exists_by_name(name, "input_objects"),
    is_directive    = function(name) private$exists_by_name(name, "directives"),
    is_value        = function(name) private$exists_by_name(name, "values"),

    get_scalar       = function(name) private$get_by_name(name, "scalars"),
    get_enum         = function(name) private$get_by_name(name, "enums"),
    get_object       = function(name) private$get_by_name(name, "objects"),
    get_interface    = function(name) private$get_by_name(name, "interfaces"),
    get_union        = function(name) private$get_by_name(name, "unions"),
    get_input_object = function(name) private$get_by_name(name, "input_objects"),
    get_directive    = function(name) private$get_by_name(name, "directives"),
    get_value        = function(name) private$get_by_name(name, "values"),

    get_scalars       = function() private$scalars,
    get_enums         = function() private$enums,
    get_objects       = function() private$objects,
    get_interfaces    = function() private$interfaces,
    get_unions        = function() private$unions,
    get_input_objects = function() private$input_objects,
    get_directives    = function() private$directives,
    get_values        = function() private$values,

    get_type         = function(name) {
      ifnull(
        self$get_scalar(name),        ifnull(
        self$get_enum(name),          ifnull(
        self$get_object(name),        ifnull(
        self$get_interface(name),     ifnull(
        self$get_union(name),         ifnull(
        self$get_input_object(name),  ifnull(
        self$get_directive(name),
        self$get_value(name)
      )))))))
    },


    # returns a char vector or NULL of names of objs that implement a particular interface
    implements_interface = function(name) {
      name_val <- name_value(name)
      names(private$implements_interface_list[[name_val]])
    },

    get_schema = function(full = FALSE) {

      scalars <- self$get_scalars()
      enums <- self$get_enums()
      objects <- self$get_objects()
      interfaces <- self$get_interfaces()
      unions <- self$get_unions()
      input_objects <- self$get_input_objects()
      directives <- self$get_directives()
      values <- self$get_values()
      schema_def <- private$schema_definition


      if (!isTRUE(full)) {
        scalars[c("Int", "Float", "String", "Boolean")] <- NULL
        values <- list()
        directives[c("include", "skip")] <- NULL
        objects[c(
          "__Schema", "__Type", "__Field", "__InputValue", "__EnumValue", "__Directive"
        )] <- NULL
        enums[c("__TypeKind", "__DirectiveLocation")] <- NULL
      }

      definitions <- list() %>%
        append(scalars) %>%
        append(enums) %>%
        append(objects) %>%
        append(interfaces) %>%
        append(unions) %>%
        append(input_objects) %>%
        append(directives) %>%
        append(values) %>%
        append(schema_def)

      document_obj <- Document$new(definitions = definitions)
      document_obj
    },

    is_valid = FALSE,
    add = function(obj) {
      if (inherits(obj, "Schema")) {
        self$add(obj$get_schema(full = FALSE))
        return(invisible(self))
      }
      if (inherits(obj, "Document")) {
        lapply(obj$definitions, private$add_item)
        return(invisible(self))
      }
      stop("Only objects of class 'Schema' or 'Document' should be added to another 'Schema'")
    }

  )
)
