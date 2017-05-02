#' @include R6--definition.R
#' @include R6-3.2-directives.R
#' @include R6-3.1.1-types-scalars.R
#' @include R6-3.1.1-types-scalars.R
#' @include R6-6.1-executing-requests.R

completed_introspection <- FALSE

#' @export
Schema <- R6Class(
  "Schema",
  private = list(
    is_done = FALSE,

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
      name_val <- self$name_helper(name_obj)
      name_val %in% names(private[[obj_list_txt]])
    },
    get_by_name = function(name_obj, obj_list_txt) {
      name_val <- self$name_helper(name_obj)
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
    }


  ),
  public = list(

    initialize = function(document_obj, ...) {

      self$add(Int)
      self$add(Float)
      self$add(String)
      self$add(Boolean)
      # self$add(ID) # nolint

      self$add(SkipDirective)
      self$add(IncludeDirective)

      if (completed_introspection) {
        self$add(Introspection__Schema)
        self$add(Introspection__Type)
        self$add(Introspection__Field)
        self$add(Introspection__InputValue)
        self$add(Introspection__EnumValue)
        self$add(Introspection__TypeKind)
        self$add(Introspection__Directive)
        self$add(Introspection__DirectiveLocation)
      }

      if (!missing(document_obj)) {
        if (inherits(document_obj, "character")) {
          document_obj <- graphql2obj(document_obj)
        }

        lapply(document_obj$definitions, self$add)
      }

      return(invisible(self))
    },

    as_type = function(name_val) {
      if (inherits(name_val, "Type")) {
        return(name_val)
      }
      if (is.character(name_val)) {
        return(
          NamedType$new(name = Name$new(value = name_val))
        )
      }
      stop("This should not be reached")
    },

    # returns a NamedType
    get_inner_type = function(type_obj) {
      if (is.character(type_obj)) {
        return(self$as_type(type_obj))
      }

      while (
        inherits(type_obj, "NonNullType") ||
        inherits(type_obj, "ListType")
      ) {
        type_obj <- type_obj$type
      }
      type_obj
    },

    name_helper = function(name_obj) {
      if (is.character(name_obj)) {
        name_obj
      } else if (inherits(name_obj, "Name")) {
        name_obj$value
      } else if (inherits(name_obj, "Type")) {
        # non null, list, named
        name_obj <- self$get_inner_type(name_obj)
        name_obj$name$value
      } else {
        str(name_obj)
        stop("must supply a string, Name, or NamedType")
      }
    },

    is_scalar       = function(name) private$exists_by_name(name, "scalars"),
    is_enum         = function(name) private$exists_by_name(name, "enums"),
    is_object       = function(name) private$exists_by_name(name, "objects"),
    is_interface    = function(name) private$exists_by_name(name, "interfaces"),
    is_union        = function(name) private$exists_by_name(name, "unions"),
    is_input_object = function(name) private$exists_by_name(name, "input_objects"),
    is_directive    = function(name) private$exists_by_name(name, "directives"),
    is_value        = function(name) private$exists_by_name(name, "values"),

    is_object_interface_or_union = function(name) {
      return(
        self$is_object(name) ||
        self$is_interface(name) ||
        self$is_union(name)
      )
    },

    get_schema_definition = function(def_name) {
      schema_def <- private$schema_definition
      if (is.null(schema_def)) {
        stop("schema definition not found")
      }
      schema_def$.get_definition_type(def_name)
    },
    get_mutation_object = function() {
      mutation_type <- self$get_schema_definition("mutation")
      self$get_object_interface_or_union(mutation_type)
    },
    get_query_object = function() {
      query_type <- self$get_schema_definition("query")
      self$get_object_interface_or_union(query_type)
    },
    is_query_root_name = function(name_obj) {
      query_type <- self$get_schema_definition("query")
      query_name <- query_type$name
      identical(format(name_obj), format(query_name))
    },

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
      name_val <- self$name_helper(name)
      names(private$implements_interface_list[[name_val]])
    },

    get_possible_types = function(name_obj) {
      name_val <- self$name_helper(name_obj)
      if (self$is_object(name_val)) {
        return(name_val)
      }
      if (self$is_interface(name_val)) {
        return(self$implements_interface(name_val))
      }
      union_obj <- self$get_union(name_val)
      if (!is.null(union_obj)) {
        union_names <- unlist(lapply(union_obj$types, self$name_helper))
        return(union_names)
      }
      stop("type: ", name_val, " is not an object, interface, or union")

    },

    get_scalar_or_enum = function(name_obj) {
      name_val <- self$name_helper(name_obj)
      ifnull(
        self$get_scalar(name_val),
        self$get_enum(name_val)
      )
    },
    get_object_interface_or_union = function(name_obj) {
      if (is.null(name_obj)) return(NULL)
      name_val <- self$name_helper(name_obj)
      ifnull(
        self$get_object(name_val),
        ifnull(
          self$get_interface(name_val),
          self$get_union(name_val)
        )
      )
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
      self$is_valid <- FALSE

      if (inherits(obj, "Schema")) {
        self$add(obj$get_schema(full = FALSE))
        return(invisible(self))
      }
      if (!inherits(obj, "AST")) {
        stop(
          "Object must be of class AST to add to a Schema. Received: ",
          paste(class(obj), collapse = ", ")
        )
      }
      if (inherits(obj, "Document")) {
        lapply(obj$definitions, self$add)
        return(invisible(self))
      }

      if (inherits(obj, "SchemaDefinition")) {
        if (!is.null(private$schema_definition)) {
          stop("Existing schema definition already found. Can not add a second definition")
        }
        private$schema_definition <- obj
        private$add_introspection_fields()

        return(invisible(self))
      }

      private$is_done <- FALSE

      if (!inherits(obj, "TypeSystemDefinition")) {
        str(obj)
        stop("To add an object to a Schema, it must have a name.")
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
        cur_obj$fields <- append(cur_obj$fields, extend_def$fields)

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
        print(obj)
        stop("Unknown object type requested to be added to schema. Type: ", obj_kind)
      }

      if (!is.null(private[[obj_group]][[obj_name]])) {
        print(private[[obj_group]][[obj_name]])
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
          obj_name_val <- self$name_helper(obj$name)
          for (interface_obj in obj$interfaces) {
            interface_obj_name <- self$name_helper(interface_obj$name)
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
  active = list(
  )
)
