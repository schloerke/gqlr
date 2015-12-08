
query_clean <- function(qStr) {
  qStr %>%
    stringr::str_trim() %>%
    stringr::str_replace_all("\\s+", " ")
}
