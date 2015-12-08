



contains_directive <- function(qStr) {
  stringr::str_detect(qStr, "@(skip|include)")
}

qStr <- "query myQuery($someTest: Boolean) {\n  experimentalField @include(if: $someTest)\n}"

# get_directive <- function(qStr) {
#   matchResults <- stringr::str_match(qStr, "@(skip|include)\\s*\\(\\s*if\\s*:\\s*(true|false)\\s*\\)")
#   includeOrSkip <- matchResults[1,2]
#   if (is.na(matchResults)) {
#     return(list(isDirective: FALSE))
#   }
#
#   boolValue <- matchResults[1,3]
#   if (is.na(boolValue)) {
#     stop(paste0("directive did not receive boolean value. X: ", x, " . boolean value: ", boolValue))
#   }
#
#   return(list(isDirective: TRUE, ))
#   if (is.na(matchResults[1,3]))
# }
