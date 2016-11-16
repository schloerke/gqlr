# 3.1.6

# Input Objects
#
# Fields can define arguments that the client passes up with the query, to configure their behavior. These inputs can be Strings or Enums, but they sometimes need to be more complex than this.
#
# The Object type defined above is inappropriate for re‐use here, because Objects can contain fields that express circular references or references to interfaces and unions, neither of which is appropriate for use as an input argument. For this reason, input objects have a separate type in the system.
#
# An Input Object defines a set of input fields; the input fields are either scalars, enums, or other input objects. This allows arguments to accept arbitrarily complex structs.
#
# Result Coercion
#
# An input object is never a valid result.
#
# Input Coercion
#
# The input to an input object should be an unordered map, otherwise an error should be thrown. The result of the coercion is an unordered map, with an entry for each input field, whose key is the name of the input field. The value of an entry in the coerced map is the result of input coercing the value of the entry in the input with the same key; if the input does not have a corresponding entry, the value is the result of coercing null. The input coercion above should be performed according to the input coercion rules of the type declared by the input field.
