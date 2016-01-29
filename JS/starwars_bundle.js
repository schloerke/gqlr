(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
"use strict";

var _language = require("graphql/language");

var _validation = require("graphql/validation");

var _execution = require("graphql/execution");

var _graphql = require("graphql");

function _asyncToGenerator(fn) { return function () { var gen = fn.apply(this, arguments); return new Promise(function (resolve, reject) { function step(key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { return Promise.resolve(value).then(function (value) { return step("next", value); }, function (err) { return step("throw", err); }); } } return step("next"); }); }; }

// # Taken directly from https://github.com/graphql/graphql-js/blob/master/src/__tests__/
// # and updated to be used within R.  'Promise's were removed
//
// # import { getFriends, getHero, getHuman, getDroid } from './starWarsData.js';

/**
* This is designed to be an end-to-end test, demonstrating
* the full GraphQL stack.
*
* We will create a GraphQL schema that describes the major
* characters in the original Star Wars trilogy.
*
* NOTE: This may contain spoilers for the original Star
* Wars trilogy.
*/
require("babel-polyfill");

var Schema = require('graph.ql');

var query_fn = Schema("\n  enum Episode { NEWHOPE, EMPIRE, JEDI }\n\n  interface Character {\n   id: String!\n   name: String\n   friends: [Character]\n   appearsIn: [Episode]\n  }\n\n  type Human implements Character {\n   id: String!\n   name: String\n   friends: [Character]\n   appearsIn: [Episode]\n   homePlanet: String\n  }\n\n  type Droid implements Character {\n   id: String!\n   name: String\n   friends: [Character]\n   appearsIn: [Episode]\n   primaryFunction: String\n  }\n\n  type Query {\n   hero(episode: Episode): Character\n   human(id: String!): Human\n   droid(id: String!): Droid\n  }\n", {
  Character: {
    resolveType: function resolveType(character) {
      // if (getHuman(character$id)) {
      //   humanType
      // } else {
      //   droidType
      // }
      return console.r.call("gqlr_retrieve_star", { type: "Character", fn: "resolveType", obj: character, args: {} });
    }
  },
  Human: {
    friends: function friends(human) {
      // getFriends(human)
      return console.r.call("gqlr_retrieve_star", { type: "Human", fn: "friends", obj: human, args: {} });
    }
  },
  Droid: {
    friends: function friends(droid) {
      //  = droid => getFriends(droid)
      return console.r.call("gqlr_retrieve_star", { type: "Droid", fn: "resolve", obj: droid, args: {} });
    }
  },
  Query: {
    hero: function hero(base, args) {
      // resolve = (root, { episode }) => getHero(episode),
      return console.r.call("gqlr_retrieve_star", { type: "Query", fn: "hero", obj: base, args: args });
    },
    human: function human(base, args) {
      // resolve = (root, { id }) => getHuman(id),
      return console.r.call("gqlr_retrieve_star", { type: "Query", fn: "human", obj: base, args: args });
    },
    droid: function droid(base, args) {
      // resolve = (root, { id }) => getDroid(id),
      return console.r.call("gqlr_retrieve_star", { type: "Query", fn: "droid", obj: base, args: args });
    }
  }
});

window.query_fn = query_fn;

var testQuery = "\n    query HeroNameQuery {\n      hero {\n        name\n      }\n    }\n  ";
window.testQuery = testQuery;

// window.res = (async function() {
//   // .then(res => console.log(res.data))
//   let res = await query_fn(testQuery)
//   console.log("Yey, story successfully loaded!");
//   return res
// }());

window.res = query_fn(testQuery).then(function (res) {
  console.log("result data!");
  console.log(res.data);
}).catch(function (err) {
  console.log(err);
}); // ES6
// ES6

var schema = new _graphql.GraphQLSchema({
  query: new _graphql.GraphQLObjectType({
    name: 'RootQueryType',
    fields: {
      hello: {
        type: _graphql.GraphQLString,
        resolve: function resolve() {
          return 'world';
        }
      }
    }
  })
});

window.gql_test = function () {
  var query = '{ hello }';

  console.log("started");
  (0, _graphql.graphql)(schema, query).then(function (result) {

    // Prints
    // {
    //   data: { hello: "world" }
    // }
    console.log("returning");
    console.log(result);
  });
  console.log("started");
};

window.gql_test_async = _asyncToGenerator(regeneratorRuntime.mark(function _callee() {
  var query, result;
  return regeneratorRuntime.wrap(function _callee$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          query = '{ hello }';

          console.log("started");
          _context.next = 4;
          return (0, _graphql.graphql)(schema, query);

        case 4:
          result = _context.sent;

          console.log("ended");
          return _context.abrupt("return", result);

        case 7:
        case "end":
          return _context.stop();
      }
    }
  }, _callee, this);
}));

window.gql_test_fn = function () {

  var requestString = '{ hello }';
  var rootValue = undefined;
  var variableValues = undefined;
  var operationName = undefined;

  var source = new _language.Source(requestString || '', 'GraphQL request');
  var documentAST = (0, _language.parse)(source);
  var validationErrors = (0, _validation.validate)(schema, documentAST);

  if (validationErrors.length > 0) {
    throw JSON.stringify({ errors: validationErrors });
  }

  console.log("start execute");
  var res = (0, _execution.execute)(schema, documentAST, rootValue, variableValues, operationName);
  console.log("end execute");

  return res;
};

window.run_test_query = function () {

  var result = _asyncToGenerator(regeneratorRuntime.mark(function _callee2() {
    var res;
    return regeneratorRuntime.wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            // .then(res => console.log(res.data))
            console.log("calling query_fn!");
            _context2.next = 3;
            return query_fn(testQuery);

          case 3:
            res = _context2.sent;

            console.log("Yey, story successfully loaded!");
            return _context2.abrupt("return", res);

          case 6:
          case "end":
            return _context2.stop();
        }
      }
    }, _callee2, this);
  }))();

  // var result = query_fn(testQuery).resolve();

  // const source = new Source(requestString || '', 'GraphQL request');
  //   const documentAST = parse(source);
  //   const validationErrors = validate(schema, documentAST);
  //   if (validationErrors.length > 0) {
  //     resolve({ errors: validationErrors });
  //   } else {
  //     resolve(
  //       execute(
  //         schema,
  //         documentAST,
  //         rootValue,
  //         variableValues,
  //         operationName
  //       )
  //     );
  //   }

  return result;
};

window.run_test_query_json = function () {
  JSON.stringify(window.run_test_query());
};

},{"babel-polyfill":2,"graph.ql":198,"graphql":212,"graphql/execution":209,"graphql/language":217,"graphql/validation":340}],2:[function(require,module,exports){
(function (global){
"use strict";

require("core-js/shim");

require("babel-regenerator-runtime");

if (global._babelPolyfill) {
  throw new Error("only one instance of babel-polyfill is allowed");
}
global._babelPolyfill = true;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"babel-regenerator-runtime":3,"core-js/shim":190}],3:[function(require,module,exports){
(function (process,global){
"use strict";

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

/**
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * https://raw.github.com/facebook/regenerator/master/LICENSE file. An
 * additional grant of patent rights can be found in the PATENTS file in
 * the same directory.
 */

!function (global) {
  "use strict";

  var hasOwn = Object.prototype.hasOwnProperty;
  var undefined; // More compressible than void 0.
  var iteratorSymbol = typeof Symbol === "function" && Symbol.iterator || "@@iterator";

  var inModule = (typeof module === "undefined" ? "undefined" : _typeof(module)) === "object";
  var runtime = global.regeneratorRuntime;
  if (runtime) {
    if (inModule) {
      // If regeneratorRuntime is defined globally and we're in a module,
      // make the exports object identical to regeneratorRuntime.
      module.exports = runtime;
    }
    // Don't bother evaluating the rest of this file if the runtime was
    // already defined globally.
    return;
  }

  // Define the runtime globally (as expected by generated code) as either
  // module.exports (if we're in a module) or a new, empty object.
  runtime = global.regeneratorRuntime = inModule ? module.exports : {};

  function wrap(innerFn, outerFn, self, tryLocsList) {
    // If outerFn provided, then outerFn.prototype instanceof Generator.
    var generator = Object.create((outerFn || Generator).prototype);
    var context = new Context(tryLocsList || []);

    // The ._invoke method unifies the implementations of the .next,
    // .throw, and .return methods.
    generator._invoke = makeInvokeMethod(innerFn, self, context);

    return generator;
  }
  runtime.wrap = wrap;

  // Try/catch helper to minimize deoptimizations. Returns a completion
  // record like context.tryEntries[i].completion. This interface could
  // have been (and was previously) designed to take a closure to be
  // invoked without arguments, but in all the cases we care about we
  // already have an existing method we want to call, so there's no need
  // to create a new function object. We can even get away with assuming
  // the method takes exactly one argument, since that happens to be true
  // in every case, so we don't have to touch the arguments object. The
  // only additional allocation required is the completion record, which
  // has a stable shape and so hopefully should be cheap to allocate.
  function tryCatch(fn, obj, arg) {
    try {
      return { type: "normal", arg: fn.call(obj, arg) };
    } catch (err) {
      return { type: "throw", arg: err };
    }
  }

  var GenStateSuspendedStart = "suspendedStart";
  var GenStateSuspendedYield = "suspendedYield";
  var GenStateExecuting = "executing";
  var GenStateCompleted = "completed";

  // Returning this object from the innerFn has the same effect as
  // breaking out of the dispatch switch statement.
  var ContinueSentinel = {};

  // Dummy constructor functions that we use as the .constructor and
  // .constructor.prototype properties for functions that return Generator
  // objects. For full spec compliance, you may wish to configure your
  // minifier not to mangle the names of these two functions.
  function Generator() {}
  function GeneratorFunction() {}
  function GeneratorFunctionPrototype() {}

  var Gp = GeneratorFunctionPrototype.prototype = Generator.prototype;
  GeneratorFunction.prototype = Gp.constructor = GeneratorFunctionPrototype;
  GeneratorFunctionPrototype.constructor = GeneratorFunction;
  GeneratorFunction.displayName = "GeneratorFunction";

  // Helper for defining the .next, .throw, and .return methods of the
  // Iterator interface in terms of a single ._invoke method.
  function defineIteratorMethods(prototype) {
    ["next", "throw", "return"].forEach(function (method) {
      prototype[method] = function (arg) {
        return this._invoke(method, arg);
      };
    });
  }

  runtime.isGeneratorFunction = function (genFun) {
    var ctor = typeof genFun === "function" && genFun.constructor;
    return ctor ? ctor === GeneratorFunction ||
    // For the native GeneratorFunction constructor, the best we can
    // do is to check its .name property.
    (ctor.displayName || ctor.name) === "GeneratorFunction" : false;
  };

  runtime.mark = function (genFun) {
    if (Object.setPrototypeOf) {
      Object.setPrototypeOf(genFun, GeneratorFunctionPrototype);
    } else {
      genFun.__proto__ = GeneratorFunctionPrototype;
    }
    genFun.prototype = Object.create(Gp);
    return genFun;
  };

  // Within the body of any async function, `await x` is transformed to
  // `yield regeneratorRuntime.awrap(x)`, so that the runtime can test
  // `value instanceof AwaitArgument` to determine if the yielded value is
  // meant to be awaited. Some may consider the name of this method too
  // cutesy, but they are curmudgeons.
  runtime.awrap = function (arg) {
    return new AwaitArgument(arg);
  };

  function AwaitArgument(arg) {
    this.arg = arg;
  }

  function AsyncIterator(generator) {
    // This invoke function is written in a style that assumes some
    // calling function (or Promise) will handle exceptions.
    function invoke(method, arg) {
      var result = generator[method](arg);
      var value = result.value;
      return value instanceof AwaitArgument ? Promise.resolve(value.arg).then(invokeNext, invokeThrow) : Promise.resolve(value).then(function (unwrapped) {
        // When a yielded Promise is resolved, its final value becomes
        // the .value of the Promise<{value,done}> result for the
        // current iteration. If the Promise is rejected, however, the
        // result for this iteration will be rejected with the same
        // reason. Note that rejections of yielded Promises are not
        // thrown back into the generator function, as is the case
        // when an awaited Promise is rejected. This difference in
        // behavior between yield and await is important, because it
        // allows the consumer to decide what to do with the yielded
        // rejection (swallow it and continue, manually .throw it back
        // into the generator, abandon iteration, whatever). With
        // await, by contrast, there is no opportunity to examine the
        // rejection reason outside the generator function, so the
        // only option is to throw it from the await expression, and
        // let the generator function handle the exception.
        result.value = unwrapped;
        return result;
      });
    }

    if ((typeof process === "undefined" ? "undefined" : _typeof(process)) === "object" && process.domain) {
      invoke = process.domain.bind(invoke);
    }

    var invokeNext = invoke.bind(generator, "next");
    var invokeThrow = invoke.bind(generator, "throw");
    var invokeReturn = invoke.bind(generator, "return");
    var previousPromise;

    function enqueue(method, arg) {
      function callInvokeWithMethodAndArg() {
        return invoke(method, arg);
      }

      return previousPromise =
      // If enqueue has been called before, then we want to wait until
      // all previous Promises have been resolved before calling invoke,
      // so that results are always delivered in the correct order. If
      // enqueue has not been called before, then it is important to
      // call invoke immediately, without waiting on a callback to fire,
      // so that the async generator function has the opportunity to do
      // any necessary setup in a predictable way. This predictability
      // is why the Promise constructor synchronously invokes its
      // executor callback, and why async functions synchronously
      // execute code before the first await. Since we implement simple
      // async functions in terms of async generators, it is especially
      // important to get this right, even though it requires care.
      previousPromise ? previousPromise.then(callInvokeWithMethodAndArg,
      // Avoid propagating failures to Promises returned by later
      // invocations of the iterator.
      callInvokeWithMethodAndArg) : new Promise(function (resolve) {
        resolve(callInvokeWithMethodAndArg());
      });
    }

    // Define the unified helper method that is used to implement .next,
    // .throw, and .return (see defineIteratorMethods).
    this._invoke = enqueue;
  }

  defineIteratorMethods(AsyncIterator.prototype);

  // Note that simple async functions are implemented on top of
  // AsyncIterator objects; they just return a Promise for the value of
  // the final result produced by the iterator.
  runtime.async = function (innerFn, outerFn, self, tryLocsList) {
    var iter = new AsyncIterator(wrap(innerFn, outerFn, self, tryLocsList));

    return runtime.isGeneratorFunction(outerFn) ? iter // If outerFn is a generator, return the full iterator.
    : iter.next().then(function (result) {
      return result.done ? result.value : iter.next();
    });
  };

  function makeInvokeMethod(innerFn, self, context) {
    var state = GenStateSuspendedStart;

    return function invoke(method, arg) {
      if (state === GenStateExecuting) {
        throw new Error("Generator is already running");
      }

      if (state === GenStateCompleted) {
        if (method === "throw") {
          throw arg;
        }

        // Be forgiving, per 25.3.3.3.3 of the spec:
        // https://people.mozilla.org/~jorendorff/es6-draft.html#sec-generatorresume
        return doneResult();
      }

      while (true) {
        var delegate = context.delegate;
        if (delegate) {
          if (method === "return" || method === "throw" && delegate.iterator[method] === undefined) {
            // A return or throw (when the delegate iterator has no throw
            // method) always terminates the yield* loop.
            context.delegate = null;

            // If the delegate iterator has a return method, give it a
            // chance to clean up.
            var returnMethod = delegate.iterator["return"];
            if (returnMethod) {
              var record = tryCatch(returnMethod, delegate.iterator, arg);
              if (record.type === "throw") {
                // If the return method threw an exception, let that
                // exception prevail over the original return or throw.
                method = "throw";
                arg = record.arg;
                continue;
              }
            }

            if (method === "return") {
              // Continue with the outer return, now that the delegate
              // iterator has been terminated.
              continue;
            }
          }

          var record = tryCatch(delegate.iterator[method], delegate.iterator, arg);

          if (record.type === "throw") {
            context.delegate = null;

            // Like returning generator.throw(uncaught), but without the
            // overhead of an extra function call.
            method = "throw";
            arg = record.arg;
            continue;
          }

          // Delegate generator ran and handled its own exceptions so
          // regardless of what the method was, we continue as if it is
          // "next" with an undefined arg.
          method = "next";
          arg = undefined;

          var info = record.arg;
          if (info.done) {
            context[delegate.resultName] = info.value;
            context.next = delegate.nextLoc;
          } else {
            state = GenStateSuspendedYield;
            return info;
          }

          context.delegate = null;
        }

        if (method === "next") {
          context._sent = arg;

          if (state === GenStateSuspendedYield) {
            context.sent = arg;
          } else {
            context.sent = undefined;
          }
        } else if (method === "throw") {
          if (state === GenStateSuspendedStart) {
            state = GenStateCompleted;
            throw arg;
          }

          if (context.dispatchException(arg)) {
            // If the dispatched exception was caught by a catch block,
            // then let that catch block handle the exception normally.
            method = "next";
            arg = undefined;
          }
        } else if (method === "return") {
          context.abrupt("return", arg);
        }

        state = GenStateExecuting;

        var record = tryCatch(innerFn, self, context);
        if (record.type === "normal") {
          // If an exception is thrown from innerFn, we leave state ===
          // GenStateExecuting and loop back for another invocation.
          state = context.done ? GenStateCompleted : GenStateSuspendedYield;

          var info = {
            value: record.arg,
            done: context.done
          };

          if (record.arg === ContinueSentinel) {
            if (context.delegate && method === "next") {
              // Deliberately forget the last sent value so that we don't
              // accidentally pass it on to the delegate.
              arg = undefined;
            }
          } else {
            return info;
          }
        } else if (record.type === "throw") {
          state = GenStateCompleted;
          // Dispatch the exception by looping back around to the
          // context.dispatchException(arg) call above.
          method = "throw";
          arg = record.arg;
        }
      }
    };
  }

  // Define Generator.prototype.{next,throw,return} in terms of the
  // unified ._invoke helper method.
  defineIteratorMethods(Gp);

  Gp[iteratorSymbol] = function () {
    return this;
  };

  Gp.toString = function () {
    return "[object Generator]";
  };

  function pushTryEntry(locs) {
    var entry = { tryLoc: locs[0] };

    if (1 in locs) {
      entry.catchLoc = locs[1];
    }

    if (2 in locs) {
      entry.finallyLoc = locs[2];
      entry.afterLoc = locs[3];
    }

    this.tryEntries.push(entry);
  }

  function resetTryEntry(entry) {
    var record = entry.completion || {};
    record.type = "normal";
    delete record.arg;
    entry.completion = record;
  }

  function Context(tryLocsList) {
    // The root entry object (effectively a try statement without a catch
    // or a finally block) gives us a place to store values thrown from
    // locations where there is no enclosing try statement.
    this.tryEntries = [{ tryLoc: "root" }];
    tryLocsList.forEach(pushTryEntry, this);
    this.reset(true);
  }

  runtime.keys = function (object) {
    var keys = [];
    for (var key in object) {
      keys.push(key);
    }
    keys.reverse();

    // Rather than returning an object with a next method, we keep
    // things simple and return the next function itself.
    return function next() {
      while (keys.length) {
        var key = keys.pop();
        if (key in object) {
          next.value = key;
          next.done = false;
          return next;
        }
      }

      // To avoid creating an additional object, we just hang the .value
      // and .done properties off the next function object itself. This
      // also ensures that the minifier will not anonymize the function.
      next.done = true;
      return next;
    };
  };

  function values(iterable) {
    if (iterable) {
      var iteratorMethod = iterable[iteratorSymbol];
      if (iteratorMethod) {
        return iteratorMethod.call(iterable);
      }

      if (typeof iterable.next === "function") {
        return iterable;
      }

      if (!isNaN(iterable.length)) {
        var i = -1,
            next = function next() {
          while (++i < iterable.length) {
            if (hasOwn.call(iterable, i)) {
              next.value = iterable[i];
              next.done = false;
              return next;
            }
          }

          next.value = undefined;
          next.done = true;

          return next;
        };

        return next.next = next;
      }
    }

    // Return an iterator with no values.
    return { next: doneResult };
  }
  runtime.values = values;

  function doneResult() {
    return { value: undefined, done: true };
  }

  Context.prototype = {
    constructor: Context,

    reset: function reset(skipTempReset) {
      this.prev = 0;
      this.next = 0;
      this.sent = undefined;
      this.done = false;
      this.delegate = null;

      this.tryEntries.forEach(resetTryEntry);

      if (!skipTempReset) {
        for (var name in this) {
          // Not sure about the optimal order of these conditions:
          if (name.charAt(0) === "t" && hasOwn.call(this, name) && !isNaN(+name.slice(1))) {
            this[name] = undefined;
          }
        }
      }
    },

    stop: function stop() {
      this.done = true;

      var rootEntry = this.tryEntries[0];
      var rootRecord = rootEntry.completion;
      if (rootRecord.type === "throw") {
        throw rootRecord.arg;
      }

      return this.rval;
    },

    dispatchException: function dispatchException(exception) {
      if (this.done) {
        throw exception;
      }

      var context = this;
      function handle(loc, caught) {
        record.type = "throw";
        record.arg = exception;
        context.next = loc;
        return !!caught;
      }

      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        var record = entry.completion;

        if (entry.tryLoc === "root") {
          // Exception thrown outside of any try block that could handle
          // it, so set the completion value of the entire function to
          // throw the exception.
          return handle("end");
        }

        if (entry.tryLoc <= this.prev) {
          var hasCatch = hasOwn.call(entry, "catchLoc");
          var hasFinally = hasOwn.call(entry, "finallyLoc");

          if (hasCatch && hasFinally) {
            if (this.prev < entry.catchLoc) {
              return handle(entry.catchLoc, true);
            } else if (this.prev < entry.finallyLoc) {
              return handle(entry.finallyLoc);
            }
          } else if (hasCatch) {
            if (this.prev < entry.catchLoc) {
              return handle(entry.catchLoc, true);
            }
          } else if (hasFinally) {
            if (this.prev < entry.finallyLoc) {
              return handle(entry.finallyLoc);
            }
          } else {
            throw new Error("try statement without catch or finally");
          }
        }
      }
    },

    abrupt: function abrupt(type, arg) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc <= this.prev && hasOwn.call(entry, "finallyLoc") && this.prev < entry.finallyLoc) {
          var finallyEntry = entry;
          break;
        }
      }

      if (finallyEntry && (type === "break" || type === "continue") && finallyEntry.tryLoc <= arg && arg <= finallyEntry.finallyLoc) {
        // Ignore the finally entry if control is not jumping to a
        // location outside the try/catch block.
        finallyEntry = null;
      }

      var record = finallyEntry ? finallyEntry.completion : {};
      record.type = type;
      record.arg = arg;

      if (finallyEntry) {
        this.next = finallyEntry.finallyLoc;
      } else {
        this.complete(record);
      }

      return ContinueSentinel;
    },

    complete: function complete(record, afterLoc) {
      if (record.type === "throw") {
        throw record.arg;
      }

      if (record.type === "break" || record.type === "continue") {
        this.next = record.arg;
      } else if (record.type === "return") {
        this.rval = record.arg;
        this.next = "end";
      } else if (record.type === "normal" && afterLoc) {
        this.next = afterLoc;
      }
    },

    finish: function finish(finallyLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.finallyLoc === finallyLoc) {
          this.complete(entry.completion, entry.afterLoc);
          resetTryEntry(entry);
          return ContinueSentinel;
        }
      }
    },

    "catch": function _catch(tryLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc === tryLoc) {
          var record = entry.completion;
          if (record.type === "throw") {
            var thrown = record.arg;
            resetTryEntry(entry);
          }
          return thrown;
        }
      }

      // The context.catch method must only be called with a location
      // argument that corresponds to a known catch block.
      throw new Error("illegal catch attempt");
    },

    delegateYield: function delegateYield(iterable, resultName, nextLoc) {
      this.delegate = {
        iterator: values(iterable),
        resultName: resultName,
        nextLoc: nextLoc
      };

      return ContinueSentinel;
    }
  };
}(
// Among the various tricks for obtaining a reference to the global
// object, this seems to be the most reliable technique that does not
// use indirect eval (which violates Content Security Policy).
(typeof global === "undefined" ? "undefined" : _typeof(global)) === "object" ? global : (typeof window === "undefined" ? "undefined" : _typeof(window)) === "object" ? window : (typeof self === "undefined" ? "undefined" : _typeof(self)) === "object" ? self : undefined);

}).call(this,require('_process'),typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"_process":193}],4:[function(require,module,exports){
'use strict';

module.exports = function (it) {
  if (typeof it != 'function') throw TypeError(it + ' is not a function!');
  return it;
};

},{}],5:[function(require,module,exports){
'use strict';

// 22.1.3.31 Array.prototype[@@unscopables]
var UNSCOPABLES = require('./$.wks')('unscopables'),
    ArrayProto = Array.prototype;
if (ArrayProto[UNSCOPABLES] == undefined) require('./$.hide')(ArrayProto, UNSCOPABLES, {});
module.exports = function (key) {
  ArrayProto[UNSCOPABLES][key] = true;
};

},{"./$.hide":33,"./$.wks":85}],6:[function(require,module,exports){
'use strict';

var isObject = require('./$.is-object');
module.exports = function (it) {
  if (!isObject(it)) throw TypeError(it + ' is not an object!');
  return it;
};

},{"./$.is-object":40}],7:[function(require,module,exports){
// 22.1.3.3 Array.prototype.copyWithin(target, start, end = this.length)
'use strict';

var toObject = require('./$.to-object'),
    toIndex = require('./$.to-index'),
    toLength = require('./$.to-length');

module.exports = [].copyWithin || function copyWithin(target /*= 0*/, start /*= 0, end = @length*/) {
  var O = toObject(this),
      len = toLength(O.length),
      to = toIndex(target, len),
      from = toIndex(start, len),
      $$ = arguments,
      end = $$.length > 2 ? $$[2] : undefined,
      count = Math.min((end === undefined ? len : toIndex(end, len)) - from, len - to),
      inc = 1;
  if (from < to && to < from + count) {
    inc = -1;
    from += count - 1;
    to += count - 1;
  }
  while (count-- > 0) {
    if (from in O) O[to] = O[from];else delete O[to];
    to += inc;
    from += inc;
  }return O;
};

},{"./$.to-index":78,"./$.to-length":81,"./$.to-object":82}],8:[function(require,module,exports){
// 22.1.3.6 Array.prototype.fill(value, start = 0, end = this.length)
'use strict';

var toObject = require('./$.to-object'),
    toIndex = require('./$.to-index'),
    toLength = require('./$.to-length');
module.exports = [].fill || function fill(value /*, start = 0, end = @length */) {
  var O = toObject(this),
      length = toLength(O.length),
      $$ = arguments,
      $$len = $$.length,
      index = toIndex($$len > 1 ? $$[1] : undefined, length),
      end = $$len > 2 ? $$[2] : undefined,
      endPos = end === undefined ? length : toIndex(end, length);
  while (endPos > index) {
    O[index++] = value;
  }return O;
};

},{"./$.to-index":78,"./$.to-length":81,"./$.to-object":82}],9:[function(require,module,exports){
'use strict';

// false -> Array#indexOf
// true  -> Array#includes
var toIObject = require('./$.to-iobject'),
    toLength = require('./$.to-length'),
    toIndex = require('./$.to-index');
module.exports = function (IS_INCLUDES) {
  return function ($this, el, fromIndex) {
    var O = toIObject($this),
        length = toLength(O.length),
        index = toIndex(fromIndex, length),
        value;
    // Array#includes uses SameValueZero equality algorithm
    if (IS_INCLUDES && el != el) while (length > index) {
      value = O[index++];
      if (value != value) return true;
      // Array#toIndex ignores holes, Array#includes - not
    } else for (; length > index; index++) {
        if (IS_INCLUDES || index in O) {
          if (O[index] === el) return IS_INCLUDES || index;
        }
      }return !IS_INCLUDES && -1;
  };
};

},{"./$.to-index":78,"./$.to-iobject":80,"./$.to-length":81}],10:[function(require,module,exports){
'use strict';

// 0 -> Array#forEach
// 1 -> Array#map
// 2 -> Array#filter
// 3 -> Array#some
// 4 -> Array#every
// 5 -> Array#find
// 6 -> Array#findIndex
var ctx = require('./$.ctx'),
    IObject = require('./$.iobject'),
    toObject = require('./$.to-object'),
    toLength = require('./$.to-length'),
    asc = require('./$.array-species-create');
module.exports = function (TYPE) {
  var IS_MAP = TYPE == 1,
      IS_FILTER = TYPE == 2,
      IS_SOME = TYPE == 3,
      IS_EVERY = TYPE == 4,
      IS_FIND_INDEX = TYPE == 6,
      NO_HOLES = TYPE == 5 || IS_FIND_INDEX;
  return function ($this, callbackfn, that) {
    var O = toObject($this),
        self = IObject(O),
        f = ctx(callbackfn, that, 3),
        length = toLength(self.length),
        index = 0,
        result = IS_MAP ? asc($this, length) : IS_FILTER ? asc($this, 0) : undefined,
        val,
        res;
    for (; length > index; index++) {
      if (NO_HOLES || index in self) {
        val = self[index];
        res = f(val, index, O);
        if (TYPE) {
          if (IS_MAP) result[index] = res; // map
          else if (res) switch (TYPE) {
              case 3:
                return true; // some
              case 5:
                return val; // find
              case 6:
                return index; // findIndex
              case 2:
                result.push(val); // filter
            } else if (IS_EVERY) return false; // every
        }
      }
    }return IS_FIND_INDEX ? -1 : IS_SOME || IS_EVERY ? IS_EVERY : result;
  };
};

},{"./$.array-species-create":11,"./$.ctx":19,"./$.iobject":36,"./$.to-length":81,"./$.to-object":82}],11:[function(require,module,exports){
'use strict';

// 9.4.2.3 ArraySpeciesCreate(originalArray, length)
var isObject = require('./$.is-object'),
    isArray = require('./$.is-array'),
    SPECIES = require('./$.wks')('species');
module.exports = function (original, length) {
  var C;
  if (isArray(original)) {
    C = original.constructor;
    // cross-realm fallback
    if (typeof C == 'function' && (C === Array || isArray(C.prototype))) C = undefined;
    if (isObject(C)) {
      C = C[SPECIES];
      if (C === null) C = undefined;
    }
  }return new (C === undefined ? Array : C)(length);
};

},{"./$.is-array":38,"./$.is-object":40,"./$.wks":85}],12:[function(require,module,exports){
'use strict';

// getting tag from 19.1.3.6 Object.prototype.toString()
var cof = require('./$.cof'),
    TAG = require('./$.wks')('toStringTag')
// ES3 wrong here
,
    ARG = cof(function () {
  return arguments;
}()) == 'Arguments';

module.exports = function (it) {
  var O, T, B;
  return it === undefined ? 'Undefined' : it === null ? 'Null'
  // @@toStringTag case
  : typeof (T = (O = Object(it))[TAG]) == 'string' ? T
  // builtinTag case
  : ARG ? cof(O)
  // ES3 arguments fallback
  : (B = cof(O)) == 'Object' && typeof O.callee == 'function' ? 'Arguments' : B;
};

},{"./$.cof":13,"./$.wks":85}],13:[function(require,module,exports){
"use strict";

var toString = {}.toString;

module.exports = function (it) {
  return toString.call(it).slice(8, -1);
};

},{}],14:[function(require,module,exports){
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var $ = require('./$'),
    hide = require('./$.hide'),
    redefineAll = require('./$.redefine-all'),
    ctx = require('./$.ctx'),
    strictNew = require('./$.strict-new'),
    defined = require('./$.defined'),
    forOf = require('./$.for-of'),
    $iterDefine = require('./$.iter-define'),
    step = require('./$.iter-step'),
    ID = require('./$.uid')('id'),
    $has = require('./$.has'),
    isObject = require('./$.is-object'),
    setSpecies = require('./$.set-species'),
    DESCRIPTORS = require('./$.descriptors'),
    isExtensible = Object.isExtensible || isObject,
    SIZE = DESCRIPTORS ? '_s' : 'size',
    id = 0;

var fastKey = function fastKey(it, create) {
  // return primitive with prefix
  if (!isObject(it)) return (typeof it === 'undefined' ? 'undefined' : _typeof(it)) == 'symbol' ? it : (typeof it == 'string' ? 'S' : 'P') + it;
  if (!$has(it, ID)) {
    // can't set id to frozen object
    if (!isExtensible(it)) return 'F';
    // not necessary to add id
    if (!create) return 'E';
    // add missing object id
    hide(it, ID, ++id);
    // return object id with prefix
  }return 'O' + it[ID];
};

var getEntry = function getEntry(that, key) {
  // fast case
  var index = fastKey(key),
      entry;
  if (index !== 'F') return that._i[index];
  // frozen object case
  for (entry = that._f; entry; entry = entry.n) {
    if (entry.k == key) return entry;
  }
};

module.exports = {
  getConstructor: function getConstructor(wrapper, NAME, IS_MAP, ADDER) {
    var C = wrapper(function (that, iterable) {
      strictNew(that, C, NAME);
      that._i = $.create(null); // index
      that._f = undefined; // first entry
      that._l = undefined; // last entry
      that[SIZE] = 0; // size
      if (iterable != undefined) forOf(iterable, IS_MAP, that[ADDER], that);
    });
    redefineAll(C.prototype, {
      // 23.1.3.1 Map.prototype.clear()
      // 23.2.3.2 Set.prototype.clear()
      clear: function clear() {
        for (var that = this, data = that._i, entry = that._f; entry; entry = entry.n) {
          entry.r = true;
          if (entry.p) entry.p = entry.p.n = undefined;
          delete data[entry.i];
        }
        that._f = that._l = undefined;
        that[SIZE] = 0;
      },
      // 23.1.3.3 Map.prototype.delete(key)
      // 23.2.3.4 Set.prototype.delete(value)
      'delete': function _delete(key) {
        var that = this,
            entry = getEntry(that, key);
        if (entry) {
          var next = entry.n,
              prev = entry.p;
          delete that._i[entry.i];
          entry.r = true;
          if (prev) prev.n = next;
          if (next) next.p = prev;
          if (that._f == entry) that._f = next;
          if (that._l == entry) that._l = prev;
          that[SIZE]--;
        }return !!entry;
      },
      // 23.2.3.6 Set.prototype.forEach(callbackfn, thisArg = undefined)
      // 23.1.3.5 Map.prototype.forEach(callbackfn, thisArg = undefined)
      forEach: function forEach(callbackfn /*, that = undefined */) {
        var f = ctx(callbackfn, arguments.length > 1 ? arguments[1] : undefined, 3),
            entry;
        while (entry = entry ? entry.n : this._f) {
          f(entry.v, entry.k, this);
          // revert to the last existing entry
          while (entry && entry.r) {
            entry = entry.p;
          }
        }
      },
      // 23.1.3.7 Map.prototype.has(key)
      // 23.2.3.7 Set.prototype.has(value)
      has: function has(key) {
        return !!getEntry(this, key);
      }
    });
    if (DESCRIPTORS) $.setDesc(C.prototype, 'size', {
      get: function get() {
        return defined(this[SIZE]);
      }
    });
    return C;
  },
  def: function def(that, key, value) {
    var entry = getEntry(that, key),
        prev,
        index;
    // change existing entry
    if (entry) {
      entry.v = value;
      // create new entry
    } else {
        that._l = entry = {
          i: index = fastKey(key, true), // <- index
          k: key, // <- key
          v: value, // <- value
          p: prev = that._l, // <- previous entry
          n: undefined, // <- next entry
          r: false // <- removed
        };
        if (!that._f) that._f = entry;
        if (prev) prev.n = entry;
        that[SIZE]++;
        // add to index
        if (index !== 'F') that._i[index] = entry;
      }return that;
  },
  getEntry: getEntry,
  setStrong: function setStrong(C, NAME, IS_MAP) {
    // add .keys, .values, .entries, [@@iterator]
    // 23.1.3.4, 23.1.3.8, 23.1.3.11, 23.1.3.12, 23.2.3.5, 23.2.3.8, 23.2.3.10, 23.2.3.11
    $iterDefine(C, NAME, function (iterated, kind) {
      this._t = iterated; // target
      this._k = kind; // kind
      this._l = undefined; // previous
    }, function () {
      var that = this,
          kind = that._k,
          entry = that._l;
      // revert to the last existing entry
      while (entry && entry.r) {
        entry = entry.p;
      } // get next entry
      if (!that._t || !(that._l = entry = entry ? entry.n : that._t._f)) {
        // or finish the iteration
        that._t = undefined;
        return step(1);
      }
      // return step by kind
      if (kind == 'keys') return step(0, entry.k);
      if (kind == 'values') return step(0, entry.v);
      return step(0, [entry.k, entry.v]);
    }, IS_MAP ? 'entries' : 'values', !IS_MAP, true);

    // add [@@species], 23.1.2.2, 23.2.2.2
    setSpecies(NAME);
  }
};

},{"./$":48,"./$.ctx":19,"./$.defined":20,"./$.descriptors":21,"./$.for-of":29,"./$.has":32,"./$.hide":33,"./$.is-object":40,"./$.iter-define":44,"./$.iter-step":46,"./$.redefine-all":62,"./$.set-species":67,"./$.strict-new":71,"./$.uid":84}],15:[function(require,module,exports){
'use strict';

// https://github.com/DavidBruant/Map-Set.prototype.toJSON
var forOf = require('./$.for-of'),
    classof = require('./$.classof');
module.exports = function (NAME) {
  return function toJSON() {
    if (classof(this) != NAME) throw TypeError(NAME + "#toJSON isn't generic");
    var arr = [];
    forOf(this, false, arr.push, arr);
    return arr;
  };
};

},{"./$.classof":12,"./$.for-of":29}],16:[function(require,module,exports){
'use strict';

var hide = require('./$.hide'),
    redefineAll = require('./$.redefine-all'),
    anObject = require('./$.an-object'),
    isObject = require('./$.is-object'),
    strictNew = require('./$.strict-new'),
    forOf = require('./$.for-of'),
    createArrayMethod = require('./$.array-methods'),
    $has = require('./$.has'),
    WEAK = require('./$.uid')('weak'),
    isExtensible = Object.isExtensible || isObject,
    arrayFind = createArrayMethod(5),
    arrayFindIndex = createArrayMethod(6),
    id = 0;

// fallback for frozen keys
var frozenStore = function frozenStore(that) {
  return that._l || (that._l = new FrozenStore());
};
var FrozenStore = function FrozenStore() {
  this.a = [];
};
var findFrozen = function findFrozen(store, key) {
  return arrayFind(store.a, function (it) {
    return it[0] === key;
  });
};
FrozenStore.prototype = {
  get: function get(key) {
    var entry = findFrozen(this, key);
    if (entry) return entry[1];
  },
  has: function has(key) {
    return !!findFrozen(this, key);
  },
  set: function set(key, value) {
    var entry = findFrozen(this, key);
    if (entry) entry[1] = value;else this.a.push([key, value]);
  },
  'delete': function _delete(key) {
    var index = arrayFindIndex(this.a, function (it) {
      return it[0] === key;
    });
    if (~index) this.a.splice(index, 1);
    return !! ~index;
  }
};

module.exports = {
  getConstructor: function getConstructor(wrapper, NAME, IS_MAP, ADDER) {
    var C = wrapper(function (that, iterable) {
      strictNew(that, C, NAME);
      that._i = id++; // collection id
      that._l = undefined; // leak store for frozen objects
      if (iterable != undefined) forOf(iterable, IS_MAP, that[ADDER], that);
    });
    redefineAll(C.prototype, {
      // 23.3.3.2 WeakMap.prototype.delete(key)
      // 23.4.3.3 WeakSet.prototype.delete(value)
      'delete': function _delete(key) {
        if (!isObject(key)) return false;
        if (!isExtensible(key)) return frozenStore(this)['delete'](key);
        return $has(key, WEAK) && $has(key[WEAK], this._i) && delete key[WEAK][this._i];
      },
      // 23.3.3.4 WeakMap.prototype.has(key)
      // 23.4.3.4 WeakSet.prototype.has(value)
      has: function has(key) {
        if (!isObject(key)) return false;
        if (!isExtensible(key)) return frozenStore(this).has(key);
        return $has(key, WEAK) && $has(key[WEAK], this._i);
      }
    });
    return C;
  },
  def: function def(that, key, value) {
    if (!isExtensible(anObject(key))) {
      frozenStore(that).set(key, value);
    } else {
      $has(key, WEAK) || hide(key, WEAK, {});
      key[WEAK][that._i] = value;
    }return that;
  },
  frozenStore: frozenStore,
  WEAK: WEAK
};

},{"./$.an-object":6,"./$.array-methods":10,"./$.for-of":29,"./$.has":32,"./$.hide":33,"./$.is-object":40,"./$.redefine-all":62,"./$.strict-new":71,"./$.uid":84}],17:[function(require,module,exports){
'use strict';

var global = require('./$.global'),
    $export = require('./$.export'),
    redefine = require('./$.redefine'),
    redefineAll = require('./$.redefine-all'),
    forOf = require('./$.for-of'),
    strictNew = require('./$.strict-new'),
    isObject = require('./$.is-object'),
    fails = require('./$.fails'),
    $iterDetect = require('./$.iter-detect'),
    setToStringTag = require('./$.set-to-string-tag');

module.exports = function (NAME, wrapper, methods, common, IS_MAP, IS_WEAK) {
  var Base = global[NAME],
      C = Base,
      ADDER = IS_MAP ? 'set' : 'add',
      proto = C && C.prototype,
      O = {};
  var fixMethod = function fixMethod(KEY) {
    var fn = proto[KEY];
    redefine(proto, KEY, KEY == 'delete' ? function (a) {
      return IS_WEAK && !isObject(a) ? false : fn.call(this, a === 0 ? 0 : a);
    } : KEY == 'has' ? function has(a) {
      return IS_WEAK && !isObject(a) ? false : fn.call(this, a === 0 ? 0 : a);
    } : KEY == 'get' ? function get(a) {
      return IS_WEAK && !isObject(a) ? undefined : fn.call(this, a === 0 ? 0 : a);
    } : KEY == 'add' ? function add(a) {
      fn.call(this, a === 0 ? 0 : a);return this;
    } : function set(a, b) {
      fn.call(this, a === 0 ? 0 : a, b);return this;
    });
  };
  if (typeof C != 'function' || !(IS_WEAK || proto.forEach && !fails(function () {
    new C().entries().next();
  }))) {
    // create collection constructor
    C = common.getConstructor(wrapper, NAME, IS_MAP, ADDER);
    redefineAll(C.prototype, methods);
  } else {
    var instance = new C()
    // early implementations not supports chaining
    ,
        HASNT_CHAINING = instance[ADDER](IS_WEAK ? {} : -0, 1) != instance
    // V8 ~  Chromium 40- weak-collections throws on primitives, but should return false
    ,
        THROWS_ON_PRIMITIVES = fails(function () {
      instance.has(1);
    })
    // most early implementations doesn't supports iterables, most modern - not close it correctly
    ,
        ACCEPT_ITERABLES = $iterDetect(function (iter) {
      new C(iter);
    }) // eslint-disable-line no-new
    // for early implementations -0 and +0 not the same
    ,
        BUGGY_ZERO;
    if (!ACCEPT_ITERABLES) {
      C = wrapper(function (target, iterable) {
        strictNew(target, C, NAME);
        var that = new Base();
        if (iterable != undefined) forOf(iterable, IS_MAP, that[ADDER], that);
        return that;
      });
      C.prototype = proto;
      proto.constructor = C;
    }
    IS_WEAK || instance.forEach(function (val, key) {
      BUGGY_ZERO = 1 / key === -Infinity;
    });
    if (THROWS_ON_PRIMITIVES || BUGGY_ZERO) {
      fixMethod('delete');
      fixMethod('has');
      IS_MAP && fixMethod('get');
    }
    if (BUGGY_ZERO || HASNT_CHAINING) fixMethod(ADDER);
    // weak collections should not contains .clear method
    if (IS_WEAK && proto.clear) delete proto.clear;
  }

  setToStringTag(C, NAME);

  O[NAME] = C;
  $export($export.G + $export.W + $export.F * (C != Base), O);

  if (!IS_WEAK) common.setStrong(C, NAME, IS_MAP);

  return C;
};

},{"./$.export":24,"./$.fails":26,"./$.for-of":29,"./$.global":31,"./$.is-object":40,"./$.iter-detect":45,"./$.redefine":63,"./$.redefine-all":62,"./$.set-to-string-tag":68,"./$.strict-new":71}],18:[function(require,module,exports){
'use strict';

var core = module.exports = { version: '1.2.6' };
if (typeof __e == 'number') __e = core; // eslint-disable-line no-undef

},{}],19:[function(require,module,exports){
'use strict';

// optional / simple context binding
var aFunction = require('./$.a-function');
module.exports = function (fn, that, length) {
  aFunction(fn);
  if (that === undefined) return fn;
  switch (length) {
    case 1:
      return function (a) {
        return fn.call(that, a);
      };
    case 2:
      return function (a, b) {
        return fn.call(that, a, b);
      };
    case 3:
      return function (a, b, c) {
        return fn.call(that, a, b, c);
      };
  }
  return function () /* ...args */{
    return fn.apply(that, arguments);
  };
};

},{"./$.a-function":4}],20:[function(require,module,exports){
"use strict";

// 7.2.1 RequireObjectCoercible(argument)
module.exports = function (it) {
  if (it == undefined) throw TypeError("Can't call method on  " + it);
  return it;
};

},{}],21:[function(require,module,exports){
'use strict';

// Thank's IE8 for his funny defineProperty
module.exports = !require('./$.fails')(function () {
  return Object.defineProperty({}, 'a', { get: function get() {
      return 7;
    } }).a != 7;
});

},{"./$.fails":26}],22:[function(require,module,exports){
'use strict';

var isObject = require('./$.is-object'),
    document = require('./$.global').document
// in old IE typeof document.createElement is 'object'
,
    is = isObject(document) && isObject(document.createElement);
module.exports = function (it) {
  return is ? document.createElement(it) : {};
};

},{"./$.global":31,"./$.is-object":40}],23:[function(require,module,exports){
'use strict';

// all enumerable object keys, includes symbols
var $ = require('./$');
module.exports = function (it) {
  var keys = $.getKeys(it),
      getSymbols = $.getSymbols;
  if (getSymbols) {
    var symbols = getSymbols(it),
        isEnum = $.isEnum,
        i = 0,
        key;
    while (symbols.length > i) {
      if (isEnum.call(it, key = symbols[i++])) keys.push(key);
    }
  }
  return keys;
};

},{"./$":48}],24:[function(require,module,exports){
'use strict';

var global = require('./$.global'),
    core = require('./$.core'),
    hide = require('./$.hide'),
    redefine = require('./$.redefine'),
    ctx = require('./$.ctx'),
    PROTOTYPE = 'prototype';

var $export = function $export(type, name, source) {
  var IS_FORCED = type & $export.F,
      IS_GLOBAL = type & $export.G,
      IS_STATIC = type & $export.S,
      IS_PROTO = type & $export.P,
      IS_BIND = type & $export.B,
      target = IS_GLOBAL ? global : IS_STATIC ? global[name] || (global[name] = {}) : (global[name] || {})[PROTOTYPE],
      exports = IS_GLOBAL ? core : core[name] || (core[name] = {}),
      expProto = exports[PROTOTYPE] || (exports[PROTOTYPE] = {}),
      key,
      own,
      out,
      exp;
  if (IS_GLOBAL) source = name;
  for (key in source) {
    // contains in native
    own = !IS_FORCED && target && key in target;
    // export native or passed
    out = (own ? target : source)[key];
    // bind timers to global for call from export context
    exp = IS_BIND && own ? ctx(out, global) : IS_PROTO && typeof out == 'function' ? ctx(Function.call, out) : out;
    // extend global
    if (target && !own) redefine(target, key, out);
    // export
    if (exports[key] != out) hide(exports, key, exp);
    if (IS_PROTO && expProto[key] != out) expProto[key] = out;
  }
};
global.core = core;
// type bitmap
$export.F = 1; // forced
$export.G = 2; // global
$export.S = 4; // static
$export.P = 8; // proto
$export.B = 16; // bind
$export.W = 32; // wrap
module.exports = $export;

},{"./$.core":18,"./$.ctx":19,"./$.global":31,"./$.hide":33,"./$.redefine":63}],25:[function(require,module,exports){
'use strict';

var MATCH = require('./$.wks')('match');
module.exports = function (KEY) {
  var re = /./;
  try {
    '/./'[KEY](re);
  } catch (e) {
    try {
      re[MATCH] = false;
      return !'/./'[KEY](re);
    } catch (f) {/* empty */}
  }return true;
};

},{"./$.wks":85}],26:[function(require,module,exports){
"use strict";

module.exports = function (exec) {
  try {
    return !!exec();
  } catch (e) {
    return true;
  }
};

},{}],27:[function(require,module,exports){
'use strict';

var hide = require('./$.hide'),
    redefine = require('./$.redefine'),
    fails = require('./$.fails'),
    defined = require('./$.defined'),
    wks = require('./$.wks');

module.exports = function (KEY, length, exec) {
  var SYMBOL = wks(KEY),
      original = ''[KEY];
  if (fails(function () {
    var O = {};
    O[SYMBOL] = function () {
      return 7;
    };
    return ''[KEY](O) != 7;
  })) {
    redefine(String.prototype, KEY, exec(defined, SYMBOL, original));
    hide(RegExp.prototype, SYMBOL, length == 2
    // 21.2.5.8 RegExp.prototype[@@replace](string, replaceValue)
    // 21.2.5.11 RegExp.prototype[@@split](string, limit)
    ? function (string, arg) {
      return original.call(string, this, arg);
    }
    // 21.2.5.6 RegExp.prototype[@@match](string)
    // 21.2.5.9 RegExp.prototype[@@search](string)
    : function (string) {
      return original.call(string, this);
    });
  }
};

},{"./$.defined":20,"./$.fails":26,"./$.hide":33,"./$.redefine":63,"./$.wks":85}],28:[function(require,module,exports){
'use strict';
// 21.2.5.3 get RegExp.prototype.flags

var anObject = require('./$.an-object');
module.exports = function () {
  var that = anObject(this),
      result = '';
  if (that.global) result += 'g';
  if (that.ignoreCase) result += 'i';
  if (that.multiline) result += 'm';
  if (that.unicode) result += 'u';
  if (that.sticky) result += 'y';
  return result;
};

},{"./$.an-object":6}],29:[function(require,module,exports){
'use strict';

var ctx = require('./$.ctx'),
    call = require('./$.iter-call'),
    isArrayIter = require('./$.is-array-iter'),
    anObject = require('./$.an-object'),
    toLength = require('./$.to-length'),
    getIterFn = require('./core.get-iterator-method');
module.exports = function (iterable, entries, fn, that) {
  var iterFn = getIterFn(iterable),
      f = ctx(fn, that, entries ? 2 : 1),
      index = 0,
      length,
      step,
      iterator;
  if (typeof iterFn != 'function') throw TypeError(iterable + ' is not iterable!');
  // fast case for arrays with default iterator
  if (isArrayIter(iterFn)) for (length = toLength(iterable.length); length > index; index++) {
    entries ? f(anObject(step = iterable[index])[0], step[1]) : f(iterable[index]);
  } else for (iterator = iterFn.call(iterable); !(step = iterator.next()).done;) {
    call(iterator, f, step.value, entries);
  }
};

},{"./$.an-object":6,"./$.ctx":19,"./$.is-array-iter":37,"./$.iter-call":42,"./$.to-length":81,"./core.get-iterator-method":86}],30:[function(require,module,exports){
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

// fallback for IE11 buggy Object.getOwnPropertyNames with iframe and window
var toIObject = require('./$.to-iobject'),
    getNames = require('./$').getNames,
    toString = {}.toString;

var windowNames = (typeof window === 'undefined' ? 'undefined' : _typeof(window)) == 'object' && Object.getOwnPropertyNames ? Object.getOwnPropertyNames(window) : [];

var getWindowNames = function getWindowNames(it) {
  try {
    return getNames(it);
  } catch (e) {
    return windowNames.slice();
  }
};

module.exports.get = function getOwnPropertyNames(it) {
  if (windowNames && toString.call(it) == '[object Window]') return getWindowNames(it);
  return getNames(toIObject(it));
};

},{"./$":48,"./$.to-iobject":80}],31:[function(require,module,exports){
'use strict';

// https://github.com/zloirock/core-js/issues/86#issuecomment-115759028
var global = module.exports = typeof window != 'undefined' && window.Math == Math ? window : typeof self != 'undefined' && self.Math == Math ? self : Function('return this')();
if (typeof __g == 'number') __g = global; // eslint-disable-line no-undef

},{}],32:[function(require,module,exports){
"use strict";

var hasOwnProperty = {}.hasOwnProperty;
module.exports = function (it, key) {
  return hasOwnProperty.call(it, key);
};

},{}],33:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    createDesc = require('./$.property-desc');
module.exports = require('./$.descriptors') ? function (object, key, value) {
  return $.setDesc(object, key, createDesc(1, value));
} : function (object, key, value) {
  object[key] = value;
  return object;
};

},{"./$":48,"./$.descriptors":21,"./$.property-desc":61}],34:[function(require,module,exports){
'use strict';

module.exports = require('./$.global').document && document.documentElement;

},{"./$.global":31}],35:[function(require,module,exports){
"use strict";

// fast apply, http://jsperf.lnkit.com/fast-apply/5
module.exports = function (fn, args, that) {
                  var un = that === undefined;
                  switch (args.length) {
                                    case 0:
                                                      return un ? fn() : fn.call(that);
                                    case 1:
                                                      return un ? fn(args[0]) : fn.call(that, args[0]);
                                    case 2:
                                                      return un ? fn(args[0], args[1]) : fn.call(that, args[0], args[1]);
                                    case 3:
                                                      return un ? fn(args[0], args[1], args[2]) : fn.call(that, args[0], args[1], args[2]);
                                    case 4:
                                                      return un ? fn(args[0], args[1], args[2], args[3]) : fn.call(that, args[0], args[1], args[2], args[3]);
                  }return fn.apply(that, args);
};

},{}],36:[function(require,module,exports){
'use strict';

// fallback for non-array-like ES3 and non-enumerable old V8 strings
var cof = require('./$.cof');
module.exports = Object('z').propertyIsEnumerable(0) ? Object : function (it) {
  return cof(it) == 'String' ? it.split('') : Object(it);
};

},{"./$.cof":13}],37:[function(require,module,exports){
'use strict';

// check on default Array iterator
var Iterators = require('./$.iterators'),
    ITERATOR = require('./$.wks')('iterator'),
    ArrayProto = Array.prototype;

module.exports = function (it) {
  return it !== undefined && (Iterators.Array === it || ArrayProto[ITERATOR] === it);
};

},{"./$.iterators":47,"./$.wks":85}],38:[function(require,module,exports){
'use strict';

// 7.2.2 IsArray(argument)
var cof = require('./$.cof');
module.exports = Array.isArray || function (arg) {
  return cof(arg) == 'Array';
};

},{"./$.cof":13}],39:[function(require,module,exports){
'use strict';

// 20.1.2.3 Number.isInteger(number)
var isObject = require('./$.is-object'),
    floor = Math.floor;
module.exports = function isInteger(it) {
  return !isObject(it) && isFinite(it) && floor(it) === it;
};

},{"./$.is-object":40}],40:[function(require,module,exports){
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

module.exports = function (it) {
  return (typeof it === 'undefined' ? 'undefined' : _typeof(it)) === 'object' ? it !== null : typeof it === 'function';
};

},{}],41:[function(require,module,exports){
'use strict';

// 7.2.8 IsRegExp(argument)
var isObject = require('./$.is-object'),
    cof = require('./$.cof'),
    MATCH = require('./$.wks')('match');
module.exports = function (it) {
  var isRegExp;
  return isObject(it) && ((isRegExp = it[MATCH]) !== undefined ? !!isRegExp : cof(it) == 'RegExp');
};

},{"./$.cof":13,"./$.is-object":40,"./$.wks":85}],42:[function(require,module,exports){
'use strict';

// call something on iterator step with safe closing on error
var anObject = require('./$.an-object');
module.exports = function (iterator, fn, value, entries) {
  try {
    return entries ? fn(anObject(value)[0], value[1]) : fn(value);
    // 7.4.6 IteratorClose(iterator, completion)
  } catch (e) {
    var ret = iterator['return'];
    if (ret !== undefined) anObject(ret.call(iterator));
    throw e;
  }
};

},{"./$.an-object":6}],43:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    descriptor = require('./$.property-desc'),
    setToStringTag = require('./$.set-to-string-tag'),
    IteratorPrototype = {};

// 25.1.2.1.1 %IteratorPrototype%[@@iterator]()
require('./$.hide')(IteratorPrototype, require('./$.wks')('iterator'), function () {
  return this;
});

module.exports = function (Constructor, NAME, next) {
  Constructor.prototype = $.create(IteratorPrototype, { next: descriptor(1, next) });
  setToStringTag(Constructor, NAME + ' Iterator');
};

},{"./$":48,"./$.hide":33,"./$.property-desc":61,"./$.set-to-string-tag":68,"./$.wks":85}],44:[function(require,module,exports){
'use strict';

var LIBRARY = require('./$.library'),
    $export = require('./$.export'),
    redefine = require('./$.redefine'),
    hide = require('./$.hide'),
    has = require('./$.has'),
    Iterators = require('./$.iterators'),
    $iterCreate = require('./$.iter-create'),
    setToStringTag = require('./$.set-to-string-tag'),
    getProto = require('./$').getProto,
    ITERATOR = require('./$.wks')('iterator'),
    BUGGY = !([].keys && 'next' in [].keys()) // Safari has buggy iterators w/o `next`
,
    FF_ITERATOR = '@@iterator',
    KEYS = 'keys',
    VALUES = 'values';

var returnThis = function returnThis() {
  return this;
};

module.exports = function (Base, NAME, Constructor, next, DEFAULT, IS_SET, FORCED) {
  $iterCreate(Constructor, NAME, next);
  var getMethod = function getMethod(kind) {
    if (!BUGGY && kind in proto) return proto[kind];
    switch (kind) {
      case KEYS:
        return function keys() {
          return new Constructor(this, kind);
        };
      case VALUES:
        return function values() {
          return new Constructor(this, kind);
        };
    }return function entries() {
      return new Constructor(this, kind);
    };
  };
  var TAG = NAME + ' Iterator',
      DEF_VALUES = DEFAULT == VALUES,
      VALUES_BUG = false,
      proto = Base.prototype,
      $native = proto[ITERATOR] || proto[FF_ITERATOR] || DEFAULT && proto[DEFAULT],
      $default = $native || getMethod(DEFAULT),
      methods,
      key;
  // Fix native
  if ($native) {
    var IteratorPrototype = getProto($default.call(new Base()));
    // Set @@toStringTag to native iterators
    setToStringTag(IteratorPrototype, TAG, true);
    // FF fix
    if (!LIBRARY && has(proto, FF_ITERATOR)) hide(IteratorPrototype, ITERATOR, returnThis);
    // fix Array#{values, @@iterator}.name in V8 / FF
    if (DEF_VALUES && $native.name !== VALUES) {
      VALUES_BUG = true;
      $default = function values() {
        return $native.call(this);
      };
    }
  }
  // Define iterator
  if ((!LIBRARY || FORCED) && (BUGGY || VALUES_BUG || !proto[ITERATOR])) {
    hide(proto, ITERATOR, $default);
  }
  // Plug for library
  Iterators[NAME] = $default;
  Iterators[TAG] = returnThis;
  if (DEFAULT) {
    methods = {
      values: DEF_VALUES ? $default : getMethod(VALUES),
      keys: IS_SET ? $default : getMethod(KEYS),
      entries: !DEF_VALUES ? $default : getMethod('entries')
    };
    if (FORCED) for (key in methods) {
      if (!(key in proto)) redefine(proto, key, methods[key]);
    } else $export($export.P + $export.F * (BUGGY || VALUES_BUG), NAME, methods);
  }
  return methods;
};

},{"./$":48,"./$.export":24,"./$.has":32,"./$.hide":33,"./$.iter-create":43,"./$.iterators":47,"./$.library":50,"./$.redefine":63,"./$.set-to-string-tag":68,"./$.wks":85}],45:[function(require,module,exports){
'use strict';

var ITERATOR = require('./$.wks')('iterator'),
    SAFE_CLOSING = false;

try {
  var riter = [7][ITERATOR]();
  riter['return'] = function () {
    SAFE_CLOSING = true;
  };
  Array.from(riter, function () {
    throw 2;
  });
} catch (e) {/* empty */}

module.exports = function (exec, skipClosing) {
  if (!skipClosing && !SAFE_CLOSING) return false;
  var safe = false;
  try {
    var arr = [7],
        iter = arr[ITERATOR]();
    iter.next = function () {
      safe = true;
    };
    arr[ITERATOR] = function () {
      return iter;
    };
    exec(arr);
  } catch (e) {/* empty */}
  return safe;
};

},{"./$.wks":85}],46:[function(require,module,exports){
"use strict";

module.exports = function (done, value) {
  return { value: value, done: !!done };
};

},{}],47:[function(require,module,exports){
"use strict";

module.exports = {};

},{}],48:[function(require,module,exports){
"use strict";

var $Object = Object;
module.exports = {
  create: $Object.create,
  getProto: $Object.getPrototypeOf,
  isEnum: {}.propertyIsEnumerable,
  getDesc: $Object.getOwnPropertyDescriptor,
  setDesc: $Object.defineProperty,
  setDescs: $Object.defineProperties,
  getKeys: $Object.keys,
  getNames: $Object.getOwnPropertyNames,
  getSymbols: $Object.getOwnPropertySymbols,
  each: [].forEach
};

},{}],49:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    toIObject = require('./$.to-iobject');
module.exports = function (object, el) {
  var O = toIObject(object),
      keys = $.getKeys(O),
      length = keys.length,
      index = 0,
      key;
  while (length > index) {
    if (O[key = keys[index++]] === el) return key;
  }
};

},{"./$":48,"./$.to-iobject":80}],50:[function(require,module,exports){
"use strict";

module.exports = false;

},{}],51:[function(require,module,exports){
"use strict";

// 20.2.2.14 Math.expm1(x)
module.exports = Math.expm1 || function expm1(x) {
  return (x = +x) == 0 ? x : x > -1e-6 && x < 1e-6 ? x + x * x / 2 : Math.exp(x) - 1;
};

},{}],52:[function(require,module,exports){
"use strict";

// 20.2.2.20 Math.log1p(x)
module.exports = Math.log1p || function log1p(x) {
  return (x = +x) > -1e-8 && x < 1e-8 ? x - x * x / 2 : Math.log(1 + x);
};

},{}],53:[function(require,module,exports){
"use strict";

// 20.2.2.28 Math.sign(x)
module.exports = Math.sign || function sign(x) {
  return (x = +x) == 0 || x != x ? x : x < 0 ? -1 : 1;
};

},{}],54:[function(require,module,exports){
'use strict';

var global = require('./$.global'),
    macrotask = require('./$.task').set,
    Observer = global.MutationObserver || global.WebKitMutationObserver,
    process = global.process,
    Promise = global.Promise,
    isNode = require('./$.cof')(process) == 'process',
    head,
    last,
    notify;

var flush = function flush() {
  var parent, domain, fn;
  if (isNode && (parent = process.domain)) {
    process.domain = null;
    parent.exit();
  }
  while (head) {
    domain = head.domain;
    fn = head.fn;
    if (domain) domain.enter();
    fn(); // <- currently we use it only for Promise - try / catch not required
    if (domain) domain.exit();
    head = head.next;
  }last = undefined;
  if (parent) parent.enter();
};

// Node.js
if (isNode) {
  notify = function notify() {
    process.nextTick(flush);
  };
  // browsers with MutationObserver
} else if (Observer) {
    var toggle = 1,
        node = document.createTextNode('');
    new Observer(flush).observe(node, { characterData: true }); // eslint-disable-line no-new
    notify = function notify() {
      node.data = toggle = -toggle;
    };
    // environments with maybe non-completely correct, but existent Promise
  } else if (Promise && Promise.resolve) {
      notify = function notify() {
        Promise.resolve().then(flush);
      };
      // for other environments - macrotask based on:
      // - setImmediate
      // - MessageChannel
      // - window.postMessag
      // - onreadystatechange
      // - setTimeout
    } else {
        notify = function notify() {
          // strange IE + webpack dev server bug - use .call(global)
          macrotask.call(global, flush);
        };
      }

module.exports = function asap(fn) {
  var task = { fn: fn, next: undefined, domain: isNode && process.domain };
  if (last) last.next = task;
  if (!head) {
    head = task;
    notify();
  }last = task;
};

},{"./$.cof":13,"./$.global":31,"./$.task":77}],55:[function(require,module,exports){
'use strict';

// 19.1.2.1 Object.assign(target, source, ...)
var $ = require('./$'),
    toObject = require('./$.to-object'),
    IObject = require('./$.iobject');

// should work with symbols and should have deterministic property order (V8 bug)
module.exports = require('./$.fails')(function () {
  var a = Object.assign,
      A = {},
      B = {},
      S = Symbol(),
      K = 'abcdefghijklmnopqrst';
  A[S] = 7;
  K.split('').forEach(function (k) {
    B[k] = k;
  });
  return a({}, A)[S] != 7 || Object.keys(a({}, B)).join('') != K;
}) ? function assign(target, source) {
  // eslint-disable-line no-unused-vars
  var T = toObject(target),
      $$ = arguments,
      $$len = $$.length,
      index = 1,
      getKeys = $.getKeys,
      getSymbols = $.getSymbols,
      isEnum = $.isEnum;
  while ($$len > index) {
    var S = IObject($$[index++]),
        keys = getSymbols ? getKeys(S).concat(getSymbols(S)) : getKeys(S),
        length = keys.length,
        j = 0,
        key;
    while (length > j) {
      if (isEnum.call(S, key = keys[j++])) T[key] = S[key];
    }
  }
  return T;
} : Object.assign;

},{"./$":48,"./$.fails":26,"./$.iobject":36,"./$.to-object":82}],56:[function(require,module,exports){
'use strict';

// most Object methods by ES6 should accept primitives
var $export = require('./$.export'),
    core = require('./$.core'),
    fails = require('./$.fails');
module.exports = function (KEY, exec) {
  var fn = (core.Object || {})[KEY] || Object[KEY],
      exp = {};
  exp[KEY] = exec(fn);
  $export($export.S + $export.F * fails(function () {
    fn(1);
  }), 'Object', exp);
};

},{"./$.core":18,"./$.export":24,"./$.fails":26}],57:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    toIObject = require('./$.to-iobject'),
    isEnum = $.isEnum;
module.exports = function (isEntries) {
  return function (it) {
    var O = toIObject(it),
        keys = $.getKeys(O),
        length = keys.length,
        i = 0,
        result = [],
        key;
    while (length > i) {
      if (isEnum.call(O, key = keys[i++])) {
        result.push(isEntries ? [key, O[key]] : O[key]);
      }
    }return result;
  };
};

},{"./$":48,"./$.to-iobject":80}],58:[function(require,module,exports){
'use strict';

// all object keys, includes non-enumerable and symbols
var $ = require('./$'),
    anObject = require('./$.an-object'),
    Reflect = require('./$.global').Reflect;
module.exports = Reflect && Reflect.ownKeys || function ownKeys(it) {
  var keys = $.getNames(anObject(it)),
      getSymbols = $.getSymbols;
  return getSymbols ? keys.concat(getSymbols(it)) : keys;
};

},{"./$":48,"./$.an-object":6,"./$.global":31}],59:[function(require,module,exports){
'use strict';

var path = require('./$.path'),
    invoke = require('./$.invoke'),
    aFunction = require('./$.a-function');
module.exports = function () /* ...pargs */{
  var fn = aFunction(this),
      length = arguments.length,
      pargs = Array(length),
      i = 0,
      _ = path._,
      holder = false;
  while (length > i) {
    if ((pargs[i] = arguments[i++]) === _) holder = true;
  }return function () /* ...args */{
    var that = this,
        $$ = arguments,
        $$len = $$.length,
        j = 0,
        k = 0,
        args;
    if (!holder && !$$len) return invoke(fn, pargs, that);
    args = pargs.slice();
    if (holder) for (; length > j; j++) {
      if (args[j] === _) args[j] = $$[k++];
    }while ($$len > k) {
      args.push($$[k++]);
    }return invoke(fn, args, that);
  };
};

},{"./$.a-function":4,"./$.invoke":35,"./$.path":60}],60:[function(require,module,exports){
'use strict';

module.exports = require('./$.global');

},{"./$.global":31}],61:[function(require,module,exports){
"use strict";

module.exports = function (bitmap, value) {
  return {
    enumerable: !(bitmap & 1),
    configurable: !(bitmap & 2),
    writable: !(bitmap & 4),
    value: value
  };
};

},{}],62:[function(require,module,exports){
'use strict';

var redefine = require('./$.redefine');
module.exports = function (target, src) {
  for (var key in src) {
    redefine(target, key, src[key]);
  }return target;
};

},{"./$.redefine":63}],63:[function(require,module,exports){
'use strict';

// add fake Function#toString
// for correct work wrapped methods / constructors with methods like LoDash isNative
var global = require('./$.global'),
    hide = require('./$.hide'),
    SRC = require('./$.uid')('src'),
    TO_STRING = 'toString',
    $toString = Function[TO_STRING],
    TPL = ('' + $toString).split(TO_STRING);

require('./$.core').inspectSource = function (it) {
  return $toString.call(it);
};

(module.exports = function (O, key, val, safe) {
  if (typeof val == 'function') {
    val.hasOwnProperty(SRC) || hide(val, SRC, O[key] ? '' + O[key] : TPL.join(String(key)));
    val.hasOwnProperty('name') || hide(val, 'name', key);
  }
  if (O === global) {
    O[key] = val;
  } else {
    if (!safe) delete O[key];
    hide(O, key, val);
  }
})(Function.prototype, TO_STRING, function toString() {
  return typeof this == 'function' && this[SRC] || $toString.call(this);
});

},{"./$.core":18,"./$.global":31,"./$.hide":33,"./$.uid":84}],64:[function(require,module,exports){
"use strict";

module.exports = function (regExp, replace) {
  var replacer = replace === Object(replace) ? function (part) {
    return replace[part];
  } : replace;
  return function (it) {
    return String(it).replace(regExp, replacer);
  };
};

},{}],65:[function(require,module,exports){
"use strict";

// 7.2.9 SameValue(x, y)
module.exports = Object.is || function is(x, y) {
  return x === y ? x !== 0 || 1 / x === 1 / y : x != x && y != y;
};

},{}],66:[function(require,module,exports){
'use strict';

// Works with __proto__ only. Old v8 can't work with null proto objects.
/* eslint-disable no-proto */
var getDesc = require('./$').getDesc,
    isObject = require('./$.is-object'),
    anObject = require('./$.an-object');
var check = function check(O, proto) {
  anObject(O);
  if (!isObject(proto) && proto !== null) throw TypeError(proto + ": can't set as prototype!");
};
module.exports = {
  set: Object.setPrototypeOf || ('__proto__' in {} ? // eslint-disable-line
  function (test, buggy, set) {
    try {
      set = require('./$.ctx')(Function.call, getDesc(Object.prototype, '__proto__').set, 2);
      set(test, []);
      buggy = !(test instanceof Array);
    } catch (e) {
      buggy = true;
    }
    return function setPrototypeOf(O, proto) {
      check(O, proto);
      if (buggy) O.__proto__ = proto;else set(O, proto);
      return O;
    };
  }({}, false) : undefined),
  check: check
};

},{"./$":48,"./$.an-object":6,"./$.ctx":19,"./$.is-object":40}],67:[function(require,module,exports){
'use strict';

var global = require('./$.global'),
    $ = require('./$'),
    DESCRIPTORS = require('./$.descriptors'),
    SPECIES = require('./$.wks')('species');

module.exports = function (KEY) {
  var C = global[KEY];
  if (DESCRIPTORS && C && !C[SPECIES]) $.setDesc(C, SPECIES, {
    configurable: true,
    get: function get() {
      return this;
    }
  });
};

},{"./$":48,"./$.descriptors":21,"./$.global":31,"./$.wks":85}],68:[function(require,module,exports){
'use strict';

var def = require('./$').setDesc,
    has = require('./$.has'),
    TAG = require('./$.wks')('toStringTag');

module.exports = function (it, tag, stat) {
  if (it && !has(it = stat ? it : it.prototype, TAG)) def(it, TAG, { configurable: true, value: tag });
};

},{"./$":48,"./$.has":32,"./$.wks":85}],69:[function(require,module,exports){
'use strict';

var global = require('./$.global'),
    SHARED = '__core-js_shared__',
    store = global[SHARED] || (global[SHARED] = {});
module.exports = function (key) {
  return store[key] || (store[key] = {});
};

},{"./$.global":31}],70:[function(require,module,exports){
'use strict';

// 7.3.20 SpeciesConstructor(O, defaultConstructor)
var anObject = require('./$.an-object'),
    aFunction = require('./$.a-function'),
    SPECIES = require('./$.wks')('species');
module.exports = function (O, D) {
  var C = anObject(O).constructor,
      S;
  return C === undefined || (S = anObject(C)[SPECIES]) == undefined ? D : aFunction(S);
};

},{"./$.a-function":4,"./$.an-object":6,"./$.wks":85}],71:[function(require,module,exports){
"use strict";

module.exports = function (it, Constructor, name) {
  if (!(it instanceof Constructor)) throw TypeError(name + ": use the 'new' operator!");
  return it;
};

},{}],72:[function(require,module,exports){
'use strict';

var toInteger = require('./$.to-integer'),
    defined = require('./$.defined');
// true  -> String#at
// false -> String#codePointAt
module.exports = function (TO_STRING) {
  return function (that, pos) {
    var s = String(defined(that)),
        i = toInteger(pos),
        l = s.length,
        a,
        b;
    if (i < 0 || i >= l) return TO_STRING ? '' : undefined;
    a = s.charCodeAt(i);
    return a < 0xd800 || a > 0xdbff || i + 1 === l || (b = s.charCodeAt(i + 1)) < 0xdc00 || b > 0xdfff ? TO_STRING ? s.charAt(i) : a : TO_STRING ? s.slice(i, i + 2) : (a - 0xd800 << 10) + (b - 0xdc00) + 0x10000;
  };
};

},{"./$.defined":20,"./$.to-integer":79}],73:[function(require,module,exports){
'use strict';

// helper for String#{startsWith, endsWith, includes}
var isRegExp = require('./$.is-regexp'),
    defined = require('./$.defined');

module.exports = function (that, searchString, NAME) {
  if (isRegExp(searchString)) throw TypeError('String#' + NAME + " doesn't accept regex!");
  return String(defined(that));
};

},{"./$.defined":20,"./$.is-regexp":41}],74:[function(require,module,exports){
'use strict';

// https://github.com/ljharb/proposal-string-pad-left-right
var toLength = require('./$.to-length'),
    repeat = require('./$.string-repeat'),
    defined = require('./$.defined');

module.exports = function (that, maxLength, fillString, left) {
  var S = String(defined(that)),
      stringLength = S.length,
      fillStr = fillString === undefined ? ' ' : String(fillString),
      intMaxLength = toLength(maxLength);
  if (intMaxLength <= stringLength) return S;
  if (fillStr == '') fillStr = ' ';
  var fillLen = intMaxLength - stringLength,
      stringFiller = repeat.call(fillStr, Math.ceil(fillLen / fillStr.length));
  if (stringFiller.length > fillLen) stringFiller = stringFiller.slice(0, fillLen);
  return left ? stringFiller + S : S + stringFiller;
};

},{"./$.defined":20,"./$.string-repeat":75,"./$.to-length":81}],75:[function(require,module,exports){
'use strict';

var toInteger = require('./$.to-integer'),
    defined = require('./$.defined');

module.exports = function repeat(count) {
  var str = String(defined(this)),
      res = '',
      n = toInteger(count);
  if (n < 0 || n == Infinity) throw RangeError("Count can't be negative");
  for (; n > 0; (n >>>= 1) && (str += str)) {
    if (n & 1) res += str;
  }return res;
};

},{"./$.defined":20,"./$.to-integer":79}],76:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    defined = require('./$.defined'),
    fails = require('./$.fails'),
    spaces = '\t\n\u000b\f\r   ᠎    ' + '         　\u2028\u2029﻿',
    space = '[' + spaces + ']',
    non = '​',
    ltrim = RegExp('^' + space + space + '*'),
    rtrim = RegExp(space + space + '*$');

var exporter = function exporter(KEY, exec) {
  var exp = {};
  exp[KEY] = exec(trim);
  $export($export.P + $export.F * fails(function () {
    return !!spaces[KEY]() || non[KEY]() != non;
  }), 'String', exp);
};

// 1 -> String#trimLeft
// 2 -> String#trimRight
// 3 -> String#trim
var trim = exporter.trim = function (string, TYPE) {
  string = String(defined(string));
  if (TYPE & 1) string = string.replace(ltrim, '');
  if (TYPE & 2) string = string.replace(rtrim, '');
  return string;
};

module.exports = exporter;

},{"./$.defined":20,"./$.export":24,"./$.fails":26}],77:[function(require,module,exports){
'use strict';

var ctx = require('./$.ctx'),
    invoke = require('./$.invoke'),
    html = require('./$.html'),
    cel = require('./$.dom-create'),
    global = require('./$.global'),
    process = global.process,
    setTask = global.setImmediate,
    clearTask = global.clearImmediate,
    MessageChannel = global.MessageChannel,
    counter = 0,
    queue = {},
    ONREADYSTATECHANGE = 'onreadystatechange',
    defer,
    channel,
    port;
var run = function run() {
  var id = +this;
  if (queue.hasOwnProperty(id)) {
    var fn = queue[id];
    delete queue[id];
    fn();
  }
};
var listner = function listner(event) {
  run.call(event.data);
};
// Node.js 0.9+ & IE10+ has setImmediate, otherwise:
if (!setTask || !clearTask) {
  setTask = function setImmediate(fn) {
    var args = [],
        i = 1;
    while (arguments.length > i) {
      args.push(arguments[i++]);
    }queue[++counter] = function () {
      invoke(typeof fn == 'function' ? fn : Function(fn), args);
    };
    defer(counter);
    return counter;
  };
  clearTask = function clearImmediate(id) {
    delete queue[id];
  };
  // Node.js 0.8-
  if (require('./$.cof')(process) == 'process') {
    defer = function defer(id) {
      process.nextTick(ctx(run, id, 1));
    };
    // Browsers with MessageChannel, includes WebWorkers
  } else if (MessageChannel) {
      channel = new MessageChannel();
      port = channel.port2;
      channel.port1.onmessage = listner;
      defer = ctx(port.postMessage, port, 1);
      // Browsers with postMessage, skip WebWorkers
      // IE8 has postMessage, but it's sync & typeof its postMessage is 'object'
    } else if (global.addEventListener && typeof postMessage == 'function' && !global.importScripts) {
        defer = function defer(id) {
          global.postMessage(id + '', '*');
        };
        global.addEventListener('message', listner, false);
        // IE8-
      } else if (ONREADYSTATECHANGE in cel('script')) {
          defer = function defer(id) {
            html.appendChild(cel('script'))[ONREADYSTATECHANGE] = function () {
              html.removeChild(this);
              run.call(id);
            };
          };
          // Rest old browsers
        } else {
            defer = function defer(id) {
              setTimeout(ctx(run, id, 1), 0);
            };
          }
}
module.exports = {
  set: setTask,
  clear: clearTask
};

},{"./$.cof":13,"./$.ctx":19,"./$.dom-create":22,"./$.global":31,"./$.html":34,"./$.invoke":35}],78:[function(require,module,exports){
'use strict';

var toInteger = require('./$.to-integer'),
    max = Math.max,
    min = Math.min;
module.exports = function (index, length) {
  index = toInteger(index);
  return index < 0 ? max(index + length, 0) : min(index, length);
};

},{"./$.to-integer":79}],79:[function(require,module,exports){
"use strict";

// 7.1.4 ToInteger
var ceil = Math.ceil,
    floor = Math.floor;
module.exports = function (it) {
  return isNaN(it = +it) ? 0 : (it > 0 ? floor : ceil)(it);
};

},{}],80:[function(require,module,exports){
'use strict';

// to indexed object, toObject with fallback for non-array-like ES3 strings
var IObject = require('./$.iobject'),
    defined = require('./$.defined');
module.exports = function (it) {
  return IObject(defined(it));
};

},{"./$.defined":20,"./$.iobject":36}],81:[function(require,module,exports){
'use strict';

// 7.1.15 ToLength
var toInteger = require('./$.to-integer'),
    min = Math.min;
module.exports = function (it) {
  return it > 0 ? min(toInteger(it), 0x1fffffffffffff) : 0; // pow(2, 53) - 1 == 9007199254740991
};

},{"./$.to-integer":79}],82:[function(require,module,exports){
'use strict';

// 7.1.13 ToObject(argument)
var defined = require('./$.defined');
module.exports = function (it) {
  return Object(defined(it));
};

},{"./$.defined":20}],83:[function(require,module,exports){
'use strict';

// 7.1.1 ToPrimitive(input [, PreferredType])
var isObject = require('./$.is-object');
// instead of the ES6 spec version, we didn't implement @@toPrimitive case
// and the second argument - flag - preferred type is a string
module.exports = function (it, S) {
  if (!isObject(it)) return it;
  var fn, val;
  if (S && typeof (fn = it.toString) == 'function' && !isObject(val = fn.call(it))) return val;
  if (typeof (fn = it.valueOf) == 'function' && !isObject(val = fn.call(it))) return val;
  if (!S && typeof (fn = it.toString) == 'function' && !isObject(val = fn.call(it))) return val;
  throw TypeError("Can't convert object to primitive value");
};

},{"./$.is-object":40}],84:[function(require,module,exports){
'use strict';

var id = 0,
    px = Math.random();
module.exports = function (key) {
  return 'Symbol('.concat(key === undefined ? '' : key, ')_', (++id + px).toString(36));
};

},{}],85:[function(require,module,exports){
'use strict';

var store = require('./$.shared')('wks'),
    uid = require('./$.uid'),
    _Symbol = require('./$.global').Symbol;
module.exports = function (name) {
  return store[name] || (store[name] = _Symbol && _Symbol[name] || (_Symbol || uid)('Symbol.' + name));
};

},{"./$.global":31,"./$.shared":69,"./$.uid":84}],86:[function(require,module,exports){
'use strict';

var classof = require('./$.classof'),
    ITERATOR = require('./$.wks')('iterator'),
    Iterators = require('./$.iterators');
module.exports = require('./$.core').getIteratorMethod = function (it) {
  if (it != undefined) return it[ITERATOR] || it['@@iterator'] || Iterators[classof(it)];
};

},{"./$.classof":12,"./$.core":18,"./$.iterators":47,"./$.wks":85}],87:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    $export = require('./$.export'),
    DESCRIPTORS = require('./$.descriptors'),
    createDesc = require('./$.property-desc'),
    html = require('./$.html'),
    cel = require('./$.dom-create'),
    has = require('./$.has'),
    cof = require('./$.cof'),
    invoke = require('./$.invoke'),
    fails = require('./$.fails'),
    anObject = require('./$.an-object'),
    aFunction = require('./$.a-function'),
    isObject = require('./$.is-object'),
    toObject = require('./$.to-object'),
    toIObject = require('./$.to-iobject'),
    toInteger = require('./$.to-integer'),
    toIndex = require('./$.to-index'),
    toLength = require('./$.to-length'),
    IObject = require('./$.iobject'),
    IE_PROTO = require('./$.uid')('__proto__'),
    createArrayMethod = require('./$.array-methods'),
    arrayIndexOf = require('./$.array-includes')(false),
    ObjectProto = Object.prototype,
    ArrayProto = Array.prototype,
    arraySlice = ArrayProto.slice,
    arrayJoin = ArrayProto.join,
    defineProperty = $.setDesc,
    getOwnDescriptor = $.getDesc,
    defineProperties = $.setDescs,
    factories = {},
    IE8_DOM_DEFINE;

if (!DESCRIPTORS) {
  IE8_DOM_DEFINE = !fails(function () {
    return defineProperty(cel('div'), 'a', { get: function get() {
        return 7;
      } }).a != 7;
  });
  $.setDesc = function (O, P, Attributes) {
    if (IE8_DOM_DEFINE) try {
      return defineProperty(O, P, Attributes);
    } catch (e) {/* empty */}
    if ('get' in Attributes || 'set' in Attributes) throw TypeError('Accessors not supported!');
    if ('value' in Attributes) anObject(O)[P] = Attributes.value;
    return O;
  };
  $.getDesc = function (O, P) {
    if (IE8_DOM_DEFINE) try {
      return getOwnDescriptor(O, P);
    } catch (e) {/* empty */}
    if (has(O, P)) return createDesc(!ObjectProto.propertyIsEnumerable.call(O, P), O[P]);
  };
  $.setDescs = defineProperties = function defineProperties(O, Properties) {
    anObject(O);
    var keys = $.getKeys(Properties),
        length = keys.length,
        i = 0,
        P;
    while (length > i) {
      $.setDesc(O, P = keys[i++], Properties[P]);
    }return O;
  };
}
$export($export.S + $export.F * !DESCRIPTORS, 'Object', {
  // 19.1.2.6 / 15.2.3.3 Object.getOwnPropertyDescriptor(O, P)
  getOwnPropertyDescriptor: $.getDesc,
  // 19.1.2.4 / 15.2.3.6 Object.defineProperty(O, P, Attributes)
  defineProperty: $.setDesc,
  // 19.1.2.3 / 15.2.3.7 Object.defineProperties(O, Properties)
  defineProperties: defineProperties
});

// IE 8- don't enum bug keys
var keys1 = ('constructor,hasOwnProperty,isPrototypeOf,propertyIsEnumerable,' + 'toLocaleString,toString,valueOf').split(',')
// Additional keys for getOwnPropertyNames
,
    keys2 = keys1.concat('length', 'prototype'),
    keysLen1 = keys1.length;

// Create object with `null` prototype: use iframe Object with cleared prototype
var _createDict = function createDict() {
  // Thrash, waste and sodomy: IE GC bug
  var iframe = cel('iframe'),
      i = keysLen1,
      gt = '>',
      iframeDocument;
  iframe.style.display = 'none';
  html.appendChild(iframe);
  iframe.src = 'javascript:'; // eslint-disable-line no-script-url
  // createDict = iframe.contentWindow.Object;
  // html.removeChild(iframe);
  iframeDocument = iframe.contentWindow.document;
  iframeDocument.open();
  iframeDocument.write('<script>document.F=Object</script' + gt);
  iframeDocument.close();
  _createDict = iframeDocument.F;
  while (i--) {
    delete _createDict.prototype[keys1[i]];
  }return _createDict();
};
var createGetKeys = function createGetKeys(names, length) {
  return function (object) {
    var O = toIObject(object),
        i = 0,
        result = [],
        key;
    for (key in O) {
      if (key != IE_PROTO) has(O, key) && result.push(key);
    } // Don't enum bug & hidden keys
    while (length > i) {
      if (has(O, key = names[i++])) {
        ~arrayIndexOf(result, key) || result.push(key);
      }
    }return result;
  };
};
var Empty = function Empty() {};
$export($export.S, 'Object', {
  // 19.1.2.9 / 15.2.3.2 Object.getPrototypeOf(O)
  getPrototypeOf: $.getProto = $.getProto || function (O) {
    O = toObject(O);
    if (has(O, IE_PROTO)) return O[IE_PROTO];
    if (typeof O.constructor == 'function' && O instanceof O.constructor) {
      return O.constructor.prototype;
    }return O instanceof Object ? ObjectProto : null;
  },
  // 19.1.2.7 / 15.2.3.4 Object.getOwnPropertyNames(O)
  getOwnPropertyNames: $.getNames = $.getNames || createGetKeys(keys2, keys2.length, true),
  // 19.1.2.2 / 15.2.3.5 Object.create(O [, Properties])
  create: $.create = $.create || function (O, /*?*/Properties) {
    var result;
    if (O !== null) {
      Empty.prototype = anObject(O);
      result = new Empty();
      Empty.prototype = null;
      // add "__proto__" for Object.getPrototypeOf shim
      result[IE_PROTO] = O;
    } else result = _createDict();
    return Properties === undefined ? result : defineProperties(result, Properties);
  },
  // 19.1.2.14 / 15.2.3.14 Object.keys(O)
  keys: $.getKeys = $.getKeys || createGetKeys(keys1, keysLen1, false)
});

var construct = function construct(F, len, args) {
  if (!(len in factories)) {
    for (var n = [], i = 0; i < len; i++) {
      n[i] = 'a[' + i + ']';
    }factories[len] = Function('F,a', 'return new F(' + n.join(',') + ')');
  }
  return factories[len](F, args);
};

// 19.2.3.2 / 15.3.4.5 Function.prototype.bind(thisArg, args...)
$export($export.P, 'Function', {
  bind: function bind(that /*, args... */) {
    var fn = aFunction(this),
        partArgs = arraySlice.call(arguments, 1);
    var bound = function bound() /* args... */{
      var args = partArgs.concat(arraySlice.call(arguments));
      return this instanceof bound ? construct(fn, args.length, args) : invoke(fn, args, that);
    };
    if (isObject(fn.prototype)) bound.prototype = fn.prototype;
    return bound;
  }
});

// fallback for not array-like ES3 strings and DOM objects
$export($export.P + $export.F * fails(function () {
  if (html) arraySlice.call(html);
}), 'Array', {
  slice: function slice(begin, end) {
    var len = toLength(this.length),
        klass = cof(this);
    end = end === undefined ? len : end;
    if (klass == 'Array') return arraySlice.call(this, begin, end);
    var start = toIndex(begin, len),
        upTo = toIndex(end, len),
        size = toLength(upTo - start),
        cloned = Array(size),
        i = 0;
    for (; i < size; i++) {
      cloned[i] = klass == 'String' ? this.charAt(start + i) : this[start + i];
    }return cloned;
  }
});
$export($export.P + $export.F * (IObject != Object), 'Array', {
  join: function join(separator) {
    return arrayJoin.call(IObject(this), separator === undefined ? ',' : separator);
  }
});

// 22.1.2.2 / 15.4.3.2 Array.isArray(arg)
$export($export.S, 'Array', { isArray: require('./$.is-array') });

var createArrayReduce = function createArrayReduce(isRight) {
  return function (callbackfn, memo) {
    aFunction(callbackfn);
    var O = IObject(this),
        length = toLength(O.length),
        index = isRight ? length - 1 : 0,
        i = isRight ? -1 : 1;
    if (arguments.length < 2) for (;;) {
      if (index in O) {
        memo = O[index];
        index += i;
        break;
      }
      index += i;
      if (isRight ? index < 0 : length <= index) {
        throw TypeError('Reduce of empty array with no initial value');
      }
    }
    for (; isRight ? index >= 0 : length > index; index += i) {
      if (index in O) {
        memo = callbackfn(memo, O[index], index, this);
      }
    }return memo;
  };
};

var methodize = function methodize($fn) {
  return function (arg1 /*, arg2 = undefined */) {
    return $fn(this, arg1, arguments[1]);
  };
};

$export($export.P, 'Array', {
  // 22.1.3.10 / 15.4.4.18 Array.prototype.forEach(callbackfn [, thisArg])
  forEach: $.each = $.each || methodize(createArrayMethod(0)),
  // 22.1.3.15 / 15.4.4.19 Array.prototype.map(callbackfn [, thisArg])
  map: methodize(createArrayMethod(1)),
  // 22.1.3.7 / 15.4.4.20 Array.prototype.filter(callbackfn [, thisArg])
  filter: methodize(createArrayMethod(2)),
  // 22.1.3.23 / 15.4.4.17 Array.prototype.some(callbackfn [, thisArg])
  some: methodize(createArrayMethod(3)),
  // 22.1.3.5 / 15.4.4.16 Array.prototype.every(callbackfn [, thisArg])
  every: methodize(createArrayMethod(4)),
  // 22.1.3.18 / 15.4.4.21 Array.prototype.reduce(callbackfn [, initialValue])
  reduce: createArrayReduce(false),
  // 22.1.3.19 / 15.4.4.22 Array.prototype.reduceRight(callbackfn [, initialValue])
  reduceRight: createArrayReduce(true),
  // 22.1.3.11 / 15.4.4.14 Array.prototype.indexOf(searchElement [, fromIndex])
  indexOf: methodize(arrayIndexOf),
  // 22.1.3.14 / 15.4.4.15 Array.prototype.lastIndexOf(searchElement [, fromIndex])
  lastIndexOf: function lastIndexOf(el, fromIndex /* = @[*-1] */) {
    var O = toIObject(this),
        length = toLength(O.length),
        index = length - 1;
    if (arguments.length > 1) index = Math.min(index, toInteger(fromIndex));
    if (index < 0) index = toLength(length + index);
    for (; index >= 0; index--) {
      if (index in O) if (O[index] === el) return index;
    }return -1;
  }
});

// 20.3.3.1 / 15.9.4.4 Date.now()
$export($export.S, 'Date', { now: function now() {
    return +new Date();
  } });

var lz = function lz(num) {
  return num > 9 ? num : '0' + num;
};

// 20.3.4.36 / 15.9.5.43 Date.prototype.toISOString()
// PhantomJS / old WebKit has a broken implementations
$export($export.P + $export.F * (fails(function () {
  return new Date(-5e13 - 1).toISOString() != '0385-07-25T07:06:39.999Z';
}) || !fails(function () {
  new Date(NaN).toISOString();
})), 'Date', {
  toISOString: function toISOString() {
    if (!isFinite(this)) throw RangeError('Invalid time value');
    var d = this,
        y = d.getUTCFullYear(),
        m = d.getUTCMilliseconds(),
        s = y < 0 ? '-' : y > 9999 ? '+' : '';
    return s + ('00000' + Math.abs(y)).slice(s ? -6 : -4) + '-' + lz(d.getUTCMonth() + 1) + '-' + lz(d.getUTCDate()) + 'T' + lz(d.getUTCHours()) + ':' + lz(d.getUTCMinutes()) + ':' + lz(d.getUTCSeconds()) + '.' + (m > 99 ? m : '0' + lz(m)) + 'Z';
  }
});

},{"./$":48,"./$.a-function":4,"./$.an-object":6,"./$.array-includes":9,"./$.array-methods":10,"./$.cof":13,"./$.descriptors":21,"./$.dom-create":22,"./$.export":24,"./$.fails":26,"./$.has":32,"./$.html":34,"./$.invoke":35,"./$.iobject":36,"./$.is-array":38,"./$.is-object":40,"./$.property-desc":61,"./$.to-index":78,"./$.to-integer":79,"./$.to-iobject":80,"./$.to-length":81,"./$.to-object":82,"./$.uid":84}],88:[function(require,module,exports){
'use strict';

// 22.1.3.3 Array.prototype.copyWithin(target, start, end = this.length)
var $export = require('./$.export');

$export($export.P, 'Array', { copyWithin: require('./$.array-copy-within') });

require('./$.add-to-unscopables')('copyWithin');

},{"./$.add-to-unscopables":5,"./$.array-copy-within":7,"./$.export":24}],89:[function(require,module,exports){
'use strict';

// 22.1.3.6 Array.prototype.fill(value, start = 0, end = this.length)
var $export = require('./$.export');

$export($export.P, 'Array', { fill: require('./$.array-fill') });

require('./$.add-to-unscopables')('fill');

},{"./$.add-to-unscopables":5,"./$.array-fill":8,"./$.export":24}],90:[function(require,module,exports){
'use strict';
// 22.1.3.9 Array.prototype.findIndex(predicate, thisArg = undefined)

var $export = require('./$.export'),
    $find = require('./$.array-methods')(6),
    KEY = 'findIndex',
    forced = true;
// Shouldn't skip holes
if (KEY in []) Array(1)[KEY](function () {
  forced = false;
});
$export($export.P + $export.F * forced, 'Array', {
  findIndex: function findIndex(callbackfn /*, that = undefined */) {
    return $find(this, callbackfn, arguments.length > 1 ? arguments[1] : undefined);
  }
});
require('./$.add-to-unscopables')(KEY);

},{"./$.add-to-unscopables":5,"./$.array-methods":10,"./$.export":24}],91:[function(require,module,exports){
'use strict';
// 22.1.3.8 Array.prototype.find(predicate, thisArg = undefined)

var $export = require('./$.export'),
    $find = require('./$.array-methods')(5),
    KEY = 'find',
    forced = true;
// Shouldn't skip holes
if (KEY in []) Array(1)[KEY](function () {
  forced = false;
});
$export($export.P + $export.F * forced, 'Array', {
  find: function find(callbackfn /*, that = undefined */) {
    return $find(this, callbackfn, arguments.length > 1 ? arguments[1] : undefined);
  }
});
require('./$.add-to-unscopables')(KEY);

},{"./$.add-to-unscopables":5,"./$.array-methods":10,"./$.export":24}],92:[function(require,module,exports){
'use strict';

var ctx = require('./$.ctx'),
    $export = require('./$.export'),
    toObject = require('./$.to-object'),
    call = require('./$.iter-call'),
    isArrayIter = require('./$.is-array-iter'),
    toLength = require('./$.to-length'),
    getIterFn = require('./core.get-iterator-method');
$export($export.S + $export.F * !require('./$.iter-detect')(function (iter) {
  Array.from(iter);
}), 'Array', {
  // 22.1.2.1 Array.from(arrayLike, mapfn = undefined, thisArg = undefined)
  from: function from(arrayLike /*, mapfn = undefined, thisArg = undefined*/) {
    var O = toObject(arrayLike),
        C = typeof this == 'function' ? this : Array,
        $$ = arguments,
        $$len = $$.length,
        mapfn = $$len > 1 ? $$[1] : undefined,
        mapping = mapfn !== undefined,
        index = 0,
        iterFn = getIterFn(O),
        length,
        result,
        step,
        iterator;
    if (mapping) mapfn = ctx(mapfn, $$len > 2 ? $$[2] : undefined, 2);
    // if object isn't iterable or it's array with default iterator - use simple case
    if (iterFn != undefined && !(C == Array && isArrayIter(iterFn))) {
      for (iterator = iterFn.call(O), result = new C(); !(step = iterator.next()).done; index++) {
        result[index] = mapping ? call(iterator, mapfn, [step.value, index], true) : step.value;
      }
    } else {
      length = toLength(O.length);
      for (result = new C(length); length > index; index++) {
        result[index] = mapping ? mapfn(O[index], index) : O[index];
      }
    }
    result.length = index;
    return result;
  }
});

},{"./$.ctx":19,"./$.export":24,"./$.is-array-iter":37,"./$.iter-call":42,"./$.iter-detect":45,"./$.to-length":81,"./$.to-object":82,"./core.get-iterator-method":86}],93:[function(require,module,exports){
'use strict';

var addToUnscopables = require('./$.add-to-unscopables'),
    step = require('./$.iter-step'),
    Iterators = require('./$.iterators'),
    toIObject = require('./$.to-iobject');

// 22.1.3.4 Array.prototype.entries()
// 22.1.3.13 Array.prototype.keys()
// 22.1.3.29 Array.prototype.values()
// 22.1.3.30 Array.prototype[@@iterator]()
module.exports = require('./$.iter-define')(Array, 'Array', function (iterated, kind) {
  this._t = toIObject(iterated); // target
  this._i = 0; // next index
  this._k = kind; // kind
  // 22.1.5.2.1 %ArrayIteratorPrototype%.next()
}, function () {
  var O = this._t,
      kind = this._k,
      index = this._i++;
  if (!O || index >= O.length) {
    this._t = undefined;
    return step(1);
  }
  if (kind == 'keys') return step(0, index);
  if (kind == 'values') return step(0, O[index]);
  return step(0, [index, O[index]]);
}, 'values');

// argumentsList[@@iterator] is %ArrayProto_values% (9.4.4.6, 9.4.4.7)
Iterators.Arguments = Iterators.Array;

addToUnscopables('keys');
addToUnscopables('values');
addToUnscopables('entries');

},{"./$.add-to-unscopables":5,"./$.iter-define":44,"./$.iter-step":46,"./$.iterators":47,"./$.to-iobject":80}],94:[function(require,module,exports){
'use strict';

var $export = require('./$.export');

// WebKit Array.of isn't generic
$export($export.S + $export.F * require('./$.fails')(function () {
  function F() {}
  return !(Array.of.call(F) instanceof F);
}), 'Array', {
  // 22.1.2.3 Array.of( ...items)
  of: function of() /* ...args */{
    var index = 0,
        $$ = arguments,
        $$len = $$.length,
        result = new (typeof this == 'function' ? this : Array)($$len);
    while ($$len > index) {
      result[index] = $$[index++];
    }result.length = $$len;
    return result;
  }
});

},{"./$.export":24,"./$.fails":26}],95:[function(require,module,exports){
'use strict';

require('./$.set-species')('Array');

},{"./$.set-species":67}],96:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    isObject = require('./$.is-object'),
    HAS_INSTANCE = require('./$.wks')('hasInstance'),
    FunctionProto = Function.prototype;
// 19.2.3.6 Function.prototype[@@hasInstance](V)
if (!(HAS_INSTANCE in FunctionProto)) $.setDesc(FunctionProto, HAS_INSTANCE, { value: function value(O) {
    if (typeof this != 'function' || !isObject(O)) return false;
    if (!isObject(this.prototype)) return O instanceof this;
    // for environment w/o native `@@hasInstance` logic enough `instanceof`, but add this:
    while (O = $.getProto(O)) {
      if (this.prototype === O) return true;
    }return false;
  } });

},{"./$":48,"./$.is-object":40,"./$.wks":85}],97:[function(require,module,exports){
'use strict';

var setDesc = require('./$').setDesc,
    createDesc = require('./$.property-desc'),
    has = require('./$.has'),
    FProto = Function.prototype,
    nameRE = /^\s*function ([^ (]*)/,
    NAME = 'name';
// 19.2.4.2 name
NAME in FProto || require('./$.descriptors') && setDesc(FProto, NAME, {
  configurable: true,
  get: function get() {
    var match = ('' + this).match(nameRE),
        name = match ? match[1] : '';
    has(this, NAME) || setDesc(this, NAME, createDesc(5, name));
    return name;
  }
});

},{"./$":48,"./$.descriptors":21,"./$.has":32,"./$.property-desc":61}],98:[function(require,module,exports){
'use strict';

var strong = require('./$.collection-strong');

// 23.1 Map Objects
require('./$.collection')('Map', function (get) {
  return function Map() {
    return get(this, arguments.length > 0 ? arguments[0] : undefined);
  };
}, {
  // 23.1.3.6 Map.prototype.get(key)
  get: function get(key) {
    var entry = strong.getEntry(this, key);
    return entry && entry.v;
  },
  // 23.1.3.9 Map.prototype.set(key, value)
  set: function set(key, value) {
    return strong.def(this, key === 0 ? 0 : key, value);
  }
}, strong, true);

},{"./$.collection":17,"./$.collection-strong":14}],99:[function(require,module,exports){
'use strict';

// 20.2.2.3 Math.acosh(x)
var $export = require('./$.export'),
    log1p = require('./$.math-log1p'),
    sqrt = Math.sqrt,
    $acosh = Math.acosh;

// V8 bug https://code.google.com/p/v8/issues/detail?id=3509
$export($export.S + $export.F * !($acosh && Math.floor($acosh(Number.MAX_VALUE)) == 710), 'Math', {
  acosh: function acosh(x) {
    return (x = +x) < 1 ? NaN : x > 94906265.62425156 ? Math.log(x) + Math.LN2 : log1p(x - 1 + sqrt(x - 1) * sqrt(x + 1));
  }
});

},{"./$.export":24,"./$.math-log1p":52}],100:[function(require,module,exports){
'use strict';

// 20.2.2.5 Math.asinh(x)
var $export = require('./$.export');

function asinh(x) {
  return !isFinite(x = +x) || x == 0 ? x : x < 0 ? -asinh(-x) : Math.log(x + Math.sqrt(x * x + 1));
}

$export($export.S, 'Math', { asinh: asinh });

},{"./$.export":24}],101:[function(require,module,exports){
'use strict';

// 20.2.2.7 Math.atanh(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  atanh: function atanh(x) {
    return (x = +x) == 0 ? x : Math.log((1 + x) / (1 - x)) / 2;
  }
});

},{"./$.export":24}],102:[function(require,module,exports){
'use strict';

// 20.2.2.9 Math.cbrt(x)
var $export = require('./$.export'),
    sign = require('./$.math-sign');

$export($export.S, 'Math', {
  cbrt: function cbrt(x) {
    return sign(x = +x) * Math.pow(Math.abs(x), 1 / 3);
  }
});

},{"./$.export":24,"./$.math-sign":53}],103:[function(require,module,exports){
'use strict';

// 20.2.2.11 Math.clz32(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  clz32: function clz32(x) {
    return (x >>>= 0) ? 31 - Math.floor(Math.log(x + 0.5) * Math.LOG2E) : 32;
  }
});

},{"./$.export":24}],104:[function(require,module,exports){
'use strict';

// 20.2.2.12 Math.cosh(x)
var $export = require('./$.export'),
    exp = Math.exp;

$export($export.S, 'Math', {
  cosh: function cosh(x) {
    return (exp(x = +x) + exp(-x)) / 2;
  }
});

},{"./$.export":24}],105:[function(require,module,exports){
'use strict';

// 20.2.2.14 Math.expm1(x)
var $export = require('./$.export');

$export($export.S, 'Math', { expm1: require('./$.math-expm1') });

},{"./$.export":24,"./$.math-expm1":51}],106:[function(require,module,exports){
'use strict';

// 20.2.2.16 Math.fround(x)
var $export = require('./$.export'),
    sign = require('./$.math-sign'),
    pow = Math.pow,
    EPSILON = pow(2, -52),
    EPSILON32 = pow(2, -23),
    MAX32 = pow(2, 127) * (2 - EPSILON32),
    MIN32 = pow(2, -126);

var roundTiesToEven = function roundTiesToEven(n) {
  return n + 1 / EPSILON - 1 / EPSILON;
};

$export($export.S, 'Math', {
  fround: function fround(x) {
    var $abs = Math.abs(x),
        $sign = sign(x),
        a,
        result;
    if ($abs < MIN32) return $sign * roundTiesToEven($abs / MIN32 / EPSILON32) * MIN32 * EPSILON32;
    a = (1 + EPSILON32 / EPSILON) * $abs;
    result = a - (a - $abs);
    if (result > MAX32 || result != result) return $sign * Infinity;
    return $sign * result;
  }
});

},{"./$.export":24,"./$.math-sign":53}],107:[function(require,module,exports){
'use strict';

// 20.2.2.17 Math.hypot([value1[, value2[, … ]]])
var $export = require('./$.export'),
    abs = Math.abs;

$export($export.S, 'Math', {
  hypot: function hypot(value1, value2) {
    // eslint-disable-line no-unused-vars
    var sum = 0,
        i = 0,
        $$ = arguments,
        $$len = $$.length,
        larg = 0,
        arg,
        div;
    while (i < $$len) {
      arg = abs($$[i++]);
      if (larg < arg) {
        div = larg / arg;
        sum = sum * div * div + 1;
        larg = arg;
      } else if (arg > 0) {
        div = arg / larg;
        sum += div * div;
      } else sum += arg;
    }
    return larg === Infinity ? Infinity : larg * Math.sqrt(sum);
  }
});

},{"./$.export":24}],108:[function(require,module,exports){
'use strict';

// 20.2.2.18 Math.imul(x, y)
var $export = require('./$.export'),
    $imul = Math.imul;

// some WebKit versions fails with big numbers, some has wrong arity
$export($export.S + $export.F * require('./$.fails')(function () {
  return $imul(0xffffffff, 5) != -5 || $imul.length != 2;
}), 'Math', {
  imul: function imul(x, y) {
    var UINT16 = 0xffff,
        xn = +x,
        yn = +y,
        xl = UINT16 & xn,
        yl = UINT16 & yn;
    return 0 | xl * yl + ((UINT16 & xn >>> 16) * yl + xl * (UINT16 & yn >>> 16) << 16 >>> 0);
  }
});

},{"./$.export":24,"./$.fails":26}],109:[function(require,module,exports){
'use strict';

// 20.2.2.21 Math.log10(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  log10: function log10(x) {
    return Math.log(x) / Math.LN10;
  }
});

},{"./$.export":24}],110:[function(require,module,exports){
'use strict';

// 20.2.2.20 Math.log1p(x)
var $export = require('./$.export');

$export($export.S, 'Math', { log1p: require('./$.math-log1p') });

},{"./$.export":24,"./$.math-log1p":52}],111:[function(require,module,exports){
'use strict';

// 20.2.2.22 Math.log2(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  log2: function log2(x) {
    return Math.log(x) / Math.LN2;
  }
});

},{"./$.export":24}],112:[function(require,module,exports){
'use strict';

// 20.2.2.28 Math.sign(x)
var $export = require('./$.export');

$export($export.S, 'Math', { sign: require('./$.math-sign') });

},{"./$.export":24,"./$.math-sign":53}],113:[function(require,module,exports){
'use strict';

// 20.2.2.30 Math.sinh(x)
var $export = require('./$.export'),
    expm1 = require('./$.math-expm1'),
    exp = Math.exp;

// V8 near Chromium 38 has a problem with very small numbers
$export($export.S + $export.F * require('./$.fails')(function () {
  return !Math.sinh(-2e-17) != -2e-17;
}), 'Math', {
  sinh: function sinh(x) {
    return Math.abs(x = +x) < 1 ? (expm1(x) - expm1(-x)) / 2 : (exp(x - 1) - exp(-x - 1)) * (Math.E / 2);
  }
});

},{"./$.export":24,"./$.fails":26,"./$.math-expm1":51}],114:[function(require,module,exports){
'use strict';

// 20.2.2.33 Math.tanh(x)
var $export = require('./$.export'),
    expm1 = require('./$.math-expm1'),
    exp = Math.exp;

$export($export.S, 'Math', {
  tanh: function tanh(x) {
    var a = expm1(x = +x),
        b = expm1(-x);
    return a == Infinity ? 1 : b == Infinity ? -1 : (a - b) / (exp(x) + exp(-x));
  }
});

},{"./$.export":24,"./$.math-expm1":51}],115:[function(require,module,exports){
'use strict';

// 20.2.2.34 Math.trunc(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  trunc: function trunc(it) {
    return (it > 0 ? Math.floor : Math.ceil)(it);
  }
});

},{"./$.export":24}],116:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    global = require('./$.global'),
    has = require('./$.has'),
    cof = require('./$.cof'),
    toPrimitive = require('./$.to-primitive'),
    fails = require('./$.fails'),
    $trim = require('./$.string-trim').trim,
    NUMBER = 'Number',
    $Number = global[NUMBER],
    Base = $Number,
    proto = $Number.prototype
// Opera ~12 has broken Object#toString
,
    BROKEN_COF = cof($.create(proto)) == NUMBER,
    TRIM = 'trim' in String.prototype;

// 7.1.3 ToNumber(argument)
var toNumber = function toNumber(argument) {
  var it = toPrimitive(argument, false);
  if (typeof it == 'string' && it.length > 2) {
    it = TRIM ? it.trim() : $trim(it, 3);
    var first = it.charCodeAt(0),
        third,
        radix,
        maxCode;
    if (first === 43 || first === 45) {
      third = it.charCodeAt(2);
      if (third === 88 || third === 120) return NaN; // Number('+0x1') should be NaN, old V8 fix
    } else if (first === 48) {
        switch (it.charCodeAt(1)) {
          case 66:case 98:
            radix = 2;maxCode = 49;break; // fast equal /^0b[01]+$/i
          case 79:case 111:
            radix = 8;maxCode = 55;break; // fast equal /^0o[0-7]+$/i
          default:
            return +it;
        }
        for (var digits = it.slice(2), i = 0, l = digits.length, code; i < l; i++) {
          code = digits.charCodeAt(i);
          // parseInt parses a string to a first unavailable symbol
          // but ToNumber should return NaN if a string contains unavailable symbols
          if (code < 48 || code > maxCode) return NaN;
        }return parseInt(digits, radix);
      }
  }return +it;
};

if (!$Number(' 0o1') || !$Number('0b1') || $Number('+0x1')) {
  $Number = function Number(value) {
    var it = arguments.length < 1 ? 0 : value,
        that = this;
    return that instanceof $Number
    // check on 1..constructor(foo) case
     && (BROKEN_COF ? fails(function () {
      proto.valueOf.call(that);
    }) : cof(that) != NUMBER) ? new Base(toNumber(it)) : toNumber(it);
  };
  $.each.call(require('./$.descriptors') ? $.getNames(Base) : (
  // ES3:
  'MAX_VALUE,MIN_VALUE,NaN,NEGATIVE_INFINITY,POSITIVE_INFINITY,' +
  // ES6 (in case, if modules with ES6 Number statics required before):
  'EPSILON,isFinite,isInteger,isNaN,isSafeInteger,MAX_SAFE_INTEGER,' + 'MIN_SAFE_INTEGER,parseFloat,parseInt,isInteger').split(','), function (key) {
    if (has(Base, key) && !has($Number, key)) {
      $.setDesc($Number, key, $.getDesc(Base, key));
    }
  });
  $Number.prototype = proto;
  proto.constructor = $Number;
  require('./$.redefine')(global, NUMBER, $Number);
}

},{"./$":48,"./$.cof":13,"./$.descriptors":21,"./$.fails":26,"./$.global":31,"./$.has":32,"./$.redefine":63,"./$.string-trim":76,"./$.to-primitive":83}],117:[function(require,module,exports){
'use strict';

// 20.1.2.1 Number.EPSILON
var $export = require('./$.export');

$export($export.S, 'Number', { EPSILON: Math.pow(2, -52) });

},{"./$.export":24}],118:[function(require,module,exports){
'use strict';

// 20.1.2.2 Number.isFinite(number)
var $export = require('./$.export'),
    _isFinite = require('./$.global').isFinite;

$export($export.S, 'Number', {
  isFinite: function isFinite(it) {
    return typeof it == 'number' && _isFinite(it);
  }
});

},{"./$.export":24,"./$.global":31}],119:[function(require,module,exports){
'use strict';

// 20.1.2.3 Number.isInteger(number)
var $export = require('./$.export');

$export($export.S, 'Number', { isInteger: require('./$.is-integer') });

},{"./$.export":24,"./$.is-integer":39}],120:[function(require,module,exports){
'use strict';

// 20.1.2.4 Number.isNaN(number)
var $export = require('./$.export');

$export($export.S, 'Number', {
  isNaN: function isNaN(number) {
    return number != number;
  }
});

},{"./$.export":24}],121:[function(require,module,exports){
'use strict';

// 20.1.2.5 Number.isSafeInteger(number)
var $export = require('./$.export'),
    isInteger = require('./$.is-integer'),
    abs = Math.abs;

$export($export.S, 'Number', {
  isSafeInteger: function isSafeInteger(number) {
    return isInteger(number) && abs(number) <= 0x1fffffffffffff;
  }
});

},{"./$.export":24,"./$.is-integer":39}],122:[function(require,module,exports){
'use strict';

// 20.1.2.6 Number.MAX_SAFE_INTEGER
var $export = require('./$.export');

$export($export.S, 'Number', { MAX_SAFE_INTEGER: 0x1fffffffffffff });

},{"./$.export":24}],123:[function(require,module,exports){
'use strict';

// 20.1.2.10 Number.MIN_SAFE_INTEGER
var $export = require('./$.export');

$export($export.S, 'Number', { MIN_SAFE_INTEGER: -0x1fffffffffffff });

},{"./$.export":24}],124:[function(require,module,exports){
'use strict';

// 20.1.2.12 Number.parseFloat(string)
var $export = require('./$.export');

$export($export.S, 'Number', { parseFloat: parseFloat });

},{"./$.export":24}],125:[function(require,module,exports){
'use strict';

// 20.1.2.13 Number.parseInt(string, radix)
var $export = require('./$.export');

$export($export.S, 'Number', { parseInt: parseInt });

},{"./$.export":24}],126:[function(require,module,exports){
'use strict';

// 19.1.3.1 Object.assign(target, source)
var $export = require('./$.export');

$export($export.S + $export.F, 'Object', { assign: require('./$.object-assign') });

},{"./$.export":24,"./$.object-assign":55}],127:[function(require,module,exports){
'use strict';

// 19.1.2.5 Object.freeze(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('freeze', function ($freeze) {
  return function freeze(it) {
    return $freeze && isObject(it) ? $freeze(it) : it;
  };
});

},{"./$.is-object":40,"./$.object-sap":56}],128:[function(require,module,exports){
'use strict';

// 19.1.2.6 Object.getOwnPropertyDescriptor(O, P)
var toIObject = require('./$.to-iobject');

require('./$.object-sap')('getOwnPropertyDescriptor', function ($getOwnPropertyDescriptor) {
  return function getOwnPropertyDescriptor(it, key) {
    return $getOwnPropertyDescriptor(toIObject(it), key);
  };
});

},{"./$.object-sap":56,"./$.to-iobject":80}],129:[function(require,module,exports){
'use strict';

// 19.1.2.7 Object.getOwnPropertyNames(O)
require('./$.object-sap')('getOwnPropertyNames', function () {
  return require('./$.get-names').get;
});

},{"./$.get-names":30,"./$.object-sap":56}],130:[function(require,module,exports){
'use strict';

// 19.1.2.9 Object.getPrototypeOf(O)
var toObject = require('./$.to-object');

require('./$.object-sap')('getPrototypeOf', function ($getPrototypeOf) {
  return function getPrototypeOf(it) {
    return $getPrototypeOf(toObject(it));
  };
});

},{"./$.object-sap":56,"./$.to-object":82}],131:[function(require,module,exports){
'use strict';

// 19.1.2.11 Object.isExtensible(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('isExtensible', function ($isExtensible) {
  return function isExtensible(it) {
    return isObject(it) ? $isExtensible ? $isExtensible(it) : true : false;
  };
});

},{"./$.is-object":40,"./$.object-sap":56}],132:[function(require,module,exports){
'use strict';

// 19.1.2.12 Object.isFrozen(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('isFrozen', function ($isFrozen) {
  return function isFrozen(it) {
    return isObject(it) ? $isFrozen ? $isFrozen(it) : false : true;
  };
});

},{"./$.is-object":40,"./$.object-sap":56}],133:[function(require,module,exports){
'use strict';

// 19.1.2.13 Object.isSealed(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('isSealed', function ($isSealed) {
  return function isSealed(it) {
    return isObject(it) ? $isSealed ? $isSealed(it) : false : true;
  };
});

},{"./$.is-object":40,"./$.object-sap":56}],134:[function(require,module,exports){
'use strict';

// 19.1.3.10 Object.is(value1, value2)
var $export = require('./$.export');
$export($export.S, 'Object', { is: require('./$.same-value') });

},{"./$.export":24,"./$.same-value":65}],135:[function(require,module,exports){
'use strict';

// 19.1.2.14 Object.keys(O)
var toObject = require('./$.to-object');

require('./$.object-sap')('keys', function ($keys) {
  return function keys(it) {
    return $keys(toObject(it));
  };
});

},{"./$.object-sap":56,"./$.to-object":82}],136:[function(require,module,exports){
'use strict';

// 19.1.2.15 Object.preventExtensions(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('preventExtensions', function ($preventExtensions) {
  return function preventExtensions(it) {
    return $preventExtensions && isObject(it) ? $preventExtensions(it) : it;
  };
});

},{"./$.is-object":40,"./$.object-sap":56}],137:[function(require,module,exports){
'use strict';

// 19.1.2.17 Object.seal(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('seal', function ($seal) {
  return function seal(it) {
    return $seal && isObject(it) ? $seal(it) : it;
  };
});

},{"./$.is-object":40,"./$.object-sap":56}],138:[function(require,module,exports){
'use strict';

// 19.1.3.19 Object.setPrototypeOf(O, proto)
var $export = require('./$.export');
$export($export.S, 'Object', { setPrototypeOf: require('./$.set-proto').set });

},{"./$.export":24,"./$.set-proto":66}],139:[function(require,module,exports){
'use strict';
// 19.1.3.6 Object.prototype.toString()

var classof = require('./$.classof'),
    test = {};
test[require('./$.wks')('toStringTag')] = 'z';
if (test + '' != '[object z]') {
  require('./$.redefine')(Object.prototype, 'toString', function toString() {
    return '[object ' + classof(this) + ']';
  }, true);
}

},{"./$.classof":12,"./$.redefine":63,"./$.wks":85}],140:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    LIBRARY = require('./$.library'),
    global = require('./$.global'),
    ctx = require('./$.ctx'),
    classof = require('./$.classof'),
    $export = require('./$.export'),
    isObject = require('./$.is-object'),
    anObject = require('./$.an-object'),
    aFunction = require('./$.a-function'),
    strictNew = require('./$.strict-new'),
    forOf = require('./$.for-of'),
    setProto = require('./$.set-proto').set,
    same = require('./$.same-value'),
    SPECIES = require('./$.wks')('species'),
    speciesConstructor = require('./$.species-constructor'),
    asap = require('./$.microtask'),
    PROMISE = 'Promise',
    process = global.process,
    isNode = classof(process) == 'process',
    P = global[PROMISE],
    Wrapper;

var testResolve = function testResolve(sub) {
  var test = new P(function () {});
  if (sub) test.constructor = Object;
  return P.resolve(test) === test;
};

var USE_NATIVE = function () {
  var works = false;
  function P2(x) {
    var self = new P(x);
    setProto(self, P2.prototype);
    return self;
  }
  try {
    works = P && P.resolve && testResolve();
    setProto(P2, P);
    P2.prototype = $.create(P.prototype, { constructor: { value: P2 } });
    // actual Firefox has broken subclass support, test that
    if (!(P2.resolve(5).then(function () {}) instanceof P2)) {
      works = false;
    }
    // actual V8 bug, https://code.google.com/p/v8/issues/detail?id=4162
    if (works && require('./$.descriptors')) {
      var thenableThenGotten = false;
      P.resolve($.setDesc({}, 'then', {
        get: function get() {
          thenableThenGotten = true;
        }
      }));
      works = thenableThenGotten;
    }
  } catch (e) {
    works = false;
  }
  return works;
}();

// helpers
var sameConstructor = function sameConstructor(a, b) {
  // library wrapper special case
  if (LIBRARY && a === P && b === Wrapper) return true;
  return same(a, b);
};
var getConstructor = function getConstructor(C) {
  var S = anObject(C)[SPECIES];
  return S != undefined ? S : C;
};
var isThenable = function isThenable(it) {
  var then;
  return isObject(it) && typeof (then = it.then) == 'function' ? then : false;
};
var PromiseCapability = function PromiseCapability(C) {
  var resolve, reject;
  this.promise = new C(function ($$resolve, $$reject) {
    if (resolve !== undefined || reject !== undefined) throw TypeError('Bad Promise constructor');
    resolve = $$resolve;
    reject = $$reject;
  });
  this.resolve = aFunction(resolve), this.reject = aFunction(reject);
};
var perform = function perform(exec) {
  try {
    exec();
  } catch (e) {
    return { error: e };
  }
};
var notify = function notify(record, isReject) {
  if (record.n) return;
  record.n = true;
  var chain = record.c;
  asap(function () {
    var value = record.v,
        ok = record.s == 1,
        i = 0;
    var run = function run(reaction) {
      var handler = ok ? reaction.ok : reaction.fail,
          resolve = reaction.resolve,
          reject = reaction.reject,
          result,
          then;
      try {
        if (handler) {
          if (!ok) record.h = true;
          result = handler === true ? value : handler(value);
          if (result === reaction.promise) {
            reject(TypeError('Promise-chain cycle'));
          } else if (then = isThenable(result)) {
            then.call(result, resolve, reject);
          } else resolve(result);
        } else reject(value);
      } catch (e) {
        reject(e);
      }
    };
    while (chain.length > i) {
      run(chain[i++]);
    } // variable length - can't use forEach
    chain.length = 0;
    record.n = false;
    if (isReject) setTimeout(function () {
      var promise = record.p,
          handler,
          console;
      if (isUnhandled(promise)) {
        if (isNode) {
          process.emit('unhandledRejection', value, promise);
        } else if (handler = global.onunhandledrejection) {
          handler({ promise: promise, reason: value });
        } else if ((console = global.console) && console.error) {
          console.error('Unhandled promise rejection', value);
        }
      }record.a = undefined;
    }, 1);
  });
};
var isUnhandled = function isUnhandled(promise) {
  var record = promise._d,
      chain = record.a || record.c,
      i = 0,
      reaction;
  if (record.h) return false;
  while (chain.length > i) {
    reaction = chain[i++];
    if (reaction.fail || !isUnhandled(reaction.promise)) return false;
  }return true;
};
var $reject = function $reject(value) {
  var record = this;
  if (record.d) return;
  record.d = true;
  record = record.r || record; // unwrap
  record.v = value;
  record.s = 2;
  record.a = record.c.slice();
  notify(record, true);
};
var $resolve = function $resolve(value) {
  var record = this,
      then;
  if (record.d) return;
  record.d = true;
  record = record.r || record; // unwrap
  try {
    if (record.p === value) throw TypeError("Promise can't be resolved itself");
    if (then = isThenable(value)) {
      asap(function () {
        var wrapper = { r: record, d: false }; // wrap
        try {
          then.call(value, ctx($resolve, wrapper, 1), ctx($reject, wrapper, 1));
        } catch (e) {
          $reject.call(wrapper, e);
        }
      });
    } else {
      record.v = value;
      record.s = 1;
      notify(record, false);
    }
  } catch (e) {
    $reject.call({ r: record, d: false }, e); // wrap
  }
};

// constructor polyfill
if (!USE_NATIVE) {
  // 25.4.3.1 Promise(executor)
  P = function Promise(executor) {
    aFunction(executor);
    var record = this._d = {
      p: strictNew(this, P, PROMISE), // <- promise
      c: [], // <- awaiting reactions
      a: undefined, // <- checked in isUnhandled reactions
      s: 0, // <- state
      d: false, // <- done
      v: undefined, // <- value
      h: false, // <- handled rejection
      n: false // <- notify
    };
    try {
      executor(ctx($resolve, record, 1), ctx($reject, record, 1));
    } catch (err) {
      $reject.call(record, err);
    }
  };
  require('./$.redefine-all')(P.prototype, {
    // 25.4.5.3 Promise.prototype.then(onFulfilled, onRejected)
    then: function then(onFulfilled, onRejected) {
      var reaction = new PromiseCapability(speciesConstructor(this, P)),
          promise = reaction.promise,
          record = this._d;
      reaction.ok = typeof onFulfilled == 'function' ? onFulfilled : true;
      reaction.fail = typeof onRejected == 'function' && onRejected;
      record.c.push(reaction);
      if (record.a) record.a.push(reaction);
      if (record.s) notify(record, false);
      return promise;
    },
    // 25.4.5.1 Promise.prototype.catch(onRejected)
    'catch': function _catch(onRejected) {
      return this.then(undefined, onRejected);
    }
  });
}

$export($export.G + $export.W + $export.F * !USE_NATIVE, { Promise: P });
require('./$.set-to-string-tag')(P, PROMISE);
require('./$.set-species')(PROMISE);
Wrapper = require('./$.core')[PROMISE];

// statics
$export($export.S + $export.F * !USE_NATIVE, PROMISE, {
  // 25.4.4.5 Promise.reject(r)
  reject: function reject(r) {
    var capability = new PromiseCapability(this),
        $$reject = capability.reject;
    $$reject(r);
    return capability.promise;
  }
});
$export($export.S + $export.F * (!USE_NATIVE || testResolve(true)), PROMISE, {
  // 25.4.4.6 Promise.resolve(x)
  resolve: function resolve(x) {
    // instanceof instead of internal slot check because we should fix it without replacement native Promise core
    if (x instanceof P && sameConstructor(x.constructor, this)) return x;
    var capability = new PromiseCapability(this),
        $$resolve = capability.resolve;
    $$resolve(x);
    return capability.promise;
  }
});
$export($export.S + $export.F * !(USE_NATIVE && require('./$.iter-detect')(function (iter) {
  P.all(iter)['catch'](function () {});
})), PROMISE, {
  // 25.4.4.1 Promise.all(iterable)
  all: function all(iterable) {
    var C = getConstructor(this),
        capability = new PromiseCapability(C),
        resolve = capability.resolve,
        reject = capability.reject,
        values = [];
    var abrupt = perform(function () {
      forOf(iterable, false, values.push, values);
      var remaining = values.length,
          results = Array(remaining);
      if (remaining) $.each.call(values, function (promise, index) {
        var alreadyCalled = false;
        C.resolve(promise).then(function (value) {
          if (alreadyCalled) return;
          alreadyCalled = true;
          results[index] = value;
          --remaining || resolve(results);
        }, reject);
      });else resolve(results);
    });
    if (abrupt) reject(abrupt.error);
    return capability.promise;
  },
  // 25.4.4.4 Promise.race(iterable)
  race: function race(iterable) {
    var C = getConstructor(this),
        capability = new PromiseCapability(C),
        reject = capability.reject;
    var abrupt = perform(function () {
      forOf(iterable, false, function (promise) {
        C.resolve(promise).then(capability.resolve, reject);
      });
    });
    if (abrupt) reject(abrupt.error);
    return capability.promise;
  }
});

},{"./$":48,"./$.a-function":4,"./$.an-object":6,"./$.classof":12,"./$.core":18,"./$.ctx":19,"./$.descriptors":21,"./$.export":24,"./$.for-of":29,"./$.global":31,"./$.is-object":40,"./$.iter-detect":45,"./$.library":50,"./$.microtask":54,"./$.redefine-all":62,"./$.same-value":65,"./$.set-proto":66,"./$.set-species":67,"./$.set-to-string-tag":68,"./$.species-constructor":70,"./$.strict-new":71,"./$.wks":85}],141:[function(require,module,exports){
'use strict';

// 26.1.1 Reflect.apply(target, thisArgument, argumentsList)
var $export = require('./$.export'),
    _apply = Function.apply;

$export($export.S, 'Reflect', {
  apply: function apply(target, thisArgument, argumentsList) {
    return _apply.call(target, thisArgument, argumentsList);
  }
});

},{"./$.export":24}],142:[function(require,module,exports){
'use strict';

// 26.1.2 Reflect.construct(target, argumentsList [, newTarget])
var $ = require('./$'),
    $export = require('./$.export'),
    aFunction = require('./$.a-function'),
    anObject = require('./$.an-object'),
    isObject = require('./$.is-object'),
    bind = Function.bind || require('./$.core').Function.prototype.bind;

// MS Edge supports only 2 arguments
// FF Nightly sets third argument as `new.target`, but does not create `this` from it
$export($export.S + $export.F * require('./$.fails')(function () {
  function F() {}
  return !(Reflect.construct(function () {}, [], F) instanceof F);
}), 'Reflect', {
  construct: function construct(Target, args /*, newTarget*/) {
    aFunction(Target);
    var newTarget = arguments.length < 3 ? Target : aFunction(arguments[2]);
    if (Target == newTarget) {
      // w/o altered newTarget, optimization for 0-4 arguments
      if (args != undefined) switch (anObject(args).length) {
        case 0:
          return new Target();
        case 1:
          return new Target(args[0]);
        case 2:
          return new Target(args[0], args[1]);
        case 3:
          return new Target(args[0], args[1], args[2]);
        case 4:
          return new Target(args[0], args[1], args[2], args[3]);
      }
      // w/o altered newTarget, lot of arguments case
      var $args = [null];
      $args.push.apply($args, args);
      return new (bind.apply(Target, $args))();
    }
    // with altered newTarget, not support built-in constructors
    var proto = newTarget.prototype,
        instance = $.create(isObject(proto) ? proto : Object.prototype),
        result = Function.apply.call(Target, instance, args);
    return isObject(result) ? result : instance;
  }
});

},{"./$":48,"./$.a-function":4,"./$.an-object":6,"./$.core":18,"./$.export":24,"./$.fails":26,"./$.is-object":40}],143:[function(require,module,exports){
'use strict';

// 26.1.3 Reflect.defineProperty(target, propertyKey, attributes)
var $ = require('./$'),
    $export = require('./$.export'),
    anObject = require('./$.an-object');

// MS Edge has broken Reflect.defineProperty - throwing instead of returning false
$export($export.S + $export.F * require('./$.fails')(function () {
  Reflect.defineProperty($.setDesc({}, 1, { value: 1 }), 1, { value: 2 });
}), 'Reflect', {
  defineProperty: function defineProperty(target, propertyKey, attributes) {
    anObject(target);
    try {
      $.setDesc(target, propertyKey, attributes);
      return true;
    } catch (e) {
      return false;
    }
  }
});

},{"./$":48,"./$.an-object":6,"./$.export":24,"./$.fails":26}],144:[function(require,module,exports){
'use strict';

// 26.1.4 Reflect.deleteProperty(target, propertyKey)
var $export = require('./$.export'),
    getDesc = require('./$').getDesc,
    anObject = require('./$.an-object');

$export($export.S, 'Reflect', {
  deleteProperty: function deleteProperty(target, propertyKey) {
    var desc = getDesc(anObject(target), propertyKey);
    return desc && !desc.configurable ? false : delete target[propertyKey];
  }
});

},{"./$":48,"./$.an-object":6,"./$.export":24}],145:[function(require,module,exports){
'use strict';
// 26.1.5 Reflect.enumerate(target)

var $export = require('./$.export'),
    anObject = require('./$.an-object');
var Enumerate = function Enumerate(iterated) {
  this._t = anObject(iterated); // target
  this._i = 0; // next index
  var keys = this._k = [] // keys
  ,
      key;
  for (key in iterated) {
    keys.push(key);
  }
};
require('./$.iter-create')(Enumerate, 'Object', function () {
  var that = this,
      keys = that._k,
      key;
  do {
    if (that._i >= keys.length) return { value: undefined, done: true };
  } while (!((key = keys[that._i++]) in that._t));
  return { value: key, done: false };
});

$export($export.S, 'Reflect', {
  enumerate: function enumerate(target) {
    return new Enumerate(target);
  }
});

},{"./$.an-object":6,"./$.export":24,"./$.iter-create":43}],146:[function(require,module,exports){
'use strict';

// 26.1.7 Reflect.getOwnPropertyDescriptor(target, propertyKey)
var $ = require('./$'),
    $export = require('./$.export'),
    anObject = require('./$.an-object');

$export($export.S, 'Reflect', {
  getOwnPropertyDescriptor: function getOwnPropertyDescriptor(target, propertyKey) {
    return $.getDesc(anObject(target), propertyKey);
  }
});

},{"./$":48,"./$.an-object":6,"./$.export":24}],147:[function(require,module,exports){
'use strict';

// 26.1.8 Reflect.getPrototypeOf(target)
var $export = require('./$.export'),
    getProto = require('./$').getProto,
    anObject = require('./$.an-object');

$export($export.S, 'Reflect', {
  getPrototypeOf: function getPrototypeOf(target) {
    return getProto(anObject(target));
  }
});

},{"./$":48,"./$.an-object":6,"./$.export":24}],148:[function(require,module,exports){
'use strict';

// 26.1.6 Reflect.get(target, propertyKey [, receiver])
var $ = require('./$'),
    has = require('./$.has'),
    $export = require('./$.export'),
    isObject = require('./$.is-object'),
    anObject = require('./$.an-object');

function get(target, propertyKey /*, receiver*/) {
  var receiver = arguments.length < 3 ? target : arguments[2],
      desc,
      proto;
  if (anObject(target) === receiver) return target[propertyKey];
  if (desc = $.getDesc(target, propertyKey)) return has(desc, 'value') ? desc.value : desc.get !== undefined ? desc.get.call(receiver) : undefined;
  if (isObject(proto = $.getProto(target))) return get(proto, propertyKey, receiver);
}

$export($export.S, 'Reflect', { get: get });

},{"./$":48,"./$.an-object":6,"./$.export":24,"./$.has":32,"./$.is-object":40}],149:[function(require,module,exports){
'use strict';

// 26.1.9 Reflect.has(target, propertyKey)
var $export = require('./$.export');

$export($export.S, 'Reflect', {
  has: function has(target, propertyKey) {
    return propertyKey in target;
  }
});

},{"./$.export":24}],150:[function(require,module,exports){
'use strict';

// 26.1.10 Reflect.isExtensible(target)
var $export = require('./$.export'),
    anObject = require('./$.an-object'),
    $isExtensible = Object.isExtensible;

$export($export.S, 'Reflect', {
  isExtensible: function isExtensible(target) {
    anObject(target);
    return $isExtensible ? $isExtensible(target) : true;
  }
});

},{"./$.an-object":6,"./$.export":24}],151:[function(require,module,exports){
'use strict';

// 26.1.11 Reflect.ownKeys(target)
var $export = require('./$.export');

$export($export.S, 'Reflect', { ownKeys: require('./$.own-keys') });

},{"./$.export":24,"./$.own-keys":58}],152:[function(require,module,exports){
'use strict';

// 26.1.12 Reflect.preventExtensions(target)
var $export = require('./$.export'),
    anObject = require('./$.an-object'),
    $preventExtensions = Object.preventExtensions;

$export($export.S, 'Reflect', {
  preventExtensions: function preventExtensions(target) {
    anObject(target);
    try {
      if ($preventExtensions) $preventExtensions(target);
      return true;
    } catch (e) {
      return false;
    }
  }
});

},{"./$.an-object":6,"./$.export":24}],153:[function(require,module,exports){
'use strict';

// 26.1.14 Reflect.setPrototypeOf(target, proto)
var $export = require('./$.export'),
    setProto = require('./$.set-proto');

if (setProto) $export($export.S, 'Reflect', {
  setPrototypeOf: function setPrototypeOf(target, proto) {
    setProto.check(target, proto);
    try {
      setProto.set(target, proto);
      return true;
    } catch (e) {
      return false;
    }
  }
});

},{"./$.export":24,"./$.set-proto":66}],154:[function(require,module,exports){
'use strict';

// 26.1.13 Reflect.set(target, propertyKey, V [, receiver])
var $ = require('./$'),
    has = require('./$.has'),
    $export = require('./$.export'),
    createDesc = require('./$.property-desc'),
    anObject = require('./$.an-object'),
    isObject = require('./$.is-object');

function set(target, propertyKey, V /*, receiver*/) {
  var receiver = arguments.length < 4 ? target : arguments[3],
      ownDesc = $.getDesc(anObject(target), propertyKey),
      existingDescriptor,
      proto;
  if (!ownDesc) {
    if (isObject(proto = $.getProto(target))) {
      return set(proto, propertyKey, V, receiver);
    }
    ownDesc = createDesc(0);
  }
  if (has(ownDesc, 'value')) {
    if (ownDesc.writable === false || !isObject(receiver)) return false;
    existingDescriptor = $.getDesc(receiver, propertyKey) || createDesc(0);
    existingDescriptor.value = V;
    $.setDesc(receiver, propertyKey, existingDescriptor);
    return true;
  }
  return ownDesc.set === undefined ? false : (ownDesc.set.call(receiver, V), true);
}

$export($export.S, 'Reflect', { set: set });

},{"./$":48,"./$.an-object":6,"./$.export":24,"./$.has":32,"./$.is-object":40,"./$.property-desc":61}],155:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    global = require('./$.global'),
    isRegExp = require('./$.is-regexp'),
    $flags = require('./$.flags'),
    $RegExp = global.RegExp,
    Base = $RegExp,
    proto = $RegExp.prototype,
    re1 = /a/g,
    re2 = /a/g
// "new" creates a new object, old webkit buggy here
,
    CORRECT_NEW = new $RegExp(re1) !== re1;

if (require('./$.descriptors') && (!CORRECT_NEW || require('./$.fails')(function () {
  re2[require('./$.wks')('match')] = false;
  // RegExp constructor can alter flags and IsRegExp works correct with @@match
  return $RegExp(re1) != re1 || $RegExp(re2) == re2 || $RegExp(re1, 'i') != '/a/i';
}))) {
  $RegExp = function RegExp(p, f) {
    var piRE = isRegExp(p),
        fiU = f === undefined;
    return !(this instanceof $RegExp) && piRE && p.constructor === $RegExp && fiU ? p : CORRECT_NEW ? new Base(piRE && !fiU ? p.source : p, f) : Base((piRE = p instanceof $RegExp) ? p.source : p, piRE && fiU ? $flags.call(p) : f);
  };
  $.each.call($.getNames(Base), function (key) {
    key in $RegExp || $.setDesc($RegExp, key, {
      configurable: true,
      get: function get() {
        return Base[key];
      },
      set: function set(it) {
        Base[key] = it;
      }
    });
  });
  proto.constructor = $RegExp;
  $RegExp.prototype = proto;
  require('./$.redefine')(global, 'RegExp', $RegExp);
}

require('./$.set-species')('RegExp');

},{"./$":48,"./$.descriptors":21,"./$.fails":26,"./$.flags":28,"./$.global":31,"./$.is-regexp":41,"./$.redefine":63,"./$.set-species":67,"./$.wks":85}],156:[function(require,module,exports){
'use strict';

// 21.2.5.3 get RegExp.prototype.flags()
var $ = require('./$');
if (require('./$.descriptors') && /./g.flags != 'g') $.setDesc(RegExp.prototype, 'flags', {
  configurable: true,
  get: require('./$.flags')
});

},{"./$":48,"./$.descriptors":21,"./$.flags":28}],157:[function(require,module,exports){
'use strict';

// @@match logic
require('./$.fix-re-wks')('match', 1, function (defined, MATCH) {
  // 21.1.3.11 String.prototype.match(regexp)
  return function match(regexp) {
    'use strict';

    var O = defined(this),
        fn = regexp == undefined ? undefined : regexp[MATCH];
    return fn !== undefined ? fn.call(regexp, O) : new RegExp(regexp)[MATCH](String(O));
  };
});

},{"./$.fix-re-wks":27}],158:[function(require,module,exports){
'use strict';

// @@replace logic
require('./$.fix-re-wks')('replace', 2, function (defined, REPLACE, $replace) {
  // 21.1.3.14 String.prototype.replace(searchValue, replaceValue)
  return function replace(searchValue, replaceValue) {
    'use strict';

    var O = defined(this),
        fn = searchValue == undefined ? undefined : searchValue[REPLACE];
    return fn !== undefined ? fn.call(searchValue, O, replaceValue) : $replace.call(String(O), searchValue, replaceValue);
  };
});

},{"./$.fix-re-wks":27}],159:[function(require,module,exports){
'use strict';

// @@search logic
require('./$.fix-re-wks')('search', 1, function (defined, SEARCH) {
  // 21.1.3.15 String.prototype.search(regexp)
  return function search(regexp) {
    'use strict';

    var O = defined(this),
        fn = regexp == undefined ? undefined : regexp[SEARCH];
    return fn !== undefined ? fn.call(regexp, O) : new RegExp(regexp)[SEARCH](String(O));
  };
});

},{"./$.fix-re-wks":27}],160:[function(require,module,exports){
'use strict';

// @@split logic
require('./$.fix-re-wks')('split', 2, function (defined, SPLIT, $split) {
  // 21.1.3.17 String.prototype.split(separator, limit)
  return function split(separator, limit) {
    'use strict';

    var O = defined(this),
        fn = separator == undefined ? undefined : separator[SPLIT];
    return fn !== undefined ? fn.call(separator, O, limit) : $split.call(String(O), separator, limit);
  };
});

},{"./$.fix-re-wks":27}],161:[function(require,module,exports){
'use strict';

var strong = require('./$.collection-strong');

// 23.2 Set Objects
require('./$.collection')('Set', function (get) {
  return function Set() {
    return get(this, arguments.length > 0 ? arguments[0] : undefined);
  };
}, {
  // 23.2.3.1 Set.prototype.add(value)
  add: function add(value) {
    return strong.def(this, value = value === 0 ? 0 : value, value);
  }
}, strong);

},{"./$.collection":17,"./$.collection-strong":14}],162:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    $at = require('./$.string-at')(false);
$export($export.P, 'String', {
  // 21.1.3.3 String.prototype.codePointAt(pos)
  codePointAt: function codePointAt(pos) {
    return $at(this, pos);
  }
});

},{"./$.export":24,"./$.string-at":72}],163:[function(require,module,exports){
// 21.1.3.6 String.prototype.endsWith(searchString [, endPosition])
'use strict';

var $export = require('./$.export'),
    toLength = require('./$.to-length'),
    context = require('./$.string-context'),
    ENDS_WITH = 'endsWith',
    $endsWith = ''[ENDS_WITH];

$export($export.P + $export.F * require('./$.fails-is-regexp')(ENDS_WITH), 'String', {
  endsWith: function endsWith(searchString /*, endPosition = @length */) {
    var that = context(this, searchString, ENDS_WITH),
        $$ = arguments,
        endPosition = $$.length > 1 ? $$[1] : undefined,
        len = toLength(that.length),
        end = endPosition === undefined ? len : Math.min(toLength(endPosition), len),
        search = String(searchString);
    return $endsWith ? $endsWith.call(that, search, end) : that.slice(end - search.length, end) === search;
  }
});

},{"./$.export":24,"./$.fails-is-regexp":25,"./$.string-context":73,"./$.to-length":81}],164:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    toIndex = require('./$.to-index'),
    fromCharCode = String.fromCharCode,
    $fromCodePoint = String.fromCodePoint;

// length should be 1, old FF problem
$export($export.S + $export.F * (!!$fromCodePoint && $fromCodePoint.length != 1), 'String', {
  // 21.1.2.2 String.fromCodePoint(...codePoints)
  fromCodePoint: function fromCodePoint(x) {
    // eslint-disable-line no-unused-vars
    var res = [],
        $$ = arguments,
        $$len = $$.length,
        i = 0,
        code;
    while ($$len > i) {
      code = +$$[i++];
      if (toIndex(code, 0x10ffff) !== code) throw RangeError(code + ' is not a valid code point');
      res.push(code < 0x10000 ? fromCharCode(code) : fromCharCode(((code -= 0x10000) >> 10) + 0xd800, code % 0x400 + 0xdc00));
    }return res.join('');
  }
});

},{"./$.export":24,"./$.to-index":78}],165:[function(require,module,exports){
// 21.1.3.7 String.prototype.includes(searchString, position = 0)
'use strict';

var $export = require('./$.export'),
    context = require('./$.string-context'),
    INCLUDES = 'includes';

$export($export.P + $export.F * require('./$.fails-is-regexp')(INCLUDES), 'String', {
  includes: function includes(searchString /*, position = 0 */) {
    return !! ~context(this, searchString, INCLUDES).indexOf(searchString, arguments.length > 1 ? arguments[1] : undefined);
  }
});

},{"./$.export":24,"./$.fails-is-regexp":25,"./$.string-context":73}],166:[function(require,module,exports){
'use strict';

var $at = require('./$.string-at')(true);

// 21.1.3.27 String.prototype[@@iterator]()
require('./$.iter-define')(String, 'String', function (iterated) {
  this._t = String(iterated); // target
  this._i = 0; // next index
  // 21.1.5.2.1 %StringIteratorPrototype%.next()
}, function () {
  var O = this._t,
      index = this._i,
      point;
  if (index >= O.length) return { value: undefined, done: true };
  point = $at(O, index);
  this._i += point.length;
  return { value: point, done: false };
});

},{"./$.iter-define":44,"./$.string-at":72}],167:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    toIObject = require('./$.to-iobject'),
    toLength = require('./$.to-length');

$export($export.S, 'String', {
  // 21.1.2.4 String.raw(callSite, ...substitutions)
  raw: function raw(callSite) {
    var tpl = toIObject(callSite.raw),
        len = toLength(tpl.length),
        $$ = arguments,
        $$len = $$.length,
        res = [],
        i = 0;
    while (len > i) {
      res.push(String(tpl[i++]));
      if (i < $$len) res.push(String($$[i]));
    }return res.join('');
  }
});

},{"./$.export":24,"./$.to-iobject":80,"./$.to-length":81}],168:[function(require,module,exports){
'use strict';

var $export = require('./$.export');

$export($export.P, 'String', {
  // 21.1.3.13 String.prototype.repeat(count)
  repeat: require('./$.string-repeat')
});

},{"./$.export":24,"./$.string-repeat":75}],169:[function(require,module,exports){
// 21.1.3.18 String.prototype.startsWith(searchString [, position ])
'use strict';

var $export = require('./$.export'),
    toLength = require('./$.to-length'),
    context = require('./$.string-context'),
    STARTS_WITH = 'startsWith',
    $startsWith = ''[STARTS_WITH];

$export($export.P + $export.F * require('./$.fails-is-regexp')(STARTS_WITH), 'String', {
  startsWith: function startsWith(searchString /*, position = 0 */) {
    var that = context(this, searchString, STARTS_WITH),
        $$ = arguments,
        index = toLength(Math.min($$.length > 1 ? $$[1] : undefined, that.length)),
        search = String(searchString);
    return $startsWith ? $startsWith.call(that, search, index) : that.slice(index, index + search.length) === search;
  }
});

},{"./$.export":24,"./$.fails-is-regexp":25,"./$.string-context":73,"./$.to-length":81}],170:[function(require,module,exports){
'use strict';
// 21.1.3.25 String.prototype.trim()

require('./$.string-trim')('trim', function ($trim) {
  return function trim() {
    return $trim(this, 3);
  };
});

},{"./$.string-trim":76}],171:[function(require,module,exports){
'use strict';
// ECMAScript 6 symbols shim

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var $ = require('./$'),
    global = require('./$.global'),
    has = require('./$.has'),
    DESCRIPTORS = require('./$.descriptors'),
    $export = require('./$.export'),
    redefine = require('./$.redefine'),
    $fails = require('./$.fails'),
    shared = require('./$.shared'),
    setToStringTag = require('./$.set-to-string-tag'),
    uid = require('./$.uid'),
    wks = require('./$.wks'),
    keyOf = require('./$.keyof'),
    $names = require('./$.get-names'),
    enumKeys = require('./$.enum-keys'),
    isArray = require('./$.is-array'),
    anObject = require('./$.an-object'),
    toIObject = require('./$.to-iobject'),
    createDesc = require('./$.property-desc'),
    getDesc = $.getDesc,
    setDesc = $.setDesc,
    _create = $.create,
    getNames = $names.get,
    $Symbol = global.Symbol,
    $JSON = global.JSON,
    _stringify = $JSON && $JSON.stringify,
    setter = false,
    HIDDEN = wks('_hidden'),
    isEnum = $.isEnum,
    SymbolRegistry = shared('symbol-registry'),
    AllSymbols = shared('symbols'),
    useNative = typeof $Symbol == 'function',
    ObjectProto = Object.prototype;

// fallback for old Android, https://code.google.com/p/v8/issues/detail?id=687
var setSymbolDesc = DESCRIPTORS && $fails(function () {
  return _create(setDesc({}, 'a', {
    get: function get() {
      return setDesc(this, 'a', { value: 7 }).a;
    }
  })).a != 7;
}) ? function (it, key, D) {
  var protoDesc = getDesc(ObjectProto, key);
  if (protoDesc) delete ObjectProto[key];
  setDesc(it, key, D);
  if (protoDesc && it !== ObjectProto) setDesc(ObjectProto, key, protoDesc);
} : setDesc;

var wrap = function wrap(tag) {
  var sym = AllSymbols[tag] = _create($Symbol.prototype);
  sym._k = tag;
  DESCRIPTORS && setter && setSymbolDesc(ObjectProto, tag, {
    configurable: true,
    set: function set(value) {
      if (has(this, HIDDEN) && has(this[HIDDEN], tag)) this[HIDDEN][tag] = false;
      setSymbolDesc(this, tag, createDesc(1, value));
    }
  });
  return sym;
};

var isSymbol = function isSymbol(it) {
  return (typeof it === 'undefined' ? 'undefined' : _typeof(it)) == 'symbol';
};

var $defineProperty = function defineProperty(it, key, D) {
  if (D && has(AllSymbols, key)) {
    if (!D.enumerable) {
      if (!has(it, HIDDEN)) setDesc(it, HIDDEN, createDesc(1, {}));
      it[HIDDEN][key] = true;
    } else {
      if (has(it, HIDDEN) && it[HIDDEN][key]) it[HIDDEN][key] = false;
      D = _create(D, { enumerable: createDesc(0, false) });
    }return setSymbolDesc(it, key, D);
  }return setDesc(it, key, D);
};
var $defineProperties = function defineProperties(it, P) {
  anObject(it);
  var keys = enumKeys(P = toIObject(P)),
      i = 0,
      l = keys.length,
      key;
  while (l > i) {
    $defineProperty(it, key = keys[i++], P[key]);
  }return it;
};
var $create = function create(it, P) {
  return P === undefined ? _create(it) : $defineProperties(_create(it), P);
};
var $propertyIsEnumerable = function propertyIsEnumerable(key) {
  var E = isEnum.call(this, key);
  return E || !has(this, key) || !has(AllSymbols, key) || has(this, HIDDEN) && this[HIDDEN][key] ? E : true;
};
var $getOwnPropertyDescriptor = function getOwnPropertyDescriptor(it, key) {
  var D = getDesc(it = toIObject(it), key);
  if (D && has(AllSymbols, key) && !(has(it, HIDDEN) && it[HIDDEN][key])) D.enumerable = true;
  return D;
};
var $getOwnPropertyNames = function getOwnPropertyNames(it) {
  var names = getNames(toIObject(it)),
      result = [],
      i = 0,
      key;
  while (names.length > i) {
    if (!has(AllSymbols, key = names[i++]) && key != HIDDEN) result.push(key);
  }return result;
};
var $getOwnPropertySymbols = function getOwnPropertySymbols(it) {
  var names = getNames(toIObject(it)),
      result = [],
      i = 0,
      key;
  while (names.length > i) {
    if (has(AllSymbols, key = names[i++])) result.push(AllSymbols[key]);
  }return result;
};
var $stringify = function stringify(it) {
  if (it === undefined || isSymbol(it)) return; // IE8 returns string on undefined
  var args = [it],
      i = 1,
      $$ = arguments,
      replacer,
      $replacer;
  while ($$.length > i) {
    args.push($$[i++]);
  }replacer = args[1];
  if (typeof replacer == 'function') $replacer = replacer;
  if ($replacer || !isArray(replacer)) replacer = function replacer(key, value) {
    if ($replacer) value = $replacer.call(this, key, value);
    if (!isSymbol(value)) return value;
  };
  args[1] = replacer;
  return _stringify.apply($JSON, args);
};
var buggyJSON = $fails(function () {
  var S = $Symbol();
  // MS Edge converts symbol values to JSON as {}
  // WebKit converts symbol values to JSON as null
  // V8 throws on boxed symbols
  return _stringify([S]) != '[null]' || _stringify({ a: S }) != '{}' || _stringify(Object(S)) != '{}';
});

// 19.4.1.1 Symbol([description])
if (!useNative) {
  $Symbol = function _Symbol() {
    if (isSymbol(this)) throw TypeError('Symbol is not a constructor');
    return wrap(uid(arguments.length > 0 ? arguments[0] : undefined));
  };
  redefine($Symbol.prototype, 'toString', function toString() {
    return this._k;
  });

  isSymbol = function isSymbol(it) {
    return it instanceof $Symbol;
  };

  $.create = $create;
  $.isEnum = $propertyIsEnumerable;
  $.getDesc = $getOwnPropertyDescriptor;
  $.setDesc = $defineProperty;
  $.setDescs = $defineProperties;
  $.getNames = $names.get = $getOwnPropertyNames;
  $.getSymbols = $getOwnPropertySymbols;

  if (DESCRIPTORS && !require('./$.library')) {
    redefine(ObjectProto, 'propertyIsEnumerable', $propertyIsEnumerable, true);
  }
}

var symbolStatics = {
  // 19.4.2.1 Symbol.for(key)
  'for': function _for(key) {
    return has(SymbolRegistry, key += '') ? SymbolRegistry[key] : SymbolRegistry[key] = $Symbol(key);
  },
  // 19.4.2.5 Symbol.keyFor(sym)
  keyFor: function keyFor(key) {
    return keyOf(SymbolRegistry, key);
  },
  useSetter: function useSetter() {
    setter = true;
  },
  useSimple: function useSimple() {
    setter = false;
  }
};
// 19.4.2.2 Symbol.hasInstance
// 19.4.2.3 Symbol.isConcatSpreadable
// 19.4.2.4 Symbol.iterator
// 19.4.2.6 Symbol.match
// 19.4.2.8 Symbol.replace
// 19.4.2.9 Symbol.search
// 19.4.2.10 Symbol.species
// 19.4.2.11 Symbol.split
// 19.4.2.12 Symbol.toPrimitive
// 19.4.2.13 Symbol.toStringTag
// 19.4.2.14 Symbol.unscopables
$.each.call(('hasInstance,isConcatSpreadable,iterator,match,replace,search,' + 'species,split,toPrimitive,toStringTag,unscopables').split(','), function (it) {
  var sym = wks(it);
  symbolStatics[it] = useNative ? sym : wrap(sym);
});

setter = true;

$export($export.G + $export.W, { Symbol: $Symbol });

$export($export.S, 'Symbol', symbolStatics);

$export($export.S + $export.F * !useNative, 'Object', {
  // 19.1.2.2 Object.create(O [, Properties])
  create: $create,
  // 19.1.2.4 Object.defineProperty(O, P, Attributes)
  defineProperty: $defineProperty,
  // 19.1.2.3 Object.defineProperties(O, Properties)
  defineProperties: $defineProperties,
  // 19.1.2.6 Object.getOwnPropertyDescriptor(O, P)
  getOwnPropertyDescriptor: $getOwnPropertyDescriptor,
  // 19.1.2.7 Object.getOwnPropertyNames(O)
  getOwnPropertyNames: $getOwnPropertyNames,
  // 19.1.2.8 Object.getOwnPropertySymbols(O)
  getOwnPropertySymbols: $getOwnPropertySymbols
});

// 24.3.2 JSON.stringify(value [, replacer [, space]])
$JSON && $export($export.S + $export.F * (!useNative || buggyJSON), 'JSON', { stringify: $stringify });

// 19.4.3.5 Symbol.prototype[@@toStringTag]
setToStringTag($Symbol, 'Symbol');
// 20.2.1.9 Math[@@toStringTag]
setToStringTag(Math, 'Math', true);
// 24.3.3 JSON[@@toStringTag]
setToStringTag(global.JSON, 'JSON', true);

},{"./$":48,"./$.an-object":6,"./$.descriptors":21,"./$.enum-keys":23,"./$.export":24,"./$.fails":26,"./$.get-names":30,"./$.global":31,"./$.has":32,"./$.is-array":38,"./$.keyof":49,"./$.library":50,"./$.property-desc":61,"./$.redefine":63,"./$.set-to-string-tag":68,"./$.shared":69,"./$.to-iobject":80,"./$.uid":84,"./$.wks":85}],172:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    redefine = require('./$.redefine'),
    weak = require('./$.collection-weak'),
    isObject = require('./$.is-object'),
    has = require('./$.has'),
    frozenStore = weak.frozenStore,
    WEAK = weak.WEAK,
    isExtensible = Object.isExtensible || isObject,
    tmp = {};

// 23.3 WeakMap Objects
var $WeakMap = require('./$.collection')('WeakMap', function (get) {
  return function WeakMap() {
    return get(this, arguments.length > 0 ? arguments[0] : undefined);
  };
}, {
  // 23.3.3.3 WeakMap.prototype.get(key)
  get: function get(key) {
    if (isObject(key)) {
      if (!isExtensible(key)) return frozenStore(this).get(key);
      if (has(key, WEAK)) return key[WEAK][this._i];
    }
  },
  // 23.3.3.5 WeakMap.prototype.set(key, value)
  set: function set(key, value) {
    return weak.def(this, key, value);
  }
}, weak, true, true);

// IE11 WeakMap frozen keys fix
if (new $WeakMap().set((Object.freeze || Object)(tmp), 7).get(tmp) != 7) {
  $.each.call(['delete', 'has', 'get', 'set'], function (key) {
    var proto = $WeakMap.prototype,
        method = proto[key];
    redefine(proto, key, function (a, b) {
      // store frozen objects on leaky map
      if (isObject(a) && !isExtensible(a)) {
        var result = frozenStore(this)[key](a, b);
        return key == 'set' ? this : result;
        // store all the rest on native weakmap
      }return method.call(this, a, b);
    });
  });
}

},{"./$":48,"./$.collection":17,"./$.collection-weak":16,"./$.has":32,"./$.is-object":40,"./$.redefine":63}],173:[function(require,module,exports){
'use strict';

var weak = require('./$.collection-weak');

// 23.4 WeakSet Objects
require('./$.collection')('WeakSet', function (get) {
  return function WeakSet() {
    return get(this, arguments.length > 0 ? arguments[0] : undefined);
  };
}, {
  // 23.4.3.1 WeakSet.prototype.add(value)
  add: function add(value) {
    return weak.def(this, value, true);
  }
}, weak, false, true);

},{"./$.collection":17,"./$.collection-weak":16}],174:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    $includes = require('./$.array-includes')(true);

$export($export.P, 'Array', {
  // https://github.com/domenic/Array.prototype.includes
  includes: function includes(el /*, fromIndex = 0 */) {
    return $includes(this, el, arguments.length > 1 ? arguments[1] : undefined);
  }
});

require('./$.add-to-unscopables')('includes');

},{"./$.add-to-unscopables":5,"./$.array-includes":9,"./$.export":24}],175:[function(require,module,exports){
'use strict';

// https://github.com/DavidBruant/Map-Set.prototype.toJSON
var $export = require('./$.export');

$export($export.P, 'Map', { toJSON: require('./$.collection-to-json')('Map') });

},{"./$.collection-to-json":15,"./$.export":24}],176:[function(require,module,exports){
'use strict';

// http://goo.gl/XkBrjD
var $export = require('./$.export'),
    $entries = require('./$.object-to-array')(true);

$export($export.S, 'Object', {
  entries: function entries(it) {
    return $entries(it);
  }
});

},{"./$.export":24,"./$.object-to-array":57}],177:[function(require,module,exports){
'use strict';

// https://gist.github.com/WebReflection/9353781
var $ = require('./$'),
    $export = require('./$.export'),
    ownKeys = require('./$.own-keys'),
    toIObject = require('./$.to-iobject'),
    createDesc = require('./$.property-desc');

$export($export.S, 'Object', {
  getOwnPropertyDescriptors: function getOwnPropertyDescriptors(object) {
    var O = toIObject(object),
        setDesc = $.setDesc,
        getDesc = $.getDesc,
        keys = ownKeys(O),
        result = {},
        i = 0,
        key,
        D;
    while (keys.length > i) {
      D = getDesc(O, key = keys[i++]);
      if (key in result) setDesc(result, key, createDesc(0, D));else result[key] = D;
    }return result;
  }
});

},{"./$":48,"./$.export":24,"./$.own-keys":58,"./$.property-desc":61,"./$.to-iobject":80}],178:[function(require,module,exports){
'use strict';

// http://goo.gl/XkBrjD
var $export = require('./$.export'),
    $values = require('./$.object-to-array')(false);

$export($export.S, 'Object', {
  values: function values(it) {
    return $values(it);
  }
});

},{"./$.export":24,"./$.object-to-array":57}],179:[function(require,module,exports){
'use strict';

// https://github.com/benjamingr/RexExp.escape
var $export = require('./$.export'),
    $re = require('./$.replacer')(/[\\^$*+?.()|[\]{}]/g, '\\$&');

$export($export.S, 'RegExp', { escape: function escape(it) {
    return $re(it);
  } });

},{"./$.export":24,"./$.replacer":64}],180:[function(require,module,exports){
'use strict';

// https://github.com/DavidBruant/Map-Set.prototype.toJSON
var $export = require('./$.export');

$export($export.P, 'Set', { toJSON: require('./$.collection-to-json')('Set') });

},{"./$.collection-to-json":15,"./$.export":24}],181:[function(require,module,exports){
'use strict';
// https://github.com/mathiasbynens/String.prototype.at

var $export = require('./$.export'),
    $at = require('./$.string-at')(true);

$export($export.P, 'String', {
  at: function at(pos) {
    return $at(this, pos);
  }
});

},{"./$.export":24,"./$.string-at":72}],182:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    $pad = require('./$.string-pad');

$export($export.P, 'String', {
  padLeft: function padLeft(maxLength /*, fillString = ' ' */) {
    return $pad(this, maxLength, arguments.length > 1 ? arguments[1] : undefined, true);
  }
});

},{"./$.export":24,"./$.string-pad":74}],183:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    $pad = require('./$.string-pad');

$export($export.P, 'String', {
  padRight: function padRight(maxLength /*, fillString = ' ' */) {
    return $pad(this, maxLength, arguments.length > 1 ? arguments[1] : undefined, false);
  }
});

},{"./$.export":24,"./$.string-pad":74}],184:[function(require,module,exports){
'use strict';
// https://github.com/sebmarkbage/ecmascript-string-left-right-trim

require('./$.string-trim')('trimLeft', function ($trim) {
  return function trimLeft() {
    return $trim(this, 1);
  };
});

},{"./$.string-trim":76}],185:[function(require,module,exports){
'use strict';
// https://github.com/sebmarkbage/ecmascript-string-left-right-trim

require('./$.string-trim')('trimRight', function ($trim) {
  return function trimRight() {
    return $trim(this, 2);
  };
});

},{"./$.string-trim":76}],186:[function(require,module,exports){
'use strict';

// JavaScript 1.6 / Strawman array statics shim
var $ = require('./$'),
    $export = require('./$.export'),
    $ctx = require('./$.ctx'),
    $Array = require('./$.core').Array || Array,
    statics = {};
var setStatics = function setStatics(keys, length) {
  $.each.call(keys.split(','), function (key) {
    if (length == undefined && key in $Array) statics[key] = $Array[key];else if (key in []) statics[key] = $ctx(Function.call, [][key], length);
  });
};
setStatics('pop,reverse,shift,keys,values,entries', 1);
setStatics('indexOf,every,some,forEach,map,filter,find,findIndex,includes', 3);
setStatics('join,slice,concat,push,splice,unshift,sort,lastIndexOf,' + 'reduce,reduceRight,copyWithin,fill');
$export($export.S, 'Array', statics);

},{"./$":48,"./$.core":18,"./$.ctx":19,"./$.export":24}],187:[function(require,module,exports){
'use strict';

require('./es6.array.iterator');
var global = require('./$.global'),
    hide = require('./$.hide'),
    Iterators = require('./$.iterators'),
    ITERATOR = require('./$.wks')('iterator'),
    NL = global.NodeList,
    HTC = global.HTMLCollection,
    NLProto = NL && NL.prototype,
    HTCProto = HTC && HTC.prototype,
    ArrayValues = Iterators.NodeList = Iterators.HTMLCollection = Iterators.Array;
if (NLProto && !NLProto[ITERATOR]) hide(NLProto, ITERATOR, ArrayValues);
if (HTCProto && !HTCProto[ITERATOR]) hide(HTCProto, ITERATOR, ArrayValues);

},{"./$.global":31,"./$.hide":33,"./$.iterators":47,"./$.wks":85,"./es6.array.iterator":93}],188:[function(require,module,exports){
'use strict';

var $export = require('./$.export'),
    $task = require('./$.task');
$export($export.G + $export.B, {
  setImmediate: $task.set,
  clearImmediate: $task.clear
});

},{"./$.export":24,"./$.task":77}],189:[function(require,module,exports){
'use strict';

// ie9- setTimeout & setInterval additional parameters fix
var global = require('./$.global'),
    $export = require('./$.export'),
    invoke = require('./$.invoke'),
    partial = require('./$.partial'),
    navigator = global.navigator,
    MSIE = !!navigator && /MSIE .\./.test(navigator.userAgent); // <- dirty ie9- check
var wrap = function wrap(set) {
  return MSIE ? function (fn, time /*, ...args */) {
    return set(invoke(partial, [].slice.call(arguments, 2), typeof fn == 'function' ? fn : Function(fn)), time);
  } : set;
};
$export($export.G + $export.B + $export.F * MSIE, {
  setTimeout: wrap(global.setTimeout),
  setInterval: wrap(global.setInterval)
});

},{"./$.export":24,"./$.global":31,"./$.invoke":35,"./$.partial":59}],190:[function(require,module,exports){
'use strict';

require('./modules/es5');
require('./modules/es6.symbol');
require('./modules/es6.object.assign');
require('./modules/es6.object.is');
require('./modules/es6.object.set-prototype-of');
require('./modules/es6.object.to-string');
require('./modules/es6.object.freeze');
require('./modules/es6.object.seal');
require('./modules/es6.object.prevent-extensions');
require('./modules/es6.object.is-frozen');
require('./modules/es6.object.is-sealed');
require('./modules/es6.object.is-extensible');
require('./modules/es6.object.get-own-property-descriptor');
require('./modules/es6.object.get-prototype-of');
require('./modules/es6.object.keys');
require('./modules/es6.object.get-own-property-names');
require('./modules/es6.function.name');
require('./modules/es6.function.has-instance');
require('./modules/es6.number.constructor');
require('./modules/es6.number.epsilon');
require('./modules/es6.number.is-finite');
require('./modules/es6.number.is-integer');
require('./modules/es6.number.is-nan');
require('./modules/es6.number.is-safe-integer');
require('./modules/es6.number.max-safe-integer');
require('./modules/es6.number.min-safe-integer');
require('./modules/es6.number.parse-float');
require('./modules/es6.number.parse-int');
require('./modules/es6.math.acosh');
require('./modules/es6.math.asinh');
require('./modules/es6.math.atanh');
require('./modules/es6.math.cbrt');
require('./modules/es6.math.clz32');
require('./modules/es6.math.cosh');
require('./modules/es6.math.expm1');
require('./modules/es6.math.fround');
require('./modules/es6.math.hypot');
require('./modules/es6.math.imul');
require('./modules/es6.math.log10');
require('./modules/es6.math.log1p');
require('./modules/es6.math.log2');
require('./modules/es6.math.sign');
require('./modules/es6.math.sinh');
require('./modules/es6.math.tanh');
require('./modules/es6.math.trunc');
require('./modules/es6.string.from-code-point');
require('./modules/es6.string.raw');
require('./modules/es6.string.trim');
require('./modules/es6.string.iterator');
require('./modules/es6.string.code-point-at');
require('./modules/es6.string.ends-with');
require('./modules/es6.string.includes');
require('./modules/es6.string.repeat');
require('./modules/es6.string.starts-with');
require('./modules/es6.array.from');
require('./modules/es6.array.of');
require('./modules/es6.array.iterator');
require('./modules/es6.array.species');
require('./modules/es6.array.copy-within');
require('./modules/es6.array.fill');
require('./modules/es6.array.find');
require('./modules/es6.array.find-index');
require('./modules/es6.regexp.constructor');
require('./modules/es6.regexp.flags');
require('./modules/es6.regexp.match');
require('./modules/es6.regexp.replace');
require('./modules/es6.regexp.search');
require('./modules/es6.regexp.split');
require('./modules/es6.promise');
require('./modules/es6.map');
require('./modules/es6.set');
require('./modules/es6.weak-map');
require('./modules/es6.weak-set');
require('./modules/es6.reflect.apply');
require('./modules/es6.reflect.construct');
require('./modules/es6.reflect.define-property');
require('./modules/es6.reflect.delete-property');
require('./modules/es6.reflect.enumerate');
require('./modules/es6.reflect.get');
require('./modules/es6.reflect.get-own-property-descriptor');
require('./modules/es6.reflect.get-prototype-of');
require('./modules/es6.reflect.has');
require('./modules/es6.reflect.is-extensible');
require('./modules/es6.reflect.own-keys');
require('./modules/es6.reflect.prevent-extensions');
require('./modules/es6.reflect.set');
require('./modules/es6.reflect.set-prototype-of');
require('./modules/es7.array.includes');
require('./modules/es7.string.at');
require('./modules/es7.string.pad-left');
require('./modules/es7.string.pad-right');
require('./modules/es7.string.trim-left');
require('./modules/es7.string.trim-right');
require('./modules/es7.regexp.escape');
require('./modules/es7.object.get-own-property-descriptors');
require('./modules/es7.object.values');
require('./modules/es7.object.entries');
require('./modules/es7.map.to-json');
require('./modules/es7.set.to-json');
require('./modules/js.array.statics');
require('./modules/web.timers');
require('./modules/web.immediate');
require('./modules/web.dom.iterable');
module.exports = require('./modules/$.core');

},{"./modules/$.core":18,"./modules/es5":87,"./modules/es6.array.copy-within":88,"./modules/es6.array.fill":89,"./modules/es6.array.find":91,"./modules/es6.array.find-index":90,"./modules/es6.array.from":92,"./modules/es6.array.iterator":93,"./modules/es6.array.of":94,"./modules/es6.array.species":95,"./modules/es6.function.has-instance":96,"./modules/es6.function.name":97,"./modules/es6.map":98,"./modules/es6.math.acosh":99,"./modules/es6.math.asinh":100,"./modules/es6.math.atanh":101,"./modules/es6.math.cbrt":102,"./modules/es6.math.clz32":103,"./modules/es6.math.cosh":104,"./modules/es6.math.expm1":105,"./modules/es6.math.fround":106,"./modules/es6.math.hypot":107,"./modules/es6.math.imul":108,"./modules/es6.math.log10":109,"./modules/es6.math.log1p":110,"./modules/es6.math.log2":111,"./modules/es6.math.sign":112,"./modules/es6.math.sinh":113,"./modules/es6.math.tanh":114,"./modules/es6.math.trunc":115,"./modules/es6.number.constructor":116,"./modules/es6.number.epsilon":117,"./modules/es6.number.is-finite":118,"./modules/es6.number.is-integer":119,"./modules/es6.number.is-nan":120,"./modules/es6.number.is-safe-integer":121,"./modules/es6.number.max-safe-integer":122,"./modules/es6.number.min-safe-integer":123,"./modules/es6.number.parse-float":124,"./modules/es6.number.parse-int":125,"./modules/es6.object.assign":126,"./modules/es6.object.freeze":127,"./modules/es6.object.get-own-property-descriptor":128,"./modules/es6.object.get-own-property-names":129,"./modules/es6.object.get-prototype-of":130,"./modules/es6.object.is":134,"./modules/es6.object.is-extensible":131,"./modules/es6.object.is-frozen":132,"./modules/es6.object.is-sealed":133,"./modules/es6.object.keys":135,"./modules/es6.object.prevent-extensions":136,"./modules/es6.object.seal":137,"./modules/es6.object.set-prototype-of":138,"./modules/es6.object.to-string":139,"./modules/es6.promise":140,"./modules/es6.reflect.apply":141,"./modules/es6.reflect.construct":142,"./modules/es6.reflect.define-property":143,"./modules/es6.reflect.delete-property":144,"./modules/es6.reflect.enumerate":145,"./modules/es6.reflect.get":148,"./modules/es6.reflect.get-own-property-descriptor":146,"./modules/es6.reflect.get-prototype-of":147,"./modules/es6.reflect.has":149,"./modules/es6.reflect.is-extensible":150,"./modules/es6.reflect.own-keys":151,"./modules/es6.reflect.prevent-extensions":152,"./modules/es6.reflect.set":154,"./modules/es6.reflect.set-prototype-of":153,"./modules/es6.regexp.constructor":155,"./modules/es6.regexp.flags":156,"./modules/es6.regexp.match":157,"./modules/es6.regexp.replace":158,"./modules/es6.regexp.search":159,"./modules/es6.regexp.split":160,"./modules/es6.set":161,"./modules/es6.string.code-point-at":162,"./modules/es6.string.ends-with":163,"./modules/es6.string.from-code-point":164,"./modules/es6.string.includes":165,"./modules/es6.string.iterator":166,"./modules/es6.string.raw":167,"./modules/es6.string.repeat":168,"./modules/es6.string.starts-with":169,"./modules/es6.string.trim":170,"./modules/es6.symbol":171,"./modules/es6.weak-map":172,"./modules/es6.weak-set":173,"./modules/es7.array.includes":174,"./modules/es7.map.to-json":175,"./modules/es7.object.entries":176,"./modules/es7.object.get-own-property-descriptors":177,"./modules/es7.object.values":178,"./modules/es7.regexp.escape":179,"./modules/es7.set.to-json":180,"./modules/es7.string.at":181,"./modules/es7.string.pad-left":182,"./modules/es7.string.pad-right":183,"./modules/es7.string.trim-left":184,"./modules/es7.string.trim-right":185,"./modules/js.array.statics":186,"./modules/web.dom.iterable":187,"./modules/web.immediate":188,"./modules/web.timers":189}],191:[function(require,module,exports){
'use strict';

// http://wiki.commonjs.org/wiki/Unit_Testing/1.0
//
// THIS IS NOT TESTED NOR LIKELY TO WORK OUTSIDE V8!
//
// Originally from narwhal.js (http://narwhaljs.org)
// Copyright (c) 2009 Thomas Robinson <280north.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the 'Software'), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// when used in node, this will actually load the util module we depend on
// versus loading the builtin util module as happens otherwise
// this is a bug in node module loading as far as I am concerned
var util = require('util/');

var pSlice = Array.prototype.slice;
var hasOwn = Object.prototype.hasOwnProperty;

// 1. The assert module provides functions that throw
// AssertionError's when particular conditions are not met. The
// assert module must conform to the following interface.

var assert = module.exports = ok;

// 2. The AssertionError is defined in assert.
// new assert.AssertionError({ message: message,
//                             actual: actual,
//                             expected: expected })

assert.AssertionError = function AssertionError(options) {
  this.name = 'AssertionError';
  this.actual = options.actual;
  this.expected = options.expected;
  this.operator = options.operator;
  if (options.message) {
    this.message = options.message;
    this.generatedMessage = false;
  } else {
    this.message = getMessage(this);
    this.generatedMessage = true;
  }
  var stackStartFunction = options.stackStartFunction || fail;

  if (Error.captureStackTrace) {
    Error.captureStackTrace(this, stackStartFunction);
  } else {
    // non v8 browsers so we can have a stacktrace
    var err = new Error();
    if (err.stack) {
      var out = err.stack;

      // try to strip useless frames
      var fn_name = stackStartFunction.name;
      var idx = out.indexOf('\n' + fn_name);
      if (idx >= 0) {
        // once we have located the function frame
        // we need to strip out everything before it (and its line)
        var next_line = out.indexOf('\n', idx + 1);
        out = out.substring(next_line + 1);
      }

      this.stack = out;
    }
  }
};

// assert.AssertionError instanceof Error
util.inherits(assert.AssertionError, Error);

function replacer(key, value) {
  if (util.isUndefined(value)) {
    return '' + value;
  }
  if (util.isNumber(value) && !isFinite(value)) {
    return value.toString();
  }
  if (util.isFunction(value) || util.isRegExp(value)) {
    return value.toString();
  }
  return value;
}

function truncate(s, n) {
  if (util.isString(s)) {
    return s.length < n ? s : s.slice(0, n);
  } else {
    return s;
  }
}

function getMessage(self) {
  return truncate(JSON.stringify(self.actual, replacer), 128) + ' ' + self.operator + ' ' + truncate(JSON.stringify(self.expected, replacer), 128);
}

// At present only the three keys mentioned above are used and
// understood by the spec. Implementations or sub modules can pass
// other keys to the AssertionError's constructor - they will be
// ignored.

// 3. All of the following functions must throw an AssertionError
// when a corresponding condition is not met, with a message that
// may be undefined if not provided.  All assertion methods provide
// both the actual and expected values to the assertion error for
// display purposes.

function fail(actual, expected, message, operator, stackStartFunction) {
  throw new assert.AssertionError({
    message: message,
    actual: actual,
    expected: expected,
    operator: operator,
    stackStartFunction: stackStartFunction
  });
}

// EXTENSION! allows for well behaved errors defined elsewhere.
assert.fail = fail;

// 4. Pure assertion tests whether a value is truthy, as determined
// by !!guard.
// assert.ok(guard, message_opt);
// This statement is equivalent to assert.equal(true, !!guard,
// message_opt);. To test strictly for the value true, use
// assert.strictEqual(true, guard, message_opt);.

function ok(value, message) {
  if (!value) fail(value, true, message, '==', assert.ok);
}
assert.ok = ok;

// 5. The equality assertion tests shallow, coercive equality with
// ==.
// assert.equal(actual, expected, message_opt);

assert.equal = function equal(actual, expected, message) {
  if (actual != expected) fail(actual, expected, message, '==', assert.equal);
};

// 6. The non-equality assertion tests for whether two objects are not equal
// with != assert.notEqual(actual, expected, message_opt);

assert.notEqual = function notEqual(actual, expected, message) {
  if (actual == expected) {
    fail(actual, expected, message, '!=', assert.notEqual);
  }
};

// 7. The equivalence assertion tests a deep equality relation.
// assert.deepEqual(actual, expected, message_opt);

assert.deepEqual = function deepEqual(actual, expected, message) {
  if (!_deepEqual(actual, expected)) {
    fail(actual, expected, message, 'deepEqual', assert.deepEqual);
  }
};

function _deepEqual(actual, expected) {
  // 7.1. All identical values are equivalent, as determined by ===.
  if (actual === expected) {
    return true;
  } else if (util.isBuffer(actual) && util.isBuffer(expected)) {
    if (actual.length != expected.length) return false;

    for (var i = 0; i < actual.length; i++) {
      if (actual[i] !== expected[i]) return false;
    }

    return true;

    // 7.2. If the expected value is a Date object, the actual value is
    // equivalent if it is also a Date object that refers to the same time.
  } else if (util.isDate(actual) && util.isDate(expected)) {
      return actual.getTime() === expected.getTime();

      // 7.3 If the expected value is a RegExp object, the actual value is
      // equivalent if it is also a RegExp object with the same source and
      // properties (`global`, `multiline`, `lastIndex`, `ignoreCase`).
    } else if (util.isRegExp(actual) && util.isRegExp(expected)) {
        return actual.source === expected.source && actual.global === expected.global && actual.multiline === expected.multiline && actual.lastIndex === expected.lastIndex && actual.ignoreCase === expected.ignoreCase;

        // 7.4. Other pairs that do not both pass typeof value == 'object',
        // equivalence is determined by ==.
      } else if (!util.isObject(actual) && !util.isObject(expected)) {
          return actual == expected;

          // 7.5 For all other Object pairs, including Array objects, equivalence is
          // determined by having the same number of owned properties (as verified
          // with Object.prototype.hasOwnProperty.call), the same set of keys
          // (although not necessarily the same order), equivalent values for every
          // corresponding key, and an identical 'prototype' property. Note: this
          // accounts for both named and indexed properties on Arrays.
        } else {
            return objEquiv(actual, expected);
          }
}

function isArguments(object) {
  return Object.prototype.toString.call(object) == '[object Arguments]';
}

function objEquiv(a, b) {
  if (util.isNullOrUndefined(a) || util.isNullOrUndefined(b)) return false;
  // an identical 'prototype' property.
  if (a.prototype !== b.prototype) return false;
  // if one is a primitive, the other must be same
  if (util.isPrimitive(a) || util.isPrimitive(b)) {
    return a === b;
  }
  var aIsArgs = isArguments(a),
      bIsArgs = isArguments(b);
  if (aIsArgs && !bIsArgs || !aIsArgs && bIsArgs) return false;
  if (aIsArgs) {
    a = pSlice.call(a);
    b = pSlice.call(b);
    return _deepEqual(a, b);
  }
  var ka = objectKeys(a),
      kb = objectKeys(b),
      key,
      i;
  // having the same number of owned properties (keys incorporates
  // hasOwnProperty)
  if (ka.length != kb.length) return false;
  //the same set of keys (although not necessarily the same order),
  ka.sort();
  kb.sort();
  //~~~cheap key test
  for (i = ka.length - 1; i >= 0; i--) {
    if (ka[i] != kb[i]) return false;
  }
  //equivalent values for every corresponding key, and
  //~~~possibly expensive deep test
  for (i = ka.length - 1; i >= 0; i--) {
    key = ka[i];
    if (!_deepEqual(a[key], b[key])) return false;
  }
  return true;
}

// 8. The non-equivalence assertion tests for any deep inequality.
// assert.notDeepEqual(actual, expected, message_opt);

assert.notDeepEqual = function notDeepEqual(actual, expected, message) {
  if (_deepEqual(actual, expected)) {
    fail(actual, expected, message, 'notDeepEqual', assert.notDeepEqual);
  }
};

// 9. The strict equality assertion tests strict equality, as determined by ===.
// assert.strictEqual(actual, expected, message_opt);

assert.strictEqual = function strictEqual(actual, expected, message) {
  if (actual !== expected) {
    fail(actual, expected, message, '===', assert.strictEqual);
  }
};

// 10. The strict non-equality assertion tests for strict inequality, as
// determined by !==.  assert.notStrictEqual(actual, expected, message_opt);

assert.notStrictEqual = function notStrictEqual(actual, expected, message) {
  if (actual === expected) {
    fail(actual, expected, message, '!==', assert.notStrictEqual);
  }
};

function expectedException(actual, expected) {
  if (!actual || !expected) {
    return false;
  }

  if (Object.prototype.toString.call(expected) == '[object RegExp]') {
    return expected.test(actual);
  } else if (actual instanceof expected) {
    return true;
  } else if (expected.call({}, actual) === true) {
    return true;
  }

  return false;
}

function _throws(shouldThrow, block, expected, message) {
  var actual;

  if (util.isString(expected)) {
    message = expected;
    expected = null;
  }

  try {
    block();
  } catch (e) {
    actual = e;
  }

  message = (expected && expected.name ? ' (' + expected.name + ').' : '.') + (message ? ' ' + message : '.');

  if (shouldThrow && !actual) {
    fail(actual, expected, 'Missing expected exception' + message);
  }

  if (!shouldThrow && expectedException(actual, expected)) {
    fail(actual, expected, 'Got unwanted exception' + message);
  }

  if (shouldThrow && actual && expected && !expectedException(actual, expected) || !shouldThrow && actual) {
    throw actual;
  }
}

// 11. Expected to throw an error:
// assert.throws(block, Error_opt, message_opt);

assert.throws = function (block, /*optional*/error, /*optional*/message) {
  _throws.apply(this, [true].concat(pSlice.call(arguments)));
};

// EXTENSION! This is annoying to write outside this module.
assert.doesNotThrow = function (block, /*optional*/message) {
  _throws.apply(this, [false].concat(pSlice.call(arguments)));
};

assert.ifError = function (err) {
  if (err) {
    throw err;
  }
};

var objectKeys = Object.keys || function (obj) {
  var keys = [];
  for (var key in obj) {
    if (hasOwn.call(obj, key)) keys.push(key);
  }
  return keys;
};

},{"util/":195}],192:[function(require,module,exports){
'use strict';

if (typeof Object.create === 'function') {
  // implementation from standard node.js 'util' module
  module.exports = function inherits(ctor, superCtor) {
    ctor.super_ = superCtor;
    ctor.prototype = Object.create(superCtor.prototype, {
      constructor: {
        value: ctor,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
  };
} else {
  // old school shim for old browsers
  module.exports = function inherits(ctor, superCtor) {
    ctor.super_ = superCtor;
    var TempCtor = function TempCtor() {};
    TempCtor.prototype = superCtor.prototype;
    ctor.prototype = new TempCtor();
    ctor.prototype.constructor = ctor;
  };
}

},{}],193:[function(require,module,exports){
'use strict';

// shim for using process in browser

var process = module.exports = {};
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = setTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while (len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    clearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        setTimeout(drainQueue, 0);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () {
    return '/';
};
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function () {
    return 0;
};

},{}],194:[function(require,module,exports){
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

module.exports = function isBuffer(arg) {
  return arg && (typeof arg === 'undefined' ? 'undefined' : _typeof(arg)) === 'object' && typeof arg.copy === 'function' && typeof arg.fill === 'function' && typeof arg.readUInt8 === 'function';
};

},{}],195:[function(require,module,exports){
(function (process,global){
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

var formatRegExp = /%[sdj%]/g;
exports.format = function (f) {
  if (!isString(f)) {
    var objects = [];
    for (var i = 0; i < arguments.length; i++) {
      objects.push(inspect(arguments[i]));
    }
    return objects.join(' ');
  }

  var i = 1;
  var args = arguments;
  var len = args.length;
  var str = String(f).replace(formatRegExp, function (x) {
    if (x === '%%') return '%';
    if (i >= len) return x;
    switch (x) {
      case '%s':
        return String(args[i++]);
      case '%d':
        return Number(args[i++]);
      case '%j':
        try {
          return JSON.stringify(args[i++]);
        } catch (_) {
          return '[Circular]';
        }
      default:
        return x;
    }
  });
  for (var x = args[i]; i < len; x = args[++i]) {
    if (isNull(x) || !isObject(x)) {
      str += ' ' + x;
    } else {
      str += ' ' + inspect(x);
    }
  }
  return str;
};

// Mark that a method should not be used.
// Returns a modified function which warns once by default.
// If --no-deprecation is set, then it is a no-op.
exports.deprecate = function (fn, msg) {
  // Allow for deprecating things in the process of starting up.
  if (isUndefined(global.process)) {
    return function () {
      return exports.deprecate(fn, msg).apply(this, arguments);
    };
  }

  if (process.noDeprecation === true) {
    return fn;
  }

  var warned = false;
  function deprecated() {
    if (!warned) {
      if (process.throwDeprecation) {
        throw new Error(msg);
      } else if (process.traceDeprecation) {
        console.trace(msg);
      } else {
        console.error(msg);
      }
      warned = true;
    }
    return fn.apply(this, arguments);
  }

  return deprecated;
};

var debugs = {};
var debugEnviron;
exports.debuglog = function (set) {
  if (isUndefined(debugEnviron)) debugEnviron = process.env.NODE_DEBUG || '';
  set = set.toUpperCase();
  if (!debugs[set]) {
    if (new RegExp('\\b' + set + '\\b', 'i').test(debugEnviron)) {
      var pid = process.pid;
      debugs[set] = function () {
        var msg = exports.format.apply(exports, arguments);
        console.error('%s %d: %s', set, pid, msg);
      };
    } else {
      debugs[set] = function () {};
    }
  }
  return debugs[set];
};

/**
 * Echos the value of a value. Trys to print the value out
 * in the best way possible given the different types.
 *
 * @param {Object} obj The object to print out.
 * @param {Object} opts Optional options object that alters the output.
 */
/* legacy: obj, showHidden, depth, colors*/
function inspect(obj, opts) {
  // default options
  var ctx = {
    seen: [],
    stylize: stylizeNoColor
  };
  // legacy...
  if (arguments.length >= 3) ctx.depth = arguments[2];
  if (arguments.length >= 4) ctx.colors = arguments[3];
  if (isBoolean(opts)) {
    // legacy...
    ctx.showHidden = opts;
  } else if (opts) {
    // got an "options" object
    exports._extend(ctx, opts);
  }
  // set default options
  if (isUndefined(ctx.showHidden)) ctx.showHidden = false;
  if (isUndefined(ctx.depth)) ctx.depth = 2;
  if (isUndefined(ctx.colors)) ctx.colors = false;
  if (isUndefined(ctx.customInspect)) ctx.customInspect = true;
  if (ctx.colors) ctx.stylize = stylizeWithColor;
  return formatValue(ctx, obj, ctx.depth);
}
exports.inspect = inspect;

// http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
inspect.colors = {
  'bold': [1, 22],
  'italic': [3, 23],
  'underline': [4, 24],
  'inverse': [7, 27],
  'white': [37, 39],
  'grey': [90, 39],
  'black': [30, 39],
  'blue': [34, 39],
  'cyan': [36, 39],
  'green': [32, 39],
  'magenta': [35, 39],
  'red': [31, 39],
  'yellow': [33, 39]
};

// Don't use 'blue' not visible on cmd.exe
inspect.styles = {
  'special': 'cyan',
  'number': 'yellow',
  'boolean': 'yellow',
  'undefined': 'grey',
  'null': 'bold',
  'string': 'green',
  'date': 'magenta',
  // "name": intentionally not styling
  'regexp': 'red'
};

function stylizeWithColor(str, styleType) {
  var style = inspect.styles[styleType];

  if (style) {
    return '\u001b[' + inspect.colors[style][0] + 'm' + str + '\u001b[' + inspect.colors[style][1] + 'm';
  } else {
    return str;
  }
}

function stylizeNoColor(str, styleType) {
  return str;
}

function arrayToHash(array) {
  var hash = {};

  array.forEach(function (val, idx) {
    hash[val] = true;
  });

  return hash;
}

function formatValue(ctx, value, recurseTimes) {
  // Provide a hook for user-specified inspect functions.
  // Check that value is an object with an inspect function on it
  if (ctx.customInspect && value && isFunction(value.inspect) &&
  // Filter out the util module, it's inspect function is special
  value.inspect !== exports.inspect &&
  // Also filter out any prototype objects using the circular check.
  !(value.constructor && value.constructor.prototype === value)) {
    var ret = value.inspect(recurseTimes, ctx);
    if (!isString(ret)) {
      ret = formatValue(ctx, ret, recurseTimes);
    }
    return ret;
  }

  // Primitive types cannot have properties
  var primitive = formatPrimitive(ctx, value);
  if (primitive) {
    return primitive;
  }

  // Look up the keys of the object.
  var keys = Object.keys(value);
  var visibleKeys = arrayToHash(keys);

  if (ctx.showHidden) {
    keys = Object.getOwnPropertyNames(value);
  }

  // IE doesn't make error fields non-enumerable
  // http://msdn.microsoft.com/en-us/library/ie/dww52sbt(v=vs.94).aspx
  if (isError(value) && (keys.indexOf('message') >= 0 || keys.indexOf('description') >= 0)) {
    return formatError(value);
  }

  // Some type of object without properties can be shortcutted.
  if (keys.length === 0) {
    if (isFunction(value)) {
      var name = value.name ? ': ' + value.name : '';
      return ctx.stylize('[Function' + name + ']', 'special');
    }
    if (isRegExp(value)) {
      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
    }
    if (isDate(value)) {
      return ctx.stylize(Date.prototype.toString.call(value), 'date');
    }
    if (isError(value)) {
      return formatError(value);
    }
  }

  var base = '',
      array = false,
      braces = ['{', '}'];

  // Make Array say that they are Array
  if (isArray(value)) {
    array = true;
    braces = ['[', ']'];
  }

  // Make functions say that they are functions
  if (isFunction(value)) {
    var n = value.name ? ': ' + value.name : '';
    base = ' [Function' + n + ']';
  }

  // Make RegExps say that they are RegExps
  if (isRegExp(value)) {
    base = ' ' + RegExp.prototype.toString.call(value);
  }

  // Make dates with properties first say the date
  if (isDate(value)) {
    base = ' ' + Date.prototype.toUTCString.call(value);
  }

  // Make error with message first say the error
  if (isError(value)) {
    base = ' ' + formatError(value);
  }

  if (keys.length === 0 && (!array || value.length == 0)) {
    return braces[0] + base + braces[1];
  }

  if (recurseTimes < 0) {
    if (isRegExp(value)) {
      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
    } else {
      return ctx.stylize('[Object]', 'special');
    }
  }

  ctx.seen.push(value);

  var output;
  if (array) {
    output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
  } else {
    output = keys.map(function (key) {
      return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
    });
  }

  ctx.seen.pop();

  return reduceToSingleString(output, base, braces);
}

function formatPrimitive(ctx, value) {
  if (isUndefined(value)) return ctx.stylize('undefined', 'undefined');
  if (isString(value)) {
    var simple = '\'' + JSON.stringify(value).replace(/^"|"$/g, '').replace(/'/g, "\\'").replace(/\\"/g, '"') + '\'';
    return ctx.stylize(simple, 'string');
  }
  if (isNumber(value)) return ctx.stylize('' + value, 'number');
  if (isBoolean(value)) return ctx.stylize('' + value, 'boolean');
  // For some reason typeof null is "object", so special case here.
  if (isNull(value)) return ctx.stylize('null', 'null');
}

function formatError(value) {
  return '[' + Error.prototype.toString.call(value) + ']';
}

function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
  var output = [];
  for (var i = 0, l = value.length; i < l; ++i) {
    if (hasOwnProperty(value, String(i))) {
      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys, String(i), true));
    } else {
      output.push('');
    }
  }
  keys.forEach(function (key) {
    if (!key.match(/^\d+$/)) {
      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys, key, true));
    }
  });
  return output;
}

function formatProperty(ctx, value, recurseTimes, visibleKeys, key, array) {
  var name, str, desc;
  desc = Object.getOwnPropertyDescriptor(value, key) || { value: value[key] };
  if (desc.get) {
    if (desc.set) {
      str = ctx.stylize('[Getter/Setter]', 'special');
    } else {
      str = ctx.stylize('[Getter]', 'special');
    }
  } else {
    if (desc.set) {
      str = ctx.stylize('[Setter]', 'special');
    }
  }
  if (!hasOwnProperty(visibleKeys, key)) {
    name = '[' + key + ']';
  }
  if (!str) {
    if (ctx.seen.indexOf(desc.value) < 0) {
      if (isNull(recurseTimes)) {
        str = formatValue(ctx, desc.value, null);
      } else {
        str = formatValue(ctx, desc.value, recurseTimes - 1);
      }
      if (str.indexOf('\n') > -1) {
        if (array) {
          str = str.split('\n').map(function (line) {
            return '  ' + line;
          }).join('\n').substr(2);
        } else {
          str = '\n' + str.split('\n').map(function (line) {
            return '   ' + line;
          }).join('\n');
        }
      }
    } else {
      str = ctx.stylize('[Circular]', 'special');
    }
  }
  if (isUndefined(name)) {
    if (array && key.match(/^\d+$/)) {
      return str;
    }
    name = JSON.stringify('' + key);
    if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
      name = name.substr(1, name.length - 2);
      name = ctx.stylize(name, 'name');
    } else {
      name = name.replace(/'/g, "\\'").replace(/\\"/g, '"').replace(/(^"|"$)/g, "'");
      name = ctx.stylize(name, 'string');
    }
  }

  return name + ': ' + str;
}

function reduceToSingleString(output, base, braces) {
  var numLinesEst = 0;
  var length = output.reduce(function (prev, cur) {
    numLinesEst++;
    if (cur.indexOf('\n') >= 0) numLinesEst++;
    return prev + cur.replace(/\u001b\[\d\d?m/g, '').length + 1;
  }, 0);

  if (length > 60) {
    return braces[0] + (base === '' ? '' : base + '\n ') + ' ' + output.join(',\n  ') + ' ' + braces[1];
  }

  return braces[0] + base + ' ' + output.join(', ') + ' ' + braces[1];
}

// NOTE: These type checking functions intentionally don't use `instanceof`
// because it is fragile and can be easily faked with `Object.create()`.
function isArray(ar) {
  return Array.isArray(ar);
}
exports.isArray = isArray;

function isBoolean(arg) {
  return typeof arg === 'boolean';
}
exports.isBoolean = isBoolean;

function isNull(arg) {
  return arg === null;
}
exports.isNull = isNull;

function isNullOrUndefined(arg) {
  return arg == null;
}
exports.isNullOrUndefined = isNullOrUndefined;

function isNumber(arg) {
  return typeof arg === 'number';
}
exports.isNumber = isNumber;

function isString(arg) {
  return typeof arg === 'string';
}
exports.isString = isString;

function isSymbol(arg) {
  return (typeof arg === 'undefined' ? 'undefined' : _typeof(arg)) === 'symbol';
}
exports.isSymbol = isSymbol;

function isUndefined(arg) {
  return arg === void 0;
}
exports.isUndefined = isUndefined;

function isRegExp(re) {
  return isObject(re) && objectToString(re) === '[object RegExp]';
}
exports.isRegExp = isRegExp;

function isObject(arg) {
  return (typeof arg === 'undefined' ? 'undefined' : _typeof(arg)) === 'object' && arg !== null;
}
exports.isObject = isObject;

function isDate(d) {
  return isObject(d) && objectToString(d) === '[object Date]';
}
exports.isDate = isDate;

function isError(e) {
  return isObject(e) && (objectToString(e) === '[object Error]' || e instanceof Error);
}
exports.isError = isError;

function isFunction(arg) {
  return typeof arg === 'function';
}
exports.isFunction = isFunction;

function isPrimitive(arg) {
  return arg === null || typeof arg === 'boolean' || typeof arg === 'number' || typeof arg === 'string' || (typeof arg === 'undefined' ? 'undefined' : _typeof(arg)) === 'symbol' || // ES6 symbol
  typeof arg === 'undefined';
}
exports.isPrimitive = isPrimitive;

exports.isBuffer = require('./support/isBuffer');

function objectToString(o) {
  return Object.prototype.toString.call(o);
}

function pad(n) {
  return n < 10 ? '0' + n.toString(10) : n.toString(10);
}

var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

// 26 Feb 16:19:34
function timestamp() {
  var d = new Date();
  var time = [pad(d.getHours()), pad(d.getMinutes()), pad(d.getSeconds())].join(':');
  return [d.getDate(), months[d.getMonth()], time].join(' ');
}

// log is just a thin wrapper to console.log that prepends a timestamp
exports.log = function () {
  console.log('%s - %s', timestamp(), exports.format.apply(exports, arguments));
};

/**
 * Inherit the prototype methods from one constructor into another.
 *
 * The Function.prototype.inherits from lang.js rewritten as a standalone
 * function (not on Function.prototype). NOTE: If this file is to be loaded
 * during bootstrapping this function needs to be rewritten using some native
 * functions as prototype setup using normal JavaScript does not work as
 * expected during bootstrapping (see mirror.js in r114903).
 *
 * @param {function} ctor Constructor function which needs to inherit the
 *     prototype.
 * @param {function} superCtor Constructor function to inherit prototype from.
 */
exports.inherits = require('inherits');

exports._extend = function (origin, add) {
  // Don't do anything if add isn't an object
  if (!add || !isObject(add)) return origin;

  var keys = Object.keys(add);
  var i = keys.length;
  while (i--) {
    origin[keys[i]] = add[keys[i]];
  }
  return origin;
};

function hasOwnProperty(obj, prop) {
  return Object.prototype.hasOwnProperty.call(obj, prop);
}

}).call(this,require('_process'),typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./support/isBuffer":194,"_process":193,"inherits":192}],196:[function(require,module,exports){
"use strict";

},{}],197:[function(require,module,exports){
'use strict';

/**
 * Module Dependencies
 */

var graphql = require('graphql');
var assert = require('assert');
/**
 * Export `Generate`
 */

module.exports = Generate;

/**
 * Definitions
 */

var InputObjectType = graphql.GraphQLInputObjectType;
var InterfaceType = graphql.GraphQLInterfaceType;
var ScalarType = graphql.GraphQLScalarType;
var ObjectType = graphql.GraphQLObjectType;
var UnionType = graphql.GraphQLUnionType;
var NonNullType = graphql.GraphQLNonNull;
var EnumType = graphql.GraphQLEnumType;
var ListType = graphql.GraphQLList;

/**
 * Built-in Scalars
 */

var builtInScalars = {
  'String': graphql.GraphQLString,
  'Int': graphql.GraphQLInt,
  'Float': graphql.GraphQLFloat,
  'Boolean': graphql.GraphQLBoolean,
  'ID': graphql.GraphQLID
};

/**
 * Generate
 */

function Generate(document, implementations) {
  var description = [];
  var unions = [];

  var objectTypes = {};
  var interfaceTypes = {};
  var inputTypes = {};
  var unionTypes = {};
  var scalarTypes = {};
  var enumTypes = {};

  /**
   * Start from the top of the document
   */

  document.definitions.forEach(function (node) {
    switch (node.kind) {
      case 'Comment':
        description.push(node.value.substr(1));
        break;
      case 'ObjectTypeDefinition':
        objectTypes[node.name.value] = getObjectTypeDefinition(node);
        break;
      case 'InterfaceTypeDefinition':
        interfaceTypes[node.name.value] = getInterfaceTypeDefinition(node);
        break;
      case 'UnionTypeDefinition':
        unions.push(node);
        break;
      case 'ScalarTypeDefinition':
        scalarTypes[node.name.value] = getScalarTypeDefinition(node);
        break;
      case 'EnumTypeDefinition':
        enumTypes[node.name.value] = getEnumTypeDefinition(node);
        break;
      case 'InputObjectTypeDefinition':
        inputTypes[node.name.value] = getInputObjectTypeDefinition(node);
        break;
      default:
        throw new Error('Unexpected node type ' + node.kind);
    }
  });

  // Delay unions until all other types exist, otherwise circular deps will cause problems
  unions.forEach(function (node) {
    unionTypes[node.name.value] = getUnionTypeDefinition(node);
  });

  /**
   * Return the types
   */

  return {
    objectTypes: objectTypes,
    interfaceTypes: interfaceTypes,
    unionTypes: unionTypes,
    scalarTypes: scalarTypes,
    enumTypes: enumTypes
  };

  /**
   * Get a description
   */

  function getDescription() {
    if (description.length === 0) return null;
    var prefix = description.reduce(function (a, b) {
      return Math.min(a, /^\s*/.exec(b)[0].length);
    }, Infinity);
    var result = description.map(function (str) {
      return str.substr(prefix);
    }).join('\n');
    description = [];
    return result;
  }

  /**
   * Get the output type
   */

  function getOutputType(node) {
    if (node.kind === 'NamedType') {
      var t = builtInScalars[node.name.value] || objectTypes[node.name.value] || interfaceTypes[node.name.value] || unionTypes[node.name.value] || scalarTypes[node.name.value] || enumTypes[node.name.value] || inputTypes[node.name.value];
      if (!t) {
        throw new Error(node.name.value + ' is not implemented.');
      }
      return t;
    }
    if (node.kind === 'ListType') {
      return new ListType(getOutputType(node.type));
    }
    if (node.kind === 'NonNullType') {
      return new NonNullType(getOutputType(node.type));
    }
    console.dir(node);
    throw new Error(node.kind + ' is not supported');
  }

  /**
   * Get the input type
   */

  function getInputType(node) {
    if (node.kind === 'NamedType') {
      var t = builtInScalars[node.name.value] || interfaceTypes[node.name.value] || unionTypes[node.name.value] || scalarTypes[node.name.value] || enumTypes[node.name.value] || inputTypes[node.name.value];

      if (!t) {
        throw new Error(node.name.value + ' is not implemented.');
      }
      return t;
    }
    if (node.kind === 'ListType') {
      return new ListType(getOutputType(node.type));
    }
    if (node.kind === 'NonNullType') {
      return new NonNullType(getOutputType(node.type));
    }
    console.dir(node);
    throw new Error(node.kind + ' is not supported');
  }

  /**
   * Get the raw value
   */

  function getRawValue(node) {
    switch (node.kind) {
      case 'NumberValue':
      case 'StringValue':
      case 'BooleanValue':
        return node.value;
      case 'EnumValue':
        return node.name.value;
      case 'ListValue':
        return node.values.map(getRawValue);
      case 'ObjectValue':
        var res = {};
        node.fields.forEach(function (field) {
          res[field.name.value] = getRawValue(field.value);
        });
        return res;
      default:
        console.dir(node);
        throw new Error(node.kind + ' is not supported');
    }
  }

  /**
   * Get the raw value from the official schema
   */

  function getRawValueFromOfficialSchema(node) {
    switch (node.kind) {
      case 'IntValue':
      case 'FloatValue':
        return JSON.parse(node.value);
      case 'StringValue':
      case 'BooleanValue':
      case 'EnumValue':
        return node.value;
      case 'ListValue':
        return node.values.map(getRawValueFromOfficialSchema);
      case 'ObjectValue':
        var res = {};
        node.fields.forEach(function (field) {
          res[field.name.value] = getRawValueFromOfficialSchema(field.value);
        });
        return res;
      default:
        console.dir(node);
        throw new Error(node.kind + ' is not supported');
    }
  }

  /**
   * Get the interface
   */

  function getInterface(node) {
    assert(node.kind === 'NamedType');
    var t = interfaceTypes[node.name.value];
    if (!t) {
      throw new Error(node.name.value + ' is not defined.');
    }
    return t;
  }

  /**
   * Get the field definitions
   */

  function getFieldDefinitions(node, isInterface) {
    var typeName = node.name.value;
    var fields = {};
    node.fields.forEach(function (field) {
      switch (field.kind) {
        case 'Comment':
          description.push(field.value.substr(1));
          break;
        case 'FieldDefinition':
          if (!isInterface && field.arguments && !(implementations[typeName] && implementations[typeName][field.name.value])) {
            throw new Error(typeName + '.' + field.name.value + ' is calculated (i.e. it ' + 'accepts arguments) but does not have an implementation');
          }
          var args = undefined;
          if (field.arguments && field.arguments.length) {
            args = {};
            field.arguments.forEach(function (arg) {
              if (arg.kind === 'Comment') return;
              args[arg.name.value] = {
                type: getInputType(arg.type),
                defaultValue: arg.defaultValue ? getRawValue(arg.defaultValue) : undefined
              };
            });
          }
          fields[field.name.value] = {
            name: field.name.value,
            type: getOutputType(field.type),
            description: getDescription(),
            args: args,
            resolve: !isInterface && field.arguments ? implementations[typeName][field.name.value] : undefined
            // TODO: deprecationReason: string
          };
          break;
        default:
          throw new Error('Unexpected node type ' + field.kind);
      }
    });
    return fields;
  }

  /**
   * Get the object type definition
   */

  function getObjectTypeDefinition(node) {
    var typeName = node.name.value;
    return new ObjectType({
      name: typeName,
      description: getDescription(),
      // TODO: interfaces
      interfaces: node.interfaces ? function () {
        return node.interfaces.map(getInterface);
      } : null,
      fields: function fields() {
        return getFieldDefinitions(node, false);
      }
    });
  }

  /**
   * Get the interface type definition
   */

  function getInterfaceTypeDefinition(node) {
    return new InterfaceType({
      name: node.name.value,
      description: getDescription(),
      // resolveType?: (value: any, info?: GraphQLResolveInfo) => ?GraphQLObjectType
      resolveType: implementations[node.name.value] && implementations[node.name.value]['resolveType'],
      fields: function fields() {
        return getFieldDefinitions(node, true);
      }
    });
  }

  /**
   * Get the union type definition
   */

  function getUnionTypeDefinition(node) {
    return new UnionType({
      name: node.name.value,
      description: getDescription(),
      types: node.types.map(getOutputType),
      resolveType: implementations[node.name.value] && implementations[node.name.value]['resolveType']
    });
  }

  /**
   * Get the scalar type definition
   */

  function getScalarTypeDefinition(node) {
    var imp = implementations[node.name.value];
    return new ScalarType({
      name: node.name.value,
      description: getDescription(),
      serialize: imp && imp.serialize,
      parseValue: imp && (imp.parseValue || imp.parse),
      parseLiteral: imp && imp.parseLiteral ? imp.parseLiteral : imp && (imp.parseValue || imp.parse) ? function (ast) {
        return (imp.parseValue || imp.parse)(getRawValueFromOfficialSchema(ast));
      } : undefined
    });
  }

  /**
   * Get the enum type definition
   */

  function getEnumTypeDefinition(node) {
    var d = getDescription();
    var values = {};
    node.values.forEach(function (value) {
      switch (value.kind) {
        case 'Comment':
          description.push(value.value.substr(1));
          break;
        case 'EnumValueDefinition':
          values[value.name.value] = {
            description: getDescription(),
            value: implementations[node.name.value] && implementations[node.name.value][value.name.value]
            // deprecationReason?: string;
          };
          break;
        default:
          throw new Error('Unexpected node type ' + value.kind);
      }
    });
    return new EnumType({
      name: node.name.value,
      description: d,
      values: values
    });
  }

  function getInputObjectTypeDefinition(node) {
    var d = getDescription();
    var fields = {};

    node.fields.forEach(function (field) {
      switch (field.kind) {
        case 'Comment':
          description.push(field.value.substr(1));
          break;
        case 'InputValueDefinition':
          fields[field.name.value] = {
            name: field.name,
            description: getDescription(),
            type: getInputType(field.type),
            defaultValue: field.defaultValue ? getRawValue(field.defaultValue) : undefined
          };
          break;
        default:
          throw new Error('Unexpected node type ' + field.kind);
      }
    });

    return new InputObjectType({
      name: node.name.value,
      description: d,
      fields: fields
    });
  }
}

},{"assert":191,"graphql":212}],198:[function(require,module,exports){
'use strict';

/**
 * Module Dependencies
 */

var graphql = require('graphql');
var parse = require('./parse');

/**
 * Generators
 */

var Schema = require('./generators/schema');
var Type = require('./generators/type');

/**
 * Export `Create`
 */

module.exports = Create;

/**
 * Create the query
 */

function Create(schema, implementation) {
  var types = Type(parse(schema), implementation);
  var object_types = types.objectTypes;

  var schema = new graphql.GraphQLSchema({
    query: object_types['Query'],
    mutation: object_types['Mutation'],
    subscription: object_types['Subscription']
  });

  return function query(query, params, root_value, operation) {
    return graphql.graphql(schema, query, root_value, params || {}, operation);
  };
}

},{"./generators/schema":196,"./generators/type":197,"./parse":199,"graphql":212}],199:[function(require,module,exports){
'use strict';

/**
 * Module Dependencies
 */

var debug = require('debug')('graph.ql:parser');

/**
 * Export `Parse`
 */

module.exports = Parse;

/**
 * Space Regexp
 */

var rspace = /^[ \f\r\t\v\u00a0\u1680\u180e\u2000-\u200a\u2028\u2029\u202f\u205f\u3000\ufeff]+/;

/**
 * Initialize `Parse`
 *
 * @param {String} schema
 * @param {Object} implementation
 * @return {Function}
 */

function Parse(schema) {
  if (!(this instanceof Parse)) return new Parse(schema);

  this.original = schema;
  this.str = schema;

  return this.document();
}

/**
 * match
 */

Parse.prototype.match = function (pattern) {
  // skip over whitespace
  this.ignored();

  var str = this.str;

  if (typeof pattern === 'string') {
    if (str.substr(0, pattern.length) === pattern) {
      this.str = str.substr(pattern.length);
      return pattern;
    }
  } else {
    var match = pattern.exec(str);
    if (match) {
      this.str = str.substr(match[0].length);
      return match[0];
    }
  }
};

/**
 * Required values
 */

Parse.prototype.required = function (value, name) {
  if (value) {
    return value;
  } else {
    throw this.error('Expected ' + name + ' but got "' + this.str[0] + '"');
  }
};

/**
 * expect
 */

Parse.prototype.expect = function (str) {
  this.required(this.match(str), '"' + str + '"');
};

/**
 * ignored
 */

Parse.prototype.ignored = function () {
  var str = this.str;

  while (true) {

    // newline
    if (str[0] === '\n') {
      str = str.substr(1);
      continue;
    }

    // comma
    if (str[0] === ',') {
      str = str.substr(1);
      continue;
    }

    // other spacing
    var m = rspace.exec(str);
    if (m) {
      str = str.substr(m[0].length);
      continue;
    }

    break;
  }

  this.str = str;
};

/**
 * document
 */

Parse.prototype.document = function () {
  var definitions = this.list(this.type_definition);

  if (this.str.length) {
    throw this.error('invalid definition (must be either a type, interface, union, scalar, input or extend)');
  }

  // document token
  return {
    kind: 'Document',
    definitions: definitions
  };
};

/**
 * list
 */

Parse.prototype.list = function (node_type) {
  var result = [];

  while (true) {
    var node = this.comment() || node_type.call(this);
    if (node) result.push(node);else break;
  }
  return result;
};

/**
 * comment
 */

Parse.prototype.comment = function () {
  var c = this.match(/^\#[^\n]*/);
  if (c) {
    return {
      kind: 'Comment',
      value: c
    };
  }
};

/**
 * type_definition
 */

Parse.prototype.type_definition = function () {
  return this.object_type_definition() || this.interface_type_definition() || this.union_type_definition() || this.scalar_type_definition() || this.enum_type_definition() || this.input_object_type_definition() || this.type_extension_definition();
};

/**
 * Object type definition
 *
 * Example: type Developer { ... }
 */

Parse.prototype.object_type_definition = function () {
  if (this.match('type')) {
    var node = { kind: 'ObjectTypeDefinition' };
    node.name = this.required(this.name(), 'name');
    node.interfaces = this.implements() || [];
    this.expect('{');
    node.fields = this.list(this.field_definition);
    this.expect('}');
    return node;
  }
};

/**
 * field_definition
 */

Parse.prototype.field_definition = function () {
  var node = { kind: 'FieldDefinition' };

  node.name = this.name();
  if (!node.name) return;

  node.arguments = this.arguments_definition();
  this.expect(':');
  node.type = this.required(this.type(), 'type');

  return node;
};

/**
 * arguments_definition
 */

Parse.prototype.arguments_definition = function () {
  if (!this.match('(')) return null;
  var args = this.list(this.input_value_definition);
  this.expect(')');
  return args || [];
};

/**
 * Input Value Definition
 */

Parse.prototype.input_value_definition = function () {
  var node = { kind: 'InputValueDefinition' };

  node.name = this.name();
  if (!node.name) return;

  this.expect(':');
  node.type = this.required(this.type(), 'type');
  node.defaultValue = this.default_value() || null;

  return node;
};

/**
 * Interface type definition
 *
 * Example: interface Person { ... }
 */

Parse.prototype.interface_type_definition = function () {
  if (this.match('interface')) {
    var node = { kind: 'InterfaceTypeDefinition' };
    node.name = this.required(this.name(), 'Name');
    this.expect('{');
    node.fields = this.list(this.field_definition);
    this.expect('}');
    return node;
  }
};

/**
 * implements
 */

Parse.prototype.implements = function () {
  if (this.match('implements')) {
    return this.list(this.named_type);
  }
};

/**
 * Union type definition
 *
 * Example: union Animal = Cat | Dog
 */

Parse.prototype.union_type_definition = function () {
  if (this.match('union')) {
    var node = { kind: 'UnionTypeDefinition' };
    node.name = this.required(this.name(), 'Name');
    this.expect('=');

    var types = [];
    types.push(this.required(this.named_type(), 'NamedType'));
    while (this.match('|')) {
      types.push(this.required(this.named_type(), 'NamedType'));
    }
    node.types = types;

    return node;
  }
};

/**
 * Scalar type definition
 *
 * Example: scalar Date
 */

Parse.prototype.scalar_type_definition = function () {
  if (this.match('scalar')) {
    var node = { kind: 'ScalarTypeDefinition' };
    node.name = this.required(this.name(), 'Name');
    return node;
  }
};

/**
 * Enum Type Definition
 *
 * Example: enum Site { ... }
 */

Parse.prototype.enum_type_definition = function () {
  if (this.match('enum')) {
    var node = { kind: 'EnumTypeDefinition' };
    node.name = this.required(this.name(), 'Name');
    this.expect('{');
    node.values = this.list(this.enum_value_definition);
    this.expect('}');
    return node;
  }
};

/**
 * enum_value_definition
 */

Parse.prototype.enum_value_definition = function () {
  var name = this.name();
  if (name) return { kind: 'EnumValueDefinition', name: name };
};

/**
 * Input Object Type Definition
 *
 * Example: input Film { ... }
 */

Parse.prototype.input_object_type_definition = function () {
  if (this.match('input')) {
    var node = { kind: 'InputObjectTypeDefinition' };
    node.name = this.required(this.name(), 'Name');
    this.expect('{');
    node.fields = this.list(this.input_value_definition);
    this.expect('}');
    return node;
  }
};

/**
 * Extension Type definition
 *
 * Example: extends type Film { ... }
 */

Parse.prototype.type_extension_definition = function () {
  if (this.match('extend')) {
    var node = { kind: 'TypeExtensionDefinition' };
    node.definition = this.required(this.object_type_definition(), 'ObjectTypeDefinition');
    return node;
  }
};

/**
 * name
 */

Parse.prototype.name = function () {
  var name = this.match(/^[_A-Za-z][_0-9A-Za-z]*/);
  if (name) {
    return {
      kind: 'Name',
      value: name
    };
  }
};

/**
 * Named type
 */

Parse.prototype.named_type = function () {
  var name = this.name();
  if (name) {
    return {
      kind: 'NamedType',
      name: name
    };
  }
};

/**
 * list_type
 */

Parse.prototype.list_type = function () {
  if (this.match('[')) {
    var node = {
      kind: 'ListType',
      type: this.required(this.type(), 'Type')
    };
    this.expect(']');
    return node;
  }
};

/**
 * type
 */

Parse.prototype.type = function () {
  var t = this.named_type() || this.list_type();
  if (this.match('!')) {
    return { kind: 'NonNullType', type: t };
  }
  return t;
};

/**
 * value
 */

Parse.prototype.value = function () {
  return this.number_value() || this.string_value() || this.boolean_value() || this.enum_value() || this.list_value() || this.object_value();
};

/**
 * number_value
 */

Parse.prototype.number_value = function () {
  var str = this.match(/^(\-?0|\-?[1-9][0-9]*)(\.[0-9]+)?([Ee](\+|\-)?[0-9]+)?/);
  if (str) {
    return {
      kind: 'NumberValue',
      value: JSON.parse(str)
    };
  }
};

/**
 * string_value
 */

Parse.prototype.string_value = function () {
  var str = this.match(/^\"([^\"\\\n]|\\\\|\\\")*\"/);
  if (str) {
    return {
      kind: 'StringValue',
      value: JSON.parse(str)
    };
  }
};

/**
 * boolean_value
 */

Parse.prototype.boolean_value = function () {
  var TRUE = this.match('true');
  var FALSE = this.match('false');
  if (TRUE || FALSE) {
    return {
      kind: 'BooleanValue',
      value: TRUE ? true : false
    };
  }
};

/**
 * enum_value
 */

Parse.prototype.enum_value = function () {
  var n = this.name();
  if (n) {
    return {
      kind: 'EnumValue',
      name: n
    };
  }
};

/**
 * list_value
 */

Parse.prototype.list_value = function () {
  if (this.match('[')) {
    var node = { kind: 'ListValue' };
    node.values = this.list(this.value);
    this.expect(']');
    return node;
  }
};

/**
 * object_field
 */

Parse.prototype.object_field = function () {
  var n = this.name();
  if (n) {
    this.expect(':');
    return {
      kind: 'ObjectField',
      name: n,
      value: this.required(this.value(), 'Value')
    };
  }
};

/**
 * object_value
 */

Parse.prototype.object_value = function () {
  if (this.match('{')) {
    var node = { kind: 'ObjectValue' };
    node.fields = this.list(this.object_field);
    this.expect('}');
    return node;
  }
};

/**
 * default_value
 */

Parse.prototype.default_value = function () {
  if (this.match('=')) {
    return this.required(this.value(), 'Value');
  }
};

/**
 * Error
 */

Parse.prototype.error = function (msg) {
  var offset = this.original.length - this.str.length;
  return new Error(msg + error_location(this.original, offset));
};

/**
 * Generate the error location
 *
 * @param {String} str
 * @param {Number} offset
 * @return {String}
 */

function error_location(str, offset) {
  var lines = [];

  var left = offset - 1;
  var right = offset;
  var chunk;

  // before
  chunk = [];
  while (str[left] && str[left] !== '\n') {
    chunk.push(str[left]);
    left--;
  }
  lines[1] = '    ' + chunk.reverse().join('');

  // place caret
  var padding = Array(lines[1].length).join(' ');
  lines[2] = padding + '^';

  // line before
  chunk = [];
  left--;
  while (str[left] && str[left] !== '\n') {
    chunk.push(str[left]);
    left--;
  }
  lines[0] = '    ' + chunk.reverse().join('');

  // after
  chunk = [];
  while (str[right] && str[right] !== '\n') {
    chunk.push(str[right]);
    right++;
  }
  lines[1] += chunk.join('');

  // line after
  chunk = [];
  right++;
  while (str[right] && str[right] !== '\n') {
    chunk.push(str[right]);
    right++;
  }
  lines[3] = '    ' + chunk.join('');

  return '\n\n' + lines.join('\n') + '\n';
}

},{"debug":200}],200:[function(require,module,exports){
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

/**
 * This is the web browser implementation of `debug()`.
 *
 * Expose `debug()` as the module.
 */

exports = module.exports = require('./debug');
exports.log = log;
exports.formatArgs = formatArgs;
exports.save = save;
exports.load = load;
exports.useColors = useColors;
exports.storage = 'undefined' != typeof chrome && 'undefined' != typeof chrome.storage ? chrome.storage.local : localstorage();

/**
 * Colors.
 */

exports.colors = ['lightseagreen', 'forestgreen', 'goldenrod', 'dodgerblue', 'darkorchid', 'crimson'];

/**
 * Currently only WebKit-based Web Inspectors, Firefox >= v31,
 * and the Firebug extension (any Firefox version) are known
 * to support "%c" CSS customizations.
 *
 * TODO: add a `localStorage` variable to explicitly enable/disable colors
 */

function useColors() {
  // is webkit? http://stackoverflow.com/a/16459606/376773
  return 'WebkitAppearance' in document.documentElement.style ||
  // is firebug? http://stackoverflow.com/a/398120/376773
  window.console && (console.firebug || console.exception && console.table) ||
  // is firefox >= v31?
  // https://developer.mozilla.org/en-US/docs/Tools/Web_Console#Styling_messages
  navigator.userAgent.toLowerCase().match(/firefox\/(\d+)/) && parseInt(RegExp.$1, 10) >= 31;
}

/**
 * Map %j to `JSON.stringify()`, since no Web Inspectors do that by default.
 */

exports.formatters.j = function (v) {
  return JSON.stringify(v);
};

/**
 * Colorize log arguments if enabled.
 *
 * @api public
 */

function formatArgs() {
  var args = arguments;
  var useColors = this.useColors;

  args[0] = (useColors ? '%c' : '') + this.namespace + (useColors ? ' %c' : ' ') + args[0] + (useColors ? '%c ' : ' ') + '+' + exports.humanize(this.diff);

  if (!useColors) return args;

  var c = 'color: ' + this.color;
  args = [args[0], c, 'color: inherit'].concat(Array.prototype.slice.call(args, 1));

  // the final "%c" is somewhat tricky, because there could be other
  // arguments passed either before or after the %c, so we need to
  // figure out the correct index to insert the CSS into
  var index = 0;
  var lastC = 0;
  args[0].replace(/%[a-z%]/g, function (match) {
    if ('%%' === match) return;
    index++;
    if ('%c' === match) {
      // we only are interested in the *last* %c
      // (the user may have provided their own)
      lastC = index;
    }
  });

  args.splice(lastC, 0, c);
  return args;
}

/**
 * Invokes `console.log()` when available.
 * No-op when `console.log` is not a "function".
 *
 * @api public
 */

function log() {
  // this hackery is required for IE8/9, where
  // the `console.log` function doesn't have 'apply'
  return 'object' === (typeof console === 'undefined' ? 'undefined' : _typeof(console)) && console.log && Function.prototype.apply.call(console.log, console, arguments);
}

/**
 * Save `namespaces`.
 *
 * @param {String} namespaces
 * @api private
 */

function save(namespaces) {
  try {
    if (null == namespaces) {
      exports.storage.removeItem('debug');
    } else {
      exports.storage.debug = namespaces;
    }
  } catch (e) {}
}

/**
 * Load `namespaces`.
 *
 * @return {String} returns the previously persisted debug modes
 * @api private
 */

function load() {
  var r;
  try {
    r = exports.storage.debug;
  } catch (e) {}
  return r;
}

/**
 * Enable namespaces listed in `localStorage.debug` initially.
 */

exports.enable(load());

/**
 * Localstorage attempts to return the localstorage.
 *
 * This is necessary because safari throws
 * when a user disables cookies/localstorage
 * and you attempt to access it.
 *
 * @return {LocalStorage}
 * @api private
 */

function localstorage() {
  try {
    return window.localStorage;
  } catch (e) {}
}

},{"./debug":201}],201:[function(require,module,exports){
'use strict';

/**
 * This is the common logic for both the Node.js and web browser
 * implementations of `debug()`.
 *
 * Expose `debug()` as the module.
 */

exports = module.exports = debug;
exports.coerce = coerce;
exports.disable = disable;
exports.enable = enable;
exports.enabled = enabled;
exports.humanize = require('ms');

/**
 * The currently active debug mode names, and names to skip.
 */

exports.names = [];
exports.skips = [];

/**
 * Map of special "%n" handling functions, for the debug "format" argument.
 *
 * Valid key names are a single, lowercased letter, i.e. "n".
 */

exports.formatters = {};

/**
 * Previously assigned color.
 */

var prevColor = 0;

/**
 * Previous log timestamp.
 */

var prevTime;

/**
 * Select a color.
 *
 * @return {Number}
 * @api private
 */

function selectColor() {
  return exports.colors[prevColor++ % exports.colors.length];
}

/**
 * Create a debugger with the given `namespace`.
 *
 * @param {String} namespace
 * @return {Function}
 * @api public
 */

function debug(namespace) {

  // define the `disabled` version
  function disabled() {}
  disabled.enabled = false;

  // define the `enabled` version
  function enabled() {

    var self = enabled;

    // set `diff` timestamp
    var curr = +new Date();
    var ms = curr - (prevTime || curr);
    self.diff = ms;
    self.prev = prevTime;
    self.curr = curr;
    prevTime = curr;

    // add the `color` if not set
    if (null == self.useColors) self.useColors = exports.useColors();
    if (null == self.color && self.useColors) self.color = selectColor();

    var args = Array.prototype.slice.call(arguments);

    args[0] = exports.coerce(args[0]);

    if ('string' !== typeof args[0]) {
      // anything else let's inspect with %o
      args = ['%o'].concat(args);
    }

    // apply any `formatters` transformations
    var index = 0;
    args[0] = args[0].replace(/%([a-z%])/g, function (match, format) {
      // if we encounter an escaped % then don't increase the array index
      if (match === '%%') return match;
      index++;
      var formatter = exports.formatters[format];
      if ('function' === typeof formatter) {
        var val = args[index];
        match = formatter.call(self, val);

        // now we need to remove `args[index]` since it's inlined in the `format`
        args.splice(index, 1);
        index--;
      }
      return match;
    });

    if ('function' === typeof exports.formatArgs) {
      args = exports.formatArgs.apply(self, args);
    }
    var logFn = enabled.log || exports.log || console.log.bind(console);
    logFn.apply(self, args);
  }
  enabled.enabled = true;

  var fn = exports.enabled(namespace) ? enabled : disabled;

  fn.namespace = namespace;

  return fn;
}

/**
 * Enables a debug mode by namespaces. This can include modes
 * separated by a colon and wildcards.
 *
 * @param {String} namespaces
 * @api public
 */

function enable(namespaces) {
  exports.save(namespaces);

  var split = (namespaces || '').split(/[\s,]+/);
  var len = split.length;

  for (var i = 0; i < len; i++) {
    if (!split[i]) continue; // ignore empty strings
    namespaces = split[i].replace(/\*/g, '.*?');
    if (namespaces[0] === '-') {
      exports.skips.push(new RegExp('^' + namespaces.substr(1) + '$'));
    } else {
      exports.names.push(new RegExp('^' + namespaces + '$'));
    }
  }
}

/**
 * Disable debug output.
 *
 * @api public
 */

function disable() {
  exports.enable('');
}

/**
 * Returns true if the given mode name is enabled, false otherwise.
 *
 * @param {String} name
 * @return {Boolean}
 * @api public
 */

function enabled(name) {
  var i, len;
  for (i = 0, len = exports.skips.length; i < len; i++) {
    if (exports.skips[i].test(name)) {
      return false;
    }
  }
  for (i = 0, len = exports.names.length; i < len; i++) {
    if (exports.names[i].test(name)) {
      return true;
    }
  }
  return false;
}

/**
 * Coerce `val`.
 *
 * @param {Mixed} val
 * @return {Mixed}
 * @api private
 */

function coerce(val) {
  if (val instanceof Error) return val.stack || val.message;
  return val;
}

},{"ms":202}],202:[function(require,module,exports){
'use strict';

/**
 * Helpers.
 */

var s = 1000;
var m = s * 60;
var h = m * 60;
var d = h * 24;
var y = d * 365.25;

/**
 * Parse or format the given `val`.
 *
 * Options:
 *
 *  - `long` verbose formatting [false]
 *
 * @param {String|Number} val
 * @param {Object} options
 * @return {String|Number}
 * @api public
 */

module.exports = function (val, options) {
  options = options || {};
  if ('string' == typeof val) return parse(val);
  return options.long ? long(val) : short(val);
};

/**
 * Parse the given `str` and return milliseconds.
 *
 * @param {String} str
 * @return {Number}
 * @api private
 */

function parse(str) {
  str = '' + str;
  if (str.length > 10000) return;
  var match = /^((?:\d+)?\.?\d+) *(milliseconds?|msecs?|ms|seconds?|secs?|s|minutes?|mins?|m|hours?|hrs?|h|days?|d|years?|yrs?|y)?$/i.exec(str);
  if (!match) return;
  var n = parseFloat(match[1]);
  var type = (match[2] || 'ms').toLowerCase();
  switch (type) {
    case 'years':
    case 'year':
    case 'yrs':
    case 'yr':
    case 'y':
      return n * y;
    case 'days':
    case 'day':
    case 'd':
      return n * d;
    case 'hours':
    case 'hour':
    case 'hrs':
    case 'hr':
    case 'h':
      return n * h;
    case 'minutes':
    case 'minute':
    case 'mins':
    case 'min':
    case 'm':
      return n * m;
    case 'seconds':
    case 'second':
    case 'secs':
    case 'sec':
    case 's':
      return n * s;
    case 'milliseconds':
    case 'millisecond':
    case 'msecs':
    case 'msec':
    case 'ms':
      return n;
  }
}

/**
 * Short format for `ms`.
 *
 * @param {Number} ms
 * @return {String}
 * @api private
 */

function short(ms) {
  if (ms >= d) return Math.round(ms / d) + 'd';
  if (ms >= h) return Math.round(ms / h) + 'h';
  if (ms >= m) return Math.round(ms / m) + 'm';
  if (ms >= s) return Math.round(ms / s) + 's';
  return ms + 'ms';
}

/**
 * Long format for `ms`.
 *
 * @param {Number} ms
 * @return {String}
 * @api private
 */

function long(ms) {
  return plural(ms, d, 'day') || plural(ms, h, 'hour') || plural(ms, m, 'minute') || plural(ms, s, 'second') || ms + ' ms';
}

/**
 * Pluralization helper.
 */

function plural(ms, n, name) {
  if (ms < n) return;
  if (ms < n * 1.5) return Math.floor(ms / n) + ' ' + name;
  return Math.ceil(ms / n) + ' ' + name + 's';
}

},{}],203:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _get = require('babel-runtime/helpers/get')['default'];

var _inherits = require('babel-runtime/helpers/inherits')['default'];

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _language = require('../language');

var GraphQLError = function (_Error) {
  _inherits(GraphQLError, _Error);

  function GraphQLError(message,
  // A flow bug keeps us from declaring nodes as an array of Node
  nodes, /* Node */stack, source, positions) {
    _classCallCheck(this, GraphQLError);

    _get(Object.getPrototypeOf(GraphQLError.prototype), 'constructor', this).call(this, message);
    this.message = message;

    Object.defineProperty(this, 'stack', { value: stack || message });
    Object.defineProperty(this, 'nodes', { value: nodes });

    // Note: flow does not yet know about Object.defineProperty with `get`.
    Object.defineProperty(this, 'source', {
      get: function get() {
        if (source) {
          return source;
        }
        if (nodes && nodes.length > 0) {
          var node = nodes[0];
          return node && node.loc && node.loc.source;
        }
      }
    });

    Object.defineProperty(this, 'positions', {
      get: function get() {
        if (positions) {
          return positions;
        }
        if (nodes) {
          var nodePositions = nodes.map(function (node) {
            return node.loc && node.loc.start;
          });
          if (nodePositions.some(function (p) {
            return p;
          })) {
            return nodePositions;
          }
        }
      }
    });

    Object.defineProperty(this, 'locations', {
      get: function get() {
        var _this = this;

        if (this.positions && this.source) {
          return this.positions.map(function (pos) {
            return (0, _language.getLocation)(_this.source, pos);
          });
        }
      }
    });
  }

  return GraphQLError;
}(Error);

exports.GraphQLError = GraphQLError;

},{"../language":217,"babel-runtime/helpers/class-call-check":237,"babel-runtime/helpers/get":240,"babel-runtime/helpers/inherits":241}],204:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Given a GraphQLError, format it according to the rules described by the
 * Response Format, Errors section of the GraphQL Specification.
 */
'use strict';

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.formatError = formatError;

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

function formatError(error) {
  (0, _jsutilsInvariant2['default'])(error, 'Received null or undefined error.');
  return {
    message: error.message,
    locations: error.locations
  };
}

},{"../jsutils/invariant":214,"babel-runtime/helpers/interop-require-default":242}],205:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _GraphQLError = require('./GraphQLError');

Object.defineProperty(exports, 'GraphQLError', {
  enumerable: true,
  get: function get() {
    return _GraphQLError.GraphQLError;
  }
});

var _syntaxError = require('./syntaxError');

Object.defineProperty(exports, 'syntaxError', {
  enumerable: true,
  get: function get() {
    return _syntaxError.syntaxError;
  }
});

var _locatedError = require('./locatedError');

Object.defineProperty(exports, 'locatedError', {
  enumerable: true,
  get: function get() {
    return _locatedError.locatedError;
  }
});

var _formatError = require('./formatError');

Object.defineProperty(exports, 'formatError', {
  enumerable: true,
  get: function get() {
    return _formatError.formatError;
  }
});

},{"./GraphQLError":203,"./formatError":204,"./locatedError":206,"./syntaxError":207}],206:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.locatedError = locatedError;

var _GraphQLError = require('./GraphQLError');

/**
 * Given an arbitrary Error, presumably thrown while attempting to execute a
 * GraphQL operation, produce a new GraphQLError aware of the location in the
 * document responsible for the original Error.
 */

function locatedError(originalError, nodes) {
  var message = originalError ? originalError.message || String(originalError) : 'An unknown error occurred.';
  var stack = originalError ? originalError.stack : null;
  var error = new _GraphQLError.GraphQLError(message, nodes, stack);
  error.originalError = originalError;
  return error;
}

},{"./GraphQLError":203}],207:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.syntaxError = syntaxError;

var _languageLocation = require('../language/location');

var _GraphQLError = require('./GraphQLError');

/**
 * Produces a GraphQLError representing a syntax error, containing useful
 * descriptive information about the syntax error's position in the source.
 */

function syntaxError(source, position, description) {
  var location = (0, _languageLocation.getLocation)(source, position);
  var error = new _GraphQLError.GraphQLError('Syntax Error ' + source.name + ' (' + location.line + ':' + location.column + ') ' + description + '\n\n' + highlightSourceAtLocation(source, location), undefined, undefined, source, [position]);
  return error;
}

/**
 * Render a helpful description of the location of the error in the GraphQL
 * Source document.
 */
function highlightSourceAtLocation(source, location) {
  var line = location.line;
  var prevLineNum = (line - 1).toString();
  var lineNum = line.toString();
  var nextLineNum = (line + 1).toString();
  var padLen = nextLineNum.length;
  var lines = source.body.split(/\r\n|[\n\r\u2028\u2029]/g);
  return (line >= 2 ? lpad(padLen, prevLineNum) + ': ' + lines[line - 2] + '\n' : '') + lpad(padLen, lineNum) + ': ' + lines[line - 1] + '\n' + Array(2 + padLen + location.column).join(' ') + '^\n' + (line < lines.length ? lpad(padLen, nextLineNum) + ': ' + lines[line] + '\n' : '');
}

function lpad(len, str) {
  return Array(len - str.length + 1).join(' ') + str;
}

},{"../language/location":220,"./GraphQLError":203}],208:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Terminology
 *
 * "Definitions" are the generic name for top-level statements in the document.
 * Examples of this include:
 * 1) Operations (such as a query)
 * 2) Fragments
 *
 * "Operations" are a generic name for requests in the document.
 * Examples of this include:
 * 1) query,
 * 2) mutation
 *
 * "Selections" are the definitions that can appear legally and at
 * single level of the query. These include:
 * 1) field references e.g "a"
 * 2) fragment "spreads" e.g. "...c"
 * 3) inline fragment "spreads" e.g. "...on Type { a }"
 */

/**
 * Data that must be available at all points during query execution.
 *
 * Namely, schema of the type system that is currently executing,
 * and the fragments defined in the query document
 */
'use strict';

/**
 * The result of execution. `data` is the result of executing the
 * query, `errors` is null if no errors occurred, and is a
 * non-empty array if an error occurred.
 */

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var _Promise = require('babel-runtime/core-js/promise')['default'];

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.execute = execute;

var _error = require('../error');

var _jsutilsFind = require('../jsutils/find');

var _jsutilsFind2 = _interopRequireDefault(_jsutilsFind);

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

var _utilitiesTypeFromAST = require('../utilities/typeFromAST');

var _language = require('../language');

var _values = require('./values');

var _typeDefinition = require('../type/definition');

var _typeSchema = require('../type/schema');

var _typeIntrospection = require('../type/introspection');

var _typeDirectives = require('../type/directives');

/**
 * Implements the "Evaluating requests" section of the GraphQL specification.
 *
 * Returns a Promise that will eventually be resolved and never rejected.
 *
 * If the arguments to this function do not result in a legal execution context,
 * a GraphQLError will be thrown immediately explaining the invalid input.
 */

function execute(schema, documentAST, rootValue, variableValues, operationName) {
  (0, _jsutilsInvariant2['default'])(schema, 'Must provide schema');
  (0, _jsutilsInvariant2['default'])(schema instanceof _typeSchema.GraphQLSchema, 'Schema must be an instance of GraphQLSchema. Also ensure that there are ' + 'not multiple versions of GraphQL installed in your node_modules directory.');

  // If a valid context cannot be created due to incorrect arguments,
  // this will throw an error.
  var context = buildExecutionContext(schema, documentAST, rootValue, variableValues, operationName);

  // Return a Promise that will eventually resolve to the data described by
  // The "Response" section of the GraphQL specification.
  //
  // If errors are encountered while executing a GraphQL field, only that
  // field and its descendants will be omitted, and sibling fields will still
  // be executed. An execution which encounters errors will still result in a
  // resolved Promise.
  return new _Promise(function (resolve) {
    resolve(executeOperation(context, context.operation, rootValue));
  })['catch'](function (error) {
    // Errors from sub-fields of a NonNull type may propagate to the top level,
    // at which point we still log the error and null the parent field, which
    // in this case is the entire response.
    context.errors.push(error);
    return null;
  }).then(function (data) {
    if (!context.errors.length) {
      return { data: data };
    }
    return { data: data, errors: context.errors };
  });
}

/**
 * Constructs a ExecutionContext object from the arguments passed to
 * execute, which we will pass throughout the other execution methods.
 *
 * Throws a GraphQLError if a valid execution context cannot be created.
 */
function buildExecutionContext(schema, documentAST, rootValue, rawVariableValues, operationName) {
  var errors = [];
  var operation;
  var fragments = {};
  documentAST.definitions.forEach(function (definition) {
    switch (definition.kind) {
      case _language.Kind.OPERATION_DEFINITION:
        if (!operationName && operation) {
          throw new _error.GraphQLError('Must provide operation name if query contains multiple operations.');
        }
        if (!operationName || definition.name && definition.name.value === operationName) {
          operation = definition;
        }
        break;
      case _language.Kind.FRAGMENT_DEFINITION:
        fragments[definition.name.value] = definition;
        break;
      default:
        throw new _error.GraphQLError('GraphQL cannot execute a request containing a ' + definition.kind + '.', definition);
    }
  });
  if (!operation) {
    if (!operationName) {
      throw new _error.GraphQLError('Unknown operation named "' + operationName + '".');
    } else {
      throw new _error.GraphQLError('Must provide an operation.');
    }
  }
  var variableValues = (0, _values.getVariableValues)(schema, operation.variableDefinitions || [], rawVariableValues || {});
  var exeContext = { schema: schema, fragments: fragments, rootValue: rootValue, operation: operation, variableValues: variableValues, errors: errors };
  return exeContext;
}

/**
 * Implements the "Evaluating operations" section of the spec.
 */
function executeOperation(exeContext, operation, rootValue) {
  var type = getOperationRootType(exeContext.schema, operation);
  var fields = collectFields(exeContext, type, operation.selectionSet, {}, {});
  if (operation.operation === 'mutation') {
    return executeFieldsSerially(exeContext, type, rootValue, fields);
  }
  return executeFields(exeContext, type, rootValue, fields);
}

/**
 * Extracts the root type of the operation from the schema.
 */
function getOperationRootType(schema, operation) {
  switch (operation.operation) {
    case 'query':
      return schema.getQueryType();
    case 'mutation':
      var mutationType = schema.getMutationType();
      if (!mutationType) {
        throw new _error.GraphQLError('Schema is not configured for mutations', [operation]);
      }
      return mutationType;
    case 'subscription':
      var subscriptionType = schema.getSubscriptionType();
      if (!subscriptionType) {
        throw new _error.GraphQLError('Schema is not configured for subscriptions', [operation]);
      }
      return subscriptionType;
    default:
      throw new _error.GraphQLError('Can only execute queries, mutations and subscriptions', [operation]);
  }
}

/**
 * Implements the "Evaluating selection sets" section of the spec
 * for "write" mode.
 */
function executeFieldsSerially(exeContext, parentType, sourceValue, fields) {
  return _Object$keys(fields).reduce(function (prevPromise, responseName) {
    return prevPromise.then(function (results) {
      var fieldASTs = fields[responseName];
      var result = resolveField(exeContext, parentType, sourceValue, fieldASTs);
      if (result === undefined) {
        return results;
      }
      if (isThenable(result)) {
        return result.then(function (resolvedResult) {
          results[responseName] = resolvedResult;
          return results;
        });
      }
      results[responseName] = result;
      return results;
    });
  }, _Promise.resolve({}));
}

/**
 * Implements the "Evaluating selection sets" section of the spec
 * for "read" mode.
 */
function executeFields(exeContext, parentType, sourceValue, fields) {
  var containsPromise = false;

  var finalResults = _Object$keys(fields).reduce(function (results, responseName) {
    var fieldASTs = fields[responseName];
    var result = resolveField(exeContext, parentType, sourceValue, fieldASTs);
    if (result === undefined) {
      return results;
    }
    results[responseName] = result;
    if (isThenable(result)) {
      containsPromise = true;
    }
    return results;
  }, {});

  // If there are no promises, we can just return the object
  if (!containsPromise) {
    return finalResults;
  }

  // Otherwise, results is a map from field name to the result
  // of resolving that field, which is possibly a promise. Return
  // a promise that will return this same map, but with any
  // promises replaced with the values they resolved to.
  return promiseForObject(finalResults);
}

/**
 * Given a selectionSet, adds all of the fields in that selection to
 * the passed in map of fields, and returns it at the end.
 *
 * CollectFields requires the "runtime type" of an object. For a field which
 * returns and Interface or Union type, the "runtime type" will be the actual
 * Object type returned by that field.
 */
function collectFields(exeContext, runtimeType, selectionSet, fields, visitedFragmentNames) {
  for (var i = 0; i < selectionSet.selections.length; i++) {
    var selection = selectionSet.selections[i];
    switch (selection.kind) {
      case _language.Kind.FIELD:
        if (!shouldIncludeNode(exeContext, selection.directives)) {
          continue;
        }
        var name = getFieldEntryKey(selection);
        if (!fields[name]) {
          fields[name] = [];
        }
        fields[name].push(selection);
        break;
      case _language.Kind.INLINE_FRAGMENT:
        if (!shouldIncludeNode(exeContext, selection.directives) || !doesFragmentConditionMatch(exeContext, selection, runtimeType)) {
          continue;
        }
        collectFields(exeContext, runtimeType, selection.selectionSet, fields, visitedFragmentNames);
        break;
      case _language.Kind.FRAGMENT_SPREAD:
        var fragName = selection.name.value;
        if (visitedFragmentNames[fragName] || !shouldIncludeNode(exeContext, selection.directives)) {
          continue;
        }
        visitedFragmentNames[fragName] = true;
        var fragment = exeContext.fragments[fragName];
        if (!fragment || !shouldIncludeNode(exeContext, fragment.directives) || !doesFragmentConditionMatch(exeContext, fragment, runtimeType)) {
          continue;
        }
        collectFields(exeContext, runtimeType, fragment.selectionSet, fields, visitedFragmentNames);
        break;
    }
  }
  return fields;
}

/**
 * Determines if a field should be included based on the @include and @skip
 * directives, where @skip has higher precidence than @include.
 */
function shouldIncludeNode(exeContext, directives) {
  var skipAST = directives && (0, _jsutilsFind2['default'])(directives, function (directive) {
    return directive.name.value === _typeDirectives.GraphQLSkipDirective.name;
  });
  if (skipAST) {
    var _getArgumentValues = (0, _values.getArgumentValues)(_typeDirectives.GraphQLSkipDirective.args, skipAST.arguments, exeContext.variableValues);

    var skipIf = _getArgumentValues['if'];

    return !skipIf;
  }

  var includeAST = directives && (0, _jsutilsFind2['default'])(directives, function (directive) {
    return directive.name.value === _typeDirectives.GraphQLIncludeDirective.name;
  });
  if (includeAST) {
    var _getArgumentValues2 = (0, _values.getArgumentValues)(_typeDirectives.GraphQLIncludeDirective.args, includeAST.arguments, exeContext.variableValues);

    var includeIf = _getArgumentValues2['if'];

    return Boolean(includeIf);
  }

  return true;
}

/**
 * Determines if a fragment is applicable to the given type.
 */
function doesFragmentConditionMatch(exeContext, fragment, type) {
  var typeConditionAST = fragment.typeCondition;
  if (!typeConditionAST) {
    return true;
  }
  var conditionalType = (0, _utilitiesTypeFromAST.typeFromAST)(exeContext.schema, typeConditionAST);
  if (conditionalType === type) {
    return true;
  }
  if ((0, _typeDefinition.isAbstractType)(conditionalType)) {
    return conditionalType.isPossibleType(type);
  }
  return false;
}

/**
 * This function transforms a JS object `{[key: string]: Promise<any>}` into
 * a `Promise<{[key: string]: any}>`
 *
 * This is akin to bluebird's `Promise.props`, but implemented only using
 * `Promise.all` so it will work with any implementation of ES6 promises.
 */
function promiseForObject(object) {
  var keys = _Object$keys(object);
  var valuesAndPromises = keys.map(function (name) {
    return object[name];
  });
  return _Promise.all(valuesAndPromises).then(function (values) {
    return values.reduce(function (resolvedObject, value, i) {
      resolvedObject[keys[i]] = value;
      return resolvedObject;
    }, {});
  });
}

/**
 * Implements the logic to compute the key of a given field’s entry
 */
function getFieldEntryKey(node) {
  return node.alias ? node.alias.value : node.name.value;
}

/**
 * Resolves the field on the given source object. In particular, this
 * figures out the value that the field returns by calling its resolve function,
 * then calls completeValue to complete promises, serialize scalars, or execute
 * the sub-selection-set for objects.
 */
function resolveField(exeContext, parentType, source, fieldASTs) {
  var fieldAST = fieldASTs[0];
  var fieldName = fieldAST.name.value;

  var fieldDef = getFieldDef(exeContext.schema, parentType, fieldName);
  if (!fieldDef) {
    return;
  }

  var returnType = fieldDef.type;
  var resolveFn = fieldDef.resolve || defaultResolveFn;

  // Build a JS object of arguments from the field.arguments AST, using the
  // variables scope to fulfill any variable references.
  // TODO: find a way to memoize, in case this field is within a List type.
  var args = (0, _values.getArgumentValues)(fieldDef.args, fieldAST.arguments, exeContext.variableValues);

  // The resolve function's optional third argument is a collection of
  // information about the current execution state.
  var info = {
    fieldName: fieldName,
    fieldASTs: fieldASTs,
    returnType: returnType,
    parentType: parentType,
    schema: exeContext.schema,
    fragments: exeContext.fragments,
    rootValue: exeContext.rootValue,
    operation: exeContext.operation,
    variableValues: exeContext.variableValues
  };

  // Get the resolve function, regardless of if its result is normal
  // or abrupt (error).
  var result = resolveOrError(resolveFn, source, args, info);

  return completeValueCatchingError(exeContext, returnType, fieldASTs, info, result);
}

// Isolates the "ReturnOrAbrupt" behavior to not de-opt the `resolveField`
// function. Returns the result of resolveFn or the abrupt-return Error object.
function resolveOrError(resolveFn, source, args, info) {
  try {
    return resolveFn(source, args, info);
  } catch (error) {
    // Sometimes a non-error is thrown, wrap it as an Error for a
    // consistent interface.
    return error instanceof Error ? error : new Error(error);
  }
}

// This is a small wrapper around completeValue which detects and logs errors
// in the execution context.
function completeValueCatchingError(exeContext, returnType, fieldASTs, info, result) {
  // If the field type is non-nullable, then it is resolved without any
  // protection from errors.
  if (returnType instanceof _typeDefinition.GraphQLNonNull) {
    return completeValue(exeContext, returnType, fieldASTs, info, result);
  }

  // Otherwise, error protection is applied, logging the error and resolving
  // a null value for this field if one is encountered.
  try {
    var completed = completeValue(exeContext, returnType, fieldASTs, info, result);
    if (isThenable(completed)) {
      // If `completeValue` returned a rejected promise, log the rejection
      // error and resolve to null.
      // Note: we don't rely on a `catch` method, but we do expect "thenable"
      // to take a second callback for the error case.
      return completed.then(undefined, function (error) {
        exeContext.errors.push(error);
        return _Promise.resolve(null);
      });
    }
    return completed;
  } catch (error) {
    // If `completeValue` returned abruptly (threw an error), log the error
    // and return null.
    exeContext.errors.push(error);
    return null;
  }
}

/**
 * Implements the instructions for completeValue as defined in the
 * "Field entries" section of the spec.
 *
 * If the field type is Non-Null, then this recursively completes the value
 * for the inner type. It throws a field error if that completion returns null,
 * as per the "Nullability" section of the spec.
 *
 * If the field type is a List, then this recursively completes the value
 * for the inner type on each item in the list.
 *
 * If the field type is a Scalar or Enum, ensures the completed value is a legal
 * value of the type by calling the `serialize` method of GraphQL type
 * definition.
 *
 * Otherwise, the field type expects a sub-selection set, and will complete the
 * value by evaluating all sub-selections.
 */
function completeValue(exeContext, returnType, fieldASTs, info, result) {
  // If result is a Promise, apply-lift over completeValue.
  if (isThenable(result)) {
    return result.then(
    // Once resolved to a value, complete that value.
    function (resolved) {
      return completeValue(exeContext, returnType, fieldASTs, info, resolved);
    },
    // If rejected, create a located error, and continue to reject.
    function (error) {
      return _Promise.reject((0, _error.locatedError)(error, fieldASTs));
    });
  }

  // If result is an Error, throw a located error.
  if (result instanceof Error) {
    throw (0, _error.locatedError)(result, fieldASTs);
  }

  // If field type is NonNull, complete for inner type, and throw field error
  // if result is null.
  if (returnType instanceof _typeDefinition.GraphQLNonNull) {
    var completed = completeValue(exeContext, returnType.ofType, fieldASTs, info, result);
    if (completed === null) {
      throw new _error.GraphQLError('Cannot return null for non-nullable ' + ('field ' + info.parentType + '.' + info.fieldName + '.'), fieldASTs);
    }
    return completed;
  }

  // If result is null-like, return null.
  if ((0, _jsutilsIsNullish2['default'])(result)) {
    return null;
  }

  // If field type is List, complete each item in the list with the inner type
  if (returnType instanceof _typeDefinition.GraphQLList) {
    (0, _jsutilsInvariant2['default'])(Array.isArray(result), 'User Error: expected iterable, but did not find one.');

    // This is specified as a simple map, however we're optimizing the path
    // where the list contains no Promises by avoiding creating another Promise.
    var itemType = returnType.ofType;
    var containsPromise = false;
    var completedResults = result.map(function (item) {
      var completedItem = completeValueCatchingError(exeContext, itemType, fieldASTs, info, item);
      if (!containsPromise && isThenable(completedItem)) {
        containsPromise = true;
      }
      return completedItem;
    });

    return containsPromise ? _Promise.all(completedResults) : completedResults;
  }

  // If field type is Scalar or Enum, serialize to a valid value, returning
  // null if serialization is not possible.
  if (returnType instanceof _typeDefinition.GraphQLScalarType || returnType instanceof _typeDefinition.GraphQLEnumType) {
    (0, _jsutilsInvariant2['default'])(returnType.serialize, 'Missing serialize method on type');
    var serializedResult = returnType.serialize(result);
    return (0, _jsutilsIsNullish2['default'])(serializedResult) ? null : serializedResult;
  }

  // Field type must be Object, Interface or Union and expect sub-selections.
  var runtimeType;

  if (returnType instanceof _typeDefinition.GraphQLObjectType) {
    runtimeType = returnType;
  } else if ((0, _typeDefinition.isAbstractType)(returnType)) {
    var abstractType = returnType;
    runtimeType = abstractType.getObjectType(result, info);
    if (runtimeType && !abstractType.isPossibleType(runtimeType)) {
      throw new _error.GraphQLError('Runtime Object type "' + runtimeType + '" is not a possible type ' + ('for "' + abstractType + '".'), fieldASTs);
    }
  }

  if (!runtimeType) {
    return null;
  }

  // If there is an isTypeOf predicate function, call it with the
  // current result. If isTypeOf returns false, then raise an error rather
  // than continuing execution.
  if (runtimeType.isTypeOf && !runtimeType.isTypeOf(result, info)) {
    throw new _error.GraphQLError('Expected value of type "' + runtimeType + '" but got: ' + result + '.', fieldASTs);
  }

  // Collect sub-fields to execute to complete this value.
  var subFieldASTs = {};
  var visitedFragmentNames = {};
  for (var i = 0; i < fieldASTs.length; i++) {
    var selectionSet = fieldASTs[i].selectionSet;
    if (selectionSet) {
      subFieldASTs = collectFields(exeContext, runtimeType, selectionSet, subFieldASTs, visitedFragmentNames);
    }
  }

  return executeFields(exeContext, runtimeType, result, subFieldASTs);
}

/**
 * If a resolve function is not given, then a default resolve behavior is used
 * which takes the property of the source object of the same name as the field
 * and returns it as the result, or if it's a function, returns the result
 * of calling that function.
 */
function defaultResolveFn(source, args, _ref) {
  var fieldName = _ref.fieldName;

  var property = source[fieldName];
  return typeof property === 'function' ? property.call(source) : property;
}

/**
 * Checks to see if this object acts like a Promise, i.e. has a "then"
 * function.
 */
function isThenable(value) {
  return value && (typeof value === 'undefined' ? 'undefined' : _typeof(value)) === 'object' && typeof value.then === 'function';
}

/**
 * This method looks up the field on the given type defintion.
 * It has special casing for the two introspection fields, __schema
 * and __typename. __typename is special because it can always be
 * queried as a field, even in situations where no other fields
 * are allowed, like on a Union. __schema could get automatically
 * added to the query type, but that would require mutating type
 * definitions, which would cause issues.
 */
function getFieldDef(schema, parentType, fieldName) {
  if (fieldName === _typeIntrospection.SchemaMetaFieldDef.name && schema.getQueryType() === parentType) {
    return _typeIntrospection.SchemaMetaFieldDef;
  } else if (fieldName === _typeIntrospection.TypeMetaFieldDef.name && schema.getQueryType() === parentType) {
    return _typeIntrospection.TypeMetaFieldDef;
  } else if (fieldName === _typeIntrospection.TypeNameMetaFieldDef.name) {
    return _typeIntrospection.TypeNameMetaFieldDef;
  }
  return parentType.getFields()[fieldName];
}

},{"../error":205,"../jsutils/find":213,"../jsutils/invariant":214,"../jsutils/isNullish":215,"../language":217,"../type/definition":328,"../type/directives":329,"../type/introspection":330,"../type/schema":332,"../utilities/typeFromAST":338,"./values":210,"babel-runtime/core-js/object/keys":233,"babel-runtime/core-js/promise":235,"babel-runtime/helpers/interop-require-default":242}],209:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _execute = require('./execute');

Object.defineProperty(exports, 'execute', {
  enumerable: true,
  get: function get() {
    return _execute.execute;
  }
});

},{"./execute":208}],210:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Prepares an object map of variableValues of the correct type based on the
 * provided variable definitions and arbitrary input. If the input cannot be
 * parsed to match the variable definitions, a GraphQLError will be thrown.
 */
'use strict';

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.getVariableValues = getVariableValues;
exports.getArgumentValues = getArgumentValues;

var _error = require('../error');

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

var _jsutilsKeyMap = require('../jsutils/keyMap');

var _jsutilsKeyMap2 = _interopRequireDefault(_jsutilsKeyMap);

var _utilitiesTypeFromAST = require('../utilities/typeFromAST');

var _utilitiesValueFromAST = require('../utilities/valueFromAST');

var _utilitiesIsValidJSValue = require('../utilities/isValidJSValue');

var _languagePrinter = require('../language/printer');

var _typeDefinition = require('../type/definition');

function getVariableValues(schema, definitionASTs, inputs) {
  return definitionASTs.reduce(function (values, defAST) {
    var varName = defAST.variable.name.value;
    values[varName] = getVariableValue(schema, defAST, inputs[varName]);
    return values;
  }, {});
}

/**
 * Prepares an object map of argument values given a list of argument
 * definitions and list of argument AST nodes.
 */

function getArgumentValues(argDefs, argASTs, variableValues) {
  if (!argDefs || !argASTs) {
    return {};
  }
  var argASTMap = (0, _jsutilsKeyMap2['default'])(argASTs, function (arg) {
    return arg.name.value;
  });
  return argDefs.reduce(function (result, argDef) {
    var name = argDef.name;
    var valueAST = argASTMap[name] ? argASTMap[name].value : null;
    var value = (0, _utilitiesValueFromAST.valueFromAST)(valueAST, argDef.type, variableValues);
    if ((0, _jsutilsIsNullish2['default'])(value)) {
      value = argDef.defaultValue;
    }
    if (!(0, _jsutilsIsNullish2['default'])(value)) {
      result[name] = value;
    }
    return result;
  }, {});
}

/**
 * Given a variable definition, and any value of input, return a value which
 * adheres to the variable definition, or throw an error.
 */
function getVariableValue(schema, definitionAST, input) {
  var type = (0, _utilitiesTypeFromAST.typeFromAST)(schema, definitionAST.type);
  var variable = definitionAST.variable;
  if (!type || !(0, _typeDefinition.isInputType)(type)) {
    throw new _error.GraphQLError('Variable "$' + variable.name.value + '" expected value of type ' + ('"' + (0, _languagePrinter.print)(definitionAST.type) + '" which cannot be used as an input type.'), [definitionAST]);
  }
  var inputType = type;
  var errors = (0, _utilitiesIsValidJSValue.isValidJSValue)(input, inputType);
  if (!errors.length) {
    if ((0, _jsutilsIsNullish2['default'])(input)) {
      var defaultValue = definitionAST.defaultValue;
      if (defaultValue) {
        return (0, _utilitiesValueFromAST.valueFromAST)(defaultValue, inputType);
      }
    }
    return coerceValue(inputType, input);
  }
  if ((0, _jsutilsIsNullish2['default'])(input)) {
    throw new _error.GraphQLError('Variable "$' + variable.name.value + '" of required type ' + ('"' + (0, _languagePrinter.print)(definitionAST.type) + '" was not provided.'), [definitionAST]);
  }
  var message = errors ? '\n' + errors.join('\n') : '';
  throw new _error.GraphQLError('Variable "$' + variable.name.value + '" got invalid value ' + (JSON.stringify(input) + '.' + message), [definitionAST]);
}

/**
 * Given a type and any value, return a runtime value coerced to match the type.
 */
function coerceValue(_x, _x2) {
  var _again = true;

  _function: while (_again) {
    var type = _x,
        value = _x2;
    nullableType = itemType = fields = parsed = undefined;
    _again = false;

    if (type instanceof _typeDefinition.GraphQLNonNull) {
      // Note: we're not checking that the result of coerceValue is non-null.

      var nullableType = type.ofType;
      _x = nullableType;
      _x2 = value;
      _again = true;
      continue _function;
    }

    if ((0, _jsutilsIsNullish2['default'])(value)) {
      return null;
    }

    if (type instanceof _typeDefinition.GraphQLList) {
      var itemType = type.ofType;
      // TODO: support iterable input
      if (Array.isArray(value)) {
        return value.map(function (item) {
          return coerceValue(itemType, item);
        });
      }
      return [coerceValue(itemType, value)];
    }

    if (type instanceof _typeDefinition.GraphQLInputObjectType) {
      var fields = type.getFields();
      return _Object$keys(fields).reduce(function (obj, fieldName) {
        var field = fields[fieldName];
        var fieldValue = coerceValue(field.type, value[fieldName]);
        if ((0, _jsutilsIsNullish2['default'])(fieldValue)) {
          fieldValue = field.defaultValue;
        }
        if (!(0, _jsutilsIsNullish2['default'])(fieldValue)) {
          obj[fieldName] = fieldValue;
        }
        return obj;
      }, {});
    }

    (0, _jsutilsInvariant2['default'])(type instanceof _typeDefinition.GraphQLScalarType || type instanceof _typeDefinition.GraphQLEnumType, 'Must be input type');

    var parsed = type.parseValue(value);
    if (!(0, _jsutilsIsNullish2['default'])(parsed)) {
      return parsed;
    }
  }
}
// We only call this function after calling isValidJSValue.

},{"../error":205,"../jsutils/invariant":214,"../jsutils/isNullish":215,"../jsutils/keyMap":216,"../language/printer":222,"../type/definition":328,"../utilities/isValidJSValue":335,"../utilities/typeFromAST":338,"../utilities/valueFromAST":339,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/interop-require-default":242}],211:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * This is the primary entry point function for fulfilling GraphQL operations
 * by parsing, validating, and executing a GraphQL document along side a
 * GraphQL schema.
 *
 * More sophisticated GraphQL servers, such as those which persist queries,
 * may wish to separate the validation and execution phases to a static time
 * tooling step, and a server runtime step.
 *
 * schema:
 *    The GraphQL type system to use when validating and executing a query.
 * requestString:
 *    A GraphQL language formatted string representing the requested operation.
 * rootValue:
 *    The value provided as the first argument to resolver functions on the top
 *    level type (e.g. the query object type).
 * variableValues:
 *    A mapping of variable name to runtime value to use for all variables
 *    defined in the requestString.
 * operationName:
 *    The name of the operation to use if requestString contains multiple
 *    possible operations. Can be omitted if requestString contains only
 *    one operation.
 */
'use strict';

var _Promise = require('babel-runtime/core-js/promise')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.graphql = graphql;

/**
 * The result of a GraphQL parse, validation and execution.
 *
 * `data` is the result of a successful execution of the query.
 * `errors` is included when any errors occurred as a non-empty array.
 */

var _languageSource = require('./language/source');

var _languageParser = require('./language/parser');

var _validationValidate = require('./validation/validate');

var _executionExecute = require('./execution/execute');

function graphql(schema, requestString, rootValue, variableValues, operationName) {
  return new _Promise(function (resolve) {
    var source = new _languageSource.Source(requestString || '', 'GraphQL request');
    var documentAST = (0, _languageParser.parse)(source);
    var validationErrors = (0, _validationValidate.validate)(schema, documentAST);
    if (validationErrors.length > 0) {
      resolve({ errors: validationErrors });
    } else {
      resolve((0, _executionExecute.execute)(schema, documentAST, rootValue, variableValues, operationName));
    }
  })['catch'](function (error) {
    return { errors: [error] };
  });
}

},{"./execution/execute":208,"./language/parser":221,"./language/source":223,"./validation/validate":365,"babel-runtime/core-js/promise":235}],212:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

// The primary entry point into fulfilling a GraphQL request.
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _graphql = require('./graphql');

Object.defineProperty(exports, 'graphql', {
  enumerable: true,
  get: function get() {
    return _graphql.graphql;
  }
});

// Produce a GraphQL type schema.

var _typeSchema = require('./type/schema');

Object.defineProperty(exports, 'GraphQLSchema', {
  enumerable: true,
  get: function get() {
    return _typeSchema.GraphQLSchema;
  }
});

// Define GraphQL types.

var _typeDefinition = require('./type/definition');

Object.defineProperty(exports, 'GraphQLScalarType', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLScalarType;
  }
});
Object.defineProperty(exports, 'GraphQLObjectType', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLObjectType;
  }
});
Object.defineProperty(exports, 'GraphQLInterfaceType', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLInterfaceType;
  }
});
Object.defineProperty(exports, 'GraphQLUnionType', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLUnionType;
  }
});
Object.defineProperty(exports, 'GraphQLEnumType', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLEnumType;
  }
});
Object.defineProperty(exports, 'GraphQLInputObjectType', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLInputObjectType;
  }
});
Object.defineProperty(exports, 'GraphQLList', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLList;
  }
});
Object.defineProperty(exports, 'GraphQLNonNull', {
  enumerable: true,
  get: function get() {
    return _typeDefinition.GraphQLNonNull;
  }
});

// Use pre-defined GraphQL scalar types.

var _typeScalars = require('./type/scalars');

Object.defineProperty(exports, 'GraphQLInt', {
  enumerable: true,
  get: function get() {
    return _typeScalars.GraphQLInt;
  }
});
Object.defineProperty(exports, 'GraphQLFloat', {
  enumerable: true,
  get: function get() {
    return _typeScalars.GraphQLFloat;
  }
});
Object.defineProperty(exports, 'GraphQLString', {
  enumerable: true,
  get: function get() {
    return _typeScalars.GraphQLString;
  }
});
Object.defineProperty(exports, 'GraphQLBoolean', {
  enumerable: true,
  get: function get() {
    return _typeScalars.GraphQLBoolean;
  }
});
Object.defineProperty(exports, 'GraphQLID', {
  enumerable: true,
  get: function get() {
    return _typeScalars.GraphQLID;
  }
});

// Format GraphQL errors.

var _errorFormatError = require('./error/formatError');

Object.defineProperty(exports, 'formatError', {
  enumerable: true,
  get: function get() {
    return _errorFormatError.formatError;
  }
});

},{"./error/formatError":204,"./graphql":211,"./type/definition":328,"./type/scalars":331,"./type/schema":332}],213:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports["default"] = find;

function find(list, predicate) {
  for (var i = 0; i < list.length; i++) {
    if (predicate(list[i])) {
      return list[i];
    }
  }
}

module.exports = exports["default"];

},{}],214:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports["default"] = invariant;

function invariant(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

module.exports = exports["default"];

},{}],215:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Returns true if a value is null, undefined, or NaN.
 */
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports["default"] = isNullish;

function isNullish(value) {
  return value === null || value === undefined || value !== value;
}

module.exports = exports["default"];

},{}],216:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Creates a keyed JS object from an array, given a function to produce the keys
 * for each value in the array.
 *
 * This provides a convenient lookup for the array items if the key function
 * produces unique results.
 *
 *     var phoneBook = [
 *       { name: 'Jon', num: '555-1234' },
 *       { name: 'Jenny', num: '867-5309' }
 *     ]
 *
 *     // { Jon: { name: 'Jon', num: '555-1234' },
 *     //   Jenny: { name: 'Jenny', num: '867-5309' } }
 *     var entriesByName = keyMap(
 *       phoneBook,
 *       entry => entry.name
 *     )
 *
 *     // { name: 'Jenny', num: '857-6309' }
 *     var jennyEntry = entriesByName['Jenny']
 *
 */
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports["default"] = keyMap;

function keyMap(list, keyFn) {
  return list.reduce(function (map, item) {
    return map[keyFn(item)] = item, map;
  }, {});
}

module.exports = exports["default"];

},{}],217:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _interopRequireWildcard = require('babel-runtime/helpers/interop-require-wildcard')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _kinds = require('./kinds');

var Kind = _interopRequireWildcard(_kinds);

var _location = require('./location');

Object.defineProperty(exports, 'getLocation', {
  enumerable: true,
  get: function get() {
    return _location.getLocation;
  }
});
exports.Kind = Kind;

var _lexer = require('./lexer');

Object.defineProperty(exports, 'lex', {
  enumerable: true,
  get: function get() {
    return _lexer.lex;
  }
});

var _parser = require('./parser');

Object.defineProperty(exports, 'parse', {
  enumerable: true,
  get: function get() {
    return _parser.parse;
  }
});
Object.defineProperty(exports, 'parseValue', {
  enumerable: true,
  get: function get() {
    return _parser.parseValue;
  }
});

var _printer = require('./printer');

Object.defineProperty(exports, 'print', {
  enumerable: true,
  get: function get() {
    return _printer.print;
  }
});

var _source = require('./source');

Object.defineProperty(exports, 'Source', {
  enumerable: true,
  get: function get() {
    return _source.Source;
  }
});

var _visitor = require('./visitor');

Object.defineProperty(exports, 'visit', {
  enumerable: true,
  get: function get() {
    return _visitor.visit;
  }
});
Object.defineProperty(exports, 'BREAK', {
  enumerable: true,
  get: function get() {
    return _visitor.BREAK;
  }
});

},{"./kinds":218,"./lexer":219,"./location":220,"./parser":221,"./printer":222,"./source":223,"./visitor":224,"babel-runtime/helpers/interop-require-wildcard":243}],218:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

// Name

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
var NAME = 'Name';

exports.NAME = NAME;
// Document

var DOCUMENT = 'Document';
exports.DOCUMENT = DOCUMENT;
var OPERATION_DEFINITION = 'OperationDefinition';
exports.OPERATION_DEFINITION = OPERATION_DEFINITION;
var VARIABLE_DEFINITION = 'VariableDefinition';
exports.VARIABLE_DEFINITION = VARIABLE_DEFINITION;
var VARIABLE = 'Variable';
exports.VARIABLE = VARIABLE;
var SELECTION_SET = 'SelectionSet';
exports.SELECTION_SET = SELECTION_SET;
var FIELD = 'Field';
exports.FIELD = FIELD;
var ARGUMENT = 'Argument';

exports.ARGUMENT = ARGUMENT;
// Fragments

var FRAGMENT_SPREAD = 'FragmentSpread';
exports.FRAGMENT_SPREAD = FRAGMENT_SPREAD;
var INLINE_FRAGMENT = 'InlineFragment';
exports.INLINE_FRAGMENT = INLINE_FRAGMENT;
var FRAGMENT_DEFINITION = 'FragmentDefinition';

exports.FRAGMENT_DEFINITION = FRAGMENT_DEFINITION;
// Values

var INT = 'IntValue';
exports.INT = INT;
var FLOAT = 'FloatValue';
exports.FLOAT = FLOAT;
var STRING = 'StringValue';
exports.STRING = STRING;
var BOOLEAN = 'BooleanValue';
exports.BOOLEAN = BOOLEAN;
var ENUM = 'EnumValue';
exports.ENUM = ENUM;
var LIST = 'ListValue';
exports.LIST = LIST;
var OBJECT = 'ObjectValue';
exports.OBJECT = OBJECT;
var OBJECT_FIELD = 'ObjectField';

exports.OBJECT_FIELD = OBJECT_FIELD;
// Directives

var DIRECTIVE = 'Directive';

exports.DIRECTIVE = DIRECTIVE;
// Types

var NAMED_TYPE = 'NamedType';
exports.NAMED_TYPE = NAMED_TYPE;
var LIST_TYPE = 'ListType';
exports.LIST_TYPE = LIST_TYPE;
var NON_NULL_TYPE = 'NonNullType';

exports.NON_NULL_TYPE = NON_NULL_TYPE;
// Type Definitions

var OBJECT_TYPE_DEFINITION = 'ObjectTypeDefinition';
exports.OBJECT_TYPE_DEFINITION = OBJECT_TYPE_DEFINITION;
var FIELD_DEFINITION = 'FieldDefinition';
exports.FIELD_DEFINITION = FIELD_DEFINITION;
var INPUT_VALUE_DEFINITION = 'InputValueDefinition';
exports.INPUT_VALUE_DEFINITION = INPUT_VALUE_DEFINITION;
var INTERFACE_TYPE_DEFINITION = 'InterfaceTypeDefinition';
exports.INTERFACE_TYPE_DEFINITION = INTERFACE_TYPE_DEFINITION;
var UNION_TYPE_DEFINITION = 'UnionTypeDefinition';
exports.UNION_TYPE_DEFINITION = UNION_TYPE_DEFINITION;
var SCALAR_TYPE_DEFINITION = 'ScalarTypeDefinition';
exports.SCALAR_TYPE_DEFINITION = SCALAR_TYPE_DEFINITION;
var ENUM_TYPE_DEFINITION = 'EnumTypeDefinition';
exports.ENUM_TYPE_DEFINITION = ENUM_TYPE_DEFINITION;
var ENUM_VALUE_DEFINITION = 'EnumValueDefinition';
exports.ENUM_VALUE_DEFINITION = ENUM_VALUE_DEFINITION;
var INPUT_OBJECT_TYPE_DEFINITION = 'InputObjectTypeDefinition';
exports.INPUT_OBJECT_TYPE_DEFINITION = INPUT_OBJECT_TYPE_DEFINITION;
var TYPE_EXTENSION_DEFINITION = 'TypeExtensionDefinition';
exports.TYPE_EXTENSION_DEFINITION = TYPE_EXTENSION_DEFINITION;

},{}],219:[function(require,module,exports){
/*  /
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

/**
 * A representation of a lexed Token. Value is optional, is it is
 * not needed for punctuators like BANG or PAREN_L.
 */

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.lex = lex;
exports.getTokenDesc = getTokenDesc;
exports.getTokenKindDesc = getTokenKindDesc;

var _error = require('../error');

/**
 * Given a Source object, this returns a Lexer for that source.
 * A Lexer is a function that acts like a generator in that every time
 * it is called, it returns the next token in the Source. Assuming the
 * source lexes, the final Token emitted by the lexer will be of kind
 * EOF, after which the lexer will repeatedly return EOF tokens whenever
 * called.
 *
 * The argument to the lexer function is optional, and can be used to
 * rewind or fast forward the lexer to a new position in the source.
 */

function lex(source) {
  var prevPosition = 0;
  return function nextToken(resetPosition) {
    var token = readToken(source, resetPosition === undefined ? prevPosition : resetPosition);
    prevPosition = token.end;
    return token;
  };
}

/**
 * An enum describing the different kinds of tokens that the lexer emits.
 */
var TokenKind = {
  EOF: 1,
  BANG: 2,
  DOLLAR: 3,
  PAREN_L: 4,
  PAREN_R: 5,
  SPREAD: 6,
  COLON: 7,
  EQUALS: 8,
  AT: 9,
  BRACKET_L: 10,
  BRACKET_R: 11,
  BRACE_L: 12,
  PIPE: 13,
  BRACE_R: 14,
  NAME: 15,
  VARIABLE: 16,
  INT: 17,
  FLOAT: 18,
  STRING: 19
};

exports.TokenKind = TokenKind;
/**
 * A helper function to describe a token as a string for debugging
 */

function getTokenDesc(token) {
  return token.value ? getTokenKindDesc(token.kind) + ' "' + token.value + '"' : getTokenKindDesc(token.kind);
}

/**
 * A helper function to describe a token kind as a string for debugging
 */

function getTokenKindDesc(kind) {
  return tokenDescription[kind];
}

var tokenDescription = {};
tokenDescription[TokenKind.EOF] = 'EOF';
tokenDescription[TokenKind.BANG] = '!';
tokenDescription[TokenKind.DOLLAR] = '$';
tokenDescription[TokenKind.PAREN_L] = '(';
tokenDescription[TokenKind.PAREN_R] = ')';
tokenDescription[TokenKind.SPREAD] = '...';
tokenDescription[TokenKind.COLON] = ':';
tokenDescription[TokenKind.EQUALS] = '=';
tokenDescription[TokenKind.AT] = '@';
tokenDescription[TokenKind.BRACKET_L] = '[';
tokenDescription[TokenKind.BRACKET_R] = ']';
tokenDescription[TokenKind.BRACE_L] = '{';
tokenDescription[TokenKind.PIPE] = '|';
tokenDescription[TokenKind.BRACE_R] = '}';
tokenDescription[TokenKind.NAME] = 'Name';
tokenDescription[TokenKind.VARIABLE] = 'Variable';
tokenDescription[TokenKind.INT] = 'Int';
tokenDescription[TokenKind.FLOAT] = 'Float';
tokenDescription[TokenKind.STRING] = 'String';

var charCodeAt = String.prototype.charCodeAt;
var slice = String.prototype.slice;

/**
 * Helper function for constructing the Token object.
 */
function makeToken(kind, start, end, value) {
  return { kind: kind, start: start, end: end, value: value };
}

function printCharCode(code) {
  return(
    // NaN/undefined represents access beyond the end of the file.
    isNaN(code) ? '<EOF>' :
    // Trust JSON for ASCII.
    code < 0x007F ? JSON.stringify(String.fromCharCode(code)) :
    // Otherwise print the escaped form.
    '"\\u' + ('00' + code.toString(16).toUpperCase()).slice(-4) + '"'
  );
}

/**
 * Gets the next token from the source starting at the given position.
 *
 * This skips over whitespace and comments until it finds the next lexable
 * token, then lexes punctuators immediately or calls the appropriate helper
 * function for more complicated tokens.
 */
function readToken(source, fromPosition) {
  var body = source.body;
  var bodyLength = body.length;

  var position = positionAfterWhitespace(body, fromPosition);

  if (position >= bodyLength) {
    return makeToken(TokenKind.EOF, position, position);
  }

  var code = charCodeAt.call(body, position);

  // SourceCharacter
  if (code < 0x0020 && code !== 0x0009 && code !== 0x000A && code !== 0x000D) {
    throw (0, _error.syntaxError)(source, position, 'Invalid character ' + printCharCode(code) + '.');
  }

  switch (code) {
    // !
    case 33:
      return makeToken(TokenKind.BANG, position, position + 1);
    // $
    case 36:
      return makeToken(TokenKind.DOLLAR, position, position + 1);
    // (
    case 40:
      return makeToken(TokenKind.PAREN_L, position, position + 1);
    // )
    case 41:
      return makeToken(TokenKind.PAREN_R, position, position + 1);
    // .
    case 46:
      if (charCodeAt.call(body, position + 1) === 46 && charCodeAt.call(body, position + 2) === 46) {
        return makeToken(TokenKind.SPREAD, position, position + 3);
      }
      break;
    // :
    case 58:
      return makeToken(TokenKind.COLON, position, position + 1);
    // =
    case 61:
      return makeToken(TokenKind.EQUALS, position, position + 1);
    // @
    case 64:
      return makeToken(TokenKind.AT, position, position + 1);
    // [
    case 91:
      return makeToken(TokenKind.BRACKET_L, position, position + 1);
    // ]
    case 93:
      return makeToken(TokenKind.BRACKET_R, position, position + 1);
    // {
    case 123:
      return makeToken(TokenKind.BRACE_L, position, position + 1);
    // |
    case 124:
      return makeToken(TokenKind.PIPE, position, position + 1);
    // }
    case 125:
      return makeToken(TokenKind.BRACE_R, position, position + 1);
    // A-Z
    case 65:case 66:case 67:case 68:case 69:case 70:case 71:case 72:
    case 73:case 74:case 75:case 76:case 77:case 78:case 79:case 80:
    case 81:case 82:case 83:case 84:case 85:case 86:case 87:case 88:
    case 89:case 90:
    // _
    case 95:
    // a-z
    case 97:case 98:case 99:case 100:case 101:case 102:case 103:case 104:
    case 105:case 106:case 107:case 108:case 109:case 110:case 111:
    case 112:case 113:case 114:case 115:case 116:case 117:case 118:
    case 119:case 120:case 121:case 122:
      return readName(source, position);
    // -
    case 45:
    // 0-9
    case 48:case 49:case 50:case 51:case 52:
    case 53:case 54:case 55:case 56:case 57:
      return readNumber(source, position, code);
    // "
    case 34:
      return readString(source, position);
  }

  throw (0, _error.syntaxError)(source, position, 'Unexpected character ' + printCharCode(code) + '.');
}

/**
 * Reads from body starting at startPosition until it finds a non-whitespace
 * or commented character, then returns the position of that character for
 * lexing.
 */
function positionAfterWhitespace(body, startPosition) {
  var bodyLength = body.length;
  var position = startPosition;
  while (position < bodyLength) {
    var code = charCodeAt.call(body, position);
    // Skip Ignored
    if (
    // BOM
    code === 0xFEFF ||
    // White Space
    code === 0x0009 || // tab
    code === 0x0020 || // space
    // Line Terminator
    code === 0x000A || // new line
    code === 0x000D || // carriage return
    // Comma
    code === 0x002C) {
      ++position;
      // Skip comments
    } else if (code === 35) {
        // #
        ++position;
        while (position < bodyLength && (code = charCodeAt.call(body, position)) !== null && (
        // SourceCharacter but not LineTerminator
        code > 0x001F || code === 0x0009) && code !== 0x000A && code !== 0x000D) {
          ++position;
        }
      } else {
        break;
      }
  }
  return position;
}

/**
 * Reads a number token from the source file, either a float
 * or an int depending on whether a decimal point appears.
 *
 * Int:   -?(0|[1-9][0-9]*)
 * Float: -?(0|[1-9][0-9]*)(\.[0-9]+)?((E|e)(+|-)?[0-9]+)?
 */
function readNumber(source, start, firstCode) {
  var code = firstCode;
  var body = source.body;
  var position = start;
  var isFloat = false;

  if (code === 45) {
    // -
    code = charCodeAt.call(body, ++position);
  }

  if (code === 48) {
    // 0
    code = charCodeAt.call(body, ++position);
    if (code >= 48 && code <= 57) {
      throw (0, _error.syntaxError)(source, position, 'Invalid number, unexpected digit after 0: ' + printCharCode(code) + '.');
    }
  } else {
    position = readDigits(source, position, code);
    code = charCodeAt.call(body, position);
  }

  if (code === 46) {
    // .
    isFloat = true;

    code = charCodeAt.call(body, ++position);
    position = readDigits(source, position, code);
    code = charCodeAt.call(body, position);
  }

  if (code === 69 || code === 101) {
    // E e
    isFloat = true;

    code = charCodeAt.call(body, ++position);
    if (code === 43 || code === 45) {
      // + -
      code = charCodeAt.call(body, ++position);
    }
    position = readDigits(source, position, code);
  }

  return makeToken(isFloat ? TokenKind.FLOAT : TokenKind.INT, start, position, slice.call(body, start, position));
}

/**
 * Returns the new position in the source after reading digits.
 */
function readDigits(source, start, firstCode) {
  var body = source.body;
  var position = start;
  var code = firstCode;
  if (code >= 48 && code <= 57) {
    // 0 - 9
    do {
      code = charCodeAt.call(body, ++position);
    } while (code >= 48 && code <= 57); // 0 - 9
    return position;
  }
  throw (0, _error.syntaxError)(source, position, 'Invalid number, expected digit but got: ' + printCharCode(code) + '.');
}

/**
 * Reads a string token from the source file.
 *
 * "([^"\\\u000A\u000D\u2028\u2029]|(\\(u[0-9a-fA-F]{4}|["\\/bfnrt])))*"
 */
function readString(source, start) {
  var body = source.body;
  var position = start + 1;
  var chunkStart = position;
  var code = 0;
  var value = '';

  while (position < body.length && (code = charCodeAt.call(body, position)) !== null &&
  // not LineTerminator
  code !== 0x000A && code !== 0x000D &&
  // not Quote (")
  code !== 34) {
    // SourceCharacter
    if (code < 0x0020 && code !== 0x0009) {
      throw (0, _error.syntaxError)(source, position, 'Invalid character within String: ' + printCharCode(code) + '.');
    }

    ++position;
    if (code === 92) {
      // \
      value += slice.call(body, chunkStart, position - 1);
      code = charCodeAt.call(body, position);
      switch (code) {
        case 34:
          value += '"';break;
        case 47:
          value += '\/';break;
        case 92:
          value += '\\';break;
        case 98:
          value += '\b';break;
        case 102:
          value += '\f';break;
        case 110:
          value += '\n';break;
        case 114:
          value += '\r';break;
        case 116:
          value += '\t';break;
        case 117:
          // u
          var charCode = uniCharCode(charCodeAt.call(body, position + 1), charCodeAt.call(body, position + 2), charCodeAt.call(body, position + 3), charCodeAt.call(body, position + 4));
          if (charCode < 0) {
            throw (0, _error.syntaxError)(source, position, 'Invalid character escape sequence: ' + ('\\u' + body.slice(position + 1, position + 5) + '.'));
          }
          value += String.fromCharCode(charCode);
          position += 4;
          break;
        default:
          throw (0, _error.syntaxError)(source, position, 'Invalid character escape sequence: \\' + String.fromCharCode(code) + '.');
      }
      ++position;
      chunkStart = position;
    }
  }

  if (code !== 34) {
    // quote (")
    throw (0, _error.syntaxError)(source, position, 'Unterminated string.');
  }

  value += slice.call(body, chunkStart, position);
  return makeToken(TokenKind.STRING, start, position + 1, value);
}

/**
 * Converts four hexidecimal chars to the integer that the
 * string represents. For example, uniCharCode('0','0','0','f')
 * will return 15, and uniCharCode('0','0','f','f') returns 255.
 *
 * Returns a negative number on error, if a char was invalid.
 *
 * This is implemented by noting that char2hex() returns -1 on error,
 * which means the result of ORing the char2hex() will also be negative.
 */
function uniCharCode(a, b, c, d) {
  return char2hex(a) << 12 | char2hex(b) << 8 | char2hex(c) << 4 | char2hex(d);
}

/**
 * Converts a hex character to its integer value.
 * '0' becomes 0, '9' becomes 9
 * 'A' becomes 10, 'F' becomes 15
 * 'a' becomes 10, 'f' becomes 15
 *
 * Returns -1 on error.
 */
function char2hex(a) {
  return a >= 48 && a <= 57 ? a - 48 : // 0-9
  a >= 65 && a <= 70 ? a - 55 : // A-F
  a >= 97 && a <= 102 ? a - 87 : // a-f
  -1;
}

/**
 * Reads an alphanumeric + underscore name from the source.
 *
 * [_A-Za-z][_0-9A-Za-z]*
 */
function readName(source, position) {
  var body = source.body;
  var bodyLength = body.length;
  var end = position + 1;
  var code = 0;
  while (end !== bodyLength && (code = charCodeAt.call(body, end)) !== null && (code === 95 || // _
  code >= 48 && code <= 57 || // 0-9
  code >= 65 && code <= 90 || // A-Z
  code >= 97 && code <= 122) // a-z
  ) {
    ++end;
  }
  return makeToken(TokenKind.NAME, position, end, slice.call(body, position, end));
}

},{"../error":205}],220:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Represents a location in a Source.
 */
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.getLocation = getLocation;

/**
 * Takes a Source and a UTF-8 character offset, and returns the corresponding
 * line and column as a SourceLocation.
 */

function getLocation(source, position) {
  var line = 1;
  var column = position + 1;
  var lineRegexp = /\r\n|[\n\r\u2028\u2029]/g;
  var match;
  while ((match = lineRegexp.exec(source.body)) && match.index < position) {
    line += 1;
    column = position + 1 - (match.index + match[0].length);
  }
  return { line: line, column: column };
}

},{}],221:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

/**
 * Configuration options to control parser behavior
 */

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.parse = parse;
exports.parseValue = parseValue;
exports.parseConstValue = parseConstValue;
exports.parseType = parseType;
exports.parseNamedType = parseNamedType;

var _source = require('./source');

var _error = require('../error');

var _lexer = require('./lexer');

var _kinds = require('./kinds');

/**
 * Given a GraphQL source, parses it into a Document.
 * Throws GraphQLError if a syntax error is encountered.
 */

function parse(source, options) {
  var sourceObj = source instanceof _source.Source ? source : new _source.Source(source);
  var parser = makeParser(sourceObj, options || {});
  return parseDocument(parser);
}

/**
 * Given a string containing a GraphQL value, parse the AST for that value.
 * Throws GraphQLError if a syntax error is encountered.
 *
 * This is useful within tools that operate upon GraphQL Values directly and
 * in isolation of complete GraphQL documents.
 */

function parseValue(source, options) {
  var sourceObj = source instanceof _source.Source ? source : new _source.Source(source);
  var parser = makeParser(sourceObj, options || {});
  return parseValueLiteral(parser);
}

/**
 * Converts a name lex token into a name parse node.
 */
function parseName(parser) {
  var token = expect(parser, _lexer.TokenKind.NAME);
  return {
    kind: _kinds.NAME,
    value: token.value,
    loc: loc(parser, token.start)
  };
}

// Implements the parsing rules in the Document section.

/**
 * Document : Definition+
 */
function parseDocument(parser) {
  var start = parser.token.start;

  var definitions = [];
  do {
    definitions.push(parseDefinition(parser));
  } while (!skip(parser, _lexer.TokenKind.EOF));

  return {
    kind: _kinds.DOCUMENT,
    definitions: definitions,
    loc: loc(parser, start)
  };
}

/**
 * Definition :
 *   - OperationDefinition
 *   - FragmentDefinition
 *   - TypeDefinition
 */
function parseDefinition(parser) {
  if (peek(parser, _lexer.TokenKind.BRACE_L)) {
    return parseOperationDefinition(parser);
  }

  if (peek(parser, _lexer.TokenKind.NAME)) {
    switch (parser.token.value) {
      case 'query':
      case 'mutation':
      // Note: subscription is an experimental non-spec addition.
      case 'subscription':
        return parseOperationDefinition(parser);

      case 'fragment':
        return parseFragmentDefinition(parser);

      case 'type':
      case 'interface':
      case 'union':
      case 'scalar':
      case 'enum':
      case 'input':
      case 'extend':
        return parseTypeDefinition(parser);
    }
  }

  throw unexpected(parser);
}

// Implements the parsing rules in the Operations section.

/**
 * OperationDefinition :
 *  - SelectionSet
 *  - OperationType Name? VariableDefinitions? Directives? SelectionSet
 *
 * OperationType : one of query mutation
 */
function parseOperationDefinition(parser) {
  var start = parser.token.start;
  if (peek(parser, _lexer.TokenKind.BRACE_L)) {
    return {
      kind: _kinds.OPERATION_DEFINITION,
      operation: 'query',
      name: null,
      variableDefinitions: null,
      directives: [],
      selectionSet: parseSelectionSet(parser),
      loc: loc(parser, start)
    };
  }
  var operationToken = expect(parser, _lexer.TokenKind.NAME);
  var operation = operationToken.value;
  var name;
  if (peek(parser, _lexer.TokenKind.NAME)) {
    name = parseName(parser);
  }
  return {
    kind: _kinds.OPERATION_DEFINITION,
    operation: operation,
    name: name,
    variableDefinitions: parseVariableDefinitions(parser),
    directives: parseDirectives(parser),
    selectionSet: parseSelectionSet(parser),
    loc: loc(parser, start)
  };
}

/**
 * VariableDefinitions : ( VariableDefinition+ )
 */
function parseVariableDefinitions(parser) {
  return peek(parser, _lexer.TokenKind.PAREN_L) ? many(parser, _lexer.TokenKind.PAREN_L, parseVariableDefinition, _lexer.TokenKind.PAREN_R) : [];
}

/**
 * VariableDefinition : Variable : Type DefaultValue?
 */
function parseVariableDefinition(parser) {
  var start = parser.token.start;
  return {
    kind: _kinds.VARIABLE_DEFINITION,
    variable: parseVariable(parser),
    type: (expect(parser, _lexer.TokenKind.COLON), parseType(parser)),
    defaultValue: skip(parser, _lexer.TokenKind.EQUALS) ? parseValueLiteral(parser, true) : null,
    loc: loc(parser, start)
  };
}

/**
 * Variable : $ Name
 */
function parseVariable(parser) {
  var start = parser.token.start;
  expect(parser, _lexer.TokenKind.DOLLAR);
  return {
    kind: _kinds.VARIABLE,
    name: parseName(parser),
    loc: loc(parser, start)
  };
}

/**
 * SelectionSet : { Selection+ }
 */
function parseSelectionSet(parser) {
  var start = parser.token.start;
  return {
    kind: _kinds.SELECTION_SET,
    selections: many(parser, _lexer.TokenKind.BRACE_L, parseSelection, _lexer.TokenKind.BRACE_R),
    loc: loc(parser, start)
  };
}

/**
 * Selection :
 *   - Field
 *   - FragmentSpread
 *   - InlineFragment
 */
function parseSelection(parser) {
  return peek(parser, _lexer.TokenKind.SPREAD) ? parseFragment(parser) : parseField(parser);
}

/**
 * Field : Alias? Name Arguments? Directives? SelectionSet?
 *
 * Alias : Name :
 */
function parseField(parser) {
  var start = parser.token.start;

  var nameOrAlias = parseName(parser);
  var alias;
  var name;
  if (skip(parser, _lexer.TokenKind.COLON)) {
    alias = nameOrAlias;
    name = parseName(parser);
  } else {
    alias = null;
    name = nameOrAlias;
  }

  return {
    kind: _kinds.FIELD,
    alias: alias,
    name: name,
    arguments: parseArguments(parser),
    directives: parseDirectives(parser),
    selectionSet: peek(parser, _lexer.TokenKind.BRACE_L) ? parseSelectionSet(parser) : null,
    loc: loc(parser, start)
  };
}

/**
 * Arguments : ( Argument+ )
 */
function parseArguments(parser) {
  return peek(parser, _lexer.TokenKind.PAREN_L) ? many(parser, _lexer.TokenKind.PAREN_L, parseArgument, _lexer.TokenKind.PAREN_R) : [];
}

/**
 * Argument : Name : Value
 */
function parseArgument(parser) {
  var start = parser.token.start;
  return {
    kind: _kinds.ARGUMENT,
    name: parseName(parser),
    value: (expect(parser, _lexer.TokenKind.COLON), parseValueLiteral(parser, false)),
    loc: loc(parser, start)
  };
}

// Implements the parsing rules in the Fragments section.

/**
 * Corresponds to both FragmentSpread and InlineFragment in the spec.
 *
 * FragmentSpread : ... FragmentName Directives?
 *
 * InlineFragment : ... TypeCondition? Directives? SelectionSet
 */
function parseFragment(parser) {
  var start = parser.token.start;
  expect(parser, _lexer.TokenKind.SPREAD);
  if (peek(parser, _lexer.TokenKind.NAME) && parser.token.value !== 'on') {
    return {
      kind: _kinds.FRAGMENT_SPREAD,
      name: parseFragmentName(parser),
      directives: parseDirectives(parser),
      loc: loc(parser, start)
    };
  }
  var typeCondition = null;
  if (parser.token.value === 'on') {
    advance(parser);
    typeCondition = parseNamedType(parser);
  }
  return {
    kind: _kinds.INLINE_FRAGMENT,
    typeCondition: typeCondition,
    directives: parseDirectives(parser),
    selectionSet: parseSelectionSet(parser),
    loc: loc(parser, start)
  };
}

/**
 * FragmentDefinition :
 *   - fragment FragmentName on TypeCondition Directives? SelectionSet
 *
 * TypeCondition : NamedType
 */
function parseFragmentDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'fragment');
  return {
    kind: _kinds.FRAGMENT_DEFINITION,
    name: parseFragmentName(parser),
    typeCondition: (expectKeyword(parser, 'on'), parseNamedType(parser)),
    directives: parseDirectives(parser),
    selectionSet: parseSelectionSet(parser),
    loc: loc(parser, start)
  };
}

/**
 * FragmentName : Name but not `on`
 */
function parseFragmentName(parser) {
  if (parser.token.value === 'on') {
    throw unexpected(parser);
  }
  return parseName(parser);
}

// Implements the parsing rules in the Values section.

/**
 * Value[Const] :
 *   - [~Const] Variable
 *   - IntValue
 *   - FloatValue
 *   - StringValue
 *   - BooleanValue
 *   - EnumValue
 *   - ListValue[?Const]
 *   - ObjectValue[?Const]
 *
 * BooleanValue : one of `true` `false`
 *
 * EnumValue : Name but not `true`, `false` or `null`
 */
function parseValueLiteral(parser, isConst) {
  var token = parser.token;
  switch (token.kind) {
    case _lexer.TokenKind.BRACKET_L:
      return parseList(parser, isConst);
    case _lexer.TokenKind.BRACE_L:
      return parseObject(parser, isConst);
    case _lexer.TokenKind.INT:
      advance(parser);
      return {
        kind: _kinds.INT,
        value: token.value,
        loc: loc(parser, token.start)
      };
    case _lexer.TokenKind.FLOAT:
      advance(parser);
      return {
        kind: _kinds.FLOAT,
        value: token.value,
        loc: loc(parser, token.start)
      };
    case _lexer.TokenKind.STRING:
      advance(parser);
      return {
        kind: _kinds.STRING,
        value: token.value,
        loc: loc(parser, token.start)
      };
    case _lexer.TokenKind.NAME:
      if (token.value === 'true' || token.value === 'false') {
        advance(parser);
        return {
          kind: _kinds.BOOLEAN,
          value: token.value === 'true',
          loc: loc(parser, token.start)
        };
      } else if (token.value !== 'null') {
        advance(parser);
        return {
          kind: _kinds.ENUM,
          value: token.value,
          loc: loc(parser, token.start)
        };
      }
      break;
    case _lexer.TokenKind.DOLLAR:
      if (!isConst) {
        return parseVariable(parser);
      }
      break;
  }
  throw unexpected(parser);
}

function parseConstValue(parser) {
  return parseValueLiteral(parser, true);
}

function parseValueValue(parser) {
  return parseValueLiteral(parser, false);
}

/**
 * ListValue[Const] :
 *   - [ ]
 *   - [ Value[?Const]+ ]
 */
function parseList(parser, isConst) {
  var start = parser.token.start;
  var item = isConst ? parseConstValue : parseValueValue;
  return {
    kind: _kinds.LIST,
    values: any(parser, _lexer.TokenKind.BRACKET_L, item, _lexer.TokenKind.BRACKET_R),
    loc: loc(parser, start)
  };
}

/**
 * ObjectValue[Const] :
 *   - { }
 *   - { ObjectField[?Const]+ }
 */
function parseObject(parser, isConst) {
  var start = parser.token.start;
  expect(parser, _lexer.TokenKind.BRACE_L);
  var fields = [];
  while (!skip(parser, _lexer.TokenKind.BRACE_R)) {
    fields.push(parseObjectField(parser, isConst));
  }
  return {
    kind: _kinds.OBJECT,
    fields: fields,
    loc: loc(parser, start)
  };
}

/**
 * ObjectField[Const] : Name : Value[?Const]
 */
function parseObjectField(parser, isConst) {
  var start = parser.token.start;
  return {
    kind: _kinds.OBJECT_FIELD,
    name: parseName(parser),
    value: (expect(parser, _lexer.TokenKind.COLON), parseValueLiteral(parser, isConst)),
    loc: loc(parser, start)
  };
}

// Implements the parsing rules in the Directives section.

/**
 * Directives : Directive+
 */
function parseDirectives(parser) {
  var directives = [];
  while (peek(parser, _lexer.TokenKind.AT)) {
    directives.push(parseDirective(parser));
  }
  return directives;
}

/**
 * Directive : @ Name Arguments?
 */
function parseDirective(parser) {
  var start = parser.token.start;
  expect(parser, _lexer.TokenKind.AT);
  return {
    kind: _kinds.DIRECTIVE,
    name: parseName(parser),
    arguments: parseArguments(parser),
    loc: loc(parser, start)
  };
}

// Implements the parsing rules in the Types section.

/**
 * Type :
 *   - NamedType
 *   - ListType
 *   - NonNullType
 */

function parseType(parser) {
  var start = parser.token.start;
  var type;
  if (skip(parser, _lexer.TokenKind.BRACKET_L)) {
    type = parseType(parser);
    expect(parser, _lexer.TokenKind.BRACKET_R);
    type = {
      kind: _kinds.LIST_TYPE,
      type: type,
      loc: loc(parser, start)
    };
  } else {
    type = parseNamedType(parser);
  }
  if (skip(parser, _lexer.TokenKind.BANG)) {
    return {
      kind: _kinds.NON_NULL_TYPE,
      type: type,
      loc: loc(parser, start)
    };
  }
  return type;
}

/**
 * NamedType : Name
 */

function parseNamedType(parser) {
  var start = parser.token.start;
  return {
    kind: _kinds.NAMED_TYPE,
    name: parseName(parser),
    loc: loc(parser, start)
  };
}

// Implements the parsing rules in the Type Definition section.

/**
 * TypeDefinition :
 *   - ObjectTypeDefinition
 *   - InterfaceTypeDefinition
 *   - UnionTypeDefinition
 *   - ScalarTypeDefinition
 *   - EnumTypeDefinition
 *   - InputObjectTypeDefinition
 *   - TypeExtensionDefinition
 */
function parseTypeDefinition(parser) {
  if (!peek(parser, _lexer.TokenKind.NAME)) {
    throw unexpected(parser);
  }
  switch (parser.token.value) {
    case 'type':
      return parseObjectTypeDefinition(parser);
    case 'interface':
      return parseInterfaceTypeDefinition(parser);
    case 'union':
      return parseUnionTypeDefinition(parser);
    case 'scalar':
      return parseScalarTypeDefinition(parser);
    case 'enum':
      return parseEnumTypeDefinition(parser);
    case 'input':
      return parseInputObjectTypeDefinition(parser);
    case 'extend':
      return parseTypeExtensionDefinition(parser);
    default:
      throw unexpected(parser);
  }
}

/**
 * ObjectTypeDefinition : type Name ImplementsInterfaces? { FieldDefinition+ }
 */
function parseObjectTypeDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'type');
  var name = parseName(parser);
  var interfaces = parseImplementsInterfaces(parser);
  var fields = any(parser, _lexer.TokenKind.BRACE_L, parseFieldDefinition, _lexer.TokenKind.BRACE_R);
  return {
    kind: _kinds.OBJECT_TYPE_DEFINITION,
    name: name,
    interfaces: interfaces,
    fields: fields,
    loc: loc(parser, start)
  };
}

/**
 * ImplementsInterfaces : implements NamedType+
 */
function parseImplementsInterfaces(parser) {
  var types = [];
  if (parser.token.value === 'implements') {
    advance(parser);
    do {
      types.push(parseNamedType(parser));
    } while (!peek(parser, _lexer.TokenKind.BRACE_L));
  }
  return types;
}

/**
 * FieldDefinition : Name ArgumentsDefinition? : Type
 */
function parseFieldDefinition(parser) {
  var start = parser.token.start;
  var name = parseName(parser);
  var args = parseArgumentDefs(parser);
  expect(parser, _lexer.TokenKind.COLON);
  var type = parseType(parser);
  return {
    kind: _kinds.FIELD_DEFINITION,
    name: name,
    arguments: args,
    type: type,
    loc: loc(parser, start)
  };
}

/**
 * ArgumentsDefinition : ( InputValueDefinition+ )
 */
function parseArgumentDefs(parser) {
  if (!peek(parser, _lexer.TokenKind.PAREN_L)) {
    return [];
  }
  return many(parser, _lexer.TokenKind.PAREN_L, parseInputValueDef, _lexer.TokenKind.PAREN_R);
}

/**
 * InputValueDefinition : Name : Type DefaultValue?
 */
function parseInputValueDef(parser) {
  var start = parser.token.start;
  var name = parseName(parser);
  expect(parser, _lexer.TokenKind.COLON);
  var type = parseType(parser);
  var defaultValue = null;
  if (skip(parser, _lexer.TokenKind.EQUALS)) {
    defaultValue = parseConstValue(parser);
  }
  return {
    kind: _kinds.INPUT_VALUE_DEFINITION,
    name: name,
    type: type,
    defaultValue: defaultValue,
    loc: loc(parser, start)
  };
}

/**
 * InterfaceTypeDefinition : interface Name { FieldDefinition+ }
 */
function parseInterfaceTypeDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'interface');
  var name = parseName(parser);
  var fields = any(parser, _lexer.TokenKind.BRACE_L, parseFieldDefinition, _lexer.TokenKind.BRACE_R);
  return {
    kind: _kinds.INTERFACE_TYPE_DEFINITION,
    name: name,
    fields: fields,
    loc: loc(parser, start)
  };
}

/**
 * UnionTypeDefinition : union Name = UnionMembers
 */
function parseUnionTypeDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'union');
  var name = parseName(parser);
  expect(parser, _lexer.TokenKind.EQUALS);
  var types = parseUnionMembers(parser);
  return {
    kind: _kinds.UNION_TYPE_DEFINITION,
    name: name,
    types: types,
    loc: loc(parser, start)
  };
}

/**
 * UnionMembers :
 *   - NamedType
 *   - UnionMembers | NamedType
 */
function parseUnionMembers(parser) {
  var members = [];
  do {
    members.push(parseNamedType(parser));
  } while (skip(parser, _lexer.TokenKind.PIPE));
  return members;
}

/**
 * ScalarTypeDefinition : scalar Name
 */
function parseScalarTypeDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'scalar');
  var name = parseName(parser);
  return {
    kind: _kinds.SCALAR_TYPE_DEFINITION,
    name: name,
    loc: loc(parser, start)
  };
}

/**
 * EnumTypeDefinition : enum Name { EnumValueDefinition+ }
 */
function parseEnumTypeDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'enum');
  var name = parseName(parser);
  var values = many(parser, _lexer.TokenKind.BRACE_L, parseEnumValueDefinition, _lexer.TokenKind.BRACE_R);
  return {
    kind: _kinds.ENUM_TYPE_DEFINITION,
    name: name,
    values: values,
    loc: loc(parser, start)
  };
}

/**
 * EnumValueDefinition : EnumValue
 *
 * EnumValue : Name
 */
function parseEnumValueDefinition(parser) {
  var start = parser.token.start;
  var name = parseName(parser);
  return {
    kind: _kinds.ENUM_VALUE_DEFINITION,
    name: name,
    loc: loc(parser, start)
  };
}

/**
 * InputObjectTypeDefinition : input Name { InputValueDefinition+ }
 */
function parseInputObjectTypeDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'input');
  var name = parseName(parser);
  var fields = any(parser, _lexer.TokenKind.BRACE_L, parseInputValueDef, _lexer.TokenKind.BRACE_R);
  return {
    kind: _kinds.INPUT_OBJECT_TYPE_DEFINITION,
    name: name,
    fields: fields,
    loc: loc(parser, start)
  };
}

/**
 * TypeExtensionDefinition : extend ObjectTypeDefinition
 */
function parseTypeExtensionDefinition(parser) {
  var start = parser.token.start;
  expectKeyword(parser, 'extend');
  var definition = parseObjectTypeDefinition(parser);
  return {
    kind: _kinds.TYPE_EXTENSION_DEFINITION,
    definition: definition,
    loc: loc(parser, start)
  };
}

// Core parsing utility functions

/**
 * Returns the parser object that is used to store state throughout the
 * process of parsing.
 */
function makeParser(source, options) {
  var _lexToken = (0, _lexer.lex)(source);
  return {
    _lexToken: _lexToken,
    source: source,
    options: options,
    prevEnd: 0,
    token: _lexToken()
  };
}

/**
 * Returns a location object, used to identify the place in
 * the source that created a given parsed object.
 */
function loc(parser, start) {
  if (parser.options.noLocation) {
    return null;
  }
  if (parser.options.noSource) {
    return { start: start, end: parser.prevEnd };
  }
  return { start: start, end: parser.prevEnd, source: parser.source };
}

/**
 * Moves the internal parser object to the next lexed token.
 */
function advance(parser) {
  var prevEnd = parser.token.end;
  parser.prevEnd = prevEnd;
  parser.token = parser._lexToken(prevEnd);
}

/**
 * Determines if the next token is of a given kind
 */
function peek(parser, kind) {
  return parser.token.kind === kind;
}

/**
 * If the next token is of the given kind, return true after advancing
 * the parser. Otherwise, do not change the parser state and return false.
 */
function skip(parser, kind) {
  var match = parser.token.kind === kind;
  if (match) {
    advance(parser);
  }
  return match;
}

/**
 * If the next token is of the given kind, return that token after advancing
 * the parser. Otherwise, do not change the parser state and return false.
 */
function expect(parser, kind) {
  var token = parser.token;
  if (token.kind === kind) {
    advance(parser);
    return token;
  }
  throw (0, _error.syntaxError)(parser.source, token.start, 'Expected ' + (0, _lexer.getTokenKindDesc)(kind) + ', found ' + (0, _lexer.getTokenDesc)(token));
}

/**
 * If the next token is a keyword with the given value, return that token after
 * advancing the parser. Otherwise, do not change the parser state and return
 * false.
 */
function expectKeyword(parser, value) {
  var token = parser.token;
  if (token.kind === _lexer.TokenKind.NAME && token.value === value) {
    advance(parser);
    return token;
  }
  throw (0, _error.syntaxError)(parser.source, token.start, 'Expected "' + value + '", found ' + (0, _lexer.getTokenDesc)(token));
}

/**
 * Helper function for creating an error when an unexpected lexed token
 * is encountered.
 */
function unexpected(parser, atToken) {
  var token = atToken || parser.token;
  return (0, _error.syntaxError)(parser.source, token.start, 'Unexpected ' + (0, _lexer.getTokenDesc)(token));
}

/**
 * Returns a possibly empty list of parse nodes, determined by
 * the parseFn. This list begins with a lex token of openKind
 * and ends with a lex token of closeKind. Advances the parser
 * to the next lex token after the closing token.
 */
function any(parser, openKind, parseFn, closeKind) {
  expect(parser, openKind);
  var nodes = [];
  while (!skip(parser, closeKind)) {
    nodes.push(parseFn(parser));
  }
  return nodes;
}

/**
 * Returns a non-empty list of parse nodes, determined by
 * the parseFn. This list begins with a lex token of openKind
 * and ends with a lex token of closeKind. Advances the parser
 * to the next lex token after the closing token.
 */
function many(parser, openKind, parseFn, closeKind) {
  expect(parser, openKind);
  var nodes = [parseFn(parser)];
  while (!skip(parser, closeKind)) {
    nodes.push(parseFn(parser));
  }
  return nodes;
}

/**
 * By default, the parser creates AST nodes that know the location
 * in the source that they correspond to. This configuration flag
 * disables that behavior for performance or testing.
 */

/**
 * By default, the parser creates AST nodes that contain a reference
 * to the source that they were created from. This configuration flag
 * disables that behavior for performance or testing.
 */

},{"../error":205,"./kinds":218,"./lexer":219,"./source":223}],222:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.print = print;

var _visitor = require('./visitor');

/**
 * Converts an AST into a string, using one set of reasonable
 * formatting rules.
 */

function print(ast) {
  return (0, _visitor.visit)(ast, { leave: printDocASTReducer });
}

var printDocASTReducer = {
  Name: function Name(node) {
    return node.value;
  },
  Variable: function Variable(node) {
    return '$' + node.name;
  },

  // Document

  Document: function Document(node) {
    return join(node.definitions, '\n\n') + '\n';
  },

  OperationDefinition: function OperationDefinition(node) {
    var op = node.operation;
    var name = node.name;
    var defs = wrap('(', join(node.variableDefinitions, ', '), ')');
    var directives = join(node.directives, ' ');
    var selectionSet = node.selectionSet;
    return !name ? selectionSet : join([op, join([name, defs]), directives, selectionSet], ' ');
  },

  VariableDefinition: function VariableDefinition(_ref) {
    var variable = _ref.variable;
    var type = _ref.type;
    var defaultValue = _ref.defaultValue;
    return variable + ': ' + type + wrap(' = ', defaultValue);
  },

  SelectionSet: function SelectionSet(_ref2) {
    var selections = _ref2.selections;
    return block(selections);
  },

  Field: function Field(_ref3) {
    var alias = _ref3.alias;
    var name = _ref3.name;
    var args = _ref3.arguments;
    var directives = _ref3.directives;
    var selectionSet = _ref3.selectionSet;
    return join([wrap('', alias, ': ') + name + wrap('(', join(args, ', '), ')'), join(directives, ' '), selectionSet], ' ');
  },

  Argument: function Argument(_ref4) {
    var name = _ref4.name;
    var value = _ref4.value;
    return name + ': ' + value;
  },

  // Fragments

  FragmentSpread: function FragmentSpread(_ref5) {
    var name = _ref5.name;
    var directives = _ref5.directives;
    return '...' + name + wrap(' ', join(directives, ' '));
  },

  InlineFragment: function InlineFragment(_ref6) {
    var typeCondition = _ref6.typeCondition;
    var directives = _ref6.directives;
    var selectionSet = _ref6.selectionSet;
    return join(['...', wrap('on ', typeCondition), join(directives, ' '), selectionSet], ' ');
  },

  FragmentDefinition: function FragmentDefinition(_ref7) {
    var name = _ref7.name;
    var typeCondition = _ref7.typeCondition;
    var directives = _ref7.directives;
    var selectionSet = _ref7.selectionSet;
    return 'fragment ' + name + ' on ' + typeCondition + ' ' + wrap('', join(directives, ' '), ' ') + selectionSet;
  },

  // Value

  IntValue: function IntValue(_ref8) {
    var value = _ref8.value;
    return value;
  },
  FloatValue: function FloatValue(_ref9) {
    var value = _ref9.value;
    return value;
  },
  StringValue: function StringValue(_ref10) {
    var value = _ref10.value;
    return JSON.stringify(value);
  },
  BooleanValue: function BooleanValue(_ref11) {
    var value = _ref11.value;
    return JSON.stringify(value);
  },
  EnumValue: function EnumValue(_ref12) {
    var value = _ref12.value;
    return value;
  },
  ListValue: function ListValue(_ref13) {
    var values = _ref13.values;
    return '[' + join(values, ', ') + ']';
  },
  ObjectValue: function ObjectValue(_ref14) {
    var fields = _ref14.fields;
    return '{' + join(fields, ', ') + '}';
  },
  ObjectField: function ObjectField(_ref15) {
    var name = _ref15.name;
    var value = _ref15.value;
    return name + ': ' + value;
  },

  // Directive

  Directive: function Directive(_ref16) {
    var name = _ref16.name;
    var args = _ref16.arguments;
    return '@' + name + wrap('(', join(args, ', '), ')');
  },

  // Type

  NamedType: function NamedType(_ref17) {
    var name = _ref17.name;
    return name;
  },
  ListType: function ListType(_ref18) {
    var type = _ref18.type;
    return '[' + type + ']';
  },
  NonNullType: function NonNullType(_ref19) {
    var type = _ref19.type;
    return type + '!';
  },

  // Type Definitions

  ObjectTypeDefinition: function ObjectTypeDefinition(_ref20) {
    var name = _ref20.name;
    var interfaces = _ref20.interfaces;
    var fields = _ref20.fields;
    return 'type ' + name + ' ' + wrap('implements ', join(interfaces, ', '), ' ') + block(fields);
  },

  FieldDefinition: function FieldDefinition(_ref21) {
    var name = _ref21.name;
    var args = _ref21.arguments;
    var type = _ref21.type;
    return name + wrap('(', join(args, ', '), ')') + ': ' + type;
  },

  InputValueDefinition: function InputValueDefinition(_ref22) {
    var name = _ref22.name;
    var type = _ref22.type;
    var defaultValue = _ref22.defaultValue;
    return name + ': ' + type + wrap(' = ', defaultValue);
  },

  InterfaceTypeDefinition: function InterfaceTypeDefinition(_ref23) {
    var name = _ref23.name;
    var fields = _ref23.fields;
    return 'interface ' + name + ' ' + block(fields);
  },

  UnionTypeDefinition: function UnionTypeDefinition(_ref24) {
    var name = _ref24.name;
    var types = _ref24.types;
    return 'union ' + name + ' = ' + join(types, ' | ');
  },

  ScalarTypeDefinition: function ScalarTypeDefinition(_ref25) {
    var name = _ref25.name;
    return 'scalar ' + name;
  },

  EnumTypeDefinition: function EnumTypeDefinition(_ref26) {
    var name = _ref26.name;
    var values = _ref26.values;
    return 'enum ' + name + ' ' + block(values);
  },

  EnumValueDefinition: function EnumValueDefinition(_ref27) {
    var name = _ref27.name;
    return name;
  },

  InputObjectTypeDefinition: function InputObjectTypeDefinition(_ref28) {
    var name = _ref28.name;
    var fields = _ref28.fields;
    return 'input ' + name + ' ' + block(fields);
  },

  TypeExtensionDefinition: function TypeExtensionDefinition(_ref29) {
    var definition = _ref29.definition;
    return 'extend ' + definition;
  }
};

/**
 * Given maybeArray, print an empty string if it is null or empty, otherwise
 * print all items together separated by separator if provided
 */
function join(maybeArray, separator) {
  return maybeArray ? maybeArray.filter(function (x) {
    return x;
  }).join(separator || '') : '';
}

/**
 * Given maybeArray, print an empty string if it is null or empty, otherwise
 * print each item on its own line, wrapped in an indented "{ }" block.
 */
function block(maybeArray) {
  return length(maybeArray) ? indent('{\n' + join(maybeArray, '\n')) + '\n}' : '';
}

/**
 * If maybeString is not null or empty, then wrap with start and end, otherwise
 * print an empty string.
 */
function wrap(start, maybeString, end) {
  return maybeString ? start + maybeString + (end || '') : '';
}

function indent(maybeString) {
  return maybeString && maybeString.replace(/\n/g, '\n  ');
}

function length(maybeArray) {
  return maybeArray ? maybeArray.length : 0;
}

},{"./visitor":224}],223:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * A representation of source input to GraphQL. The name is optional,
 * but is mostly useful for clients who store GraphQL documents in
 * source files; for example, if the GraphQL input is in a file Foo.graphql,
 * it might be useful for name to be "Foo.graphql".
 */
'use strict';

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});

var Source = function Source(body, name) {
  _classCallCheck(this, Source);

  this.body = body;
  this.name = name || 'GraphQL';
};

exports.Source = Source;

},{"babel-runtime/helpers/class-call-check":237}],224:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _slicedToArray = require('babel-runtime/helpers/sliced-to-array')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.visit = visit;
exports.visitInParallel = visitInParallel;
exports.visitWithTypeInfo = visitWithTypeInfo;
var QueryDocumentKeys = {
  Name: [],

  Document: ['definitions'],
  OperationDefinition: ['name', 'variableDefinitions', 'directives', 'selectionSet'],
  VariableDefinition: ['variable', 'type', 'defaultValue'],
  Variable: ['name'],
  SelectionSet: ['selections'],
  Field: ['alias', 'name', 'arguments', 'directives', 'selectionSet'],
  Argument: ['name', 'value'],

  FragmentSpread: ['name', 'directives'],
  InlineFragment: ['typeCondition', 'directives', 'selectionSet'],
  FragmentDefinition: ['name', 'typeCondition', 'directives', 'selectionSet'],

  IntValue: [],
  FloatValue: [],
  StringValue: [],
  BooleanValue: [],
  EnumValue: [],
  ListValue: ['values'],
  ObjectValue: ['fields'],
  ObjectField: ['name', 'value'],

  Directive: ['name', 'arguments'],

  NamedType: ['name'],
  ListType: ['type'],
  NonNullType: ['type'],

  ObjectTypeDefinition: ['name', 'interfaces', 'fields'],
  FieldDefinition: ['name', 'arguments', 'type'],
  InputValueDefinition: ['name', 'type', 'defaultValue'],
  InterfaceTypeDefinition: ['name', 'fields'],
  UnionTypeDefinition: ['name', 'types'],
  ScalarTypeDefinition: ['name'],
  EnumTypeDefinition: ['name', 'values'],
  EnumValueDefinition: ['name'],
  InputObjectTypeDefinition: ['name', 'fields'],
  TypeExtensionDefinition: ['definition']
};

exports.QueryDocumentKeys = QueryDocumentKeys;
var BREAK = {};

exports.BREAK = BREAK;
/**
 * visit() will walk through an AST using a depth first traversal, calling
 * the visitor's enter function at each node in the traversal, and calling the
 * leave function after visiting that node and all of its child nodes.
 *
 * By returning different values from the enter and leave functions, the
 * behavior of the visitor can be altered, including skipping over a sub-tree of
 * the AST (by returning false), editing the AST by returning a value or null
 * to remove the value, or to stop the whole traversal by returning BREAK.
 *
 * When using visit() to edit an AST, the original AST will not be modified, and
 * a new version of the AST with the changes applied will be returned from the
 * visit function.
 *
 *     var editedAST = visit(ast, {
 *       enter(node, key, parent, path, ancestors) {
 *         // @return
 *         //   undefined: no action
 *         //   false: skip visiting this node
 *         //   visitor.BREAK: stop visiting altogether
 *         //   null: delete this node
 *         //   any value: replace this node with the returned value
 *       },
 *       leave(node, key, parent, path, ancestors) {
 *         // @return
 *         //   undefined: no action
 *         //   false: no action
 *         //   visitor.BREAK: stop visiting altogether
 *         //   null: delete this node
 *         //   any value: replace this node with the returned value
 *       }
 *     });
 *
 * Alternatively to providing enter() and leave() functions, a visitor can
 * instead provide functions named the same as the kinds of AST nodes, or
 * enter/leave visitors at a named key, leading to four permutations of
 * visitor API:
 *
 * 1) Named visitors triggered when entering a node a specific kind.
 *
 *     visit(ast, {
 *       Kind(node) {
 *         // enter the "Kind" node
 *       }
 *     })
 *
 * 2) Named visitors that trigger upon entering and leaving a node of
 *    a specific kind.
 *
 *     visit(ast, {
 *       Kind: {
 *         enter(node) {
 *           // enter the "Kind" node
 *         }
 *         leave(node) {
 *           // leave the "Kind" node
 *         }
 *       }
 *     })
 *
 * 3) Generic visitors that trigger upon entering and leaving any node.
 *
 *     visit(ast, {
 *       enter(node) {
 *         // enter any node
 *       },
 *       leave(node) {
 *         // leave any node
 *       }
 *     })
 *
 * 4) Parallel visitors for entering and leaving nodes of a specific kind.
 *
 *     visit(ast, {
 *       enter: {
 *         Kind(node) {
 *           // enter the "Kind" node
 *         }
 *       },
 *       leave: {
 *         Kind(node) {
 *           // leave the "Kind" node
 *         }
 *       }
 *     })
 */

function visit(root, visitor, keyMap) {
  var visitorKeys = keyMap || QueryDocumentKeys;

  var stack;
  var inArray = Array.isArray(root);
  var keys = [root];
  var index = -1;
  var edits = [];
  var parent;
  var path = [];
  var ancestors = [];
  var newRoot = root;

  do {
    index++;
    var isLeaving = index === keys.length;
    var key;
    var node;
    var isEdited = isLeaving && edits.length !== 0;
    if (isLeaving) {
      key = ancestors.length === 0 ? undefined : path.pop();
      node = parent;
      parent = ancestors.pop();
      if (isEdited) {
        if (inArray) {
          node = node.slice();
        } else {
          var clone = {};
          for (var k in node) {
            if (node.hasOwnProperty(k)) {
              clone[k] = node[k];
            }
          }
          node = clone;
        }
        var editOffset = 0;
        for (var ii = 0; ii < edits.length; ii++) {
          var _edits$ii = _slicedToArray(edits[ii], 2);

          var editKey = _edits$ii[0];
          var editValue = _edits$ii[1];

          if (inArray) {
            editKey -= editOffset;
          }
          if (inArray && editValue === null) {
            node.splice(editKey, 1);
            editOffset++;
          } else {
            node[editKey] = editValue;
          }
        }
      }
      index = stack.index;
      keys = stack.keys;
      edits = stack.edits;
      inArray = stack.inArray;
      stack = stack.prev;
    } else {
      key = parent ? inArray ? index : keys[index] : undefined;
      node = parent ? parent[key] : newRoot;
      if (node === null || node === undefined) {
        continue;
      }
      if (parent) {
        path.push(key);
      }
    }

    var result = undefined;
    if (!Array.isArray(node)) {
      if (!isNode(node)) {
        throw new Error('Invalid AST Node: ' + JSON.stringify(node));
      }
      var visitFn = getVisitFn(visitor, node.kind, isLeaving);
      if (visitFn) {
        result = visitFn.call(visitor, node, key, parent, path, ancestors);

        if (result === BREAK) {
          break;
        }

        if (result === false) {
          if (!isLeaving) {
            path.pop();
            continue;
          }
        } else if (result !== undefined) {
          edits.push([key, result]);
          if (!isLeaving) {
            if (isNode(result)) {
              node = result;
            } else {
              path.pop();
              continue;
            }
          }
        }
      }
    }

    if (result === undefined && isEdited) {
      edits.push([key, node]);
    }

    if (!isLeaving) {
      stack = { inArray: inArray, index: index, keys: keys, edits: edits, prev: stack };
      inArray = Array.isArray(node);
      keys = inArray ? node : visitorKeys[node.kind] || [];
      index = -1;
      edits = [];
      if (parent) {
        ancestors.push(parent);
      }
      parent = node;
    }
  } while (stack !== undefined);

  if (edits.length !== 0) {
    newRoot = edits[0][1];
  }

  return newRoot;
}

function isNode(maybeNode) {
  return maybeNode && typeof maybeNode.kind === 'string';
}

/**
 * Creates a new visitor instance which delegates to many visitors to run in
 * parallel. Each visitor will be visited for each node before moving on.
 *
 * If a prior visitor edits a node, no following visitors will see that node.
 */

function visitInParallel(visitors) {
  var skipping = new Array(visitors.length);

  return {
    enter: function enter(node) {
      for (var i = 0; i < visitors.length; i++) {
        if (!skipping[i]) {
          var fn = getVisitFn(visitors[i], node.kind, /* isLeaving */false);
          if (fn) {
            var result = fn.apply(visitors[i], arguments);
            if (result === false) {
              skipping[i] = node;
            } else if (result === BREAK) {
              skipping[i] = BREAK;
            } else if (result !== undefined) {
              return result;
            }
          }
        }
      }
    },
    leave: function leave(node) {
      for (var i = 0; i < visitors.length; i++) {
        if (!skipping[i]) {
          var fn = getVisitFn(visitors[i], node.kind, /* isLeaving */true);
          if (fn) {
            var result = fn.apply(visitors[i], arguments);
            if (result === BREAK) {
              skipping[i] = BREAK;
            } else if (result !== undefined && result !== false) {
              return result;
            }
          }
        } else if (skipping[i] === node) {
          skipping[i] = null;
        }
      }
    }
  };
}

/**
 * Creates a new visitor instance which maintains a provided TypeInfo instance
 * along with visiting visitor.
 */

function visitWithTypeInfo(typeInfo, visitor) {
  return {
    enter: function enter(node) {
      typeInfo.enter(node);
      var fn = getVisitFn(visitor, node.kind, /* isLeaving */false);
      if (fn) {
        var result = fn.apply(visitor, arguments);
        if (result !== undefined) {
          typeInfo.leave(node);
          if (isNode(result)) {
            typeInfo.enter(result);
          }
        }
        return result;
      }
    },
    leave: function leave(node) {
      var fn = getVisitFn(visitor, node.kind, /* isLeaving */true);
      var result = undefined;
      if (fn) {
        result = fn.apply(visitor, arguments);
      }
      typeInfo.leave(node);
      return result;
    }
  };
}

/**
 * Given a visitor instance, if it is leaving or not, and a node kind, return
 * the function the visitor runtime should call.
 */
function getVisitFn(visitor, kind, isLeaving) {
  var kindVisitor = visitor[kind];
  if (kindVisitor) {
    if (!isLeaving && typeof kindVisitor === 'function') {
      // { Kind() {} }
      return kindVisitor;
    }
    var kindSpecificVisitor = isLeaving ? kindVisitor.leave : kindVisitor.enter;
    if (typeof kindSpecificVisitor === 'function') {
      // { Kind: { enter() {}, leave() {} } }
      return kindSpecificVisitor;
    }
  } else {
    var specificVisitor = isLeaving ? visitor.leave : visitor.enter;
    if (specificVisitor) {
      if (typeof specificVisitor === 'function') {
        // { enter() {}, leave() {} }
        return specificVisitor;
      }
      var specificKindVisitor = specificVisitor[kind];
      if (typeof specificKindVisitor === 'function') {
        // { enter: { Kind() {} }, leave: { Kind() {} } }
        return specificKindVisitor;
      }
    }
  }
}

},{"babel-runtime/helpers/sliced-to-array":244}],225:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/array/from"), __esModule: true };

},{"core-js/library/fn/array/from":246}],226:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/get-iterator"), __esModule: true };

},{"core-js/library/fn/get-iterator":247}],227:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/is-iterable"), __esModule: true };

},{"core-js/library/fn/is-iterable":248}],228:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/map"), __esModule: true };

},{"core-js/library/fn/map":249}],229:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/object/assign"), __esModule: true };

},{"core-js/library/fn/object/assign":250}],230:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/object/create"), __esModule: true };

},{"core-js/library/fn/object/create":251}],231:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/object/define-property"), __esModule: true };

},{"core-js/library/fn/object/define-property":252}],232:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/object/get-own-property-descriptor"), __esModule: true };

},{"core-js/library/fn/object/get-own-property-descriptor":253}],233:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/object/keys"), __esModule: true };

},{"core-js/library/fn/object/keys":254}],234:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/object/set-prototype-of"), __esModule: true };

},{"core-js/library/fn/object/set-prototype-of":255}],235:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/promise"), __esModule: true };

},{"core-js/library/fn/promise":256}],236:[function(require,module,exports){
"use strict";

module.exports = { "default": require("core-js/library/fn/set"), __esModule: true };

},{"core-js/library/fn/set":257}],237:[function(require,module,exports){
"use strict";

exports["default"] = function (instance, Constructor) {
  if (!(instance instanceof Constructor)) {
    throw new TypeError("Cannot call a class as a function");
  }
};

exports.__esModule = true;

},{}],238:[function(require,module,exports){
"use strict";

var _Object$defineProperty = require("babel-runtime/core-js/object/define-property")["default"];

exports["default"] = function () {
  function defineProperties(target, props) {
    for (var i = 0; i < props.length; i++) {
      var descriptor = props[i];
      descriptor.enumerable = descriptor.enumerable || false;
      descriptor.configurable = true;
      if ("value" in descriptor) descriptor.writable = true;

      _Object$defineProperty(target, descriptor.key, descriptor);
    }
  }

  return function (Constructor, protoProps, staticProps) {
    if (protoProps) defineProperties(Constructor.prototype, protoProps);
    if (staticProps) defineProperties(Constructor, staticProps);
    return Constructor;
  };
}();

exports.__esModule = true;

},{"babel-runtime/core-js/object/define-property":231}],239:[function(require,module,exports){
"use strict";

var _Object$assign = require("babel-runtime/core-js/object/assign")["default"];

exports["default"] = _Object$assign || function (target) {
  for (var i = 1; i < arguments.length; i++) {
    var source = arguments[i];

    for (var key in source) {
      if (Object.prototype.hasOwnProperty.call(source, key)) {
        target[key] = source[key];
      }
    }
  }

  return target;
};

exports.__esModule = true;

},{"babel-runtime/core-js/object/assign":229}],240:[function(require,module,exports){
"use strict";

var _Object$getOwnPropertyDescriptor = require("babel-runtime/core-js/object/get-own-property-descriptor")["default"];

exports["default"] = function get(_x, _x2, _x3) {
  var _again = true;

  _function: while (_again) {
    var object = _x,
        property = _x2,
        receiver = _x3;
    _again = false;
    if (object === null) object = Function.prototype;

    var desc = _Object$getOwnPropertyDescriptor(object, property);

    if (desc === undefined) {
      var parent = Object.getPrototypeOf(object);

      if (parent === null) {
        return undefined;
      } else {
        _x = parent;
        _x2 = property;
        _x3 = receiver;
        _again = true;
        desc = parent = undefined;
        continue _function;
      }
    } else if ("value" in desc) {
      return desc.value;
    } else {
      var getter = desc.get;

      if (getter === undefined) {
        return undefined;
      }

      return getter.call(receiver);
    }
  }
};

exports.__esModule = true;

},{"babel-runtime/core-js/object/get-own-property-descriptor":232}],241:[function(require,module,exports){
"use strict";

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var _Object$create = require("babel-runtime/core-js/object/create")["default"];

var _Object$setPrototypeOf = require("babel-runtime/core-js/object/set-prototype-of")["default"];

exports["default"] = function (subClass, superClass) {
  if (typeof superClass !== "function" && superClass !== null) {
    throw new TypeError("Super expression must either be null or a function, not " + (typeof superClass === "undefined" ? "undefined" : _typeof(superClass)));
  }

  subClass.prototype = _Object$create(superClass && superClass.prototype, {
    constructor: {
      value: subClass,
      enumerable: false,
      writable: true,
      configurable: true
    }
  });
  if (superClass) _Object$setPrototypeOf ? _Object$setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
};

exports.__esModule = true;

},{"babel-runtime/core-js/object/create":230,"babel-runtime/core-js/object/set-prototype-of":234}],242:[function(require,module,exports){
"use strict";

exports["default"] = function (obj) {
  return obj && obj.__esModule ? obj : {
    "default": obj
  };
};

exports.__esModule = true;

},{}],243:[function(require,module,exports){
"use strict";

exports["default"] = function (obj) {
  if (obj && obj.__esModule) {
    return obj;
  } else {
    var newObj = {};

    if (obj != null) {
      for (var key in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key];
      }
    }

    newObj["default"] = obj;
    return newObj;
  }
};

exports.__esModule = true;

},{}],244:[function(require,module,exports){
"use strict";

var _getIterator = require("babel-runtime/core-js/get-iterator")["default"];

var _isIterable = require("babel-runtime/core-js/is-iterable")["default"];

exports["default"] = function () {
  function sliceIterator(arr, i) {
    var _arr = [];
    var _n = true;
    var _d = false;
    var _e = undefined;

    try {
      for (var _i = _getIterator(arr), _s; !(_n = (_s = _i.next()).done); _n = true) {
        _arr.push(_s.value);

        if (i && _arr.length === i) break;
      }
    } catch (err) {
      _d = true;
      _e = err;
    } finally {
      try {
        if (!_n && _i["return"]) _i["return"]();
      } finally {
        if (_d) throw _e;
      }
    }

    return _arr;
  }

  return function (arr, i) {
    if (Array.isArray(arr)) {
      return arr;
    } else if (_isIterable(Object(arr))) {
      return sliceIterator(arr, i);
    } else {
      throw new TypeError("Invalid attempt to destructure non-iterable instance");
    }
  };
}();

exports.__esModule = true;

},{"babel-runtime/core-js/get-iterator":226,"babel-runtime/core-js/is-iterable":227}],245:[function(require,module,exports){
"use strict";

var _Array$from = require("babel-runtime/core-js/array/from")["default"];

exports["default"] = function (arr) {
  if (Array.isArray(arr)) {
    for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) {
      arr2[i] = arr[i];
    }return arr2;
  } else {
    return _Array$from(arr);
  }
};

exports.__esModule = true;

},{"babel-runtime/core-js/array/from":225}],246:[function(require,module,exports){
'use strict';

require('../../modules/es6.string.iterator');
require('../../modules/es6.array.from');
module.exports = require('../../modules/$.core').Array.from;

},{"../../modules/$.core":266,"../../modules/es6.array.from":314,"../../modules/es6.string.iterator":324}],247:[function(require,module,exports){
'use strict';

require('../modules/web.dom.iterable');
require('../modules/es6.string.iterator');
module.exports = require('../modules/core.get-iterator');

},{"../modules/core.get-iterator":312,"../modules/es6.string.iterator":324,"../modules/web.dom.iterable":327}],248:[function(require,module,exports){
'use strict';

require('../modules/web.dom.iterable');
require('../modules/es6.string.iterator');
module.exports = require('../modules/core.is-iterable');

},{"../modules/core.is-iterable":313,"../modules/es6.string.iterator":324,"../modules/web.dom.iterable":327}],249:[function(require,module,exports){
'use strict';

require('../modules/es6.object.to-string');
require('../modules/es6.string.iterator');
require('../modules/web.dom.iterable');
require('../modules/es6.map');
require('../modules/es7.map.to-json');
module.exports = require('../modules/$.core').Map;

},{"../modules/$.core":266,"../modules/es6.map":316,"../modules/es6.object.to-string":321,"../modules/es6.string.iterator":324,"../modules/es7.map.to-json":325,"../modules/web.dom.iterable":327}],250:[function(require,module,exports){
'use strict';

require('../../modules/es6.object.assign');
module.exports = require('../../modules/$.core').Object.assign;

},{"../../modules/$.core":266,"../../modules/es6.object.assign":317}],251:[function(require,module,exports){
'use strict';

var $ = require('../../modules/$');
module.exports = function create(P, D) {
  return $.create(P, D);
};

},{"../../modules/$":288}],252:[function(require,module,exports){
'use strict';

var $ = require('../../modules/$');
module.exports = function defineProperty(it, key, desc) {
  return $.setDesc(it, key, desc);
};

},{"../../modules/$":288}],253:[function(require,module,exports){
'use strict';

var $ = require('../../modules/$');
require('../../modules/es6.object.get-own-property-descriptor');
module.exports = function getOwnPropertyDescriptor(it, key) {
  return $.getDesc(it, key);
};

},{"../../modules/$":288,"../../modules/es6.object.get-own-property-descriptor":318}],254:[function(require,module,exports){
'use strict';

require('../../modules/es6.object.keys');
module.exports = require('../../modules/$.core').Object.keys;

},{"../../modules/$.core":266,"../../modules/es6.object.keys":319}],255:[function(require,module,exports){
'use strict';

require('../../modules/es6.object.set-prototype-of');
module.exports = require('../../modules/$.core').Object.setPrototypeOf;

},{"../../modules/$.core":266,"../../modules/es6.object.set-prototype-of":320}],256:[function(require,module,exports){
'use strict';

require('../modules/es6.object.to-string');
require('../modules/es6.string.iterator');
require('../modules/web.dom.iterable');
require('../modules/es6.promise');
module.exports = require('../modules/$.core').Promise;

},{"../modules/$.core":266,"../modules/es6.object.to-string":321,"../modules/es6.promise":322,"../modules/es6.string.iterator":324,"../modules/web.dom.iterable":327}],257:[function(require,module,exports){
'use strict';

require('../modules/es6.object.to-string');
require('../modules/es6.string.iterator');
require('../modules/web.dom.iterable');
require('../modules/es6.set');
require('../modules/es7.set.to-json');
module.exports = require('../modules/$.core').Set;

},{"../modules/$.core":266,"../modules/es6.object.to-string":321,"../modules/es6.set":323,"../modules/es6.string.iterator":324,"../modules/es7.set.to-json":326,"../modules/web.dom.iterable":327}],258:[function(require,module,exports){
arguments[4][4][0].apply(exports,arguments)
},{"dup":4}],259:[function(require,module,exports){
"use strict";

module.exports = function () {/* empty */};

},{}],260:[function(require,module,exports){
arguments[4][6][0].apply(exports,arguments)
},{"./$.is-object":281,"dup":6}],261:[function(require,module,exports){
arguments[4][12][0].apply(exports,arguments)
},{"./$.cof":262,"./$.wks":310,"dup":12}],262:[function(require,module,exports){
arguments[4][13][0].apply(exports,arguments)
},{"dup":13}],263:[function(require,module,exports){
arguments[4][14][0].apply(exports,arguments)
},{"./$":288,"./$.ctx":267,"./$.defined":268,"./$.descriptors":269,"./$.for-of":273,"./$.has":275,"./$.hide":276,"./$.is-object":281,"./$.iter-define":284,"./$.iter-step":286,"./$.redefine-all":294,"./$.set-species":298,"./$.strict-new":302,"./$.uid":309,"dup":14}],264:[function(require,module,exports){
arguments[4][15][0].apply(exports,arguments)
},{"./$.classof":261,"./$.for-of":273,"dup":15}],265:[function(require,module,exports){
'use strict';

var $ = require('./$'),
    global = require('./$.global'),
    $export = require('./$.export'),
    fails = require('./$.fails'),
    hide = require('./$.hide'),
    redefineAll = require('./$.redefine-all'),
    forOf = require('./$.for-of'),
    strictNew = require('./$.strict-new'),
    isObject = require('./$.is-object'),
    setToStringTag = require('./$.set-to-string-tag'),
    DESCRIPTORS = require('./$.descriptors');

module.exports = function (NAME, wrapper, methods, common, IS_MAP, IS_WEAK) {
  var Base = global[NAME],
      C = Base,
      ADDER = IS_MAP ? 'set' : 'add',
      proto = C && C.prototype,
      O = {};
  if (!DESCRIPTORS || typeof C != 'function' || !(IS_WEAK || proto.forEach && !fails(function () {
    new C().entries().next();
  }))) {
    // create collection constructor
    C = common.getConstructor(wrapper, NAME, IS_MAP, ADDER);
    redefineAll(C.prototype, methods);
  } else {
    C = wrapper(function (target, iterable) {
      strictNew(target, C, NAME);
      target._c = new Base();
      if (iterable != undefined) forOf(iterable, IS_MAP, target[ADDER], target);
    });
    $.each.call('add,clear,delete,forEach,get,has,set,keys,values,entries'.split(','), function (KEY) {
      var IS_ADDER = KEY == 'add' || KEY == 'set';
      if (KEY in proto && !(IS_WEAK && KEY == 'clear')) hide(C.prototype, KEY, function (a, b) {
        if (!IS_ADDER && IS_WEAK && !isObject(a)) return KEY == 'get' ? undefined : false;
        var result = this._c[KEY](a === 0 ? 0 : a, b);
        return IS_ADDER ? this : result;
      });
    });
    if ('size' in proto) $.setDesc(C.prototype, 'size', {
      get: function get() {
        return this._c.size;
      }
    });
  }

  setToStringTag(C, NAME);

  O[NAME] = C;
  $export($export.G + $export.W + $export.F, O);

  if (!IS_WEAK) common.setStrong(C, NAME, IS_MAP);

  return C;
};

},{"./$":288,"./$.descriptors":269,"./$.export":271,"./$.fails":272,"./$.for-of":273,"./$.global":274,"./$.hide":276,"./$.is-object":281,"./$.redefine-all":294,"./$.set-to-string-tag":299,"./$.strict-new":302}],266:[function(require,module,exports){
arguments[4][18][0].apply(exports,arguments)
},{"dup":18}],267:[function(require,module,exports){
arguments[4][19][0].apply(exports,arguments)
},{"./$.a-function":258,"dup":19}],268:[function(require,module,exports){
arguments[4][20][0].apply(exports,arguments)
},{"dup":20}],269:[function(require,module,exports){
arguments[4][21][0].apply(exports,arguments)
},{"./$.fails":272,"dup":21}],270:[function(require,module,exports){
arguments[4][22][0].apply(exports,arguments)
},{"./$.global":274,"./$.is-object":281,"dup":22}],271:[function(require,module,exports){
'use strict';

var global = require('./$.global'),
    core = require('./$.core'),
    ctx = require('./$.ctx'),
    PROTOTYPE = 'prototype';

var $export = function $export(type, name, source) {
  var IS_FORCED = type & $export.F,
      IS_GLOBAL = type & $export.G,
      IS_STATIC = type & $export.S,
      IS_PROTO = type & $export.P,
      IS_BIND = type & $export.B,
      IS_WRAP = type & $export.W,
      exports = IS_GLOBAL ? core : core[name] || (core[name] = {}),
      target = IS_GLOBAL ? global : IS_STATIC ? global[name] : (global[name] || {})[PROTOTYPE],
      key,
      own,
      out;
  if (IS_GLOBAL) source = name;
  for (key in source) {
    // contains in native
    own = !IS_FORCED && target && key in target;
    if (own && key in exports) continue;
    // export native or passed
    out = own ? target[key] : source[key];
    // prevent global pollution for namespaces
    exports[key] = IS_GLOBAL && typeof target[key] != 'function' ? source[key]
    // bind timers to global for call from export context
    : IS_BIND && own ? ctx(out, global)
    // wrap global constructors for prevent change them in library
    : IS_WRAP && target[key] == out ? function (C) {
      var F = function F(param) {
        return this instanceof C ? new C(param) : C(param);
      };
      F[PROTOTYPE] = C[PROTOTYPE];
      return F;
      // make static versions for prototype methods
    }(out) : IS_PROTO && typeof out == 'function' ? ctx(Function.call, out) : out;
    if (IS_PROTO) (exports[PROTOTYPE] || (exports[PROTOTYPE] = {}))[key] = out;
  }
};
// type bitmap
$export.F = 1; // forced
$export.G = 2; // global
$export.S = 4; // static
$export.P = 8; // proto
$export.B = 16; // bind
$export.W = 32; // wrap
module.exports = $export;

},{"./$.core":266,"./$.ctx":267,"./$.global":274}],272:[function(require,module,exports){
arguments[4][26][0].apply(exports,arguments)
},{"dup":26}],273:[function(require,module,exports){
arguments[4][29][0].apply(exports,arguments)
},{"./$.an-object":260,"./$.ctx":267,"./$.is-array-iter":280,"./$.iter-call":282,"./$.to-length":307,"./core.get-iterator-method":311,"dup":29}],274:[function(require,module,exports){
arguments[4][31][0].apply(exports,arguments)
},{"dup":31}],275:[function(require,module,exports){
arguments[4][32][0].apply(exports,arguments)
},{"dup":32}],276:[function(require,module,exports){
arguments[4][33][0].apply(exports,arguments)
},{"./$":288,"./$.descriptors":269,"./$.property-desc":293,"dup":33}],277:[function(require,module,exports){
arguments[4][34][0].apply(exports,arguments)
},{"./$.global":274,"dup":34}],278:[function(require,module,exports){
arguments[4][35][0].apply(exports,arguments)
},{"dup":35}],279:[function(require,module,exports){
arguments[4][36][0].apply(exports,arguments)
},{"./$.cof":262,"dup":36}],280:[function(require,module,exports){
arguments[4][37][0].apply(exports,arguments)
},{"./$.iterators":287,"./$.wks":310,"dup":37}],281:[function(require,module,exports){
arguments[4][40][0].apply(exports,arguments)
},{"dup":40}],282:[function(require,module,exports){
arguments[4][42][0].apply(exports,arguments)
},{"./$.an-object":260,"dup":42}],283:[function(require,module,exports){
arguments[4][43][0].apply(exports,arguments)
},{"./$":288,"./$.hide":276,"./$.property-desc":293,"./$.set-to-string-tag":299,"./$.wks":310,"dup":43}],284:[function(require,module,exports){
arguments[4][44][0].apply(exports,arguments)
},{"./$":288,"./$.export":271,"./$.has":275,"./$.hide":276,"./$.iter-create":283,"./$.iterators":287,"./$.library":289,"./$.redefine":295,"./$.set-to-string-tag":299,"./$.wks":310,"dup":44}],285:[function(require,module,exports){
arguments[4][45][0].apply(exports,arguments)
},{"./$.wks":310,"dup":45}],286:[function(require,module,exports){
arguments[4][46][0].apply(exports,arguments)
},{"dup":46}],287:[function(require,module,exports){
arguments[4][47][0].apply(exports,arguments)
},{"dup":47}],288:[function(require,module,exports){
arguments[4][48][0].apply(exports,arguments)
},{"dup":48}],289:[function(require,module,exports){
"use strict";

module.exports = true;

},{}],290:[function(require,module,exports){
arguments[4][54][0].apply(exports,arguments)
},{"./$.cof":262,"./$.global":274,"./$.task":304,"dup":54}],291:[function(require,module,exports){
arguments[4][55][0].apply(exports,arguments)
},{"./$":288,"./$.fails":272,"./$.iobject":279,"./$.to-object":308,"dup":55}],292:[function(require,module,exports){
arguments[4][56][0].apply(exports,arguments)
},{"./$.core":266,"./$.export":271,"./$.fails":272,"dup":56}],293:[function(require,module,exports){
arguments[4][61][0].apply(exports,arguments)
},{"dup":61}],294:[function(require,module,exports){
arguments[4][62][0].apply(exports,arguments)
},{"./$.redefine":295,"dup":62}],295:[function(require,module,exports){
'use strict';

module.exports = require('./$.hide');

},{"./$.hide":276}],296:[function(require,module,exports){
arguments[4][65][0].apply(exports,arguments)
},{"dup":65}],297:[function(require,module,exports){
arguments[4][66][0].apply(exports,arguments)
},{"./$":288,"./$.an-object":260,"./$.ctx":267,"./$.is-object":281,"dup":66}],298:[function(require,module,exports){
'use strict';

var core = require('./$.core'),
    $ = require('./$'),
    DESCRIPTORS = require('./$.descriptors'),
    SPECIES = require('./$.wks')('species');

module.exports = function (KEY) {
  var C = core[KEY];
  if (DESCRIPTORS && C && !C[SPECIES]) $.setDesc(C, SPECIES, {
    configurable: true,
    get: function get() {
      return this;
    }
  });
};

},{"./$":288,"./$.core":266,"./$.descriptors":269,"./$.wks":310}],299:[function(require,module,exports){
arguments[4][68][0].apply(exports,arguments)
},{"./$":288,"./$.has":275,"./$.wks":310,"dup":68}],300:[function(require,module,exports){
arguments[4][69][0].apply(exports,arguments)
},{"./$.global":274,"dup":69}],301:[function(require,module,exports){
arguments[4][70][0].apply(exports,arguments)
},{"./$.a-function":258,"./$.an-object":260,"./$.wks":310,"dup":70}],302:[function(require,module,exports){
arguments[4][71][0].apply(exports,arguments)
},{"dup":71}],303:[function(require,module,exports){
arguments[4][72][0].apply(exports,arguments)
},{"./$.defined":268,"./$.to-integer":305,"dup":72}],304:[function(require,module,exports){
arguments[4][77][0].apply(exports,arguments)
},{"./$.cof":262,"./$.ctx":267,"./$.dom-create":270,"./$.global":274,"./$.html":277,"./$.invoke":278,"dup":77}],305:[function(require,module,exports){
arguments[4][79][0].apply(exports,arguments)
},{"dup":79}],306:[function(require,module,exports){
arguments[4][80][0].apply(exports,arguments)
},{"./$.defined":268,"./$.iobject":279,"dup":80}],307:[function(require,module,exports){
arguments[4][81][0].apply(exports,arguments)
},{"./$.to-integer":305,"dup":81}],308:[function(require,module,exports){
arguments[4][82][0].apply(exports,arguments)
},{"./$.defined":268,"dup":82}],309:[function(require,module,exports){
arguments[4][84][0].apply(exports,arguments)
},{"dup":84}],310:[function(require,module,exports){
arguments[4][85][0].apply(exports,arguments)
},{"./$.global":274,"./$.shared":300,"./$.uid":309,"dup":85}],311:[function(require,module,exports){
arguments[4][86][0].apply(exports,arguments)
},{"./$.classof":261,"./$.core":266,"./$.iterators":287,"./$.wks":310,"dup":86}],312:[function(require,module,exports){
'use strict';

var anObject = require('./$.an-object'),
    get = require('./core.get-iterator-method');
module.exports = require('./$.core').getIterator = function (it) {
  var iterFn = get(it);
  if (typeof iterFn != 'function') throw TypeError(it + ' is not iterable!');
  return anObject(iterFn.call(it));
};

},{"./$.an-object":260,"./$.core":266,"./core.get-iterator-method":311}],313:[function(require,module,exports){
'use strict';

var classof = require('./$.classof'),
    ITERATOR = require('./$.wks')('iterator'),
    Iterators = require('./$.iterators');
module.exports = require('./$.core').isIterable = function (it) {
  var O = Object(it);
  return O[ITERATOR] !== undefined || '@@iterator' in O || Iterators.hasOwnProperty(classof(O));
};

},{"./$.classof":261,"./$.core":266,"./$.iterators":287,"./$.wks":310}],314:[function(require,module,exports){
arguments[4][92][0].apply(exports,arguments)
},{"./$.ctx":267,"./$.export":271,"./$.is-array-iter":280,"./$.iter-call":282,"./$.iter-detect":285,"./$.to-length":307,"./$.to-object":308,"./core.get-iterator-method":311,"dup":92}],315:[function(require,module,exports){
arguments[4][93][0].apply(exports,arguments)
},{"./$.add-to-unscopables":259,"./$.iter-define":284,"./$.iter-step":286,"./$.iterators":287,"./$.to-iobject":306,"dup":93}],316:[function(require,module,exports){
arguments[4][98][0].apply(exports,arguments)
},{"./$.collection":265,"./$.collection-strong":263,"dup":98}],317:[function(require,module,exports){
arguments[4][126][0].apply(exports,arguments)
},{"./$.export":271,"./$.object-assign":291,"dup":126}],318:[function(require,module,exports){
arguments[4][128][0].apply(exports,arguments)
},{"./$.object-sap":292,"./$.to-iobject":306,"dup":128}],319:[function(require,module,exports){
arguments[4][135][0].apply(exports,arguments)
},{"./$.object-sap":292,"./$.to-object":308,"dup":135}],320:[function(require,module,exports){
arguments[4][138][0].apply(exports,arguments)
},{"./$.export":271,"./$.set-proto":297,"dup":138}],321:[function(require,module,exports){
"use strict";

},{}],322:[function(require,module,exports){
arguments[4][140][0].apply(exports,arguments)
},{"./$":288,"./$.a-function":258,"./$.an-object":260,"./$.classof":261,"./$.core":266,"./$.ctx":267,"./$.descriptors":269,"./$.export":271,"./$.for-of":273,"./$.global":274,"./$.is-object":281,"./$.iter-detect":285,"./$.library":289,"./$.microtask":290,"./$.redefine-all":294,"./$.same-value":296,"./$.set-proto":297,"./$.set-species":298,"./$.set-to-string-tag":299,"./$.species-constructor":301,"./$.strict-new":302,"./$.wks":310,"dup":140}],323:[function(require,module,exports){
arguments[4][161][0].apply(exports,arguments)
},{"./$.collection":265,"./$.collection-strong":263,"dup":161}],324:[function(require,module,exports){
arguments[4][166][0].apply(exports,arguments)
},{"./$.iter-define":284,"./$.string-at":303,"dup":166}],325:[function(require,module,exports){
arguments[4][175][0].apply(exports,arguments)
},{"./$.collection-to-json":264,"./$.export":271,"dup":175}],326:[function(require,module,exports){
arguments[4][180][0].apply(exports,arguments)
},{"./$.collection-to-json":264,"./$.export":271,"dup":180}],327:[function(require,module,exports){
'use strict';

require('./es6.array.iterator');
var Iterators = require('./$.iterators');
Iterators.NodeList = Iterators.HTMLCollection = Iterators.Array;

},{"./$.iterators":287,"./es6.array.iterator":315}],328:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

// Predicates

/**
 * These are all of the possible kinds of types.
 */
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var _createClass = require('babel-runtime/helpers/create-class')['default'];

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

var _extends = require('babel-runtime/helpers/extends')['default'];

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _Map = require('babel-runtime/core-js/map')['default'];

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.isType = isType;

/**
 * These types may be used as input types for arguments and directives.
 */
exports.isInputType = isInputType;

/**
 * These types may be used as output types as the result of fields.
 */
exports.isOutputType = isOutputType;

/**
 * These types may describe types which may be leaf values.
 */
exports.isLeafType = isLeafType;

/**
 * These types may describe the parent context of a selection set.
 */
exports.isCompositeType = isCompositeType;

/**
 * These types may describe the parent context of a selection set.
 */
exports.isAbstractType = isAbstractType;

/**
 * These types can all accept null as a value.
 */
exports.getNullableType = getNullableType;

/**
 * These named types do not include modifiers like List or NonNull.
 */
exports.getNamedType = getNamedType;

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

var _jsutilsKeyMap = require('../jsutils/keyMap');

var _jsutilsKeyMap2 = _interopRequireDefault(_jsutilsKeyMap);

var _languageKinds = require('../language/kinds');

function isType(type) {
  return type instanceof GraphQLScalarType || type instanceof GraphQLObjectType || type instanceof GraphQLInterfaceType || type instanceof GraphQLUnionType || type instanceof GraphQLEnumType || type instanceof GraphQLInputObjectType || type instanceof GraphQLList || type instanceof GraphQLNonNull;
}

function isInputType(type) {
  var namedType = getNamedType(type);
  return namedType instanceof GraphQLScalarType || namedType instanceof GraphQLEnumType || namedType instanceof GraphQLInputObjectType;
}

function isOutputType(type) {
  var namedType = getNamedType(type);
  return namedType instanceof GraphQLScalarType || namedType instanceof GraphQLObjectType || namedType instanceof GraphQLInterfaceType || namedType instanceof GraphQLUnionType || namedType instanceof GraphQLEnumType;
}

function isLeafType(type) {
  var namedType = getNamedType(type);
  return namedType instanceof GraphQLScalarType || namedType instanceof GraphQLEnumType;
}

function isCompositeType(type) {
  return type instanceof GraphQLObjectType || type instanceof GraphQLInterfaceType || type instanceof GraphQLUnionType;
}

function isAbstractType(type) {
  return type instanceof GraphQLInterfaceType || type instanceof GraphQLUnionType;
}

function getNullableType(type) {
  return type instanceof GraphQLNonNull ? type.ofType : type;
}

function getNamedType(type) {
  var unmodifiedType = type;
  while (unmodifiedType instanceof GraphQLList || unmodifiedType instanceof GraphQLNonNull) {
    unmodifiedType = unmodifiedType.ofType;
  }
  return unmodifiedType;
}

/**
 * Scalar Type Definition
 *
 * The leaf values of any request and input values to arguments are
 * Scalars (or Enums) and are defined with a name and a series of functions
 * used to parse input from ast or variables and to ensure validity.
 *
 * Example:
 *
 *     var OddType = new GraphQLScalarType({
 *       name: 'Odd',
 *       serialize(value) {
 *         return value % 2 === 1 ? value : null;
 *       }
 *     });
 *
 */

var GraphQLScalarType /* <T> */ = function () {
  /* <T> */
  function GraphQLScalarType(config /* <T> */) {
    _classCallCheck(this, GraphQLScalarType);

    (0, _jsutilsInvariant2['default'])(config.name, 'Type must be named.');
    assertValidName(config.name);
    this.name = config.name;
    this.description = config.description;
    (0, _jsutilsInvariant2['default'])(typeof config.serialize === 'function', this + ' must provide "serialize" function. If this custom Scalar is ' + 'also used as an input type, ensure "parseValue" and "parseLiteral" ' + 'functions are also provided.');
    if (config.parseValue || config.parseLiteral) {
      (0, _jsutilsInvariant2['default'])(typeof config.parseValue === 'function' && typeof config.parseLiteral === 'function', this + ' must provide both "parseValue" and "parseLiteral" functions.');
    }
    this._scalarConfig = config;
  }

  _createClass(GraphQLScalarType, [{
    key: 'serialize',
    value: function serialize(value) /* T */{
      var serializer = this._scalarConfig.serialize;
      return serializer(value);
    }
  }, {
    key: 'parseValue',
    value: function parseValue(value) /* T */{
      var parser = this._scalarConfig.parseValue;
      return parser ? parser(value) : null;
    }
  }, {
    key: 'parseLiteral',
    value: function parseLiteral(valueAST) /* T */{
      var parser = this._scalarConfig.parseLiteral;
      return parser ? parser(valueAST) : null;
    }
  }, {
    key: 'toString',
    value: function toString() {
      return this.name;
    }
  }]);

  return GraphQLScalarType;
}();

exports.GraphQLScalarType = GraphQLScalarType;
/* T */

/**
 * Object Type Definition
 *
 * Almost all of the GraphQL types you define will be object types. Object types
 * have a name, but most importantly describe their fields.
 *
 * Example:
 *
 *     var AddressType = new GraphQLObjectType({
 *       name: 'Address',
 *       fields: {
 *         street: { type: GraphQLString },
 *         number: { type: GraphQLInt },
 *         formatted: {
 *           type: GraphQLString,
 *           resolve(obj) {
 *             return obj.number + ' ' + obj.street
 *           }
 *         }
 *       }
 *     });
 *
 * When two types need to refer to each other, or a type needs to refer to
 * itself in a field, you can use a function expression (aka a closure or a
 * thunk) to supply the fields lazily.
 *
 * Example:
 *
 *     var PersonType = new GraphQLObjectType({
 *       name: 'Person',
 *       fields: () => ({
 *         name: { type: GraphQLString },
 *         bestFriend: { type: PersonType },
 *       })
 *     });
 *
 */

var GraphQLObjectType = function () {
  function GraphQLObjectType(config) {
    _classCallCheck(this, GraphQLObjectType);

    (0, _jsutilsInvariant2['default'])(config.name, 'Type must be named.');
    assertValidName(config.name);
    this.name = config.name;
    this.description = config.description;
    if (config.isTypeOf) {
      (0, _jsutilsInvariant2['default'])(typeof config.isTypeOf === 'function', this + ' must provide "isTypeOf" as a function.');
    }
    this.isTypeOf = config.isTypeOf;
    this._typeConfig = config;
    addImplementationToInterfaces(this);
  }

  _createClass(GraphQLObjectType, [{
    key: 'getFields',
    value: function getFields() {
      return this._fields || (this._fields = defineFieldMap(this, this._typeConfig.fields));
    }
  }, {
    key: 'getInterfaces',
    value: function getInterfaces() {
      return this._interfaces || (this._interfaces = defineInterfaces(this, this._typeConfig.interfaces));
    }
  }, {
    key: 'toString',
    value: function toString() {
      return this.name;
    }
  }]);

  return GraphQLObjectType;
}();

exports.GraphQLObjectType = GraphQLObjectType;

function resolveMaybeThunk(thingOrThunk) {
  return typeof thingOrThunk === 'function' ? thingOrThunk() : thingOrThunk;
}

function defineInterfaces(type, interfacesOrThunk) {
  var interfaces = resolveMaybeThunk(interfacesOrThunk);
  if (!interfaces) {
    return [];
  }
  (0, _jsutilsInvariant2['default'])(Array.isArray(interfaces), type + ' interfaces must be an Array or a function which returns an Array.');
  interfaces.forEach(function (iface) {
    (0, _jsutilsInvariant2['default'])(iface instanceof GraphQLInterfaceType, type + ' may only implement Interface types, it cannot ' + ('implement: ' + iface + '.'));
    if (typeof iface.resolveType !== 'function') {
      (0, _jsutilsInvariant2['default'])(typeof type.isTypeOf === 'function', 'Interface Type ' + iface + ' does not provide a "resolveType" function ' + ('and implementing Type ' + type + ' does not provide a "isTypeOf" ') + 'function. There is no way to resolve this implementing type ' + 'during execution.');
    }
  });
  return interfaces;
}

function defineFieldMap(type, fields) {
  var fieldMap = resolveMaybeThunk(fields);
  (0, _jsutilsInvariant2['default'])(isPlainObj(fieldMap), type + ' fields must be an object with field names as keys or a ' + 'function which returns such an object.');

  var fieldNames = _Object$keys(fieldMap);
  (0, _jsutilsInvariant2['default'])(fieldNames.length > 0, type + ' fields must be an object with field names as keys or a ' + 'function which returns such an object.');

  var resultFieldMap = {};
  fieldNames.forEach(function (fieldName) {
    assertValidName(fieldName);
    var field = _extends({}, fieldMap[fieldName], {
      name: fieldName
    });
    (0, _jsutilsInvariant2['default'])(!field.hasOwnProperty('isDeprecated'), type + '.' + fieldName + ' should provide "deprecationReason" instead ' + 'of "isDeprecated".');
    (0, _jsutilsInvariant2['default'])(isOutputType(field.type), type + '.' + fieldName + ' field type must be Output Type but ' + ('got: ' + field.type + '.'));
    if (!field.args) {
      field.args = [];
    } else {
      (0, _jsutilsInvariant2['default'])(isPlainObj(field.args), type + '.' + fieldName + ' args must be an object with argument names ' + 'as keys.');
      field.args = _Object$keys(field.args).map(function (argName) {
        assertValidName(argName);
        var arg = field.args[argName];
        (0, _jsutilsInvariant2['default'])(isInputType(arg.type), type + '.' + fieldName + '(' + argName + ':) argument type must be ' + ('Input Type but got: ' + arg.type + '.'));
        return {
          name: argName,
          description: arg.description === undefined ? null : arg.description,
          type: arg.type,
          defaultValue: arg.defaultValue === undefined ? null : arg.defaultValue
        };
      });
    }
    resultFieldMap[fieldName] = field;
  });
  return resultFieldMap;
}

function isPlainObj(obj) {
  return obj && (typeof obj === 'undefined' ? 'undefined' : _typeof(obj)) === 'object' && !Array.isArray(obj);
}

/**
 * Update the interfaces to know about this implementation.
 * This is an rare and unfortunate use of mutation in the type definition
 * implementations, but avoids an expensive "getPossibleTypes"
 * implementation for Interface types.
 */
function addImplementationToInterfaces(impl) {
  impl.getInterfaces().forEach(function (type) {
    type._implementations.push(impl);
  });
}

/**
 * Interface Type Definition
 *
 * When a field can return one of a heterogeneous set of types, a Interface type
 * is used to describe what types are possible, what fields are in common across
 * all types, as well as a function to determine which type is actually used
 * when the field is resolved.
 *
 * Example:
 *
 *     var EntityType = new GraphQLInterfaceType({
 *       name: 'Entity',
 *       fields: {
 *         name: { type: GraphQLString }
 *       }
 *     });
 *
 */

var GraphQLInterfaceType = function () {
  function GraphQLInterfaceType(config) {
    _classCallCheck(this, GraphQLInterfaceType);

    (0, _jsutilsInvariant2['default'])(config.name, 'Type must be named.');
    assertValidName(config.name);
    this.name = config.name;
    this.description = config.description;
    if (config.resolveType) {
      (0, _jsutilsInvariant2['default'])(typeof config.resolveType === 'function', this + ' must provide "resolveType" as a function.');
    }
    this.resolveType = config.resolveType;
    this._typeConfig = config;
    this._implementations = [];
  }

  _createClass(GraphQLInterfaceType, [{
    key: 'getFields',
    value: function getFields() {
      return this._fields || (this._fields = defineFieldMap(this, this._typeConfig.fields));
    }
  }, {
    key: 'getPossibleTypes',
    value: function getPossibleTypes() {
      return this._implementations;
    }
  }, {
    key: 'isPossibleType',
    value: function isPossibleType(type) {
      var possibleTypes = this._possibleTypes || (this._possibleTypes = (0, _jsutilsKeyMap2['default'])(this.getPossibleTypes(), function (possibleType) {
        return possibleType.name;
      }));
      return Boolean(possibleTypes[type.name]);
    }
  }, {
    key: 'getObjectType',
    value: function getObjectType(value, info) {
      var resolver = this.resolveType;
      return resolver ? resolver(value, info) : getTypeOf(value, info, this);
    }
  }, {
    key: 'toString',
    value: function toString() {
      return this.name;
    }
  }]);

  return GraphQLInterfaceType;
}();

exports.GraphQLInterfaceType = GraphQLInterfaceType;

function getTypeOf(value, info, abstractType) {
  var possibleTypes = abstractType.getPossibleTypes();
  for (var i = 0; i < possibleTypes.length; i++) {
    var type = possibleTypes[i];
    if (typeof type.isTypeOf === 'function' && type.isTypeOf(value, info)) {
      return type;
    }
  }
}

/**
 * Union Type Definition
 *
 * When a field can return one of a heterogeneous set of types, a Union type
 * is used to describe what types are possible as well as providing a function
 * to determine which type is actually used when the field is resolved.
 *
 * Example:
 *
 *     var PetType = new GraphQLUnionType({
 *       name: 'Pet',
 *       types: [ DogType, CatType ],
 *       resolveType(value) {
 *         if (value instanceof Dog) {
 *           return DogType;
 *         }
 *         if (value instanceof Cat) {
 *           return CatType;
 *         }
 *       }
 *     });
 *
 */

var GraphQLUnionType = function () {
  function GraphQLUnionType(config) {
    var _this = this;

    _classCallCheck(this, GraphQLUnionType);

    (0, _jsutilsInvariant2['default'])(config.name, 'Type must be named.');
    assertValidName(config.name);
    this.name = config.name;
    this.description = config.description;
    if (config.resolveType) {
      (0, _jsutilsInvariant2['default'])(typeof config.resolveType === 'function', this + ' must provide "resolveType" as a function.');
    }
    this.resolveType = config.resolveType;
    (0, _jsutilsInvariant2['default'])(Array.isArray(config.types) && config.types.length > 0, 'Must provide Array of types for Union ' + config.name + '.');
    config.types.forEach(function (type) {
      (0, _jsutilsInvariant2['default'])(type instanceof GraphQLObjectType, _this + ' may only contain Object types, it cannot contain: ' + type + '.');
      if (typeof _this.resolveType !== 'function') {
        (0, _jsutilsInvariant2['default'])(typeof type.isTypeOf === 'function', 'Union Type ' + _this + ' does not provide a "resolveType" function ' + ('and possible Type ' + type + ' does not provide a "isTypeOf" ') + 'function. There is no way to resolve this possible type ' + 'during execution.');
      }
    });
    this._types = config.types;
    this._typeConfig = config;
  }

  _createClass(GraphQLUnionType, [{
    key: 'getPossibleTypes',
    value: function getPossibleTypes() {
      return this._types;
    }
  }, {
    key: 'isPossibleType',
    value: function isPossibleType(type) {
      var possibleTypeNames = this._possibleTypeNames;
      if (!possibleTypeNames) {
        this._possibleTypeNames = possibleTypeNames = this.getPossibleTypes().reduce(function (map, possibleType) {
          return map[possibleType.name] = true, map;
        }, {});
      }
      return possibleTypeNames[type.name] === true;
    }
  }, {
    key: 'getObjectType',
    value: function getObjectType(value, info) {
      var resolver = this._typeConfig.resolveType;
      return resolver ? resolver(value, info) : getTypeOf(value, info, this);
    }
  }, {
    key: 'toString',
    value: function toString() {
      return this.name;
    }
  }]);

  return GraphQLUnionType;
}();

exports.GraphQLUnionType = GraphQLUnionType;

/**
 * Enum Type Definition
 *
 * Some leaf values of requests and input values are Enums. GraphQL serializes
 * Enum values as strings, however internally Enums can be represented by any
 * kind of type, often integers.
 *
 * Example:
 *
 *     var RGBType = new GraphQLEnumType({
 *       name: 'RGB',
 *       values: {
 *         RED: { value: 0 },
 *         GREEN: { value: 1 },
 *         BLUE: { value: 2 }
 *       }
 *     });
 *
 * Note: If a value is not provided in a definition, the name of the enum value
 * will be used as its internal value.
 */

var GraphQLEnumType /* <T> */ = function () {
  function GraphQLEnumType(config /* <T> */) {
    _classCallCheck(this, GraphQLEnumType);

    this.name = config.name;
    assertValidName(config.name);
    this.description = config.description;
    this._values = defineEnumValues(this, config.values);
    this._enumConfig = config;
  }

  _createClass(GraphQLEnumType, [{
    key: 'getValues',
    value: function getValues() /* <T> */{
      return this._values;
    }
  }, {
    key: 'serialize',
    value: function serialize(value /* T */) {
      var enumValue = this._getValueLookup().get(value);
      return enumValue ? enumValue.name : null;
    }
  }, {
    key: 'parseValue',
    value: function parseValue(value) /* T */{
      var enumValue = this._getNameLookup()[value];
      if (enumValue) {
        return enumValue.value;
      }
    }
  }, {
    key: 'parseLiteral',
    value: function parseLiteral(valueAST) /* T */{
      if (valueAST.kind === _languageKinds.ENUM) {
        var enumValue = this._getNameLookup()[valueAST.value];
        if (enumValue) {
          return enumValue.value;
        }
      }
    }
  }, {
    key: '_getValueLookup',
    value: function _getValueLookup() {
      if (!this._valueLookup) {
        var lookup = new _Map();
        this.getValues().forEach(function (value) {
          lookup.set(value.value, value);
        });
        this._valueLookup = lookup;
      }
      return this._valueLookup;
    }
  }, {
    key: '_getNameLookup',
    value: function _getNameLookup() {
      if (!this._nameLookup) {
        var lookup = _Object$create(null);
        this.getValues().forEach(function (value) {
          lookup[value.name] = value;
        });
        this._nameLookup = lookup;
      }
      return this._nameLookup;
    }
  }, {
    key: 'toString',
    value: function toString() {
      return this.name;
    }
  }]);

  return GraphQLEnumType;
}();

exports.GraphQLEnumType = GraphQLEnumType;

function defineEnumValues(type, valueMap /* <T> */
) /* <T> */{
  (0, _jsutilsInvariant2['default'])(isPlainObj(valueMap), type + ' values must be an object with value names as keys.');
  var valueNames = _Object$keys(valueMap);
  (0, _jsutilsInvariant2['default'])(valueNames.length > 0, type + ' values must be an object with value names as keys.');
  return valueNames.map(function (valueName) {
    assertValidName(valueName);
    var value = valueMap[valueName];
    (0, _jsutilsInvariant2['default'])(isPlainObj(value), type + '.' + valueName + ' must refer to an object with a "value" key ' + ('representing an internal value but got: ' + value + '.'));
    (0, _jsutilsInvariant2['default'])(!value.hasOwnProperty('isDeprecated'), type + '.' + valueName + ' should provide "deprecationReason" instead ' + 'of "isDeprecated".');
    return {
      name: valueName,
      description: value.description,
      deprecationReason: value.deprecationReason,
      value: (0, _jsutilsIsNullish2['default'])(value.value) ? valueName : value.value
    };
  });
}

/* <T> */ /* T */

/**
 * Input Object Type Definition
 *
 * An input object defines a structured collection of fields which may be
 * supplied to a field argument.
 *
 * Using `NonNull` will ensure that a value must be provided by the query
 *
 * Example:
 *
 *     var GeoPoint = new GraphQLInputObjectType({
 *       name: 'GeoPoint',
 *       fields: {
 *         lat: { type: new GraphQLNonNull(GraphQLFloat) },
 *         lon: { type: new GraphQLNonNull(GraphQLFloat) },
 *         alt: { type: GraphQLFloat, defaultValue: 0 },
 *       }
 *     });
 *
 */

var GraphQLInputObjectType = function () {
  function GraphQLInputObjectType(config) {
    _classCallCheck(this, GraphQLInputObjectType);

    (0, _jsutilsInvariant2['default'])(config.name, 'Type must be named.');
    assertValidName(config.name);
    this.name = config.name;
    this.description = config.description;
    this._typeConfig = config;
  }

  _createClass(GraphQLInputObjectType, [{
    key: 'getFields',
    value: function getFields() {
      return this._fields || (this._fields = this._defineFieldMap());
    }
  }, {
    key: '_defineFieldMap',
    value: function _defineFieldMap() {
      var _this2 = this;

      var fieldMap = resolveMaybeThunk(this._typeConfig.fields);
      (0, _jsutilsInvariant2['default'])(isPlainObj(fieldMap), this + ' fields must be an object with field names as keys or a ' + 'function which returns such an object.');
      var fieldNames = _Object$keys(fieldMap);
      (0, _jsutilsInvariant2['default'])(fieldNames.length > 0, this + ' fields must be an object with field names as keys or a ' + 'function which returns such an object.');
      var resultFieldMap = {};
      fieldNames.forEach(function (fieldName) {
        assertValidName(fieldName);
        var field = _extends({}, fieldMap[fieldName], {
          name: fieldName
        });
        (0, _jsutilsInvariant2['default'])(isInputType(field.type), _this2 + '.' + fieldName + ' field type must be Input Type but ' + ('got: ' + field.type + '.'));
        resultFieldMap[fieldName] = field;
      });
      return resultFieldMap;
    }
  }, {
    key: 'toString',
    value: function toString() {
      return this.name;
    }
  }]);

  return GraphQLInputObjectType;
}();

exports.GraphQLInputObjectType = GraphQLInputObjectType;

/**
 * List Modifier
 *
 * A list is a kind of type marker, a wrapping type which points to another
 * type. Lists are often created within the context of defining the fields of
 * an object type.
 *
 * Example:
 *
 *     var PersonType = new GraphQLObjectType({
 *       name: 'Person',
 *       fields: () => ({
 *         parents: { type: new GraphQLList(Person) },
 *         children: { type: new GraphQLList(Person) },
 *       })
 *     })
 *
 */

var GraphQLList = function () {
  function GraphQLList(type) {
    _classCallCheck(this, GraphQLList);

    (0, _jsutilsInvariant2['default'])(isType(type), 'Can only create List of a GraphQLType but got: ' + type + '.');
    this.ofType = type;
  }

  /**
   * Non-Null Modifier
   *
   * A non-null is a kind of type marker, a wrapping type which points to another
   * type. Non-null types enforce that their values are never null and can ensure
   * an error is raised if this ever occurs during a request. It is useful for
   * fields which you can make a strong guarantee on non-nullability, for example
   * usually the id field of a database row will never be null.
   *
   * Example:
   *
   *     var RowType = new GraphQLObjectType({
   *       name: 'Row',
   *       fields: () => ({
   *         id: { type: new GraphQLNonNull(GraphQLString) },
   *       })
   *     })
   *
   * Note: the enforcement of non-nullability occurs within the executor.
   */

  _createClass(GraphQLList, [{
    key: 'toString',
    value: function toString() {
      return '[' + String(this.ofType) + ']';
    }
  }]);

  return GraphQLList;
}();

exports.GraphQLList = GraphQLList;

var GraphQLNonNull = function () {
  function GraphQLNonNull(type) {
    _classCallCheck(this, GraphQLNonNull);

    (0, _jsutilsInvariant2['default'])(isType(type) && !(type instanceof GraphQLNonNull), 'Can only create NonNull of a Nullable GraphQLType but got: ' + type + '.');
    this.ofType = type;
  }

  _createClass(GraphQLNonNull, [{
    key: 'toString',
    value: function toString() {
      return this.ofType.toString() + '!';
    }
  }]);

  return GraphQLNonNull;
}();

exports.GraphQLNonNull = GraphQLNonNull;

var NAME_RX = /^[_a-zA-Z][_a-zA-Z0-9]*$/;

// Helper to assert that provided names are valid.
function assertValidName(name) {
  (0, _jsutilsInvariant2['default'])(NAME_RX.test(name), 'Names must match /^[_a-zA-Z][_a-zA-Z0-9]*$/ but "' + name + '" does not.');
}
/* <T> */ /* T */ /* T */
/**
 * Optionally provide a custom type resolver function. If one is not provided,
 * the default implementation will call `isTypeOf` on each implementing
 * Object type.
 */

/**
 * Optionally provide a custom type resolver function. If one is not provided,
 * the default implementation will call `isTypeOf` on each implementing
 * Object type.
 */
/* <T> */ /* <T> */ /* T */ /* T */ /* <T> */ /* <T> */ /* <T> */ /* <T> */ /* T */ /* <T> */

},{"../jsutils/invariant":214,"../jsutils/isNullish":215,"../jsutils/keyMap":216,"../language/kinds":218,"babel-runtime/core-js/map":228,"babel-runtime/core-js/object/create":230,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/class-call-check":237,"babel-runtime/helpers/create-class":238,"babel-runtime/helpers/extends":239,"babel-runtime/helpers/interop-require-default":242}],329:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _definition = require('./definition');

var _scalars = require('./scalars');

/**
 * Directives are used by the GraphQL runtime as a way of modifying execution
 * behavior. Type system creators will usually not create these directly.
 */

var GraphQLDirective = function GraphQLDirective(config) {
  _classCallCheck(this, GraphQLDirective);

  this.name = config.name;
  this.description = config.description;
  this.args = config.args || [];
  this.onOperation = Boolean(config.onOperation);
  this.onFragment = Boolean(config.onFragment);
  this.onField = Boolean(config.onField);
};

exports.GraphQLDirective = GraphQLDirective;

/**
 * Used to conditionally include fields or fragments
 */
var GraphQLIncludeDirective = new GraphQLDirective({
  name: 'include',
  description: 'Directs the executor to include this field or fragment only when ' + 'the `if` argument is true.',
  args: [{ name: 'if',
    type: new _definition.GraphQLNonNull(_scalars.GraphQLBoolean),
    description: 'Included when true.' }],
  onOperation: false,
  onFragment: true,
  onField: true
});

exports.GraphQLIncludeDirective = GraphQLIncludeDirective;
/**
 * Used to conditionally skip (exclude) fields or fragments
 */
var GraphQLSkipDirective = new GraphQLDirective({
  name: 'skip',
  description: 'Directs the executor to skip this field or fragment when the `if` ' + 'argument is true.',
  args: [{ name: 'if',
    type: new _definition.GraphQLNonNull(_scalars.GraphQLBoolean),
    description: 'Skipped when true.' }],
  onOperation: false,
  onFragment: true,
  onField: true
});
exports.GraphQLSkipDirective = GraphQLSkipDirective;

},{"./definition":328,"./scalars":331,"babel-runtime/helpers/class-call-check":237}],330:[function(require,module,exports){
/*  weak */
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

var _utilitiesAstFromValue = require('../utilities/astFromValue');

var _languagePrinter = require('../language/printer');

var _definition = require('./definition');

var _scalars = require('./scalars');

var __Schema = new _definition.GraphQLObjectType({
  name: '__Schema',
  description: 'A GraphQL Schema defines the capabilities of a GraphQL server. It ' + 'exposes all available types and directives on the server, as well as ' + 'the entry points for query, mutation, and subscription operations.',
  fields: function fields() {
    return {
      types: {
        description: 'A list of all types supported by this server.',
        type: new _definition.GraphQLNonNull(new _definition.GraphQLList(new _definition.GraphQLNonNull(__Type))),
        resolve: function resolve(schema) {
          var typeMap = schema.getTypeMap();
          return _Object$keys(typeMap).map(function (key) {
            return typeMap[key];
          });
        }
      },
      queryType: {
        description: 'The type that query operations will be rooted at.',
        type: new _definition.GraphQLNonNull(__Type),
        resolve: function resolve(schema) {
          return schema.getQueryType();
        }
      },
      mutationType: {
        description: 'If this server supports mutation, the type that ' + 'mutation operations will be rooted at.',
        type: __Type,
        resolve: function resolve(schema) {
          return schema.getMutationType();
        }
      },
      subscriptionType: {
        description: 'If this server support subscription, the type that ' + 'subscription operations will be rooted at.',
        type: __Type,
        resolve: function resolve(schema) {
          return schema.getSubscriptionType();
        }
      },
      directives: {
        description: 'A list of all directives supported by this server.',
        type: new _definition.GraphQLNonNull(new _definition.GraphQLList(new _definition.GraphQLNonNull(__Directive))),
        resolve: function resolve(schema) {
          return schema.getDirectives();
        }
      }
    };
  }
});

exports.__Schema = __Schema;
var __Directive = new _definition.GraphQLObjectType({
  name: '__Directive',
  description: 'A Directive provides a way to describe alternate runtime execution and ' + 'type validation behavior in a GraphQL document.' + '\n\nIn some cases, you need to provide options to alter GraphQL’s ' + 'execution behavior in ways field arguments will not suffice, such as ' + 'conditionally including or skipping a field. Directives provide this by ' + 'describing additional information to the executor.',
  fields: function fields() {
    return {
      name: { type: new _definition.GraphQLNonNull(_scalars.GraphQLString) },
      description: { type: _scalars.GraphQLString },
      args: {
        type: new _definition.GraphQLNonNull(new _definition.GraphQLList(new _definition.GraphQLNonNull(__InputValue))),
        resolve: function resolve(directive) {
          return directive.args || [];
        }
      },
      onOperation: { type: new _definition.GraphQLNonNull(_scalars.GraphQLBoolean) },
      onFragment: { type: new _definition.GraphQLNonNull(_scalars.GraphQLBoolean) },
      onField: { type: new _definition.GraphQLNonNull(_scalars.GraphQLBoolean) }
    };
  }
});

var __Type = new _definition.GraphQLObjectType({
  name: '__Type',
  description: 'The fundamental unit of any GraphQL Schema is the type. There are ' + 'many kinds of types in GraphQL as represented by the `__TypeKind` enum.' + '\n\nDepending on the kind of a type, certain fields describe ' + 'information about that type. Scalar types provide no information ' + 'beyond a name and description, while Enum types provide their values. ' + 'Object and Interface types provide the fields they describe. Abstract ' + 'types, Union and Interface, provide the Object types possible ' + 'at runtime. List and NonNull types compose other types.',
  fields: function fields() {
    return {
      kind: {
        type: new _definition.GraphQLNonNull(__TypeKind),
        resolve: function resolve(type) {
          if (type instanceof _definition.GraphQLScalarType) {
            return TypeKind.SCALAR;
          } else if (type instanceof _definition.GraphQLObjectType) {
            return TypeKind.OBJECT;
          } else if (type instanceof _definition.GraphQLInterfaceType) {
            return TypeKind.INTERFACE;
          } else if (type instanceof _definition.GraphQLUnionType) {
            return TypeKind.UNION;
          } else if (type instanceof _definition.GraphQLEnumType) {
            return TypeKind.ENUM;
          } else if (type instanceof _definition.GraphQLInputObjectType) {
            return TypeKind.INPUT_OBJECT;
          } else if (type instanceof _definition.GraphQLList) {
            return TypeKind.LIST;
          } else if (type instanceof _definition.GraphQLNonNull) {
            return TypeKind.NON_NULL;
          }
          throw new Error('Unknown kind of type: ' + type);
        }
      },
      name: { type: _scalars.GraphQLString },
      description: { type: _scalars.GraphQLString },
      fields: {
        type: new _definition.GraphQLList(new _definition.GraphQLNonNull(__Field)),
        args: {
          includeDeprecated: { type: _scalars.GraphQLBoolean, defaultValue: false }
        },
        resolve: function resolve(type, _ref) {
          var includeDeprecated = _ref.includeDeprecated;

          if (type instanceof _definition.GraphQLObjectType || type instanceof _definition.GraphQLInterfaceType) {
            var fieldMap = type.getFields();
            var fields = _Object$keys(fieldMap).map(function (fieldName) {
              return fieldMap[fieldName];
            });
            if (!includeDeprecated) {
              fields = fields.filter(function (field) {
                return !field.deprecationReason;
              });
            }
            return fields;
          }
          return null;
        }
      },
      interfaces: {
        type: new _definition.GraphQLList(new _definition.GraphQLNonNull(__Type)),
        resolve: function resolve(type) {
          if (type instanceof _definition.GraphQLObjectType) {
            return type.getInterfaces();
          }
        }
      },
      possibleTypes: {
        type: new _definition.GraphQLList(new _definition.GraphQLNonNull(__Type)),
        resolve: function resolve(type) {
          if (type instanceof _definition.GraphQLInterfaceType || type instanceof _definition.GraphQLUnionType) {
            return type.getPossibleTypes();
          }
        }
      },
      enumValues: {
        type: new _definition.GraphQLList(new _definition.GraphQLNonNull(__EnumValue)),
        args: {
          includeDeprecated: { type: _scalars.GraphQLBoolean, defaultValue: false }
        },
        resolve: function resolve(type, _ref2) {
          var includeDeprecated = _ref2.includeDeprecated;

          if (type instanceof _definition.GraphQLEnumType) {
            var values = type.getValues();
            if (!includeDeprecated) {
              values = values.filter(function (value) {
                return !value.deprecationReason;
              });
            }
            return values;
          }
        }
      },
      inputFields: {
        type: new _definition.GraphQLList(new _definition.GraphQLNonNull(__InputValue)),
        resolve: function resolve(type) {
          if (type instanceof _definition.GraphQLInputObjectType) {
            var fieldMap = type.getFields();
            return _Object$keys(fieldMap).map(function (fieldName) {
              return fieldMap[fieldName];
            });
          }
        }
      },
      ofType: { type: __Type }
    };
  }
});

var __Field = new _definition.GraphQLObjectType({
  name: '__Field',
  description: 'Object and Interface types are described by a list of Fields, each of ' + 'which has a name, potentially a list of arguments, and a return type.',
  fields: function fields() {
    return {
      name: { type: new _definition.GraphQLNonNull(_scalars.GraphQLString) },
      description: { type: _scalars.GraphQLString },
      args: {
        type: new _definition.GraphQLNonNull(new _definition.GraphQLList(new _definition.GraphQLNonNull(__InputValue))),
        resolve: function resolve(field) {
          return field.args || [];
        }
      },
      type: { type: new _definition.GraphQLNonNull(__Type) },
      isDeprecated: {
        type: new _definition.GraphQLNonNull(_scalars.GraphQLBoolean),
        resolve: function resolve(field) {
          return !(0, _jsutilsIsNullish2['default'])(field.deprecationReason);
        }
      },
      deprecationReason: {
        type: _scalars.GraphQLString
      }
    };
  }
});

var __InputValue = new _definition.GraphQLObjectType({
  name: '__InputValue',
  description: 'Arguments provided to Fields or Directives and the input fields of an ' + 'InputObject are represented as Input Values which describe their type ' + 'and optionally a default value.',
  fields: function fields() {
    return {
      name: { type: new _definition.GraphQLNonNull(_scalars.GraphQLString) },
      description: { type: _scalars.GraphQLString },
      type: { type: new _definition.GraphQLNonNull(__Type) },
      defaultValue: {
        type: _scalars.GraphQLString,
        description: 'A GraphQL-formatted string representing the default value for this ' + 'input value.',
        resolve: function resolve(inputVal) {
          return (0, _jsutilsIsNullish2['default'])(inputVal.defaultValue) ? null : (0, _languagePrinter.print)((0, _utilitiesAstFromValue.astFromValue)(inputVal.defaultValue, inputVal));
        }
      }
    };
  }
});

var __EnumValue = new _definition.GraphQLObjectType({
  name: '__EnumValue',
  description: 'One possible value for a given Enum. Enum values are unique values, not ' + 'a placeholder for a string or numeric value. However an Enum value is ' + 'returned in a JSON response as a string.',
  fields: {
    name: { type: new _definition.GraphQLNonNull(_scalars.GraphQLString) },
    description: { type: _scalars.GraphQLString },
    isDeprecated: {
      type: new _definition.GraphQLNonNull(_scalars.GraphQLBoolean),
      resolve: function resolve(enumValue) {
        return !(0, _jsutilsIsNullish2['default'])(enumValue.deprecationReason);
      }
    },
    deprecationReason: {
      type: _scalars.GraphQLString
    }
  }
});

var TypeKind = {
  SCALAR: 'SCALAR',
  OBJECT: 'OBJECT',
  INTERFACE: 'INTERFACE',
  UNION: 'UNION',
  ENUM: 'ENUM',
  INPUT_OBJECT: 'INPUT_OBJECT',
  LIST: 'LIST',
  NON_NULL: 'NON_NULL'
};

exports.TypeKind = TypeKind;
var __TypeKind = new _definition.GraphQLEnumType({
  name: '__TypeKind',
  description: 'An enum describing what kind of type a given `__Type` is.',
  values: {
    SCALAR: {
      value: TypeKind.SCALAR,
      description: 'Indicates this type is a scalar.'
    },
    OBJECT: {
      value: TypeKind.OBJECT,
      description: 'Indicates this type is an object. ' + '`fields` and `interfaces` are valid fields.'
    },
    INTERFACE: {
      value: TypeKind.INTERFACE,
      description: 'Indicates this type is an interface. ' + '`fields` and `possibleTypes` are valid fields.'
    },
    UNION: {
      value: TypeKind.UNION,
      description: 'Indicates this type is a union. ' + '`possibleTypes` is a valid field.'
    },
    ENUM: {
      value: TypeKind.ENUM,
      description: 'Indicates this type is an enum. ' + '`enumValues` is a valid field.'
    },
    INPUT_OBJECT: {
      value: TypeKind.INPUT_OBJECT,
      description: 'Indicates this type is an input object. ' + '`inputFields` is a valid field.'
    },
    LIST: {
      value: TypeKind.LIST,
      description: 'Indicates this type is a list. ' + '`ofType` is a valid field.'
    },
    NON_NULL: {
      value: TypeKind.NON_NULL,
      description: 'Indicates this type is a non-null. ' + '`ofType` is a valid field.'
    }
  }
});

/**
 * Note that these are GraphQLFieldDefinition and not GraphQLFieldConfig,
 * so the format for args is different.
 */

var SchemaMetaFieldDef = {
  name: '__schema',
  type: new _definition.GraphQLNonNull(__Schema),
  description: 'Access the current type schema of this server.',
  args: [],
  resolve: function resolve(source, args, _ref3) {
    var schema = _ref3.schema;
    return schema;
  }
};

exports.SchemaMetaFieldDef = SchemaMetaFieldDef;
var TypeMetaFieldDef = {
  name: '__type',
  type: __Type,
  description: 'Request the type information of a single type.',
  args: [{ name: 'name', type: new _definition.GraphQLNonNull(_scalars.GraphQLString) }],
  resolve: function resolve(source, _ref4, _ref5) {
    var name = _ref4.name;
    var schema = _ref5.schema;
    return schema.getType(name);
  }
};

exports.TypeMetaFieldDef = TypeMetaFieldDef;
var TypeNameMetaFieldDef = {
  name: '__typename',
  type: new _definition.GraphQLNonNull(_scalars.GraphQLString),
  description: 'The name of the current Object type at runtime.',
  args: [],
  resolve: function resolve(source, args, _ref6) {
    var parentType = _ref6.parentType;
    return parentType.name;
  }
};
exports.TypeNameMetaFieldDef = TypeNameMetaFieldDef;

},{"../jsutils/isNullish":215,"../language/printer":222,"../utilities/astFromValue":334,"./definition":328,"./scalars":331,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/interop-require-default":242}],331:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _definition = require('./definition');

var _language = require('../language');

// As per the GraphQL Spec, Integers are only treated as valid when a valid
// 32-bit signed integer, providing the broadest support across platforms.
//
// n.b. JavaScript's integers are safe between -(2^53 - 1) and 2^53 - 1 because
// they are internally represented as IEEE 754 doubles.
var MAX_INT = 2147483647;
var MIN_INT = -2147483648;

function coerceInt(value) {
  var num = Number(value);
  if (num === num && num <= MAX_INT && num >= MIN_INT) {
    return (num < 0 ? Math.ceil : Math.floor)(num);
  }
  return null;
}

var GraphQLInt = new _definition.GraphQLScalarType({
  name: 'Int',
  description: 'The `Int` scalar type represents non-fractional signed whole numeric ' + 'values. Int can represent values between -(2^53 - 1) and 2^53 - 1 since ' + 'represented in JSON as double-precision floating point numbers specified' + 'by [IEEE 754](http://en.wikipedia.org/wiki/IEEE_floating_point).',
  serialize: coerceInt,
  parseValue: coerceInt,
  parseLiteral: function parseLiteral(ast) {
    if (ast.kind === _language.Kind.INT) {
      var num = parseInt(ast.value, 10);
      if (num <= MAX_INT && num >= MIN_INT) {
        return num;
      }
    }
    return null;
  }
});

exports.GraphQLInt = GraphQLInt;
function coerceFloat(value) {
  var num = Number(value);
  return num === num ? num : null;
}

var GraphQLFloat = new _definition.GraphQLScalarType({
  name: 'Float',
  description: 'The `Float` scalar type represents signed double-precision fractional ' + 'values as specified by ' + '[IEEE 754](http://en.wikipedia.org/wiki/IEEE_floating_point). ',
  serialize: coerceFloat,
  parseValue: coerceFloat,
  parseLiteral: function parseLiteral(ast) {
    return ast.kind === _language.Kind.FLOAT || ast.kind === _language.Kind.INT ? parseFloat(ast.value) : null;
  }
});

exports.GraphQLFloat = GraphQLFloat;
var GraphQLString = new _definition.GraphQLScalarType({
  name: 'String',
  description: 'The `String` scalar type represents textual data, represented as UTF-8 ' + 'character sequences. The String type is most often used by GraphQL to ' + 'represent free-form human-readable text.',
  serialize: String,
  parseValue: String,
  parseLiteral: function parseLiteral(ast) {
    return ast.kind === _language.Kind.STRING ? ast.value : null;
  }
});

exports.GraphQLString = GraphQLString;
var GraphQLBoolean = new _definition.GraphQLScalarType({
  name: 'Boolean',
  description: 'The `Boolean` scalar type represents `true` or `false`.',
  serialize: Boolean,
  parseValue: Boolean,
  parseLiteral: function parseLiteral(ast) {
    return ast.kind === _language.Kind.BOOLEAN ? ast.value : null;
  }
});

exports.GraphQLBoolean = GraphQLBoolean;
var GraphQLID = new _definition.GraphQLScalarType({
  name: 'ID',
  description: 'The `ID` scalar type represents a unique identifier, often used to ' + 'refetch an object or as key for a cache. The ID type appears in a JSON ' + 'response as a String; however, it is not intended to be human-readable. ' + 'When expected as an input type, any string (such as `"4"`) or integer ' + '(such as `4`) input value will be accepted as an ID.',
  serialize: String,
  parseValue: String,
  parseLiteral: function parseLiteral(ast) {
    return ast.kind === _language.Kind.STRING || ast.kind === _language.Kind.INT ? ast.value : null;
  }
});
exports.GraphQLID = GraphQLID;

},{"../language":217,"./definition":328}],332:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var _createClass = require('babel-runtime/helpers/create-class')['default'];

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _definition = require('./definition');

var _directives = require('./directives');

var _introspection = require('./introspection');

var _jsutilsFind = require('../jsutils/find');

var _jsutilsFind2 = _interopRequireDefault(_jsutilsFind);

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _utilitiesTypeComparators = require('../utilities/typeComparators');

/**
 * Schema Definition
 *
 * A Schema is created by supplying the root types of each type of operation,
 * query and mutation (optional). A schema definition is then supplied to the
 * validator and executor.
 *
 * Example:
 *
 *     var MyAppSchema = new GraphQLSchema({
 *       query: MyAppQueryRootType
 *       mutation: MyAppMutationRootType
 *     });
 *
 */

var GraphQLSchema = function () {
  function GraphQLSchema(config) {
    var _this = this;

    _classCallCheck(this, GraphQLSchema);

    (0, _jsutilsInvariant2['default'])((typeof config === 'undefined' ? 'undefined' : _typeof(config)) === 'object', 'Must provide configuration object.');

    (0, _jsutilsInvariant2['default'])(config.query instanceof _definition.GraphQLObjectType, 'Schema query must be Object Type but got: ' + config.query + '.');
    this._queryType = config.query;

    (0, _jsutilsInvariant2['default'])(!config.mutation || config.mutation instanceof _definition.GraphQLObjectType, 'Schema mutation must be Object Type if provided but ' + ('got: ' + config.mutation + '.'));
    this._mutationType = config.mutation;

    (0, _jsutilsInvariant2['default'])(!config.subscription || config.subscription instanceof _definition.GraphQLObjectType, 'Schema subscription must be Object Type if provided but ' + ('got: ' + config.subscription + '.'));
    this._subscriptionType = config.subscription;

    (0, _jsutilsInvariant2['default'])(!config.directives || Array.isArray(config.directives) && config.directives.every(function (directive) {
      return directive instanceof _directives.GraphQLDirective;
    }), 'Schema directives must be Array<GraphQLDirective> if provided but ' + ('got: ' + config.directives + '.'));
    // Provide `@include() and `@skip()` directives by default.
    this._directives = config.directives || [_directives.GraphQLIncludeDirective, _directives.GraphQLSkipDirective];

    // Build type map now to detect any errors within this schema.
    this._typeMap = [this.getQueryType(), this.getMutationType(), this.getSubscriptionType(), _introspection.__Schema].reduce(typeMapReducer, {});

    // Enforce correct interface implementations
    _Object$keys(this._typeMap).forEach(function (typeName) {
      var type = _this._typeMap[typeName];
      if (type instanceof _definition.GraphQLObjectType) {
        type.getInterfaces().forEach(function (iface) {
          return assertObjectImplementsInterface(type, iface);
        });
      }
    });
  }

  _createClass(GraphQLSchema, [{
    key: 'getQueryType',
    value: function getQueryType() {
      return this._queryType;
    }
  }, {
    key: 'getMutationType',
    value: function getMutationType() {
      return this._mutationType;
    }
  }, {
    key: 'getSubscriptionType',
    value: function getSubscriptionType() {
      return this._subscriptionType;
    }
  }, {
    key: 'getTypeMap',
    value: function getTypeMap() {
      return this._typeMap;
    }
  }, {
    key: 'getType',
    value: function getType(name) {
      return this.getTypeMap()[name];
    }
  }, {
    key: 'getDirectives',
    value: function getDirectives() {
      return this._directives;
    }
  }, {
    key: 'getDirective',
    value: function getDirective(name) {
      return (0, _jsutilsFind2['default'])(this.getDirectives(), function (directive) {
        return directive.name === name;
      });
    }
  }]);

  return GraphQLSchema;
}();

exports.GraphQLSchema = GraphQLSchema;

function typeMapReducer(_x, _x2) {
  var _again = true;

  _function: while (_again) {
    var map = _x,
        type = _x2;
    reducedMap = fieldMap = undefined;
    _again = false;

    if (!type) {
      return map;
    }
    if (type instanceof _definition.GraphQLList || type instanceof _definition.GraphQLNonNull) {
      _x = map;
      _x2 = type.ofType;
      _again = true;
      continue _function;
    }
    if (map[type.name]) {
      (0, _jsutilsInvariant2['default'])(map[type.name] === type, 'Schema must contain unique named types but contains multiple ' + ('types named "' + type + '".'));
      return map;
    }
    map[type.name] = type;

    var reducedMap = map;

    if (type instanceof _definition.GraphQLUnionType || type instanceof _definition.GraphQLInterfaceType) {
      reducedMap = type.getPossibleTypes().reduce(typeMapReducer, reducedMap);
    }

    if (type instanceof _definition.GraphQLObjectType) {
      reducedMap = type.getInterfaces().reduce(typeMapReducer, reducedMap);
    }

    if (type instanceof _definition.GraphQLObjectType || type instanceof _definition.GraphQLInterfaceType || type instanceof _definition.GraphQLInputObjectType) {
      var fieldMap = type.getFields();
      _Object$keys(fieldMap).forEach(function (fieldName) {
        var field = fieldMap[fieldName];

        if (field.args) {
          var fieldArgTypes = field.args.map(function (arg) {
            return arg.type;
          });
          reducedMap = fieldArgTypes.reduce(typeMapReducer, reducedMap);
        }
        reducedMap = typeMapReducer(reducedMap, field.type);
      });
    }

    return reducedMap;
  }
}

function assertObjectImplementsInterface(object, iface) {
  var objectFieldMap = object.getFields();
  var ifaceFieldMap = iface.getFields();

  // Assert each interface field is implemented.
  _Object$keys(ifaceFieldMap).forEach(function (fieldName) {
    var objectField = objectFieldMap[fieldName];
    var ifaceField = ifaceFieldMap[fieldName];

    // Assert interface field exists on object.
    (0, _jsutilsInvariant2['default'])(objectField, '"' + iface + '" expects field "' + fieldName + '" but "' + object + '" does not ' + 'provide it.');

    // Assert interface field type is satisfied by object field type, by being
    // a valid subtype. (covariant)
    (0, _jsutilsInvariant2['default'])((0, _utilitiesTypeComparators.isTypeSubTypeOf)(objectField.type, ifaceField.type), iface + '.' + fieldName + ' expects type "' + ifaceField.type + '" but ' + (object + '.' + fieldName + ' provides type "' + objectField.type + '".'));

    // Assert each interface field arg is implemented.
    ifaceField.args.forEach(function (ifaceArg) {
      var argName = ifaceArg.name;
      var objectArg = (0, _jsutilsFind2['default'])(objectField.args, function (arg) {
        return arg.name === argName;
      });

      // Assert interface field arg exists on object field.
      (0, _jsutilsInvariant2['default'])(objectArg, iface + '.' + fieldName + ' expects argument "' + argName + '" but ' + (object + '.' + fieldName + ' does not provide it.'));

      // Assert interface field arg type matches object field arg type.
      // (invariant)
      (0, _jsutilsInvariant2['default'])((0, _utilitiesTypeComparators.isEqualType)(ifaceArg.type, objectArg.type), iface + '.' + fieldName + '(' + argName + ':) expects type "' + ifaceArg.type + '" ' + ('but ' + object + '.' + fieldName + '(' + argName + ':) provides ') + ('type "' + objectArg.type + '".'));
    });

    // Assert additional arguments must not be required.
    objectField.args.forEach(function (objectArg) {
      var argName = objectArg.name;
      var ifaceArg = (0, _jsutilsFind2['default'])(ifaceField.args, function (arg) {
        return arg.name === argName;
      });
      if (!ifaceArg) {
        (0, _jsutilsInvariant2['default'])(!(objectArg.type instanceof _definition.GraphQLNonNull), object + '.' + fieldName + '(' + argName + ':) is of required type ' + ('"' + objectArg.type + '" but is not also provided by the ') + ('interface ' + iface + '.' + fieldName + '.'));
      }
    });
  });
}

},{"../jsutils/find":213,"../jsutils/invariant":214,"../utilities/typeComparators":337,"./definition":328,"./directives":329,"./introspection":330,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/class-call-check":237,"babel-runtime/helpers/create-class":238,"babel-runtime/helpers/interop-require-default":242}],333:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _createClass = require('babel-runtime/helpers/create-class')['default'];

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

var _interopRequireWildcard = require('babel-runtime/helpers/interop-require-wildcard')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _languageKinds = require('../language/kinds');

var Kind = _interopRequireWildcard(_languageKinds);

var _typeDefinition = require('../type/definition');

var _typeIntrospection = require('../type/introspection');

var _typeFromAST = require('./typeFromAST');

var _jsutilsFind = require('../jsutils/find');

var _jsutilsFind2 = _interopRequireDefault(_jsutilsFind);

/**
 * TypeInfo is a utility class which, given a GraphQL schema, can keep track
 * of the current field and type definitions at any point in a GraphQL document
 * AST during a recursive descent by calling `enter(node)` and `leave(node)`.
 */

var TypeInfo = function () {
  function TypeInfo(schema,
  // NOTE: this experimental optional second parameter is only needed in order
  // to support non-spec-compliant codebases. You should never need to use it.
  getFieldDefFn) {
    _classCallCheck(this, TypeInfo);

    this._schema = schema;
    this._typeStack = [];
    this._parentTypeStack = [];
    this._inputTypeStack = [];
    this._fieldDefStack = [];
    this._directive = null;
    this._argument = null;
    this._getFieldDef = getFieldDefFn || getFieldDef;
  }

  /**
   * Not exactly the same as the executor's definition of getFieldDef, in this
   * statically evaluated environment we do not always have an Object type,
   * and need to handle Interface and Union types.
   */

  _createClass(TypeInfo, [{
    key: 'getType',
    value: function getType() {
      if (this._typeStack.length > 0) {
        return this._typeStack[this._typeStack.length - 1];
      }
    }
  }, {
    key: 'getParentType',
    value: function getParentType() {
      if (this._parentTypeStack.length > 0) {
        return this._parentTypeStack[this._parentTypeStack.length - 1];
      }
    }
  }, {
    key: 'getInputType',
    value: function getInputType() {
      if (this._inputTypeStack.length > 0) {
        return this._inputTypeStack[this._inputTypeStack.length - 1];
      }
    }
  }, {
    key: 'getFieldDef',
    value: function getFieldDef() {
      if (this._fieldDefStack.length > 0) {
        return this._fieldDefStack[this._fieldDefStack.length - 1];
      }
    }
  }, {
    key: 'getDirective',
    value: function getDirective() {
      return this._directive;
    }
  }, {
    key: 'getArgument',
    value: function getArgument() {
      return this._argument;
    }

    // Flow does not yet handle this case.
  }, {
    key: 'enter',
    value: function enter(node /* Node */) {
      var schema = this._schema;
      switch (node.kind) {
        case Kind.SELECTION_SET:
          var namedType = (0, _typeDefinition.getNamedType)(this.getType());
          var compositeType;
          if ((0, _typeDefinition.isCompositeType)(namedType)) {
            // isCompositeType is a type refining predicate, so this is safe.
            compositeType = namedType;
          }
          this._parentTypeStack.push(compositeType);
          break;
        case Kind.FIELD:
          var parentType = this.getParentType();
          var fieldDef;
          if (parentType) {
            fieldDef = this._getFieldDef(schema, parentType, node);
          }
          this._fieldDefStack.push(fieldDef);
          this._typeStack.push(fieldDef && fieldDef.type);
          break;
        case Kind.DIRECTIVE:
          this._directive = schema.getDirective(node.name.value);
          break;
        case Kind.OPERATION_DEFINITION:
          var type = undefined;
          if (node.operation === 'query') {
            type = schema.getQueryType();
          } else if (node.operation === 'mutation') {
            type = schema.getMutationType();
          } else if (node.operation === 'subscription') {
            type = schema.getSubscriptionType();
          }
          this._typeStack.push(type);
          break;
        case Kind.INLINE_FRAGMENT:
        case Kind.FRAGMENT_DEFINITION:
          var typeConditionAST = node.typeCondition;
          var outputType = typeConditionAST ? (0, _typeFromAST.typeFromAST)(schema, typeConditionAST) : this.getType();
          this._typeStack.push(outputType);
          break;
        case Kind.VARIABLE_DEFINITION:
          var inputType = (0, _typeFromAST.typeFromAST)(schema, node.type);
          this._inputTypeStack.push(inputType);
          break;
        case Kind.ARGUMENT:
          var argDef;
          var argType;
          var fieldOrDirective = this.getDirective() || this.getFieldDef();
          if (fieldOrDirective) {
            argDef = (0, _jsutilsFind2['default'])(fieldOrDirective.args, function (arg) {
              return arg.name === node.name.value;
            });
            if (argDef) {
              argType = argDef.type;
            }
          }
          this._argument = argDef;
          this._inputTypeStack.push(argType);
          break;
        case Kind.LIST:
          var listType = (0, _typeDefinition.getNullableType)(this.getInputType());
          this._inputTypeStack.push(listType instanceof _typeDefinition.GraphQLList ? listType.ofType : undefined);
          break;
        case Kind.OBJECT_FIELD:
          var objectType = (0, _typeDefinition.getNamedType)(this.getInputType());
          var fieldType;
          if (objectType instanceof _typeDefinition.GraphQLInputObjectType) {
            var inputField = objectType.getFields()[node.name.value];
            fieldType = inputField ? inputField.type : undefined;
          }
          this._inputTypeStack.push(fieldType);
          break;
      }
    }
  }, {
    key: 'leave',
    value: function leave(node) {
      switch (node.kind) {
        case Kind.SELECTION_SET:
          this._parentTypeStack.pop();
          break;
        case Kind.FIELD:
          this._fieldDefStack.pop();
          this._typeStack.pop();
          break;
        case Kind.DIRECTIVE:
          this._directive = null;
          break;
        case Kind.OPERATION_DEFINITION:
        case Kind.INLINE_FRAGMENT:
        case Kind.FRAGMENT_DEFINITION:
          this._typeStack.pop();
          break;
        case Kind.VARIABLE_DEFINITION:
          this._inputTypeStack.pop();
          break;
        case Kind.ARGUMENT:
          this._argument = null;
          this._inputTypeStack.pop();
          break;
        case Kind.LIST:
        case Kind.OBJECT_FIELD:
          this._inputTypeStack.pop();
          break;
      }
    }
  }]);

  return TypeInfo;
}();

exports.TypeInfo = TypeInfo;
function getFieldDef(schema, parentType, fieldAST) {
  var name = fieldAST.name.value;
  if (name === _typeIntrospection.SchemaMetaFieldDef.name && schema.getQueryType() === parentType) {
    return _typeIntrospection.SchemaMetaFieldDef;
  }
  if (name === _typeIntrospection.TypeMetaFieldDef.name && schema.getQueryType() === parentType) {
    return _typeIntrospection.TypeMetaFieldDef;
  }
  if (name === _typeIntrospection.TypeNameMetaFieldDef.name && (parentType instanceof _typeDefinition.GraphQLObjectType || parentType instanceof _typeDefinition.GraphQLInterfaceType || parentType instanceof _typeDefinition.GraphQLUnionType)) {
    return _typeIntrospection.TypeNameMetaFieldDef;
  }
  if (parentType instanceof _typeDefinition.GraphQLObjectType || parentType instanceof _typeDefinition.GraphQLInterfaceType) {
    return parentType.getFields()[name];
  }
}
// It may disappear in the future.

},{"../jsutils/find":213,"../language/kinds":218,"../type/definition":328,"../type/introspection":330,"./typeFromAST":338,"babel-runtime/helpers/class-call-check":237,"babel-runtime/helpers/create-class":238,"babel-runtime/helpers/interop-require-default":242,"babel-runtime/helpers/interop-require-wildcard":243}],334:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.astFromValue = astFromValue;

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

var _languageKinds = require('../language/kinds');

var _typeDefinition = require('../type/definition');

var _typeScalars = require('../type/scalars');

/**
 * Produces a GraphQL Value AST given a JavaScript value.
 *
 * Optionally, a GraphQL type may be provided, which will be used to
 * disambiguate between value primitives.
 *
 * | JSON Value    | GraphQL Value        |
 * | ------------- | -------------------- |
 * | Object        | Input Object         |
 * | Array         | List                 |
 * | Boolean       | Boolean              |
 * | String        | String / Enum Value  |
 * | Number        | Int / Float          |
 *
 */

function astFromValue(_x, _x2) {
  var _again = true;

  _function: while (_again) {
    var value = _x,
        type = _x2;
    itemType = stringNum = isIntValue = fields = undefined;
    _again = false;

    if (type instanceof _typeDefinition.GraphQLNonNull) {
      // Note: we're not checking that the result is non-null.
      // This function is not responsible for validating the input value.
      _x = value;
      _x2 = type.ofType;
      _again = true;
      continue _function;
    }

    if ((0, _jsutilsIsNullish2['default'])(value)) {
      return null;
    }

    // Convert JavaScript array to GraphQL list. If the GraphQLType is a list, but
    // the value is not an array, convert the value using the list's item type.
    if (Array.isArray(value)) {
      var itemType = type instanceof _typeDefinition.GraphQLList ? type.ofType : null;
      return {
        kind: _languageKinds.LIST,
        values: value.map(function (item) {
          return astFromValue(item, itemType);
        })
      };
    } else if (type instanceof _typeDefinition.GraphQLList) {
      // Because GraphQL will accept single values as a "list of one" when
      // expecting a list, if there's a non-array value and an expected list type,
      // create an AST using the list's item type.
      _x = value;
      _x2 = type.ofType;
      _again = true;
      continue _function;
    }

    if (typeof value === 'boolean') {
      return { kind: _languageKinds.BOOLEAN, value: value };
    }

    // JavaScript numbers can be Float or Int values. Use the GraphQLType to
    // differentiate if available, otherwise prefer Int if the value is a
    // valid Int.
    if (typeof value === 'number') {
      var stringNum = String(value);
      var isIntValue = /^[0-9]+$/.test(stringNum);
      if (isIntValue) {
        if (type === _typeScalars.GraphQLFloat) {
          return { kind: _languageKinds.FLOAT, value: stringNum + '.0' };
        }
        return { kind: _languageKinds.INT, value: stringNum };
      }
      return { kind: _languageKinds.FLOAT, value: stringNum };
    }

    // JavaScript strings can be Enum values or String values. Use the
    // GraphQLType to differentiate if possible.
    if (typeof value === 'string') {
      if (type instanceof _typeDefinition.GraphQLEnumType && /^[_a-zA-Z][_a-zA-Z0-9]*$/.test(value)) {
        return { kind: _languageKinds.ENUM, value: value };
      }
      // Use JSON stringify, which uses the same string encoding as GraphQL,
      // then remove the quotes.
      return { kind: _languageKinds.STRING, value: JSON.stringify(value).slice(1, -1) };
    }

    // last remaining possible typeof
    (0, _jsutilsInvariant2['default'])((typeof value === 'undefined' ? 'undefined' : _typeof(value)) === 'object');

    // Populate the fields of the input object by creating ASTs from each value
    // in the JavaScript object.
    var fields = [];
    _Object$keys(value).forEach(function (fieldName) {
      var fieldType;
      if (type instanceof _typeDefinition.GraphQLInputObjectType) {
        var fieldDef = type.getFields()[fieldName];
        fieldType = fieldDef && fieldDef.type;
      }
      var fieldValue = astFromValue(value[fieldName], fieldType);
      if (fieldValue) {
        fields.push({
          kind: _languageKinds.OBJECT_FIELD,
          name: { kind: _languageKinds.NAME, value: fieldName },
          value: fieldValue
        });
      }
    });
    return { kind: _languageKinds.OBJECT, fields: fields };
  }
}

},{"../jsutils/invariant":214,"../jsutils/isNullish":215,"../language/kinds":218,"../type/definition":328,"../type/scalars":331,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/interop-require-default":242}],335:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Given a JavaScript value and a GraphQL type, determine if the value will be
 * accepted for that type. This is primarily useful for validating the
 * runtime values of query variables.
 */
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

var _toConsumableArray = require('babel-runtime/helpers/to-consumable-array')['default'];

var _getIterator = require('babel-runtime/core-js/get-iterator')['default'];

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.isValidJSValue = isValidJSValue;

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

var _typeDefinition = require('../type/definition');

function isValidJSValue(_x, _x2) {
  var _again = true;

  _function: while (_again) {
    var value = _x,
        type = _x2;
    ofType = itemType = fields = errors = _iteratorNormalCompletion = _didIteratorError = _iteratorError = _iteratorNormalCompletion2 = _didIteratorError2 = _iteratorError2 = parseResult = undefined;
    _again = false;

    // A value must be provided if the type is non-null.
    if (type instanceof _typeDefinition.GraphQLNonNull) {
      var ofType = type.ofType;
      if ((0, _jsutilsIsNullish2['default'])(value)) {
        if (ofType.name) {
          return ['Expected "' + ofType.name + '!", found null.'];
        }
        return ['Expected non-null value, found null.'];
      }
      _x = value;
      _x2 = ofType;
      _again = true;
      continue _function;
    }

    if ((0, _jsutilsIsNullish2['default'])(value)) {
      return [];
    }

    // Lists accept a non-list value as a list of one.
    if (type instanceof _typeDefinition.GraphQLList) {
      var itemType = type.ofType;
      if (Array.isArray(value)) {
        return value.reduce(function (acc, item, index) {
          var errors = isValidJSValue(item, itemType);
          return acc.concat(errors.map(function (error) {
            return 'In element #' + index + ': ' + error;
          }));
        }, []);
      }
      _x = value;
      _x2 = itemType;
      _again = true;
      continue _function;
    }

    // Input objects check each defined field.
    if (type instanceof _typeDefinition.GraphQLInputObjectType) {
      if ((typeof value === 'undefined' ? 'undefined' : _typeof(value)) !== 'object') {
        return ['Expected "' + type.name + '", found not an object.'];
      }
      var fields = type.getFields();

      var errors = [];

      // Ensure every provided field is defined.
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = _getIterator(_Object$keys(value)), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var providedField = _step.value;

          if (!fields[providedField]) {
            errors.push('In field "${providedField}": Unknown field.');
          }
        }

        // Ensure every defined field is valid.
      } catch (err) {
        _didIteratorError = true;
        _iteratorError = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion && _iterator['return']) {
            _iterator['return']();
          }
        } finally {
          if (_didIteratorError) {
            throw _iteratorError;
          }
        }
      }

      var _iteratorNormalCompletion2 = true;
      var _didIteratorError2 = false;
      var _iteratorError2 = undefined;

      try {
        for (var _iterator2 = _getIterator(_Object$keys(fields)), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
          var fieldName = _step2.value;

          var newErrors = isValidJSValue(value[fieldName], fields[fieldName].type);
          errors.push.apply(errors, _toConsumableArray(newErrors.map(function (error) {
            return 'In field "' + fieldName + '": ' + error;
          })));
        }
      } catch (err) {
        _didIteratorError2 = true;
        _iteratorError2 = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion2 && _iterator2['return']) {
            _iterator2['return']();
          }
        } finally {
          if (_didIteratorError2) {
            throw _iteratorError2;
          }
        }
      }

      return errors;
    }

    (0, _jsutilsInvariant2['default'])(type instanceof _typeDefinition.GraphQLScalarType || type instanceof _typeDefinition.GraphQLEnumType, 'Must be input type');

    // Scalar/Enum input checks to ensure the type can parse the value to
    // a non-null value.
    var parseResult = type.parseValue(value);
    if ((0, _jsutilsIsNullish2['default'])(parseResult)) {
      return ['Expected type "' + type.name + '", found ' + JSON.stringify(value) + '.'];
    }

    return [];
  }
}

},{"../jsutils/invariant":214,"../jsutils/isNullish":215,"../type/definition":328,"babel-runtime/core-js/get-iterator":226,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/interop-require-default":242,"babel-runtime/helpers/to-consumable-array":245}],336:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _toConsumableArray = require('babel-runtime/helpers/to-consumable-array')['default'];

var _getIterator = require('babel-runtime/core-js/get-iterator')['default'];

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.isValidLiteralValue = isValidLiteralValue;

var _languagePrinter = require('../language/printer');

var _languageKinds = require('../language/kinds');

var _typeDefinition = require('../type/definition');

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _jsutilsKeyMap = require('../jsutils/keyMap');

var _jsutilsKeyMap2 = _interopRequireDefault(_jsutilsKeyMap);

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

/**
 * Utility for validators which determines if a value literal AST is valid given
 * an input type.
 *
 * Note that this only validates literal values, variables are assumed to
 * provide values of the correct type.
 */

function isValidLiteralValue(_x, _x2) {
  var _again = true;

  _function: while (_again) {
    var type = _x,
        valueAST = _x2;
    ofType = itemType = fields = errors = fieldASTs = _iteratorNormalCompletion = _didIteratorError = _iteratorError = fieldASTMap = _iteratorNormalCompletion2 = _didIteratorError2 = _iteratorError2 = parseResult = undefined;
    _again = false;

    // A value must be provided if the type is non-null.
    if (type instanceof _typeDefinition.GraphQLNonNull) {
      var ofType = type.ofType;
      if (!valueAST) {
        if (ofType.name) {
          return ['Expected "' + ofType.name + '!", found null.'];
        }
        return ['Expected non-null value, found null.'];
      }
      _x = ofType;
      _x2 = valueAST;
      _again = true;
      continue _function;
    }

    if (!valueAST) {
      return [];
    }

    // This function only tests literals, and assumes variables will provide
    // values of the correct type.
    if (valueAST.kind === _languageKinds.VARIABLE) {
      return [];
    }

    // Lists accept a non-list value as a list of one.
    if (type instanceof _typeDefinition.GraphQLList) {
      var itemType = type.ofType;
      if (valueAST.kind === _languageKinds.LIST) {
        return valueAST.values.reduce(function (acc, itemAST, index) {
          var errors = isValidLiteralValue(itemType, itemAST);
          return acc.concat(errors.map(function (error) {
            return 'In element #' + index + ': ' + error;
          }));
        }, []);
      }
      _x = itemType;
      _x2 = valueAST;
      _again = true;
      continue _function;
    }

    // Input objects check each defined field and look for undefined fields.
    if (type instanceof _typeDefinition.GraphQLInputObjectType) {
      if (valueAST.kind !== _languageKinds.OBJECT) {
        return ['Expected "' + type.name + '", found not an object.'];
      }
      var fields = type.getFields();

      var errors = [];

      // Ensure every provided field is defined.
      var fieldASTs = valueAST.fields;
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = _getIterator(fieldASTs), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var providedFieldAST = _step.value;

          if (!fields[providedFieldAST.name.value]) {
            errors.push('In field "' + providedFieldAST.name.value + '": Unknown field.');
          }
        }

        // Ensure every defined field is valid.
      } catch (err) {
        _didIteratorError = true;
        _iteratorError = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion && _iterator['return']) {
            _iterator['return']();
          }
        } finally {
          if (_didIteratorError) {
            throw _iteratorError;
          }
        }
      }

      var fieldASTMap = (0, _jsutilsKeyMap2['default'])(fieldASTs, function (fieldAST) {
        return fieldAST.name.value;
      });
      var _iteratorNormalCompletion2 = true;
      var _didIteratorError2 = false;
      var _iteratorError2 = undefined;

      try {
        for (var _iterator2 = _getIterator(_Object$keys(fields)), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
          var fieldName = _step2.value;

          var result = isValidLiteralValue(fields[fieldName].type, fieldASTMap[fieldName] && fieldASTMap[fieldName].value);
          errors.push.apply(errors, _toConsumableArray(result.map(function (error) {
            return 'In field "' + fieldName + '": ' + error;
          })));
        }
      } catch (err) {
        _didIteratorError2 = true;
        _iteratorError2 = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion2 && _iterator2['return']) {
            _iterator2['return']();
          }
        } finally {
          if (_didIteratorError2) {
            throw _iteratorError2;
          }
        }
      }

      return errors;
    }

    (0, _jsutilsInvariant2['default'])(type instanceof _typeDefinition.GraphQLScalarType || type instanceof _typeDefinition.GraphQLEnumType, 'Must be input type');

    // Scalar/Enum input checks to ensure the type can parse the value to
    // a non-null value.
    var parseResult = type.parseLiteral(valueAST);
    if ((0, _jsutilsIsNullish2['default'])(parseResult)) {
      return ['Expected type "' + type.name + '", found ' + (0, _languagePrinter.print)(valueAST) + '.'];
    }

    return [];
  }
}

},{"../jsutils/invariant":214,"../jsutils/isNullish":215,"../jsutils/keyMap":216,"../language/kinds":218,"../language/printer":222,"../type/definition":328,"babel-runtime/core-js/get-iterator":226,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/interop-require-default":242,"babel-runtime/helpers/to-consumable-array":245}],337:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Provided two types, return true if the types are equal (invariant).
 */
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.isEqualType = isEqualType;
exports.isTypeSubTypeOf = isTypeSubTypeOf;

var _typeDefinition = require('../type/definition');

function isEqualType(_x, _x2) {
  var _again = true;

  _function: while (_again) {
    var typeA = _x,
        typeB = _x2;
    _again = false;

    // Equivalent types are equal.
    if (typeA === typeB) {
      return true;
    }

    // If either type is non-null, the other must also be non-null.
    if (typeA instanceof _typeDefinition.GraphQLNonNull && typeB instanceof _typeDefinition.GraphQLNonNull) {
      _x = typeA.ofType;
      _x2 = typeB.ofType;
      _again = true;
      continue _function;
    }

    // If either type is a list, the other must also be a list.
    if (typeA instanceof _typeDefinition.GraphQLList && typeB instanceof _typeDefinition.GraphQLList) {
      _x = typeA.ofType;
      _x2 = typeB.ofType;
      _again = true;
      continue _function;
    }

    // Otherwise the types are not equal.
    return false;
  }
}

/**
 * Provided a type and a super type, return true if the first type is either
 * equal or a subset of the second super type (covariant).
 */

function isTypeSubTypeOf(_x3, _x4) {
  var _again2 = true;

  _function2: while (_again2) {
    var maybeSubType = _x3,
        superType = _x4;
    _again2 = false;

    // Equivalent type is a valid subtype
    if (maybeSubType === superType) {
      return true;
    }

    // If superType is non-null, maybeSubType must also be nullable.
    if (superType instanceof _typeDefinition.GraphQLNonNull) {
      if (maybeSubType instanceof _typeDefinition.GraphQLNonNull) {
        _x3 = maybeSubType.ofType;
        _x4 = superType.ofType;
        _again2 = true;
        continue _function2;
      }
      return false;
    } else if (maybeSubType instanceof _typeDefinition.GraphQLNonNull) {
      // If superType is nullable, maybeSubType may be non-null.
      _x3 = maybeSubType.ofType;
      _x4 = superType;
      _again2 = true;
      continue _function2;
    }

    // If superType type is a list, maybeSubType type must also be a list.
    if (superType instanceof _typeDefinition.GraphQLList) {
      if (maybeSubType instanceof _typeDefinition.GraphQLList) {
        _x3 = maybeSubType.ofType;
        _x4 = superType.ofType;
        _again2 = true;
        continue _function2;
      }
      return false;
    } else if (maybeSubType instanceof _typeDefinition.GraphQLList) {
      // If superType is not a list, maybeSubType must also be not a list.
      return false;
    }

    // If superType type is an abstract type, maybeSubType type may be a currently
    // possible object type.
    if ((0, _typeDefinition.isAbstractType)(superType) && maybeSubType instanceof _typeDefinition.GraphQLObjectType && superType.isPossibleType(maybeSubType)) {
      return true;
    }

    // Otherwise, the child type is not a valid subtype of the parent type.
    return false;
  }
}

},{"../type/definition":328}],338:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.typeFromAST = typeFromAST;

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _languageKinds = require('../language/kinds');

var _typeDefinition = require('../type/definition');

function typeFromAST(schema, inputTypeAST) {
  var innerType;
  if (inputTypeAST.kind === _languageKinds.LIST_TYPE) {
    innerType = typeFromAST(schema, inputTypeAST.type);
    return innerType && new _typeDefinition.GraphQLList(innerType);
  }
  if (inputTypeAST.kind === _languageKinds.NON_NULL_TYPE) {
    innerType = typeFromAST(schema, inputTypeAST.type);
    return innerType && new _typeDefinition.GraphQLNonNull(innerType);
  }
  (0, _jsutilsInvariant2['default'])(inputTypeAST.kind === _languageKinds.NAMED_TYPE, 'Must be a named type.');
  return schema.getType(inputTypeAST.name.value);
}

},{"../jsutils/invariant":214,"../language/kinds":218,"../type/definition":328,"babel-runtime/helpers/interop-require-default":242}],339:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 * Produces a JavaScript value given a GraphQL Value AST.
 *
 * A GraphQL type must be provided, which will be used to interpret different
 * GraphQL Value literals.
 *
 * | GraphQL Value        | JSON Value    |
 * | -------------------- | ------------- |
 * | Input Object         | Object        |
 * | List                 | Array         |
 * | Boolean              | Boolean       |
 * | String / Enum Value  | String        |
 * | Int / Float          | Number        |
 *
 */
'use strict';

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

var _interopRequireWildcard = require('babel-runtime/helpers/interop-require-wildcard')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.valueFromAST = valueFromAST;

var _jsutilsKeyMap = require('../jsutils/keyMap');

var _jsutilsKeyMap2 = _interopRequireDefault(_jsutilsKeyMap);

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _jsutilsIsNullish = require('../jsutils/isNullish');

var _jsutilsIsNullish2 = _interopRequireDefault(_jsutilsIsNullish);

var _languageKinds = require('../language/kinds');

var Kind = _interopRequireWildcard(_languageKinds);

var _typeDefinition = require('../type/definition');

function valueFromAST(_x, _x2, _x3) {
  var _again = true;

  _function: while (_again) {
    var valueAST = _x,
        type = _x2,
        variables = _x3;
    nullableType = variableName = itemType = fields = fieldASTs = parsed = undefined;
    _again = false;

    if (type instanceof _typeDefinition.GraphQLNonNull) {
      var nullableType = type.ofType;
      // Note: we're not checking that the result of valueFromAST is non-null.
      // We're assuming that this query has been validated and the value used
      // here is of the correct type.
      _x = valueAST;
      _x2 = nullableType;
      _x3 = variables;
      _again = true;
      continue _function;
    }

    if (!valueAST) {
      return null;
    }

    if (valueAST.kind === Kind.VARIABLE) {
      var variableName = valueAST.name.value;
      if (!variables || !variables.hasOwnProperty(variableName)) {
        return null;
      }
      // Note: we're not doing any checking that this variable is correct. We're
      // assuming that this query has been validated and the variable usage here
      // is of the correct type.
      return variables[variableName];
    }

    if (type instanceof _typeDefinition.GraphQLList) {
      var itemType = type.ofType;
      if (valueAST.kind === Kind.LIST) {
        return valueAST.values.map(function (itemAST) {
          return valueFromAST(itemAST, itemType, variables);
        });
      }
      return [valueFromAST(valueAST, itemType, variables)];
    }

    if (type instanceof _typeDefinition.GraphQLInputObjectType) {
      var fields = type.getFields();
      if (valueAST.kind !== Kind.OBJECT) {
        return null;
      }
      var fieldASTs = (0, _jsutilsKeyMap2['default'])(valueAST.fields, function (field) {
        return field.name.value;
      });
      return _Object$keys(fields).reduce(function (obj, fieldName) {
        var field = fields[fieldName];
        var fieldAST = fieldASTs[fieldName];
        var fieldValue = valueFromAST(fieldAST && fieldAST.value, field.type, variables);
        if ((0, _jsutilsIsNullish2['default'])(fieldValue)) {
          fieldValue = field.defaultValue;
        }
        if (!(0, _jsutilsIsNullish2['default'])(fieldValue)) {
          obj[fieldName] = fieldValue;
        }
        return obj;
      }, {});
    }

    (0, _jsutilsInvariant2['default'])(type instanceof _typeDefinition.GraphQLScalarType || type instanceof _typeDefinition.GraphQLEnumType, 'Must be input type');

    var parsed = type.parseLiteral(valueAST);
    if (!(0, _jsutilsIsNullish2['default'])(parsed)) {
      return parsed;
    }
  }
}

},{"../jsutils/invariant":214,"../jsutils/isNullish":215,"../jsutils/keyMap":216,"../language/kinds":218,"../type/definition":328,"babel-runtime/core-js/object/keys":233,"babel-runtime/helpers/interop-require-default":242,"babel-runtime/helpers/interop-require-wildcard":243}],340:[function(require,module,exports){
/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _validate = require('./validate');

Object.defineProperty(exports, 'validate', {
  enumerable: true,
  get: function get() {
    return _validate.validate;
  }
});

var _specifiedRules = require('./specifiedRules');

Object.defineProperty(exports, 'specifiedRules', {
  enumerable: true,
  get: function get() {
    return _specifiedRules.specifiedRules;
  }
});

},{"./specifiedRules":364,"./validate":365}],341:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.badValueMessage = badValueMessage;
exports.ArgumentsOfCorrectType = ArgumentsOfCorrectType;

var _error = require('../../error');

var _languagePrinter = require('../../language/printer');

var _utilitiesIsValidLiteralValue = require('../../utilities/isValidLiteralValue');

function badValueMessage(argName, type, value, verboseErrors) {
  var message = verboseErrors ? '\n' + verboseErrors.join('\n') : '';
  return 'Argument "' + argName + '" has invalid value ' + value + '.' + message;
}

/**
 * Argument values of correct type
 *
 * A GraphQL document is only valid if all field argument literal values are
 * of the type expected by their position.
 */

function ArgumentsOfCorrectType(context) {
  return {
    Argument: function Argument(argAST) {
      var argDef = context.getArgument();
      if (argDef) {
        var errors = (0, _utilitiesIsValidLiteralValue.isValidLiteralValue)(argDef.type, argAST.value);
        if (errors && errors.length > 0) {
          context.reportError(new _error.GraphQLError(badValueMessage(argAST.name.value, argDef.type, (0, _languagePrinter.print)(argAST.value), errors), [argAST.value]));
        }
      }
      return false;
    }
  };
}

},{"../../error":205,"../../language/printer":222,"../../utilities/isValidLiteralValue":336}],342:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.defaultForNonNullArgMessage = defaultForNonNullArgMessage;
exports.badValueForDefaultArgMessage = badValueForDefaultArgMessage;
exports.DefaultValuesOfCorrectType = DefaultValuesOfCorrectType;

var _error = require('../../error');

var _languagePrinter = require('../../language/printer');

var _typeDefinition = require('../../type/definition');

var _utilitiesIsValidLiteralValue = require('../../utilities/isValidLiteralValue');

function defaultForNonNullArgMessage(varName, type, guessType) {
  return 'Variable "$' + varName + '" of type "' + type + '" is required and will not ' + ('use the default value. Perhaps you meant to use type "' + guessType + '".');
}

function badValueForDefaultArgMessage(varName, type, value, verboseErrors) {
  var message = verboseErrors ? '\n' + verboseErrors.join('\n') : '';
  return 'Variable "$' + varName + ' has invalid default value ' + value + '.' + message;
}

/**
 * Variable default values of correct type
 *
 * A GraphQL document is only valid if all variable default values are of the
 * type expected by their definition.
 */

function DefaultValuesOfCorrectType(context) {
  return {
    VariableDefinition: function VariableDefinition(varDefAST) {
      var name = varDefAST.variable.name.value;
      var defaultValue = varDefAST.defaultValue;
      var type = context.getInputType();
      if (type instanceof _typeDefinition.GraphQLNonNull && defaultValue) {
        context.reportError(new _error.GraphQLError(defaultForNonNullArgMessage(name, type, type.ofType), [defaultValue]));
      }
      if (type && defaultValue) {
        var errors = (0, _utilitiesIsValidLiteralValue.isValidLiteralValue)(type, defaultValue);
        if (errors && errors.length > 0) {
          context.reportError(new _error.GraphQLError(badValueForDefaultArgMessage(name, type, (0, _languagePrinter.print)(defaultValue), errors), [defaultValue]));
        }
      }
      return false;
    },
    SelectionSet: function SelectionSet() {
      return false;
    },
    FragmentDefinition: function FragmentDefinition() {
      return false;
    }
  };
}

},{"../../error":205,"../../language/printer":222,"../../type/definition":328,"../../utilities/isValidLiteralValue":336}],343:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.undefinedFieldMessage = undefinedFieldMessage;
exports.FieldsOnCorrectType = FieldsOnCorrectType;

var _error = require('../../error');

function undefinedFieldMessage(fieldName, type) {
  return 'Cannot query field "' + fieldName + '" on "' + type + '".';
}

/**
 * Fields on correct type
 *
 * A GraphQL document is only valid if all fields selected are defined by the
 * parent type, or are an allowed meta field such as __typenamme
 */

function FieldsOnCorrectType(context) {
  return {
    Field: function Field(node) {
      var type = context.getParentType();
      if (type) {
        var fieldDef = context.getFieldDef();
        if (!fieldDef) {
          context.reportError(new _error.GraphQLError(undefinedFieldMessage(node.name.value, type.name), [node]));
        }
      }
    }
  };
}

},{"../../error":205}],344:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.inlineFragmentOnNonCompositeErrorMessage = inlineFragmentOnNonCompositeErrorMessage;
exports.fragmentOnNonCompositeErrorMessage = fragmentOnNonCompositeErrorMessage;
exports.FragmentsOnCompositeTypes = FragmentsOnCompositeTypes;

var _error = require('../../error');

var _languagePrinter = require('../../language/printer');

var _typeDefinition = require('../../type/definition');

function inlineFragmentOnNonCompositeErrorMessage(type) {
  return 'Fragment cannot condition on non composite type "' + type + '".';
}

function fragmentOnNonCompositeErrorMessage(fragName, type) {
  return 'Fragment "' + fragName + '" cannot condition on non composite ' + ('type "' + type + '".');
}

/**
 * Fragments on composite type
 *
 * Fragments use a type condition to determine if they apply, since fragments
 * can only be spread into a composite type (object, interface, or union), the
 * type condition must also be a composite type.
 */

function FragmentsOnCompositeTypes(context) {
  return {
    InlineFragment: function InlineFragment(node) {
      var type = context.getType();
      if (node.typeCondition && type && !(0, _typeDefinition.isCompositeType)(type)) {
        context.reportError(new _error.GraphQLError(inlineFragmentOnNonCompositeErrorMessage((0, _languagePrinter.print)(node.typeCondition)), [node.typeCondition]));
      }
    },
    FragmentDefinition: function FragmentDefinition(node) {
      var type = context.getType();
      if (type && !(0, _typeDefinition.isCompositeType)(type)) {
        context.reportError(new _error.GraphQLError(fragmentOnNonCompositeErrorMessage(node.name.value, (0, _languagePrinter.print)(node.typeCondition)), [node.typeCondition]));
      }
    }
  };
}

},{"../../error":205,"../../language/printer":222,"../../type/definition":328}],345:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.unknownArgMessage = unknownArgMessage;
exports.unknownDirectiveArgMessage = unknownDirectiveArgMessage;
exports.KnownArgumentNames = KnownArgumentNames;

var _error = require('../../error');

var _jsutilsFind = require('../../jsutils/find');

var _jsutilsFind2 = _interopRequireDefault(_jsutilsFind);

var _jsutilsInvariant = require('../../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _languageKinds = require('../../language/kinds');

function unknownArgMessage(argName, fieldName, type) {
  return 'Unknown argument "' + argName + '" on field "' + fieldName + '" of ' + ('type "' + type + '".');
}

function unknownDirectiveArgMessage(argName, directiveName) {
  return 'Unknown argument "' + argName + '" on directive "@' + directiveName + '".';
}

/**
 * Known argument names
 *
 * A GraphQL field is only valid if all supplied arguments are defined by
 * that field.
 */

function KnownArgumentNames(context) {
  return {
    Argument: function Argument(node, key, parent, path, ancestors) {
      var argumentOf = ancestors[ancestors.length - 1];
      if (argumentOf.kind === _languageKinds.FIELD) {
        var fieldDef = context.getFieldDef();
        if (fieldDef) {
          var fieldArgDef = (0, _jsutilsFind2['default'])(fieldDef.args, function (arg) {
            return arg.name === node.name.value;
          });
          if (!fieldArgDef) {
            var parentType = context.getParentType();
            (0, _jsutilsInvariant2['default'])(parentType);
            context.reportError(new _error.GraphQLError(unknownArgMessage(node.name.value, fieldDef.name, parentType.name), [node]));
          }
        }
      } else if (argumentOf.kind === _languageKinds.DIRECTIVE) {
        var directive = context.getDirective();
        if (directive) {
          var directiveArgDef = (0, _jsutilsFind2['default'])(directive.args, function (arg) {
            return arg.name === node.name.value;
          });
          if (!directiveArgDef) {
            context.reportError(new _error.GraphQLError(unknownDirectiveArgMessage(node.name.value, directive.name), [node]));
          }
        }
      }
    }
  };
}

},{"../../error":205,"../../jsutils/find":213,"../../jsutils/invariant":214,"../../language/kinds":218,"babel-runtime/helpers/interop-require-default":242}],346:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.unknownDirectiveMessage = unknownDirectiveMessage;
exports.misplacedDirectiveMessage = misplacedDirectiveMessage;
exports.KnownDirectives = KnownDirectives;

var _error = require('../../error');

var _jsutilsFind = require('../../jsutils/find');

var _jsutilsFind2 = _interopRequireDefault(_jsutilsFind);

var _languageKinds = require('../../language/kinds');

function unknownDirectiveMessage(directiveName) {
  return 'Unknown directive "' + directiveName + '".';
}

function misplacedDirectiveMessage(directiveName, placement) {
  return 'Directive "' + directiveName + '" may not be used on "' + placement + '".';
}

/**
 * Known directives
 *
 * A GraphQL document is only valid if all `@directives` are known by the
 * schema and legally positioned.
 */

function KnownDirectives(context) {
  return {
    Directive: function Directive(node, key, parent, path, ancestors) {
      var directiveDef = (0, _jsutilsFind2['default'])(context.getSchema().getDirectives(), function (def) {
        return def.name === node.name.value;
      });
      if (!directiveDef) {
        context.reportError(new _error.GraphQLError(unknownDirectiveMessage(node.name.value), [node]));
        return;
      }
      var appliedTo = ancestors[ancestors.length - 1];
      switch (appliedTo.kind) {
        case _languageKinds.OPERATION_DEFINITION:
          if (!directiveDef.onOperation) {
            context.reportError(new _error.GraphQLError(misplacedDirectiveMessage(node.name.value, 'operation'), [node]));
          }
          break;
        case _languageKinds.FIELD:
          if (!directiveDef.onField) {
            context.reportError(new _error.GraphQLError(misplacedDirectiveMessage(node.name.value, 'field'), [node]));
          }
          break;
        case _languageKinds.FRAGMENT_SPREAD:
        case _languageKinds.INLINE_FRAGMENT:
        case _languageKinds.FRAGMENT_DEFINITION:
          if (!directiveDef.onFragment) {
            context.reportError(new _error.GraphQLError(misplacedDirectiveMessage(node.name.value, 'fragment'), [node]));
          }
          break;
      }
    }
  };
}

},{"../../error":205,"../../jsutils/find":213,"../../language/kinds":218,"babel-runtime/helpers/interop-require-default":242}],347:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.unknownFragmentMessage = unknownFragmentMessage;
exports.KnownFragmentNames = KnownFragmentNames;

var _error = require('../../error');

function unknownFragmentMessage(fragName) {
  return 'Unknown fragment "' + fragName + '".';
}

/**
 * Known fragment names
 *
 * A GraphQL document is only valid if all `...Fragment` fragment spreads refer
 * to fragments defined in the same document.
 */

function KnownFragmentNames(context) {
  return {
    FragmentSpread: function FragmentSpread(node) {
      var fragmentName = node.name.value;
      var fragment = context.getFragment(fragmentName);
      if (!fragment) {
        context.reportError(new _error.GraphQLError(unknownFragmentMessage(fragmentName), [node.name]));
      }
    }
  };
}

},{"../../error":205}],348:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.unknownTypeMessage = unknownTypeMessage;
exports.KnownTypeNames = KnownTypeNames;

var _error = require('../../error');

function unknownTypeMessage(type) {
  return 'Unknown type "' + type + '".';
}

/**
 * Known type names
 *
 * A GraphQL document is only valid if referenced types (specifically
 * variable definitions and fragment conditions) are defined by the type schema.
 */

function KnownTypeNames(context) {
  return {
    // TODO: when validating IDL, re-enable these. Experimental version does not
    // add unreferenced types, resulting in false-positive errors. Squelched
    // errors for now.
    ObjectTypeDefinition: function ObjectTypeDefinition() {
      return false;
    },
    InterfaceTypeDefinition: function InterfaceTypeDefinition() {
      return false;
    },
    UnionTypeDefinition: function UnionTypeDefinition() {
      return false;
    },
    InputObjectTypeDefinition: function InputObjectTypeDefinition() {
      return false;
    },
    NamedType: function NamedType(node) {
      var typeName = node.name.value;
      var type = context.getSchema().getType(typeName);
      if (!type) {
        context.reportError(new _error.GraphQLError(unknownTypeMessage(typeName), [node]));
      }
    }
  };
}

},{"../../error":205}],349:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.anonOperationNotAloneMessage = anonOperationNotAloneMessage;
exports.LoneAnonymousOperation = LoneAnonymousOperation;

var _error = require('../../error');

var _languageKinds = require('../../language/kinds');

function anonOperationNotAloneMessage() {
  return 'This anonymous operation must be the only defined operation.';
}

/**
 * Lone anonymous operation
 *
 * A GraphQL document is only valid if when it contains an anonymous operation
 * (the query short-hand) that it contains only that one operation definition.
 */

function LoneAnonymousOperation(context) {
  var operationCount = 0;
  return {
    Document: function Document(node) {
      operationCount = node.definitions.filter(function (definition) {
        return definition.kind === _languageKinds.OPERATION_DEFINITION;
      }).length;
    },
    OperationDefinition: function OperationDefinition(node) {
      if (!node.name && operationCount > 1) {
        context.reportError(new _error.GraphQLError(anonOperationNotAloneMessage(), [node]));
      }
    }
  };
}

},{"../../error":205,"../../language/kinds":218}],350:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.cycleErrorMessage = cycleErrorMessage;
exports.NoFragmentCycles = NoFragmentCycles;

var _error = require('../../error');

function cycleErrorMessage(fragName, spreadNames) {
  var via = spreadNames.length ? ' via ' + spreadNames.join(', ') : '';
  return 'Cannot spread fragment "' + fragName + '" within itself' + via + '.';
}

function NoFragmentCycles(context) {
  // Tracks already visited fragments to maintain O(N) and to ensure that cycles
  // are not redundantly reported.
  var visitedFrags = _Object$create(null);

  // Array of AST nodes used to produce meaningful errors
  var spreadPath = [];

  // Position in the spread path
  var spreadPathIndexByName = _Object$create(null);

  return {
    OperationDefinition: function OperationDefinition() {
      return false;
    },
    FragmentDefinition: function FragmentDefinition(node) {
      if (!visitedFrags[node.name.value]) {
        detectCycleRecursive(node);
      }
      return false;
    }
  };

  // This does a straight-forward DFS to find cycles.
  // It does not terminate when a cycle was found but continues to explore
  // the graph to find all possible cycles.
  function detectCycleRecursive(fragment) {
    var fragmentName = fragment.name.value;
    visitedFrags[fragmentName] = true;

    var spreadNodes = context.getFragmentSpreads(fragment);
    if (spreadNodes.length === 0) {
      return;
    }

    spreadPathIndexByName[fragmentName] = spreadPath.length;

    for (var i = 0; i < spreadNodes.length; i++) {
      var spreadNode = spreadNodes[i];
      var spreadName = spreadNode.name.value;
      var cycleIndex = spreadPathIndexByName[spreadName];

      if (cycleIndex === undefined) {
        spreadPath.push(spreadNode);
        if (!visitedFrags[spreadName]) {
          var spreadFragment = context.getFragment(spreadName);
          if (spreadFragment) {
            detectCycleRecursive(spreadFragment);
          }
        }
        spreadPath.pop();
      } else {
        var cyclePath = spreadPath.slice(cycleIndex);
        context.reportError(new _error.GraphQLError(cycleErrorMessage(spreadName, cyclePath.map(function (s) {
          return s.name.value;
        })), cyclePath.concat(spreadNode)));
      }
    }

    spreadPathIndexByName[fragmentName] = undefined;
  }
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],351:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.undefinedVarMessage = undefinedVarMessage;
exports.NoUndefinedVariables = NoUndefinedVariables;

var _error = require('../../error');

function undefinedVarMessage(varName, opName) {
  return opName ? 'Variable "$' + varName + '" is not defined by operation "' + opName + '".' : 'Variable "$' + varName + '" is not defined.';
}

/**
 * No undefined variables
 *
 * A GraphQL operation is only valid if all variables encountered, both directly
 * and via fragment spreads, are defined by that operation.
 */

function NoUndefinedVariables(context) {
  var variableNameDefined = _Object$create(null);

  return {
    OperationDefinition: {
      enter: function enter() {
        variableNameDefined = _Object$create(null);
      },
      leave: function leave(operation) {
        var usages = context.getRecursiveVariableUsages(operation);

        usages.forEach(function (_ref) {
          var node = _ref.node;

          var varName = node.name.value;
          if (variableNameDefined[varName] !== true) {
            context.reportError(new _error.GraphQLError(undefinedVarMessage(varName, operation.name && operation.name.value), [node, operation]));
          }
        });
      }
    },
    VariableDefinition: function VariableDefinition(varDefAST) {
      variableNameDefined[varDefAST.variable.name.value] = true;
    }
  };
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],352:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.unusedFragMessage = unusedFragMessage;
exports.NoUnusedFragments = NoUnusedFragments;

var _error = require('../../error');

function unusedFragMessage(fragName) {
  return 'Fragment "' + fragName + '" is never used.';
}

/**
 * No unused fragments
 *
 * A GraphQL document is only valid if all fragment definitions are spread
 * within operations, or spread within other fragments spread within operations.
 */

function NoUnusedFragments(context) {
  var operationDefs = [];
  var fragmentDefs = [];

  return {
    OperationDefinition: function OperationDefinition(node) {
      operationDefs.push(node);
      return false;
    },
    FragmentDefinition: function FragmentDefinition(node) {
      fragmentDefs.push(node);
      return false;
    },
    Document: {
      leave: function leave() {
        var fragmentNameUsed = _Object$create(null);
        operationDefs.forEach(function (operation) {
          context.getRecursivelyReferencedFragments(operation).forEach(function (fragment) {
            fragmentNameUsed[fragment.name.value] = true;
          });
        });

        fragmentDefs.forEach(function (fragmentDef) {
          var fragName = fragmentDef.name.value;
          if (fragmentNameUsed[fragName] !== true) {
            context.reportError(new _error.GraphQLError(unusedFragMessage(fragName), [fragmentDef]));
          }
        });
      }
    }
  };
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],353:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.unusedVariableMessage = unusedVariableMessage;
exports.NoUnusedVariables = NoUnusedVariables;

var _error = require('../../error');

function unusedVariableMessage(varName) {
  return 'Variable "$' + varName + '" is never used.';
}

/**
 * No unused variables
 *
 * A GraphQL operation is only valid if all variables defined by an operation
 * are used, either directly or within a spread fragment.
 */

function NoUnusedVariables(context) {
  var variableDefs = [];

  return {
    OperationDefinition: {
      enter: function enter() {
        variableDefs = [];
      },
      leave: function leave(operation) {
        var variableNameUsed = _Object$create(null);
        var usages = context.getRecursiveVariableUsages(operation);

        usages.forEach(function (_ref) {
          var node = _ref.node;

          variableNameUsed[node.name.value] = true;
        });

        variableDefs.forEach(function (variableDef) {
          var variableName = variableDef.variable.name.value;
          if (variableNameUsed[variableName] !== true) {
            context.reportError(new _error.GraphQLError(unusedVariableMessage(variableName), [variableDef]));
          }
        });
      }
    },
    VariableDefinition: function VariableDefinition(def) {
      variableDefs.push(def);
    }
  };
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],354:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _createClass = require('babel-runtime/helpers/create-class')['default'];

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

var _slicedToArray = require('babel-runtime/helpers/sliced-to-array')['default'];

var _Object$keys = require('babel-runtime/core-js/object/keys')['default'];

var _Map = require('babel-runtime/core-js/map')['default'];

var _Set = require('babel-runtime/core-js/set')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.fieldsConflictMessage = fieldsConflictMessage;
exports.OverlappingFieldsCanBeMerged = OverlappingFieldsCanBeMerged;

// Field name and reason.

// Reason is a string, or a nested list of conflicts.

var _error = require('../../error');

var _jsutilsFind = require('../../jsutils/find');

var _jsutilsFind2 = _interopRequireDefault(_jsutilsFind);

var _languageKinds = require('../../language/kinds');

var _languagePrinter = require('../../language/printer');

var _typeDefinition = require('../../type/definition');

var _utilitiesTypeComparators = require('../../utilities/typeComparators');

var _utilitiesTypeFromAST = require('../../utilities/typeFromAST');

function fieldsConflictMessage(responseName, reason) {
  return 'Fields "' + responseName + '" conflict because ' + reasonMessage(reason) + '.';
}

function reasonMessage(reason) {
  if (Array.isArray(reason)) {
    return reason.map(function (_ref) {
      var _ref2 = _slicedToArray(_ref, 2);

      var responseName = _ref2[0];
      var subreason = _ref2[1];
      return 'subfields "' + responseName + '" conflict because ' + reasonMessage(subreason);
    }).join(' and ');
  }
  return reason;
}

/**
 * Overlapping fields can be merged
 *
 * A selection set is only valid if all fields (including spreading any
 * fragments) either correspond to distinct response names or can be merged
 * without ambiguity.
 */

function OverlappingFieldsCanBeMerged(context) {
  var comparedSet = new PairSet();

  function findConflicts(fieldMap) {
    var conflicts = [];
    _Object$keys(fieldMap).forEach(function (responseName) {
      var fields = fieldMap[responseName];
      if (fields.length > 1) {
        for (var i = 0; i < fields.length; i++) {
          for (var j = i; j < fields.length; j++) {
            var conflict = findConflict(responseName, fields[i], fields[j]);
            if (conflict) {
              conflicts.push(conflict);
            }
          }
        }
      }
    });
    return conflicts;
  }

  function findConflict(responseName, field1, field2) {
    var _field1 = _slicedToArray(field1, 3);

    var parentType1 = _field1[0];
    var ast1 = _field1[1];
    var def1 = _field1[2];

    var _field2 = _slicedToArray(field2, 3);

    var parentType2 = _field2[0];
    var ast2 = _field2[1];
    var def2 = _field2[2];

    // Not a pair.
    if (ast1 === ast2) {
      return;
    }

    // If the statically known parent types could not possibly apply at the same
    // time, then it is safe to permit them to diverge as they will not present
    // any ambiguity by differing.
    // It is known that two parent types could never overlap if they are
    // different Object types. Interface or Union types might overlap - if not
    // in the current state of the schema, then perhaps in some future version,
    // thus may not safely diverge.
    if (parentType1 !== parentType2 && parentType1 instanceof _typeDefinition.GraphQLObjectType && parentType2 instanceof _typeDefinition.GraphQLObjectType) {
      return;
    }

    // Memoize, do not report the same issue twice.
    if (comparedSet.has(ast1, ast2)) {
      return;
    }
    comparedSet.add(ast1, ast2);

    var name1 = ast1.name.value;
    var name2 = ast2.name.value;
    if (name1 !== name2) {
      return [[responseName, name1 + ' and ' + name2 + ' are different fields'], [ast1], [ast2]];
    }

    var type1 = def1 && def1.type;
    var type2 = def2 && def2.type;
    if (type1 && type2 && !(0, _utilitiesTypeComparators.isEqualType)(type1, type2)) {
      return [[responseName, 'they return differing types ' + type1 + ' and ' + type2], [ast1], [ast2]];
    }

    if (!sameArguments(ast1.arguments || [], ast2.arguments || [])) {
      return [[responseName, 'they have differing arguments'], [ast1], [ast2]];
    }

    var selectionSet1 = ast1.selectionSet;
    var selectionSet2 = ast2.selectionSet;
    if (selectionSet1 && selectionSet2) {
      var visitedFragmentNames = {};
      var subfieldMap = collectFieldASTsAndDefs(context, (0, _typeDefinition.getNamedType)(type1), selectionSet1, visitedFragmentNames);
      subfieldMap = collectFieldASTsAndDefs(context, (0, _typeDefinition.getNamedType)(type2), selectionSet2, visitedFragmentNames, subfieldMap);
      var conflicts = findConflicts(subfieldMap);
      if (conflicts.length > 0) {
        return [[responseName, conflicts.map(function (_ref3) {
          var _ref32 = _slicedToArray(_ref3, 1);

          var reason = _ref32[0];
          return reason;
        })], conflicts.reduce(function (allFields, _ref4) {
          var _ref42 = _slicedToArray(_ref4, 2);

          var fields1 = _ref42[1];
          return allFields.concat(fields1);
        }, [ast1]), conflicts.reduce(function (allFields, _ref5) {
          var _ref52 = _slicedToArray(_ref5, 3);

          var fields2 = _ref52[2];
          return allFields.concat(fields2);
        }, [ast2])];
      }
    }
  }

  return {
    SelectionSet: {
      // Note: we validate on the reverse traversal so deeper conflicts will be
      // caught first, for clearer error messages.
      leave: function leave(selectionSet) {
        var fieldMap = collectFieldASTsAndDefs(context, context.getParentType(), selectionSet);
        var conflicts = findConflicts(fieldMap);
        conflicts.forEach(function (_ref6) {
          var _ref62 = _slicedToArray(_ref6, 3);

          var _ref62$0 = _slicedToArray(_ref62[0], 2);

          var responseName = _ref62$0[0];
          var reason = _ref62$0[1];
          var fields1 = _ref62[1];
          var fields2 = _ref62[2];
          return context.reportError(new _error.GraphQLError(fieldsConflictMessage(responseName, reason), fields1.concat(fields2)));
        });
      }
    }
  };
}

function sameArguments(arguments1, arguments2) {
  if (arguments1.length !== arguments2.length) {
    return false;
  }
  return arguments1.every(function (argument1) {
    var argument2 = (0, _jsutilsFind2['default'])(arguments2, function (argument) {
      return argument.name.value === argument1.name.value;
    });
    if (!argument2) {
      return false;
    }
    return sameValue(argument1.value, argument2.value);
  });
}

function sameValue(value1, value2) {
  return !value1 && !value2 || (0, _languagePrinter.print)(value1) === (0, _languagePrinter.print)(value2);
}

/**
 * Given a selectionSet, adds all of the fields in that selection to
 * the passed in map of fields, and returns it at the end.
 *
 * Note: This is not the same as execution's collectFields because at static
 * time we do not know what object type will be used, so we unconditionally
 * spread in all fragments.
 */
function collectFieldASTsAndDefs(context, parentType, selectionSet, visitedFragmentNames, astAndDefs) {
  var _visitedFragmentNames = visitedFragmentNames || {};
  var _astAndDefs = astAndDefs || {};
  for (var i = 0; i < selectionSet.selections.length; i++) {
    var selection = selectionSet.selections[i];
    switch (selection.kind) {
      case _languageKinds.FIELD:
        var fieldName = selection.name.value;
        var fieldDef;
        if (parentType instanceof _typeDefinition.GraphQLObjectType || parentType instanceof _typeDefinition.GraphQLInterfaceType) {
          fieldDef = parentType.getFields()[fieldName];
        }
        var responseName = selection.alias ? selection.alias.value : fieldName;
        if (!_astAndDefs[responseName]) {
          _astAndDefs[responseName] = [];
        }
        _astAndDefs[responseName].push([parentType, selection, fieldDef]);
        break;
      case _languageKinds.INLINE_FRAGMENT:
        var typeCondition = selection.typeCondition;
        var inlineFragmentType = typeCondition ? (0, _utilitiesTypeFromAST.typeFromAST)(context.getSchema(), selection.typeCondition) : parentType;
        _astAndDefs = collectFieldASTsAndDefs(context, inlineFragmentType, selection.selectionSet, _visitedFragmentNames, _astAndDefs);
        break;
      case _languageKinds.FRAGMENT_SPREAD:
        var fragName = selection.name.value;
        if (_visitedFragmentNames[fragName]) {
          continue;
        }
        _visitedFragmentNames[fragName] = true;
        var fragment = context.getFragment(fragName);
        if (!fragment) {
          continue;
        }
        var fragmentType = (0, _utilitiesTypeFromAST.typeFromAST)(context.getSchema(), fragment.typeCondition);
        _astAndDefs = collectFieldASTsAndDefs(context, fragmentType, fragment.selectionSet, _visitedFragmentNames, _astAndDefs);
        break;
    }
  }
  return _astAndDefs;
}

/**
 * A way to keep track of pairs of things when the ordering of the pair does
 * not matter. We do this by maintaining a sort of double adjacency sets.
 */

var PairSet = function () {
  function PairSet() {
    _classCallCheck(this, PairSet);

    this._data = new _Map();
  }

  _createClass(PairSet, [{
    key: 'has',
    value: function has(a, b) {
      var first = this._data.get(a);
      return first && first.has(b);
    }
  }, {
    key: 'add',
    value: function add(a, b) {
      _pairSetAdd(this._data, a, b);
      _pairSetAdd(this._data, b, a);
    }
  }]);

  return PairSet;
}();

function _pairSetAdd(data, a, b) {
  var set = data.get(a);
  if (!set) {
    set = new _Set();
    data.set(a, set);
  }
  set.add(b);
}

},{"../../error":205,"../../jsutils/find":213,"../../language/kinds":218,"../../language/printer":222,"../../type/definition":328,"../../utilities/typeComparators":337,"../../utilities/typeFromAST":338,"babel-runtime/core-js/map":228,"babel-runtime/core-js/object/keys":233,"babel-runtime/core-js/set":236,"babel-runtime/helpers/class-call-check":237,"babel-runtime/helpers/create-class":238,"babel-runtime/helpers/interop-require-default":242,"babel-runtime/helpers/sliced-to-array":244}],355:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.typeIncompatibleSpreadMessage = typeIncompatibleSpreadMessage;
exports.typeIncompatibleAnonSpreadMessage = typeIncompatibleAnonSpreadMessage;
exports.PossibleFragmentSpreads = PossibleFragmentSpreads;

var _error = require('../../error');

var _jsutilsKeyMap = require('../../jsutils/keyMap');

var _jsutilsKeyMap2 = _interopRequireDefault(_jsutilsKeyMap);

var _typeDefinition = require('../../type/definition');

var _utilitiesTypeFromAST = require('../../utilities/typeFromAST');

function typeIncompatibleSpreadMessage(fragName, parentType, fragType) {
  return 'Fragment "' + fragName + '" cannot be spread here as objects of ' + ('type "' + parentType + '" can never be of type "' + fragType + '".');
}

function typeIncompatibleAnonSpreadMessage(parentType, fragType) {
  return 'Fragment cannot be spread here as objects of ' + ('type "' + parentType + '" can never be of type "' + fragType + '".');
}

/**
 * Possible fragment spread
 *
 * A fragment spread is only valid if the type condition could ever possibly
 * be true: if there is a non-empty intersection of the possible parent types,
 * and possible types which pass the type condition.
 */

function PossibleFragmentSpreads(context) {
  return {
    InlineFragment: function InlineFragment(node) {
      var fragType = context.getType();
      var parentType = context.getParentType();
      if (fragType && parentType && !doTypesOverlap(fragType, parentType)) {
        context.reportError(new _error.GraphQLError(typeIncompatibleAnonSpreadMessage(parentType, fragType), [node]));
      }
    },
    FragmentSpread: function FragmentSpread(node) {
      var fragName = node.name.value;
      var fragType = getFragmentType(context, fragName);
      var parentType = context.getParentType();
      if (fragType && parentType && !doTypesOverlap(fragType, parentType)) {
        context.reportError(new _error.GraphQLError(typeIncompatibleSpreadMessage(fragName, parentType, fragType), [node]));
      }
    }
  };
}

function getFragmentType(context, name) {
  var frag = context.getFragment(name);
  return frag && (0, _utilitiesTypeFromAST.typeFromAST)(context.getSchema(), frag.typeCondition);
}

function doTypesOverlap(t1, t2) {
  if (t1 === t2) {
    return true;
  }
  if (t1 instanceof _typeDefinition.GraphQLObjectType) {
    if (t2 instanceof _typeDefinition.GraphQLObjectType) {
      return false;
    }
    return t2.getPossibleTypes().indexOf(t1) !== -1;
  }
  if (t1 instanceof _typeDefinition.GraphQLInterfaceType || t1 instanceof _typeDefinition.GraphQLUnionType) {
    if (t2 instanceof _typeDefinition.GraphQLObjectType) {
      return t1.getPossibleTypes().indexOf(t2) !== -1;
    }
    var t1TypeNames = (0, _jsutilsKeyMap2['default'])(t1.getPossibleTypes(), function (type) {
      return type.name;
    });
    return t2.getPossibleTypes().some(function (type) {
      return t1TypeNames[type.name];
    });
  }
}

},{"../../error":205,"../../jsutils/keyMap":216,"../../type/definition":328,"../../utilities/typeFromAST":338,"babel-runtime/helpers/interop-require-default":242}],356:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.missingFieldArgMessage = missingFieldArgMessage;
exports.missingDirectiveArgMessage = missingDirectiveArgMessage;
exports.ProvidedNonNullArguments = ProvidedNonNullArguments;

var _error = require('../../error');

var _jsutilsKeyMap = require('../../jsutils/keyMap');

var _jsutilsKeyMap2 = _interopRequireDefault(_jsutilsKeyMap);

var _typeDefinition = require('../../type/definition');

function missingFieldArgMessage(fieldName, argName, type) {
  return 'Field "' + fieldName + '" argument "' + argName + '" of type "' + type + '" ' + 'is required but not provided.';
}

function missingDirectiveArgMessage(directiveName, argName, type) {
  return 'Directive "@' + directiveName + '" argument "' + argName + '" of type ' + ('"' + type + '" is required but not provided.');
}

/**
 * Provided required arguments
 *
 * A field or directive is only valid if all required (non-null) field arguments
 * have been provided.
 */

function ProvidedNonNullArguments(context) {
  return {
    Field: {
      // Validate on leave to allow for deeper errors to appear first.
      leave: function leave(fieldAST) {
        var fieldDef = context.getFieldDef();
        if (!fieldDef) {
          return false;
        }
        var argASTs = fieldAST.arguments || [];

        var argASTMap = (0, _jsutilsKeyMap2['default'])(argASTs, function (arg) {
          return arg.name.value;
        });
        fieldDef.args.forEach(function (argDef) {
          var argAST = argASTMap[argDef.name];
          if (!argAST && argDef.type instanceof _typeDefinition.GraphQLNonNull) {
            context.reportError(new _error.GraphQLError(missingFieldArgMessage(fieldAST.name.value, argDef.name, argDef.type), [fieldAST]));
          }
        });
      }
    },

    Directive: {
      // Validate on leave to allow for deeper errors to appear first.
      leave: function leave(directiveAST) {
        var directiveDef = context.getDirective();
        if (!directiveDef) {
          return false;
        }
        var argASTs = directiveAST.arguments || [];

        var argASTMap = (0, _jsutilsKeyMap2['default'])(argASTs, function (arg) {
          return arg.name.value;
        });
        directiveDef.args.forEach(function (argDef) {
          var argAST = argASTMap[argDef.name];
          if (!argAST && argDef.type instanceof _typeDefinition.GraphQLNonNull) {
            context.reportError(new _error.GraphQLError(missingDirectiveArgMessage(directiveAST.name.value, argDef.name, argDef.type), [directiveAST]));
          }
        });
      }
    }
  };
}

},{"../../error":205,"../../jsutils/keyMap":216,"../../type/definition":328,"babel-runtime/helpers/interop-require-default":242}],357:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.noSubselectionAllowedMessage = noSubselectionAllowedMessage;
exports.requiredSubselectionMessage = requiredSubselectionMessage;
exports.ScalarLeafs = ScalarLeafs;

var _error = require('../../error');

var _typeDefinition = require('../../type/definition');

function noSubselectionAllowedMessage(field, type) {
  return 'Field "' + field + '" of type "' + type + '" must not have a sub selection.';
}

function requiredSubselectionMessage(field, type) {
  return 'Field "' + field + '" of type "' + type + '" must have a sub selection.';
}

/**
 * Scalar leafs
 *
 * A GraphQL document is valid only if all leaf fields (fields without
 * sub selections) are of scalar or enum types.
 */

function ScalarLeafs(context) {
  return {
    Field: function Field(node) {
      var type = context.getType();
      if (type) {
        if ((0, _typeDefinition.isLeafType)(type)) {
          if (node.selectionSet) {
            context.reportError(new _error.GraphQLError(noSubselectionAllowedMessage(node.name.value, type), [node.selectionSet]));
          }
        } else if (!node.selectionSet) {
          context.reportError(new _error.GraphQLError(requiredSubselectionMessage(node.name.value, type), [node]));
        }
      }
    }
  };
}

},{"../../error":205,"../../type/definition":328}],358:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.duplicateArgMessage = duplicateArgMessage;
exports.UniqueArgumentNames = UniqueArgumentNames;

var _error = require('../../error');

function duplicateArgMessage(argName) {
  return 'There can be only one argument named "' + argName + '".';
}

/**
 * Unique argument names
 *
 * A GraphQL field or directive is only valid if all supplied arguments are
 * uniquely named.
 */

function UniqueArgumentNames(context) {
  var knownArgNames = _Object$create(null);
  return {
    Field: function Field() {
      knownArgNames = _Object$create(null);
    },
    Directive: function Directive() {
      knownArgNames = _Object$create(null);
    },
    Argument: function Argument(node) {
      var argName = node.name.value;
      if (knownArgNames[argName]) {
        context.reportError(new _error.GraphQLError(duplicateArgMessage(argName), [knownArgNames[argName], node.name]));
      } else {
        knownArgNames[argName] = node.name;
      }
      return false;
    }
  };
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],359:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.duplicateFragmentNameMessage = duplicateFragmentNameMessage;
exports.UniqueFragmentNames = UniqueFragmentNames;

var _error = require('../../error');

function duplicateFragmentNameMessage(fragName) {
  return 'There can only be one fragment named "' + fragName + '".';
}

/**
 * Unique fragment names
 *
 * A GraphQL document is only valid if all defined fragments have unique names.
 */

function UniqueFragmentNames(context) {
  var knownFragmentNames = _Object$create(null);
  return {
    OperationDefinition: function OperationDefinition() {
      return false;
    },
    FragmentDefinition: function FragmentDefinition(node) {
      var fragmentName = node.name.value;
      if (knownFragmentNames[fragmentName]) {
        context.reportError(new _error.GraphQLError(duplicateFragmentNameMessage(fragmentName), [knownFragmentNames[fragmentName], node.name]));
      } else {
        knownFragmentNames[fragmentName] = node.name;
      }
      return false;
    }
  };
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],360:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.duplicateInputFieldMessage = duplicateInputFieldMessage;
exports.UniqueInputFieldNames = UniqueInputFieldNames;

var _error = require('../../error');

function duplicateInputFieldMessage(fieldName) {
  return 'There can be only one input field named "' + fieldName + '".';
}

/**
 * Unique input field names
 *
 * A GraphQL input object value is only valid if all supplied fields are
 * uniquely named.
 */

function UniqueInputFieldNames(context) {
  var knownNameStack = [];
  var knownNames = _Object$create(null);

  return {
    ObjectValue: {
      enter: function enter() {
        knownNameStack.push(knownNames);
        knownNames = _Object$create(null);
      },
      leave: function leave() {
        knownNames = knownNameStack.pop();
      }
    },
    ObjectField: function ObjectField(node) {
      var fieldName = node.name.value;
      if (knownNames[fieldName]) {
        context.reportError(new _error.GraphQLError(duplicateInputFieldMessage(fieldName), [knownNames[fieldName], node.name]));
      } else {
        knownNames[fieldName] = node.name;
      }
      return false;
    }
  };
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],361:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.duplicateOperationNameMessage = duplicateOperationNameMessage;
exports.UniqueOperationNames = UniqueOperationNames;

var _error = require('../../error');

function duplicateOperationNameMessage(operationName) {
  return 'There can only be one operation named "' + operationName + '".';
}

/**
 * Unique operation names
 *
 * A GraphQL document is only valid if all defined operations have unique names.
 */

function UniqueOperationNames(context) {
  var knownOperationNames = _Object$create(null);
  return {
    OperationDefinition: function OperationDefinition(node) {
      var operationName = node.name;
      if (operationName) {
        if (knownOperationNames[operationName.value]) {
          context.reportError(new _error.GraphQLError(duplicateOperationNameMessage(operationName.value), [knownOperationNames[operationName.value], operationName]));
        } else {
          knownOperationNames[operationName.value] = operationName;
        }
      }
      return false;
    },
    FragmentDefinition: function FragmentDefinition() {
      return false;
    }
  };
}

},{"../../error":205,"babel-runtime/core-js/object/create":230}],362:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.nonInputTypeOnVarMessage = nonInputTypeOnVarMessage;
exports.VariablesAreInputTypes = VariablesAreInputTypes;

var _error = require('../../error');

var _languagePrinter = require('../../language/printer');

var _typeDefinition = require('../../type/definition');

var _utilitiesTypeFromAST = require('../../utilities/typeFromAST');

function nonInputTypeOnVarMessage(variableName, typeName) {
  return 'Variable "$' + variableName + '" cannot be non-input type "' + typeName + '".';
}

/**
 * Variables are input types
 *
 * A GraphQL operation is only valid if all the variables it defines are of
 * input types (scalar, enum, or input object).
 */

function VariablesAreInputTypes(context) {
  return {
    VariableDefinition: function VariableDefinition(node) {
      var type = (0, _utilitiesTypeFromAST.typeFromAST)(context.getSchema(), node.type);

      // If the variable type is not an input type, return an error.
      if (type && !(0, _typeDefinition.isInputType)(type)) {
        var variableName = node.variable.name.value;
        context.reportError(new _error.GraphQLError(nonInputTypeOnVarMessage(variableName, (0, _languagePrinter.print)(node.type)), [node.type]));
      }
    }
  };
}

},{"../../error":205,"../../language/printer":222,"../../type/definition":328,"../../utilities/typeFromAST":338}],363:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.badVarPosMessage = badVarPosMessage;
exports.VariablesInAllowedPosition = VariablesInAllowedPosition;

var _error = require('../../error');

var _typeDefinition = require('../../type/definition');

var _utilitiesTypeComparators = require('../../utilities/typeComparators');

var _utilitiesTypeFromAST = require('../../utilities/typeFromAST');

function badVarPosMessage(varName, varType, expectedType) {
  return 'Variable "$' + varName + '" of type "' + varType + '" used in position ' + ('expecting type "' + expectedType + '".');
}

/**
 * Variables passed to field arguments conform to type
 */

function VariablesInAllowedPosition(context) {
  var varDefMap = _Object$create(null);

  return {
    OperationDefinition: {
      enter: function enter() {
        varDefMap = _Object$create(null);
      },
      leave: function leave(operation) {
        var usages = context.getRecursiveVariableUsages(operation);

        usages.forEach(function (_ref) {
          var node = _ref.node;
          var type = _ref.type;

          var varName = node.name.value;
          var varDef = varDefMap[varName];
          if (varDef && type) {
            // A var type is allowed if it is the same or more strict (e.g. is
            // a subtype of) than the expected type. It can be more strict if
            // the variable type is non-null when the expected type is nullable.
            // If both are list types, the variable item type can be more strict
            // than the expected item type (contravariant).
            var varType = (0, _utilitiesTypeFromAST.typeFromAST)(context.getSchema(), varDef.type);
            if (varType && !(0, _utilitiesTypeComparators.isTypeSubTypeOf)(effectiveType(varType, varDef), type)) {
              context.reportError(new _error.GraphQLError(badVarPosMessage(varName, varType, type), [varDef, node]));
            }
          }
        });
      }
    },
    VariableDefinition: function VariableDefinition(varDefAST) {
      varDefMap[varDefAST.variable.name.value] = varDefAST;
    }
  };
}

// If a variable definition has a default value, it's effectively non-null.
function effectiveType(varType, varDef) {
  return !varDef.defaultValue || varType instanceof _typeDefinition.GraphQLNonNull ? varType : new _typeDefinition.GraphQLNonNull(varType);
}

},{"../../error":205,"../../type/definition":328,"../../utilities/typeComparators":337,"../../utilities/typeFromAST":338,"babel-runtime/core-js/object/create":230}],364:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

// Spec Section: "Operation Name Uniqueness"
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _rulesUniqueOperationNames = require('./rules/UniqueOperationNames');

// Spec Section: "Lone Anonymous Operation"

var _rulesLoneAnonymousOperation = require('./rules/LoneAnonymousOperation');

// Spec Section: "Fragment Spread Type Existence"

var _rulesKnownTypeNames = require('./rules/KnownTypeNames');

// Spec Section: "Fragments on Composite Types"

var _rulesFragmentsOnCompositeTypes = require('./rules/FragmentsOnCompositeTypes');

// Spec Section: "Variables are Input Types"

var _rulesVariablesAreInputTypes = require('./rules/VariablesAreInputTypes');

// Spec Section: "Leaf Field Selections"

var _rulesScalarLeafs = require('./rules/ScalarLeafs');

// Spec Section: "Field Selections on Objects, Interfaces, and Unions Types"

var _rulesFieldsOnCorrectType = require('./rules/FieldsOnCorrectType');

// Spec Section: "Fragment Name Uniqueness"

var _rulesUniqueFragmentNames = require('./rules/UniqueFragmentNames');

// Spec Section: "Fragment spread target defined"

var _rulesKnownFragmentNames = require('./rules/KnownFragmentNames');

// Spec Section: "Fragments must be used"

var _rulesNoUnusedFragments = require('./rules/NoUnusedFragments');

// Spec Section: "Fragment spread is possible"

var _rulesPossibleFragmentSpreads = require('./rules/PossibleFragmentSpreads');

// Spec Section: "Fragments must not form cycles"

var _rulesNoFragmentCycles = require('./rules/NoFragmentCycles');

// Spec Section: "All Variable Used Defined"

var _rulesNoUndefinedVariables = require('./rules/NoUndefinedVariables');

// Spec Section: "All Variables Used"

var _rulesNoUnusedVariables = require('./rules/NoUnusedVariables');

// Spec Section: "Directives Are Defined"

var _rulesKnownDirectives = require('./rules/KnownDirectives');

// Spec Section: "Argument Names"

var _rulesKnownArgumentNames = require('./rules/KnownArgumentNames');

// Spec Section: "Argument Uniqueness"

var _rulesUniqueArgumentNames = require('./rules/UniqueArgumentNames');

// Spec Section: "Argument Values Type Correctness"

var _rulesArgumentsOfCorrectType = require('./rules/ArgumentsOfCorrectType');

// Spec Section: "Argument Optionality"

var _rulesProvidedNonNullArguments = require('./rules/ProvidedNonNullArguments');

// Spec Section: "Variable Default Values Are Correctly Typed"

var _rulesDefaultValuesOfCorrectType = require('./rules/DefaultValuesOfCorrectType');

// Spec Section: "All Variable Usages Are Allowed"

var _rulesVariablesInAllowedPosition = require('./rules/VariablesInAllowedPosition');

// Spec Section: "Field Selection Merging"

var _rulesOverlappingFieldsCanBeMerged = require('./rules/OverlappingFieldsCanBeMerged');

// Spec Section: "Input Object Field Uniqueness"

var _rulesUniqueInputFieldNames = require('./rules/UniqueInputFieldNames');

/**
 * This set includes all validation rules defined by the GraphQL spec.
 */
var specifiedRules = [_rulesUniqueOperationNames.UniqueOperationNames, _rulesLoneAnonymousOperation.LoneAnonymousOperation, _rulesKnownTypeNames.KnownTypeNames, _rulesFragmentsOnCompositeTypes.FragmentsOnCompositeTypes, _rulesVariablesAreInputTypes.VariablesAreInputTypes, _rulesScalarLeafs.ScalarLeafs, _rulesFieldsOnCorrectType.FieldsOnCorrectType, _rulesUniqueFragmentNames.UniqueFragmentNames, _rulesKnownFragmentNames.KnownFragmentNames, _rulesNoUnusedFragments.NoUnusedFragments, _rulesPossibleFragmentSpreads.PossibleFragmentSpreads, _rulesNoFragmentCycles.NoFragmentCycles, _rulesNoUndefinedVariables.NoUndefinedVariables, _rulesNoUnusedVariables.NoUnusedVariables, _rulesKnownDirectives.KnownDirectives, _rulesKnownArgumentNames.KnownArgumentNames, _rulesUniqueArgumentNames.UniqueArgumentNames, _rulesArgumentsOfCorrectType.ArgumentsOfCorrectType, _rulesProvidedNonNullArguments.ProvidedNonNullArguments, _rulesDefaultValuesOfCorrectType.DefaultValuesOfCorrectType, _rulesVariablesInAllowedPosition.VariablesInAllowedPosition, _rulesOverlappingFieldsCanBeMerged.OverlappingFieldsCanBeMerged, _rulesUniqueInputFieldNames.UniqueInputFieldNames];
exports.specifiedRules = specifiedRules;

},{"./rules/ArgumentsOfCorrectType":341,"./rules/DefaultValuesOfCorrectType":342,"./rules/FieldsOnCorrectType":343,"./rules/FragmentsOnCompositeTypes":344,"./rules/KnownArgumentNames":345,"./rules/KnownDirectives":346,"./rules/KnownFragmentNames":347,"./rules/KnownTypeNames":348,"./rules/LoneAnonymousOperation":349,"./rules/NoFragmentCycles":350,"./rules/NoUndefinedVariables":351,"./rules/NoUnusedFragments":352,"./rules/NoUnusedVariables":353,"./rules/OverlappingFieldsCanBeMerged":354,"./rules/PossibleFragmentSpreads":355,"./rules/ProvidedNonNullArguments":356,"./rules/ScalarLeafs":357,"./rules/UniqueArgumentNames":358,"./rules/UniqueFragmentNames":359,"./rules/UniqueInputFieldNames":360,"./rules/UniqueOperationNames":361,"./rules/VariablesAreInputTypes":362,"./rules/VariablesInAllowedPosition":363}],365:[function(require,module,exports){

/**
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

'use strict';

var _createClass = require('babel-runtime/helpers/create-class')['default'];

var _classCallCheck = require('babel-runtime/helpers/class-call-check')['default'];

var _Map = require('babel-runtime/core-js/map')['default'];

var _Object$create = require('babel-runtime/core-js/object/create')['default'];

var _interopRequireDefault = require('babel-runtime/helpers/interop-require-default')['default'];

var _interopRequireWildcard = require('babel-runtime/helpers/interop-require-wildcard')['default'];

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.validate = validate;
exports.visitUsingRules = visitUsingRules;

var _jsutilsInvariant = require('../jsutils/invariant');

var _jsutilsInvariant2 = _interopRequireDefault(_jsutilsInvariant);

var _error = require('../error');

var _languageVisitor = require('../language/visitor');

var _languageKinds = require('../language/kinds');

var Kind = _interopRequireWildcard(_languageKinds);

var _typeSchema = require('../type/schema');

var _utilitiesTypeInfo = require('../utilities/TypeInfo');

var _specifiedRules = require('./specifiedRules');

/**
 * Implements the "Validation" section of the spec.
 *
 * Validation runs synchronously, returning an array of encountered errors, or
 * an empty array if no errors were encountered and the document is valid.
 *
 * A list of specific validation rules may be provided. If not provided, the
 * default list of rules defined by the GraphQL specification will be used.
 *
 * Each validation rules is a function which returns a visitor
 * (see the language/visitor API). Visitor methods are expected to return
 * GraphQLErrors, or Arrays of GraphQLErrors when invalid.
 */

function validate(schema, ast, rules) {
  (0, _jsutilsInvariant2['default'])(schema, 'Must provide schema');
  (0, _jsutilsInvariant2['default'])(ast, 'Must provide document');
  (0, _jsutilsInvariant2['default'])(schema instanceof _typeSchema.GraphQLSchema, 'Schema must be an instance of GraphQLSchema. Also ensure that there are ' + 'not multiple versions of GraphQL installed in your node_modules directory.');
  var typeInfo = new _utilitiesTypeInfo.TypeInfo(schema);
  return visitUsingRules(schema, typeInfo, ast, rules || _specifiedRules.specifiedRules);
}

/**
 * This uses a specialized visitor which runs multiple visitors in parallel,
 * while maintaining the visitor skip and break API.
 *
 * @internal
 */

function visitUsingRules(schema, typeInfo, documentAST, rules) {
  var context = new ValidationContext(schema, documentAST, typeInfo);
  var visitors = rules.map(function (rule) {
    return rule(context);
  });
  // Visit the whole document with each instance of all provided rules.
  (0, _languageVisitor.visit)(documentAST, (0, _languageVisitor.visitWithTypeInfo)(typeInfo, (0, _languageVisitor.visitInParallel)(visitors)));
  return context.getErrors();
}

/**
 * An instance of this class is passed as the "this" context to all validators,
 * allowing access to commonly useful contextual information from within a
 * validation rule.
 */

var ValidationContext = function () {
  function ValidationContext(schema, ast, typeInfo) {
    _classCallCheck(this, ValidationContext);

    this._schema = schema;
    this._ast = ast;
    this._typeInfo = typeInfo;
    this._errors = [];
    this._fragmentSpreads = new _Map();
    this._recursivelyReferencedFragments = new _Map();
    this._variableUsages = new _Map();
    this._recursiveVariableUsages = new _Map();
  }

  _createClass(ValidationContext, [{
    key: 'reportError',
    value: function reportError(error) {
      this._errors.push(error);
    }
  }, {
    key: 'getErrors',
    value: function getErrors() {
      return this._errors;
    }
  }, {
    key: 'getSchema',
    value: function getSchema() {
      return this._schema;
    }
  }, {
    key: 'getDocument',
    value: function getDocument() {
      return this._ast;
    }
  }, {
    key: 'getFragment',
    value: function getFragment(name) {
      var fragments = this._fragments;
      if (!fragments) {
        this._fragments = fragments = this.getDocument().definitions.reduce(function (frags, statement) {
          if (statement.kind === Kind.FRAGMENT_DEFINITION) {
            frags[statement.name.value] = statement;
          }
          return frags;
        }, {});
      }
      return fragments[name];
    }
  }, {
    key: 'getFragmentSpreads',
    value: function getFragmentSpreads(node) {
      var spreads = this._fragmentSpreads.get(node);
      if (!spreads) {
        spreads = [];
        var setsToVisit = [node.selectionSet];
        while (setsToVisit.length !== 0) {
          var set = setsToVisit.pop();
          for (var i = 0; i < set.selections.length; i++) {
            var selection = set.selections[i];
            if (selection.kind === Kind.FRAGMENT_SPREAD) {
              spreads.push(selection);
            } else if (selection.selectionSet) {
              setsToVisit.push(selection.selectionSet);
            }
          }
        }
        this._fragmentSpreads.set(node, spreads);
      }
      return spreads;
    }
  }, {
    key: 'getRecursivelyReferencedFragments',
    value: function getRecursivelyReferencedFragments(operation) {
      var fragments = this._recursivelyReferencedFragments.get(operation);
      if (!fragments) {
        fragments = [];
        var collectedNames = _Object$create(null);
        var nodesToVisit = [operation];
        while (nodesToVisit.length !== 0) {
          var _node = nodesToVisit.pop();
          var spreads = this.getFragmentSpreads(_node);
          for (var i = 0; i < spreads.length; i++) {
            var fragName = spreads[i].name.value;
            if (collectedNames[fragName] !== true) {
              collectedNames[fragName] = true;
              var fragment = this.getFragment(fragName);
              if (fragment) {
                fragments.push(fragment);
                nodesToVisit.push(fragment);
              }
            }
          }
        }
        this._recursivelyReferencedFragments.set(operation, fragments);
      }
      return fragments;
    }
  }, {
    key: 'getVariableUsages',
    value: function getVariableUsages(node) {
      var _this = this;

      var usages = this._variableUsages.get(node);
      if (!usages) {
        (function () {
          usages = [];
          var typeInfo = new _utilitiesTypeInfo.TypeInfo(_this._schema);
          (0, _languageVisitor.visit)(node, (0, _languageVisitor.visitWithTypeInfo)(typeInfo, {
            VariableDefinition: function VariableDefinition() {
              return false;
            },
            Variable: function Variable(variable) {
              usages.push({ node: variable, type: typeInfo.getInputType() });
            }
          }));
          _this._variableUsages.set(node, usages);
        })();
      }
      return usages;
    }
  }, {
    key: 'getRecursiveVariableUsages',
    value: function getRecursiveVariableUsages(operation) {
      var usages = this._recursiveVariableUsages.get(operation);
      if (!usages) {
        usages = this.getVariableUsages(operation);
        var fragments = this.getRecursivelyReferencedFragments(operation);
        for (var i = 0; i < fragments.length; i++) {
          Array.prototype.push.apply(usages, this.getVariableUsages(fragments[i]));
        }
        this._recursiveVariableUsages.set(operation, usages);
      }
      return usages;
    }
  }, {
    key: 'getType',
    value: function getType() {
      return this._typeInfo.getType();
    }
  }, {
    key: 'getParentType',
    value: function getParentType() {
      return this._typeInfo.getParentType();
    }
  }, {
    key: 'getInputType',
    value: function getInputType() {
      return this._typeInfo.getInputType();
    }
  }, {
    key: 'getFieldDef',
    value: function getFieldDef() {
      return this._typeInfo.getFieldDef();
    }
  }, {
    key: 'getDirective',
    value: function getDirective() {
      return this._typeInfo.getDirective();
    }
  }, {
    key: 'getArgument',
    value: function getArgument() {
      return this._typeInfo.getArgument();
    }
  }]);

  return ValidationContext;
}();

exports.ValidationContext = ValidationContext;

},{"../error":205,"../jsutils/invariant":214,"../language/kinds":218,"../language/visitor":224,"../type/schema":332,"../utilities/TypeInfo":333,"./specifiedRules":364,"babel-runtime/core-js/map":228,"babel-runtime/core-js/object/create":230,"babel-runtime/helpers/class-call-check":237,"babel-runtime/helpers/create-class":238,"babel-runtime/helpers/interop-require-default":242,"babel-runtime/helpers/interop-require-wildcard":243}]},{},[1]);
