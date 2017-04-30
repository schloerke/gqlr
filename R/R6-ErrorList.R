#' @export
ErrorList <- R6Class("ErrorList",
  private = list(
    # http://facebook.github.io/graphql/
    # document.querySelectorAll("#sec-Validation section").forEach(function(x,i){console.log(x.firstChild.innerText)} )
    rule_names = list(

      "3.1.1" = "Scalars",
      "3.1.1.1" = "Int",
      "3.1.1.2" = "Float",
      "3.1.1.3" = "String",
      "3.1.1.4" = "Boolean",
      "3.1.1.5" = "ID",
      "3.1.2" = "Objects",
      "3.1.2.1" = "Object Field Arguments",
      "3.1.2.2" = "Object Field deprecation",
      "3.1.2.3" = "Object type validation",
      "3.1.3" = "Interfaces",
      "3.1.3.1" = "Interface type validation",
      "3.1.4" = "Unions",
      "3.1.4.1" = "Union type validation",
      "3.1.5" = "Enums",
      "3.1.6" = "Input Objects",
      "3.1.6.1" = "Input Object type validation",
      "3.1.7" = "Lists",
      "3.1.8" = "Non-Null",

      "5.1" = "Operations",
      "5.1.1" = "Named Operation Definitions",
      "5.1.1.1" = "Operation Name Uniqueness",
      "5.1.2" = "Anonymous Operation Definitions",
      "5.1.2.1" = "Lone Anonymous Operation",

      "5.2" = "Fields",
      "5.2.1" = "Field Selections on Objects, Interfaces, and Unions Types",
      "5.2.2" = "Field Selection Merging",
      "5.2.3" = "Leaf Field Selections",

      "5.3" = "Arguments",
      "5.3.1" = "Argument Names",
      "5.3.2" = "Argument Uniqueness",
      "5.3.3" = "Argument Values Type Correctness",
      "5.3.3.1" = "Compatible Values",
      "5.3.3.2" = "Required Non-Null Arguments",

      "5.4" = "Fragments",
      "5.4.1" = "Fragment Declarations",
      "5.4.1.1" = "Fragment Name Uniqueness",
      "5.4.1.2" = "Fragment Spread Type Existence",
      "5.4.1.3" = "Fragments On Composite Types",
      "5.4.1.4" = "Fragments Must Be Used",
      "5.4.2" = "Fragment Spreads",
      "5.4.2.1" = "Fragment spread target defined",
      "5.4.2.2" = "Fragment spreads must not form cycles",
      "5.4.2.3" = "Fragment spread is possible",
      "5.4.2.3.1" = "Object Spreads In Object Scope",
      "5.4.2.3.2" = "Abstract Spreads in Object Scope",
      "5.4.2.3.3" = "Object Spreads In Abstract Scope",
      "5.4.2.3.4" = "Abstract Spreads in Abstract Scope",

      "5.5" = "Values",
      "5.5.1" = "Input Object Field Uniqueness",

      "5.6" = "Directives",
      "5.6.1" = "Directives Are Defined",
      "5.6.2" = "Directives Are In Valid Locations",
      "5.6.3" = "Directives Are Unique Per Location",

      "5.7" = "Variables",
      "5.7.1" = "Variable Uniqueness",
      "5.7.2" = "Variable Default Values Are Correctly Typed",
      "5.7.3" = "Variables Are Input Types",
      "5.7.4" = "All Variable Uses Defined",
      "5.7.5" = "All Variables Used",
      "5.7.6" = "All Variable Usages are Allowed",

      "6.1" = "Executing Requests",
      "6.1.1" = "Validating Requests",
      "6.1.2" = "Coercing Variable Values",

      "6.2" = "Executing Operations",

      "6.3" = "Executing Selection Sets",
      "6.3.1" = "Normal and Serial Execution",
      "6.3.2" = "Field Collection",

      "6.4" = "Executing Fields",
      "6.4.1" = "Coercing Field Arguments",
      "6.4.2" = "Value Resolution",
      "6.4.3" = "Value Completion",
      "6.4.4" = "Errors and Non-Nullability"
    )
  ),
  public = list(
    n = 0,
    errors = list(),
    verbose = TRUE,

    initialize = function(verbose = TRUE) {
      self$verbose <- verbose
      invisible(self)
    },

    has_no_errors = function() {
      self$n == 0
    },
    has_any_errors = function() {
      self$n > 0
    },

    add = function(rule_code, ...) {

      rule_name <- private$rule_names[[rule_code]]
      if (is.null(rule_name)) {
        stop("Name not found for rule: '", rule_code, "'")
      }

      err <- str_c(
        rule_code, ": ", rule_name, "\n",
        ...,
        sep = ""
      )

      if (isTRUE(self$verbose))
        message("Error: ", err)

      self$n <- self$n + 1
      self$errors[[length(self$errors) + 1]] <- err
      invisible(self)
    },

    .format = function(...) {
      if (self$has_any_errors()) {
        str_c(
          "<ErrorList>\n",
          "Errors: \n",
          str_c(self$errors, collapse = ",\n")
        )
      } else {
        "<ErrorList> No errors"
      }
    },
    print = function(...) {
      cat(self$.format(...))
    }
  )
)
format.ErrorList <- function(x, ...) {
  x$.format(...)
}
str.ErrorList <- function(x, ...) {
  print(x)
}
