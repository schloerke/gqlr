// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// make_json_ast
Rcpp::CharacterVector make_json_ast(Rcpp::String queryString);
RcppExport SEXP graphqlr_make_json_ast(SEXP queryStringSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< Rcpp::String >::type queryString(queryStringSEXP);
    __result = Rcpp::wrap(make_json_ast(queryString));
    return __result;
END_RCPP
}