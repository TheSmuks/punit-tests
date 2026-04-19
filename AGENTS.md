# AGENTS.md

## Project overview

PUnit is a JUnit-inspired testing framework written in Pike (8.0.1116+). The framework lives in `PUnit.pmod/` and is invoked through `run_tests.pike`. Test files are `.pike` files that `import PUnit` and `inherit PUnit.TestCase`.

## Setup commands

- Run all tests: `pike -M . run_tests.pike tests/`
- Run one file: `pike -M . run_tests.pike tests/ExampleTests.pike`
- Verbose output: `pike -M . run_tests.pike -v tests/`
- TAP output: `pike -M . run_tests.pike --tap tests/`
- JUnit XML: `pike -M . run_tests.pike --junit=report.xml tests/`
- List tests: `pike -M . run_tests.pike --list=verbose tests/`
- Strict validation: `pike -M . run_tests.pike --strict tests/`
- Tag filtering: `pike -M . run_tests.pike --tag=math tests/`
- Method filtering: `pike -M . run_tests.pike --filter=test_add* tests/`

Expected result: 28 passed, 1 skipped, exit code 0.

## Architecture

- `PUnit.pmod/module.pmod` -- re-exports `Assertions.pmod` so `import PUnit` exposes all assert functions
- `PUnit.pmod/Assertions.pmod` -- 20 assertion functions, each with an optional `_loc` parameter for exact source location
- `PUnit.pmod/macros.h` -- preprocessor macros that inject `__FILE__:__LINE__` into assertions. Included via `#include <PUnit.pmod/macros.h>`
- `PUnit.pmod/TestCase.pike` -- base class with `setup()`, `teardown()`, `setup_class()`, `teardown_class()` lifecycle hooks
- `PUnit.pmod/TestSuite.pike` -- discovers test methods, handles parameterization, inline tags, filtering, strict validation
- `PUnit.pmod/TestRunner.pike` -- CLI harness, compiles test files via `compile_string`, discovers classes with `test_*` methods
- `PUnit.pmod/Error.pmod` -- `AssertionError` class, `find_caller_location()` for backtrace-based location reporting
- `PUnit.pmod/Reporter.pike` -- base reporter interface
- `PUnit.pmod/DotReporter.pike`, `VerboseReporter.pike`, `TAPReporter.pike`, `JUnitReporter.pike` -- output formats
- `PUnit.pmod/TestResult.pike` -- per-test result container
- `PUnit.pmod/Colors.pmod` -- ANSI color helpers
- `run_tests.pike` -- CLI entry point, parses flags and delegates to TestRunner

## Code style

- Pike 8.0 syntax. Use `protected` for internal members, `void|type` for optional parameters.
- Doc comments use `//!` prefix with `@expr{}`, `@ref{}`, `@tt{}` Pike doc markup.
- Arrays: `({})`, mappings: `([])`, multisets: `(<>)`.
- `catch` blocks use `if (mixed e = catch { ... })` pattern for error handling.
- No tabs in `.pmod`/`.pike` files -- use 2-space indentation following existing convention.

## Testing instructions

- Every change to framework code must be verified with `pike -M . run_tests.pike tests/`.
- New features should include test cases in `tests/`.
- Test files must `import PUnit` and typically `inherit PUnit.TestCase`.
- The runner discovers any class with `test_*` methods via duck-typing; inheriting TestCase is only needed for lifecycle hooks.
- Parameterized tests use `constant test_data = ([ "method_name": ({ row_mappings }) ]);`
- Tag annotations use `constant test_tags = ([ "method_name": ({"tag1", "tag2"}) ]);` or inline `__tag` suffixes in method names.
- Skip tests with `constant skip_tests = (< "method_name" >);`.

## Pike gotchas

- Pike does not have `multiset` as a constructor function. Use `(< >)` literal syntax or populate via `foreach`.
- `compile_string` resolves `""` includes relative to the source file, so `macros.h` must be included with angle brackets: `#include <PUnit.pmod/macros.h>`.
- Type declarations like `multiset(string)` are not valid in Pike. Use `multiset` without type parameters.
- `if (!(mixed e = catch {...}))` is not valid syntax. Use `mixed err = catch {...}; if (!err) ...` instead.
- Pike arrays use `({})`, not `[]`. Mappings use `([])`, not `{}`. Multisets use `(<>)`, not `set()`.
- `sprintf("%O", val)` gives debug output. `sprintf("%q", str)` gives quoted string.
- Method references: `map(arr, function_name)` works if `function_name` is in scope.

## PR instructions

- Title format: descriptive summary of the change
- Run `pike -M . run_tests.pike tests/` before committing -- all 28 tests must pass
- If adding new assertions or framework features, add corresponding test cases
