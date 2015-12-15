
(function() {
  graphqlLanguage = require('graphql/language');

  var stringify = function(str) {
    obj = graphqlLanguage.parse(str);
    obj.loc.source.body = "__body_removed__"
    return JSON.stringify(obj);
  }



  window.graphqlLanguage = graphqlLanguage;
  window.stringify = stringify;
})()
