# √5.7.1 - Variable Uniqueness
# √5.7.2 - Variable Default Values Are Correctly Typed
# √5.7.3 - Variables Are Input Types
# √5.7.4 - All Variable Uses Defined
# √5.7.5 - All Variables Used
# 5.7.6 - All Variable Usages are Allowed - TODO need type coercion
VariableValdationHelper <- R6Class("VariableValdationHelper",
  public = list(
    names = character(0),
    has_been_seen = list(),
    type = list(),
    variables = list(),
    oh = NULL,

    check_variable = function(var, argument_type) {
      if (is.null(var)) {
        return(invisible(TRUE))
      }

      var_name <- format(var$name)

      var_obj <- self$variables[[var_name]]

      # 5.7.4 - All Variable Uses Defined
      if (is.null(var_obj)) {
        self$oh$error_list$add(
          "5.7.4",
          "Matching variable definition can not be found for variable: ", var_name
        )
        return(invisible(FALSE))
      }

      self$has_been_seen[[var_name]] <- TRUE

      # 5.7.6
      # AreTypesCompatible
      variable_type <- var_obj$type
      # If hasDefault is true, treat the variableType as non‐null.
      if (!is.null(var_obj$defaultValue)) {
        if (!inherits(variable_type, "NonNullType")) {
          variable_type <- NonNullType$new(type = variable_type)
        }
      }

      # If argumentType and variableType have different list dimensions, return false
      # If any list level of variableType is not non‐null, and the corresponding level in argument
      # is non‐null, the types are not compatible.
      cur_var_type <- variable_type
      cur_arg_type <- argument_type
      while (
        inherits(cur_var_type, "NonNullType") ||
        inherits(cur_var_type, "ListType") ||
        inherits(cur_arg_type, "NonNullType") ||
        inherits(cur_arg_type, "ListType")
      ) {
        if (
          inherits(cur_var_type, "NonNullType") ||
          inherits(cur_arg_type, "NonNullType")
        ) {
          if (!inherits(cur_var_type, "NonNullType")) {
            self$oh$error_list$add(
              "5.7.6",
              "Variable can not provide a nullible argument to a non-nullible definition"
            )
            return(invisible(FALSE))
          } else {
            cur_var_type <- cur_var_type$type
          }
          if (inherits(cur_arg_type, "NonNullType")) {
            cur_arg_type <- cur_arg_type$type
          }

        } else {
          if (
            !inherits(cur_var_type, "ListType") ||
            !inherits(cur_arg_type, "ListType")
          ) {
            # if either is not a list
            self$oh$error_list$add(
              "5.7.6",
              "Variable list dimensions do not match argument's list dimensions"
            )
            return(invisible(FALSE))
          } else {
            # must both be lists at this point
            cur_var_type <- cur_var_type$type
            cur_arg_type <- cur_arg_type$type
          }
        }
      }

      # If inner type of argumentType and variableType are different, return false
      if (!identical(
        format(cur_var_type),
        format(cur_arg_type)
      )) {
        self$oh$error_list$add(
          "5.7.6",
          "Argument and variable inner types do not match. Found: ",
          format(cur_arg_type), " and ", format(cur_var_type)
        )
        return(invisible(FALSE))
      }

      invisible(TRUE)
    },


    finally = function() {

      # 5.7.5 - All Variables Used
      has_been_seen <- unlist(self$has_been_seen)
      if (!all(has_been_seen)) {
        self$oh$error_list$add(
          "5.7.5",
          "Not all variable definitions have been seen.",
          " Unused variables: ", names(has_been_seen)[!has_been_seen]
        )
        invisible(FALSE)
      } else {
        invisible(TRUE)
      }
    },


    default_value_can_be_coerced = function(from_input, to_type) {
      validate_value_can_be_coerced(
        from_input, to_type,
        oh = self$oh,
        rule_code = "5.7.2"
      )
    },


    initialize = function(vars, oh) {
      self$variables <- list()
      self$oh <- oh

      if (is.null(vars)) {
        return(invisible(self))
      }

      if (!is.list(vars)) stop("vars must be a list")

      vars %>%
        lapply(function(var) {
          name <- format(var$variable$name)

          self$variables[[name]] <- var
          self$has_been_seen[[name]] <- FALSE

          self$type[[name]] <- var$type

          # 5.7.2
          default_value_obj <- var$defaultValue
          if (!is.null(default_value_obj)) {
            if (inherits(var$type, "NonNullType")) {
              self$oh$error_list$add(
                "5.7.2",
                "Non-Null Variables are not allowed to have default values. ",
                " Found a default value for variable: ", name
              )
              return(name)
            }

            default_val <- var$defaultValue$value
            if (!is.null(default_val)) {
              type_obj <- self$oh$schema$get_type(name_value(var$type))

              self$default_value_can_be_coerced(
                from_input = var$defaultValue,
                to_type = var$type
              )
            }
          }


          # 5.7.3 - Variables Are Input Types
          core_var_type <- get_inner_type(var$type)
          matching_core_type_object <- ifnull(
            self$oh$schema$get_scalar(core_var_type), ifnull(
            self$oh$schema$get_enum(core_var_type),
            self$oh$schema$get_input_object(core_var_type)
          ))

          if (is.null(matching_core_type_object)) {
            self$oh$error_list$add(
              "5.7.3",
              "Can not find matching Scalar, Enum, or Input Object with type: ",
              format(var$type),
              " for variable: ", name
            )
            return(name)
          }


          name
        }) %>%
        unlist() ->
      names

      self$names <- names

      # 5.7.1 - Variable Uniqueness
      if (length(names) != length(unique(names))) {
        name_count <- table(names)
        name_count <- name_count[name_count > 1]
        duplicate_names <- names(name_count)
        self$oh$error_list$add(
          "5.7.1",
          "All defined variables must be unique.",
          " Found duplicates of name: ", str_c(duplicate_names, collapse = ", ")
        )
      }

      self$names <- names

      invisible(self)
    }
  )
)
