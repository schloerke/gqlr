
if (FALSE) {

  load_all(); test_json("simple-query") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("kitchen-query") %>% r6_from_list() %>% gqlr_str()

  load_all(); test_json("simple-schema") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("kitchen-schema") %>% r6_from_list() %>% gqlr_str()

  load_all(); test_json("film-schema") %>% r6_from_list() %>% gqlr_str()
  load_all(); test_json("film-query") %>% r6_from_list() %>% gqlr_str()

}
