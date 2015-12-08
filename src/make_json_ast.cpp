#include <Rcpp.h>

/**
 * Copyright (c) 2015, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#include <AstNode.h>
#include <GraphQLParser.h>
#include <c/GraphQLAstToJSON.h>

#include <cstdio>
#include <cstdlib>
#include <iostream>


using std::cerr;
using std::endl;
using std::free;


// [[Rcpp::export]]
Rcpp::CharacterVector make_json_ast(Rcpp::String queryString) {
  const char *error;

  auto AST = facebook::graphql::parseString(queryString.get_cstring(), &error);

  if (!AST) {
    cerr << "Parser failed with error: " << error << endl;
    free((void *)error);
    return 1;
  }

  const char *json = graphql_ast_to_json(
    (const struct GraphQLAstNode *)AST.get());

  Rcpp::CharacterVector ans(1);
  ans[0] = json;
  return ans;
}
