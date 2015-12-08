

get_first_level_closing_paren_pos = function(qChars) {
  parenPosStart <- which(qChars == "{")
  parenPosEnd <- which(qChars == "}")
  level <- rep(0, length(qChars))
  level[parenPosStart] <- 1
  level[parenPosEnd] <- -1
  levelCumSum <- base::cumsum(level)
  parenPosEnd[levelCumSum[parenPosEnd] == 0]
}



# split a query string into multiple parts
#
# @param qStr query string
# @return an array of a query and fragments+
query_split <- function(qStr) {
  splitLocs <- stringr::str_split(qStr, "")[[1]] %>%
    get_first_level_closing_paren_pos()

  stringr::str_sub(
    qStr,
    start = c(0, splitLocs[-length(splitLocs)] + 1),
    splitLocs
  )
}



qStr <- "query FragmentTyping {\n  profiles(handles: [\"zuck\", \"cocacola\"]) {\n    handle\n    ...userFragment\n    ...pageFragment\n  }\n}\n\nfragment userFragment on User {\n  friends {\n    count\n  }\n}\n\nfragment pageFragment on Page {\n  likers {\n    count\n  }\n}"
query_split(qStr)
query_clean(query_split(qStr))

qStr <- "query hasConditionalFragment($condition: Boolean) {\n  ...maybeFragment @include(if: $condition)\n}\n\nfragment maybeFragment on Query {\n  me {\n    name\n  }\n}"




query_str_to_list <- function(qStr, qChars = stringr::str_split(qStr, "")[[1]]) {
  ret <- list()

  get_first_level_closing_paren_pos(qChars)

  ret
}

qStr <- "{\n  entity {\n    name\n  }\n  phoneNumber\n}"
query_str_to_list(query_clean(qStr))
