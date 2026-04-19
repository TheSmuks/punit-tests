
[![CI](https://github.com/TheSmuks/punit-tests/actions/workflows/ci.yml/badge.svg)](https://github.com/TheSmuks/punit-tests/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/tag/TheSmuks/punit-tests?label=release)](https://github.com/TheSmuks/punit-tests/releases/latest)
[![License](https://img.shields.io/github/license/TheSmuks/punit-tests)](LICENSE)
[![Pike](https://img.shields.io/badge/Pike-8.0-blue)](https://pike.lysator.liu.se/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# PUnit

JUnit-inspired testing framework for Pike. Provides structured test discovery, rich assertions, parameterized tests, tag-based filtering, and multiple output formats.

## Requirements

- Pike 8.0.1116 or later

## Quick Start

Write a test file:

```pike
import PUnit;
inherit PUnit.TestCase;

constant test_tags = ([
  "test_addition": ({"math", "core"}),
]);

void test_addition() {
  assert_equal(2, 1 + 1);
}

void test_comparison() {
  assert_gt(10, 5);
  assert_lte(5, 5);
}
```

Run it:

```bash
pike -M . run_tests.pike tests/
```

Output:

```
..

Results: 2 passed (0.0ms)
```

## Features

### Assertions

| Assertion | Description |
|---|---|
| `assert_equal(expected, actual)` | Strict equality |
| `assert_not_equal(expected, actual)` | Inequality |
| `assert_true(val)` / `assert_false(val)` | Boolean check |
| `assert_null(val)` / `assert_not_null(val)` | Zero check |
| `assert_undefined(val)` | UNDEFINED check |
| `assert_gt(a, b)` / `assert_lt(a, b)` | Ordered comparison |
| `assert_gte(a, b)` / `assert_lte(a, b)` | Inclusive bounds |
| `assert_contains(needle, haystack)` | Membership (array, mapping, string) |
| `assert_match(pattern, str)` | Regexp match |
| `assert_approx_equal(a, b, tolerance)` | Floating-point comparison |
| `assert_type(type_name, val)` | Runtime type check |
| `assert_throws(error_type, fn)` | Exception expected |
| `assert_throws_fn(fn)` | Any exception expected |
| `assert_no_throw(fn)` | No exception expected |
| `assert_fail(msg)` | Unconditional failure |

### Exact Source Locations

By default, assertion failures report locations inferred from the backtrace. For exact `file:line` reporting, include the macro header:

```pike
#include <PUnit.pmod/macros.h>
import PUnit;
inherit PUnit.TestCase;

void test_example() {
  assert_equal(2, 1 + 1);  // failure shows this exact line
}
```

The header redefines all assertion functions as preprocessor macros that inject `__FILE__` and `__LINE__`.

### Parameterized Tests

Define `test_data` as a mapping from method names to arrays of row data. Each row is passed as a mapping argument:

```pike
constant test_data = ([
  "test_add": ({
    ([ "a": 1, "b": 1, "expected": 2 ]),
    ([ "a": -1, "b": 1, "expected": 0 ]),
    ([ "a": 100, "b": 200, "expected": 300 ]),
  }),
]);

void test_add(mapping p) {
  assert_equal(p->expected, p->a + p->b);
}
```

The runner expands these into individual tests named `test_add[0]`, `test_add[1]`, `test_add[2]`. Each row runs independently and reports its own pass/fail status.

### Tag Filtering

Assign tags via the `test_tags` constant:

```pike
constant test_tags = ([
  "test_addition": ({"math", "core"}),
  "test_slow_operation": ({"slow"}),
]);
```

Or use inline tags directly in method names with double-underscore suffixes:

```pike
void test_add__math__fast() {
  // Automatically tagged with "math" and "fast"
  assert_true(1);
}
```

Inline tags are merged with any explicit `test_tags` entries for the base method name.

Run filtered subsets:

```bash
# Only tests tagged "math"
pike -M . run_tests.pike --tag=math tests/

# Exclude "slow" tests
pike -M . run_tests.pike --exclude-tag=slow tests/

# Combine: run "core" tests but not "slow" ones
pike -M . run_tests.pike -t core -e slow tests/
```

### Skipping Tests

```pike
constant skip_tests = (< "test_not_ready" >);

void test_not_ready() {
  assert_fail("This should not run");
}
```

Skipped tests are reported separately and do not count as failures.

### Test Fixtures

Override `setup()` and `teardown()` in your test class:

```pike
inherit PUnit.TestCase;

protected object db;

void setup() {
  db = Database.Connection("test://localhost");
}

void teardown() {
  db->close();
  db = 0;
}
```

`setup()` runs before each test method. `teardown()` runs after each test method, even if the test or setup failed.

### Listing and Validation

List test names without running them:

```bash
# Names only
pike -M . run_tests.pike --list tests/

# Names with tags
pike -M . run_tests.pike --list=verbose tests/
```

Validate configuration correctness (catch typos in `test_tags`, `skip_tests`, or `test_data` keys):

```bash
pike -M . run_tests.pike --strict tests/
```

Without `--strict`, mismatches produce warnings. With `--strict`, they become errors that cause a non-zero exit code.

## Reporters

### Dot (default)

```
....S..F.

Results: 8 passed, 1 failed, 1 skipped (12.3ms)
```

### Verbose

```bash
pike -M . run_tests.pike -v tests/
```

```
[ ExampleTests ] (5 tests)
  OK ExampleTests::test_addition (0.1ms)
  OK ExampleTests::test_subtraction (0.0ms)
  SKIP ExampleTests::test_slow (skipped)
  FAIL ExampleTests::test_broken (0.0ms)
    Expected: 42
    Actual:   0
    at tests/ExampleTests.pike:15
Results: 3 passed, 1 failed, 1 skipped (0.1ms)
```

### TAP v13

```bash
pike -M . run_tests.pike --tap tests/
```

```
TAP version 13
ok 1 - ExampleTests::test_addition
ok 2 - ExampleTests::test_subtraction
ok 3 - ExampleTests::test_slow # SKIP skipped
not ok 4 - ExampleTests::test_broken
  ---
  message: "Expected 42, got 0"
  severity: fail
  location: "tests/ExampleTests.pike:15"
  ...
1..4
```

### JUnit XML

```bash
pike -M . run_tests.pike --junit=report.xml tests/
```

Writes a JUnit-compatible XML report suitable for CI systems.

## CLI Reference

```
pike -M . run_tests.pike [options] <directories...>

Options:
  -v, --verbose          Show each test name with status
  -t, --tag=TAG          Run only tests with this tag (repeatable)
  -e, --exclude-tag=TAG  Skip tests with this tag (repeatable)
  -f, --filter=GLOB      Run only test methods matching glob
  -s, --stop-on-failure  Stop after first failure
  --list                 List test names without running
  --list=verbose         List test names with tags
  --strict               Treat validation warnings as errors
  --no-color             Disable ANSI colors
  --junit=FILE           Write JUnit XML report to FILE
  --tap                  Output TAP v13 to stdout
  -h, --help             Show this help

Exit code: 0 if all pass, 1 if any failure.
```

## Project Structure

```
PUnit.pmod/
  Assertions.pmod      Assertion functions
  Colors.pmod          ANSI color helpers
  DotReporter.pike     Dot-matrix output
  Error.pmod           Error formatting and location extraction
  JUnitReporter.pike   JUnit XML output
  macros.h             Preprocessor macros for exact locations
  module.pmod          Module entry point (re-exports Assertions)
  Reporter.pike        Base reporter interface
  TAPReporter.pike     TAP v13 output
  TestCase.pike        Base test class with setup/teardown
  TestResult.pike      Per-test result container
  TestRunner.pike      CLI harness, file discovery, compilation
  TestSuite.pike       Suite runner, parameterization, tag filtering
  VerboseReporter.pike Human-readable verbose output
run_tests.pike         CLI entry point
tests/                 Example tests
```

## License

MIT
