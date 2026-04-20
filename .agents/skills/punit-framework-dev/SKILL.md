---
name: punit-framework-dev
description: Develop and modify the PUnit testing framework itself. Use when editing PUnit.pmod source files, adding assertions, modifying TestSuite/TestRunner behavior, fixing framework bugs, or extending reporter output formats.
license: MIT
compatibility: Requires Pike 8.0.1116 or later
metadata:
  author: TheSmuks
  version: "1.0"
---

# PUnit Framework Development

This skill covers making changes to the PUnit framework source code in `PUnit.pmod/`.

## Module structure

```
PUnit.pmod/
  module.pmod        -- re-exports Assertions via inherit
  Assertions.pmod    -- all assert_* functions
  macros.h           -- preprocessor macros wrapping assertions with __FILE__:__LINE__
  Error.pmod         -- AssertionError class, find_caller_location()
  TestCase.pike      -- base class with lifecycle hooks (setup, teardown, etc.)
  TestSuite.pike     -- test discovery, parameterization, tag filtering, validation
  TestRunner.pike    -- CLI harness, file scanning, compilation
  Reporter.pike      -- base reporter interface
  DotReporter.pike   -- dot-matrix output (default)
  VerboseReporter.pike -- per-test status with details
  TAPReporter.pike   -- TAP v13 output
  JUnitReporter.pike -- JUnit XML output
  TestResult.pike    -- per-test result container
  Colors.pmod        -- ANSI color helpers
  Version.pmod        -- version constant ("1.1.0")

  # Granular headers for selective import:
  equal.h              -- assert_equal, assert_not_equal, assert_same, assert_not_same
  boolean.h            -- assert_true, assert_false
  comparison.h         -- assert_gt, assert_lt, assert_gte, assert_lte
  null.h               -- assert_null, assert_not_null, assert_undefined
  membership.h         -- assert_contains, assert_match
  exception.h          -- assert_throws, assert_throws_fn, assert_no_throw, assert_throws_message
  collection.h         -- assert_each, assert_contains_only, assert_has_size
  misc.h               -- assert_fail, assert_type, assert_approx_equal
```

## Adding a new assertion

1. Add the function in `Assertions.pmod`. Signature pattern:

```pike
void assert_XXXX(mixed ... args, void|string msg, void|string _loc) {
  // check condition
  // on failure: _fail(_msg(msg, "description of what went wrong", ...format_args), _loc);
}
```

The last two parameters must always be `void|string msg, void|string _loc`. `_loc` is the exact source location injected by macros; when absent, `_fail` falls back to backtrace walking.

2. Add the corresponding macro in `macros.h`:

```pike
#define assert_XXXX(...) PUnit.assert_XXXX(__VA_ARGS__, UNDEFINED, __FILE__ + ":" + __LINE__)
```

Use `PUnit.assert_XXXX` (fully qualified) to avoid recursive macro expansion. Use `__VA_ARGS__` for assertions that take variable argument counts, or list the named parameters for fixed-arity ones.

3. Update the assertion table in `README.md`.


## Assertion reference (28 functions)

All assertions live in `Assertions.pmod` and are exposed via `macros.h`.

### Equality (equal.h)
- `assert_equal(actual, expected, msg, _loc)`
- `assert_not_equal(actual, expected, msg, _loc)`
- `assert_same(actual, expected, msg, _loc)` -- reference identity
- `assert_not_same(actual, expected, msg, _loc)`

### Boolean (boolean.h)
- `assert_true(value, msg, _loc)`
- `assert_false(value, msg, _loc)`

### Comparison (comparison.h)
- `assert_gt(actual, expected, msg, _loc)`
- `assert_lt(actual, expected, msg, _loc)`
- `assert_gte(actual, expected, msg, _loc)`
- `assert_lte(actual, expected, msg, _loc)`

### Null / undefined (null.h)
- `assert_null(value, msg, _loc)`
- `assert_not_null(value, msg, _loc)`
- `assert_undefined(value, msg, _loc)`

### Membership (membership.h)
- `assert_contains(collection, item, msg, _loc)`
- `assert_match(pattern, subject, msg, _loc)`

### Exception (exception.h)
- `assert_throws(error_type, fn, msg, _loc)` -- asserts fn() throws error_type
- `assert_throws_fn(error_type, fn, args, msg, _loc)` -- passes args to fn
- `assert_no_throw(fn, msg, _loc)` -- asserts fn() completes without error
- `assert_throws_message(error_type, expected_msg, fn, msg, _loc)` -- asserts throw and message substring

### Collection (collection.h)
- `assert_each(collection, checker_fn, msg, _loc)` -- checker_fn must return true for every element
- `assert_contains_only(collection, allowed, msg, _loc)` -- every element is in allowed set
- `assert_has_size(collection, expected_size, msg, _loc)` -- checks sizeof(collection)

### Misc (misc.h)
- `assert_fail(msg, _loc)` -- unconditional failure
- `assert_type(value, expected_type, msg, _loc)` -- checks typeof(value)
- `assert_approx_equal(actual, expected, tolerance, msg, _loc)` -- float comparison with tolerance

### Skipping tests
- `skip(string reason)` -- call inside a test to skip it; throws `SkipError`
- `SkipError` class in `Error.pmod` -- caught by TestSuite to report skipped tests

## Parameterized test expansion (TestSuite.pike)

- `test_data` constant maps base method names to arrays of row mappings
- `_discover_test_methods()` expands parameterized methods into `method[0]`, `method[1]`, etc.
- `_invoke_test()` looks up row data from `test_data` using `_base_method()` and passes it as argument
- `_base_method()` strips both `[N]` suffixes and `__tag` suffixes

## Tag system (TestSuite.pike)

Three sources of tags, merged in `_should_run()`:
1. `test_tags` constant -- explicit mapping from method name to tag array
2. Inline `__suffixes` -- extracted by `_inline_tags()`, e.g. `test_add__math__fast` yields `({"math", "fast"})`
3. `_strip_inline_tags()` returns the base name (everything before first `__` after `test_` prefix)

Filtering: `_include_tags` (must match at least one) and `_exclude_tags` (must match none).

## Strict validation (TestSuite.pike)

`_validate_class()` checks that keys in `test_tags`, `skip_tests`, and `test_data` correspond to actual test methods. Warnings accumulate in `_validation_warnings`. With `_strict` set, these become errors that cause a non-zero exit code.

The method uses `catch` blocks to safely access constants that may not exist on test instances.

## TestRunner compilation flow

1. `_collect_files()` scans directories recursively for `.pike` files
2. `_discover_in_file()` reads each file and calls `compile_string(source, file)`
3. Instantiates the compiled program and checks for `test_*` methods via `_has_test_methods()`
4. Also checks inner classes defined in the file
5. `create()` calls `master()->add_module_path(cwd)` and `master()->add_include_path(cwd)` so `import PUnit` and `#include <PUnit.pmod/macros.h>` work

## Reporter interface

All reporters inherit `Reporter.pike` and implement:
- `suite_started(name, num_tests)`
- `test_started(name)`
- `test_passed(name, elapsed_ms)`
- `test_failed(name, elapsed_ms, message, location)`
- `test_error(name, elapsed_ms, message, location)`
- `test_skipped(name, reason)`
- `suite_finished(passed, failed, errors, skipped, elapsed_ms)`
- `run_finished(all_results)`

## Pike syntax constraints

- No `multiset(type)` declarations. Use `multiset` without type parameter.
- No `multiset(@array)` constructor. Use `(< @array >)` or populate via `foreach`.
- No `if (!(mixed e = catch {...}))`. Use `mixed err = catch {...}; if (!err) ...`.
- `compile_string` resolves `""` includes relative to source file. Angle brackets (`<>`) resolve via include paths. This is why `macros.h` uses angle brackets.
- Arrays: `({})`, mappings: `([])`, multisets: `(<>)`.
- `sprintf("%O", val)` for debug output, `sprintf("%q", str)` for quoted strings.

## Test timeout (TestSuite.pike)

- `_timeout` field set via `create()`, defaults to 0 (disabled)
- `_invoke_test()` wrapped in `Thread.Thread` + mutex/condition polling
- Parent polls every 20ms; on timeout, reports error "Test timed out after Ns"
- Thread-based approach is used because Pike cannot kill running threads

## Randomized test ordering (TestSuite.pike)

- `_randomize` and `_seed` fields set via `create()`
- Fisher-Yates shuffle in `_discover_test_methods()` after `sort(result)`
- Uses a deterministic LCG PRNG (`_prng_state`) for reproducibility (Pike's `random_seed` is not deterministic across processes)
- TestRunner initializes seed once and logs it to stderr via `werror()`
- Seed is shared across all suites in a run

## Verification checklist

After any framework change:

```bash
# Basic run
pike -M . run_tests.pike tests/

# Verbose (check individual test names)
pike -M . run_tests.pike -v tests/

# All reporters
pike -M . run_tests.pike --tap tests/
pike -M . run_tests.pike --junit=/tmp/test.xml tests/

# Strict mode
pike -M . run_tests.pike --strict tests/

# Listing
pike -M . run_tests.pike --list=verbose tests/

# Timeout
pike -M . run_tests.pike --timeout=2 tests/

# Randomized order (reproducible)
pike -M . run_tests.pike --randomize --seed=42 tests/
```

Expected: 41 passed, 3 skipped, exit code 0 on all commands.
