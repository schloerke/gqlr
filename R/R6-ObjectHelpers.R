

ObjectHelpers <- R6Class(
  "ObjectHelpers",
  private = list(
    schema_val = NULL,
    error_list_val = NULL
  ),
  public = list(

    variable_validator = NULL,
    unset_variable_validator = function() {
      self$variable_validator <- NULL
    },
    set_variable_validator = function(variable_validator) {
      self$variable_validator <- variable_validator
    },

    variable_values = NULL,
    unset_coerced_variables = function() {
      self$variable_values <- NULL
    },
    set_coerced_variables = function(variable_values) {
      self$variable_values <- variable_values
    },
    has_variable_value = function(variable_obj) {
      variable_name <- format(variable_obj$name)
      variable_name %in% names(self$variable_values)
    },
    get_variable_value = function(variable_obj) {
      variable_name <- format(variable_obj$name)
      self$variable_values[[variable_name]]
    },

    # get_argument_value = function(arg_value) {
    #   if (inherits(arg_value, "Variable")) {
    #
    #   }
    # },

    initialize = function(schema, error_list = ErrorList$new()) {
      self$schema <- schema
      self$error_list <- error_list

      invisible(self)
    }
  ),
  active = list(
    error_list = function(value) {
      if (missing(value)) {
        return(private$error_list_val)
      }

      if (!inherits(value, "ErrorList")) {
        stop("must supply a object of class 'ErrorList'")
      }

      private$error_list_val <- value

      invisible(self)
    },

    schema = function(value) {
      if (missing(value)) {
        return(private$schema_val)
      }

      if (
        inherits(value, "character") ||
        inherits(value, "Document")
      ) {
        value <- Schema$new(value)
      }

      if (!inherits(value, "Schema")) {
        stop("must supply a object of class 'Schema'")
      }

      private$schema_val <- value

      invisible(self)
    }
  )

)
