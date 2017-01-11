
#' @export
# load_all(); test_string() %>% make_ast() -> a
test_string <- function(pos = 0) {
  switch(as.character(pos),
    "1" = "{\n    name\n    relationship {\n      name\n    }\n  }",
    "2" = "fragment userFragment on User {\n  friends {\n    count\n  }\n}\n\nquery FragmentTyping {\n  profiles(handles: [\"zuck\", \"cocacola\"]) {\n    handle\n    ...userFragment\n    ...pageFragment\n  }\n}\n\nfragment pageFragment on Page {\n  likers {\n    count\n  }\n}",
    "4" =   "query HeroNameAndFriendsQuery {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  }",
    "5" = "{\n  firstSearchResult {\n    ... on Person {\n      name\n    }\n    ... on\nPhoto {\n      height\n    }\n  }\n}",
    "6" = "mutation StoryLikeMutation($input: StoryLikeInput) {\n  storyLike(input: $input) {\n    story {\n      likers { count }\n      likeSentence { text }\n    }\n  }\n}",
    "7" =   "query HeroNameAndFriendsQuery {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  } query HeroNameAndFriendsQuery2 {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  }",

    # has error. (expected)
    "8" =   " {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  } query HeroNameAndFriendsQuery2 {\n    hero {\n      id\n      name\n      friends {\n        name\n      }\n    }\n  }",

    "kitchen-query" = ,
    "kitchen" = "# Copyright (c) 2015, Facebook, Inc.\n# All rights reserved.\n#\n# This source code is licensed under the BSD-style license found in the\n# LICENSE file in the root directory of this source tree. An additional grant\n# of patent rights can be found in the PATENTS file in the same directory.\n\nquery queryName($foo: ComplexType, $site: Site = MOBILE) {\n  whoever123is: node(id: [123, 456]) {\n    id ,\n    ... on User @defer {\n      field2 {\n        id ,\n        alias: field1(first:10, after:$foo,) @include(if: $foo) {\n          id,\n          ...frag\n        }\n      }\n    }\n    ... @skip(unless: $foo) {\n      id\n    }\n    ... {\n      id\n    }\n  }\n}\n\nmutation likeStory {\n  like(story: 123) @defer {\n    story {\n      id\n    }\n  }\n}\n\nsubscription StoryLikeSubscription($input: StoryLikeSubscribeInput) {\n  storyLikeSubscribe(input: $input) {\n    story {\n      likers {\n        count\n      }\n      likeSentence {\n        text\n      }\n    }\n  }\n}\n\nfragment frag on Friend {\n  foo(size: $size, bar: $b, obj: {key: \"value\"})\n}\n\n{\n  unnamed(truthy: true, falsey: false, nullish: null),\n  query\n}\n",

    "kitchen-schema" = "# Copyright (c) 2015, Facebook, Inc.\n# All rights reserved.\n#\n# This source code is licensed under the BSD-style license found in the\n# LICENSE file in the root directory of this source tree. An additional grant\n# of patent rights can be found in the PATENTS file in the same directory.\n\nschema {\n  query: QueryType\n  mutation: MutationType\n}\n\ntype Foo implements Bar {\n  one: Type\n  two(argument: InputType!): Type\n  three(argument: InputType, other: String): Int\n  four(argument: String = \"string\"): String\n  five(argument: [String] = [\"string\", \"string\"]): String\n  six(argument: InputType = {key: \"value\"}): Type\n  seven(argument: Int = null): Type\n}\n\ntype AnnotatedObject @onObject(arg: \"value\") {\n  annotatedField(arg: Type = \"default\" @onArg): Type @onField\n}\n\ninterface Bar {\n  one: Type\n  four(argument: String = \"string\"): String\n}\n\ninterface AnnotatedInterface @onInterface {\n  annotatedField(arg: Type @onArg): Type @onField\n}\n\nunion Feed = Story | Article | Advert\n\nunion AnnotatedUnion @onUnion = A | B\n\nscalar CustomScalar\n\nscalar AnnotatedScalar @onScalar\n\nenum Site {\n  DESKTOP\n  MOBILE\n}\n\nenum AnnotatedEnum @onEnum {\n  ANNOTATED_VALUE @onEnumValue\n  OTHER_VALUE\n}\n\ninput InputType {\n  key: String!\n  answer: Int = 42\n}\n\ninput AnnotatedInput @onInputObjectType {\n  annotatedField: Type @onField\n}\n\nextend type Foo {\n  seven(argument: [String]): Type\n}\n\n# NOTE: out-of-spec test cases commented out until the spec is clarified; see\n# https://github.com/graphql/graphql-js/issues/650 .\n# extend type Foo @onType {}\n\n#type NoFields {}\n\ndirective @skip(if: Boolean!) on FIELD | FRAGMENT_SPREAD | INLINE_FRAGMENT\n\ndirective @include(if: Boolean!)\n  on FIELD\n   | FRAGMENT_SPREAD\n   | INLINE_FRAGMENT\n",

    "simple-schema" = "type Film {\n  title: String\n}\n\ntype Query {\n  film(id: Int): Film\n}\n",
    # "simple-query" = "{\n  title: String\n  id: Int\n  cast: [String]\n}\n",

    "film-schema" = "  scalar Date\n  type Person {\n    name: String\n    films: [Film]\n  }\n  type Film {\n    title: String,\n    producers: [String]\n    characters(limit: Int): [Person]\n    release_date: Date\n  }\n  type Query {\n    film(id: Int): Film\n    person(id: Int): Person\n  }\n",
    "film-query" = "  query fetch_film($id: Int) {\n    film(id: $id) {\n      title\n      producers\n      release_date\n      characters {\n        name\n        films {\n          title\n        }\n      }\n    }\n  }",

    "{\n    name\n    relationship {\n      name\n    }\n  }"
  )
}

#' @export
test_json <- function(...) {
  test_string(...) %>%
    eval_json()
}

from_json <- function(...) {
  rjson::fromJSON(...)
}

to_json <- function(...) {
  rjson::toJSON(...)
}
