# load_all(); testthat::test_file(file.path("tests", "testthat", "test-r6_from_args.R")); # nolint



parse_args_txt <- " operation: 'query' | 'mutation' | 'subscription';
                    name: Name;
                    names?: ?Array<Name>;
                    variableDefinitions?: ?Array<VariableDefinition>;
                    char: string;
                    func: fn;"

test_that("formatting", {

  ans <- parse_args(parse_args_txt)

  expected <- list(
    operation = list(
      type = "string", is_array = FALSE, can_be_null = FALSE,
      possible_values = c("query", "mutation", "subscription")
    ),
    name = list(
      type = "Name", is_array = FALSE, can_be_null = FALSE, value = NULL
    ),
    names = list(
      type = "Name", is_array = TRUE, can_be_null = TRUE, value = NULL
    ),
    variableDefinitions = list(
      type = "VariableDefinition", is_array = TRUE, can_be_null = TRUE, value = NULL
    ),
    char = list(
      type = "string", is_array = FALSE, can_be_null = FALSE, value = NULL
    ),
    func = list(
      type = "fn", is_array = FALSE, can_be_null = FALSE, value = NULL
    )
  )

  expect_equal(ans, expected)

})


test_that("R6_from_args", {


AnsGen <- R6_from_args(
  inherit = Node,
  "MyDef",
  parse_args_txt,
  public = list(
    .format = function(...) {
      R6:::format.R6(self)
    }
  ),
  private = list(),
  active = list(
    .not_an_arg = function(ignore) {
      2
    }
  )
)

expect_error({
    ans <- AnsGen$new(
      operation = "query",
      char = "5",
      func = function() {
        "hi!"
      }
    )
  },
  "Did not receive: 'name'"
)


ans <- AnsGen$new(
  operation = "query",
  char = "5",
  func = function() {
    "hi!"
  },
  name = Name$new(value = "myname")
)

expect_error({
    AnsGen$new(
      operation = "query",
      char = "5",
      func = function() {
        "hi!"
      }
    )
  },
  "'name' must be supplied"
)

expect_error({
    my_named_type <- NamedType$new(name = Name$new(value = "Value"))
    my_named_type$loc <- NULL
    my_named_type$name <- NULL
  },
  "Can not set value to NULL for Name\\$name"
)
expect_error({
    my_type <- NonNullType$new(type = NamedType$new(name = Name$new(value = "Value")))
    my_type$type <- NamedType$new(name = Name$new(value = "Valid Type"))
    my_type$type <- Name$new(value = "Not a type")
  },
  "must be supplied an object of class: NamedType"
)


expect_error({
    Name$new(value = "5")
  },
  "Name value must match"
)
expect_error({
    ans$operation <- "Barret"
  },
  "not in accepted values"
)
expect_error({
    ans$func <- "Barret"
  },
  "to a non function value"
)
expect_error({
    ans$name <- NullValue$new()
  },
  "Expected value with class of"
)
expect_error({
    ans$names <- NullValue$new()
  },
  "Expected value should be an array of"
)
expect_error({
    ans$names <- list(Name$new(value = "hi"), NullValue$new())
  },
  "Expected value with class of"
)
expect_silent({
  ans$names <- list(Name$new(value = "hi"))
  ans$names <- NULL
})


txt <- format_str(ans)

expect_equal(txt,
"<MyDef>
. operation: 'query'
. name: <Name>
. . value: 'myname'
. char: '5'
. func: function"
)


expect_equal(FloatValue$new(value = 4.5) %>% format_str(), "<FloatValue>\n. value: '4.5'")

expect_error({
    a <- NamedType$new(name = Name$new(value = "Barret"))
    capture.output(a$.matches("Barret"))
  },
  "supply a Type object"
)

expect_error({
    dog_cat_doc$definitions[[length(dog_cat_doc$definitions)]]$.get_definition_type("Barret")
  },
  "must be either 'query' or 'mutation'"
)


})
