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

Expected: 35 passed, 1 skipped, exit code 0 on all commands.
