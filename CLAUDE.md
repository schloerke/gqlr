# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

`gqlr` is a GraphQL server implementation for R that follows the
[GraphQL specification](https://graphql.github.io/graphql-spec/). It
allows R developers to create GraphQL schemas using GraphQL syntax
strings and attach R functions as resolvers. The package handles query
parsing, validation, execution, and can serve GraphQL APIs via Plumber.

## Key Commands

### Testing

``` r

# Run all tests
devtools::test()

# Run a specific test file
testthat::test_file("tests/testthat/test-gqlr_schema.R")

# Run tests with coverage
covr::package_coverage()
```

### Building & Checking

``` r

# Build and install the package locally
devtools::install()

# Run R CMD check
devtools::check()

# Build documentation
devtools::document()
```

### Running a Development Server

``` r

# Load package in development mode
devtools::load_all()

# Start GraphQL server with a schema (includes GraphiQL interface)
gqlr:::server(schema_object, port = 8000, log = TRUE)
```

## Architecture

### Core Schema System (R6 Classes)

The package uses R6 classes extensively to model GraphQL type system
definitions:

- **[R6-Schema.R](http://schloerke.com/gqlr/R/R6-Schema.R)**: Central
  `Schema` R6 class that manages all type definitions (scalars, enums,
  objects, interfaces, unions, input objects, directives). Provides
  methods like `get_type()`, `is_object()`, `implements_interface()`,
  etc.

- **[R6–definition.R](http://schloerke.com/gqlr/R/R6--definition.R)**:
  Base R6 class definitions for all GraphQL type system components
  (ObjectTypeDefinition, InterfaceTypeDefinition, UnionTypeDefinition,
  EnumTypeDefinition, etc.). These mirror the GraphQL spec’s type
  system.

### Schema Creation Flow

1.  **[gqlr_schema.R](http://schloerke.com/gqlr/R/gqlr_schema.R)**: Main
    user-facing function
    [`gqlr_schema()`](http://schloerke.com/gqlr/reference/gqlr_schema.md)
    that:
    - Takes a GraphQL schema string and additional R configuration
      (resolve functions, descriptions)
    - Parses the string via `graphql2obj()` (from the `graphql` package)
    - Creates a `Schema$new()` object
    - Attaches R functions as `.resolve`, `.resolve_type`, or
      `.parse_ast` methods to the appropriate type definitions
2.  **[graphql_json.R](http://schloerke.com/gqlr/R/graphql_json.R)**:
    Contains `graphql2obj()` which uses the `graphql` package to parse
    GraphQL strings into R6 objects representing the AST.

### Query Execution Pipeline

The execution follows the GraphQL spec sections 6.1-6.4:

1.  **[R6-6.1-executing-requests.R](http://schloerke.com/gqlr/R/R6-6.1-executing-requests.R)**:
    [`execute_request()`](http://schloerke.com/gqlr/reference/execute_request.md)
    entry point
    - Validates schema and query
    - Gets the operation from the document
    - Coerces variable values
    - Dispatches to `execute_query()` or `execute_mutation()`
2.  **[R6-6.2-executing-operations.R](http://schloerke.com/gqlr/R/R6-6.2-executing-operations.R)**:
    Executes operations (query/mutation)
    - Retrieves root object using schema’s query/mutation resolve
      methods
    - Calls `execute_selection_set()` on the root selection set
3.  **[R6-6.3-executing-selection-sets.R](http://schloerke.com/gqlr/R/R6-6.3-executing-selection-sets.R)**:
    Processes selection sets
    - Collects fields (handles fragments, inline fragments)
    - Determines fragment type applicability
    - Executes each field in the selection
4.  **[R6-6.4-executing-fields.R](http://schloerke.com/gqlr/R/R6-6.4-executing-fields.R)**:
    Field execution
    - Coerces argument values
    - Resolves field values using attached R functions
    - Completes values (handles scalars, lists, objects)
    - Resolves abstract types (interfaces/unions)

### Validation System

Query validation is performed before execution:

- **[validation-query.R](http://schloerke.com/gqlr/R/validation-query.R)**:
  Main `validate_query()` orchestrator

  - Operation name uniqueness (5.1)
  - Field selections on objects/interfaces/unions (5.2)
  - Fragment handling and inline expansion

- **[validation-arguments.R](http://schloerke.com/gqlr/R/validation-arguments.R)**:
  Validates arguments match field/directive definitions

- **[validation-input-coercion.R](http://schloerke.com/gqlr/R/validation-input-coercion.R)**:
  Coerces input values to match GraphQL types

- **[validation-selection-set-can-merge.R](http://schloerke.com/gqlr/R/validation-selection-set-can-merge.R)**:
  Ensures fields can be merged according to GraphQL spec

- **[upgrade_query_remove_fragments.R](http://schloerke.com/gqlr/R/upgrade_query_remove_fragments.R)**:
  Preprocesses queries by expanding fragment spreads into inline
  fragments

### Supporting Infrastructure

- **[R6-Result.R](http://schloerke.com/gqlr/R/R6-Result.R)** &
  **[R6-7-response.R](http://schloerke.com/gqlr/R/R6-7-response.R)**:
  Result objects that structure response data and errors

- **[R6-ErrorList.R](http://schloerke.com/gqlr/R/R6-ErrorList.R)**:
  Collects and formats validation/execution errors with GraphQL spec
  section references

- **[R6-ObjectHelpers.R](http://schloerke.com/gqlr/R/R6-ObjectHelpers.R)**:
  Helper class that bundles schema, error list, and execution context

- **[R6-4-introspection.R](http://schloerke.com/gqlr/R/R6-4-introspection.R)**:
  Implements GraphQL introspection types (`__Schema`, `__Type`,
  `__Field`, etc.)

### Server Implementation

- **[server.R](http://schloerke.com/gqlr/R/server.R)**:
  [`server()`](http://schloerke.com/gqlr/reference/server.md) function
  creates a Plumber-based HTTP server
  - Requires `plumber` package \>= 1.2.0
  - GET and POST `/graphql` endpoints
  - `/graphiql/` interface for interactive queries (when running
    interactively)
  - Handles `application/json` and `application/graphql` content types

## File Naming Conventions

- `R6-*.R`: R6 class definitions for GraphQL type system or execution
  components
- `R6-[section]-*.R`: Files implementing specific sections of the
  GraphQL spec (e.g., `R6-6.1-executing-requests.R`)
- `validation-*.R`: Query and schema validation logic
- `S3-*.R`: S3 method definitions (print, format, str)
- `AAA-*.R`: Utility functions loaded first (collation order)

## Important Patterns

### Resolve Functions

Resolve functions attached via
[`gqlr_schema()`](http://schloerke.com/gqlr/reference/gqlr_schema.md)
have different signatures depending on type:

- **Scalar**: `function(x, schema)` - coerce raw value
- **Enum**: `function(x, schema)` - map internal value to enum value
- **Object**: `function(id, args, schema)` - return named list of field
  values
- **Interface/Union**: `resolve_type = function(obj, schema)` - return
  type name as string
- **Field values**: Can be static values or
  `function(obj, args, schema)` for lazy evaluation

### Schema Collation Order

The `DESCRIPTION` file’s `Collate` field defines source file loading
order, which is critical for R6 class dependencies and `@include`
roxygen directives.

## Testing Infrastructure

- **[tests/testthat.R](http://schloerke.com/gqlr/tests/testthat.R)**:
  Test runner entry point
- \*\*helper-\*.R\*\* files: Shared test fixtures (e.g., Star Wars
  schema, Dog/Cat schema)
- Tests are organized by GraphQL spec section numbers (e.g.,
  `test-validation-5.2-fields.R`)

## Dependencies

Key external packages: - `graphql`: Parses GraphQL strings into JSON/R
objects - `R6`: Object-oriented class system - `jsonlite`: JSON
serialization - `magrittr`: Pipe operators - `pryr`: Function
manipulation utilities - `plumber` (optional): HTTP server for GraphQL
endpoints
