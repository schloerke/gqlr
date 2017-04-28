# testthat::test_file(file.path("tests", "testthat", "test-r6_from_args.R"))

context("r6_from_args")

source("validate_helper.R")

parse_args_txt <- " operation: 'query' | 'mutation' | 'subscription';
                    name?: ?Name;
                    variableDefinitions?: ?Array<VariableDefinition>;
                    char: string;
                    func: fn;"

test_that("formatting", {

  ans <- parse_args(parse_args_txt)

  expected <- list(
    operation = list(
      type = "string", isArray = FALSE,canBeNull = FALSE,
      possibleValues = c("query","mutation","subscription")
    ),
    name = list(
      type = "Name", isArray = FALSE, canBeNull = TRUE, value = NULL
    ),
    variableDefinitions = list(
      type = "VariableDefinition", isArray = TRUE, canBeNull = TRUE, value = NULL
    ),
    char = list(
      type = "string", isArray = FALSE, canBeNull = FALSE, value = NULL
    ),
    func = list(
      type = "fn", isArray = FALSE, canBeNull = FALSE, value = NULL
    )
  )

  expect_subset(ans, expected)

})


test_that("R6_from_args", {


AnsGen <- R6_from_args(
  inherit = Node,
  "MyDef",
  parse_args_txt,
  public = list(),
  private = list(),
  active = list(
    .not_an_arg = function(ignore) {
      2
    }
  )
)

ans <- AnsGen$new(operation = "query", char = "5", func = function() { "hi!"})

txt <- format_str(ans)

expect_equal(txt,
"<MyDef>
. operation: 'query'
. char: '5'
. func: function"
)

# browser()


})