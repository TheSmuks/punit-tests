---
name: punit-write-test
description: Write PUnit test files for the Pike testing framework. Use when creating new test files, adding test methods, writing parameterized tests, or adding tag-annotated tests in a project using PUnit.
license: MIT
compatibility: Requires Pike 8.0.1116 or later
metadata:
  author: TheSmuks
  version: "1.0"
---

# Writing PUnit Tests

## Basic test file structure

Every test file follows this pattern:

```pike
#include <PUnit.pmod/macros.h>
import PUnit;
inherit PUnit.TestCase;

// Optional: tag annotations
constant test_tags = ([
  "test_addition": ({"math", "core"}),
]);

// Optional: skip specific tests
constant skip_tests = (< "test_not_ready" >);

// Optional: skip entire class
// constant skip_all = true;

void setup() {
  // Runs before each test method
}

void teardown() {
  // Runs after each test method, even on failure
}

void test_addition() {
  assert_equal(2, 1 + 1);
}
```

The `#include` is optional but recommended -- it gives exact file:line in failure messages instead of backtrace guessing.

## Assertion reference

### Equality

```pike
assert_equal(expected, actual);
assert_not_equal(expected, actual);
```

Uses Pike's `equal()` -- works for arrays, mappings, multisets, and objects implementing `_equal()`.

### Boolean and null

```pike
assert_true(val);
assert_false(val);
assert_null(val);
assert_not_null(val);
assert_undefined(val);
```

### Comparison

```pike
assert_gt(a, b);   // a > b
assert_lt(a, b);   // a < b
assert_gte(a, b);  // a >= b
assert_lte(a, b);  // a <= b
```

### Collections and strings

```pike
assert_contains(needle, haystack);  // works on arrays, mappings, strings
assert_match(pattern, str);          // regexp match
```

### Floating-point

```pike
assert_approx_equal(expected, actual, tolerance);
```

### Type checking

```pike
assert_type("int", 42);
assert_type("string", "hello");
assert_type("array", ({1, 2, 3}));
```

### Exceptions

```pike
assert_throws(error_type, lambda() { /* code that throws */ });
assert_throws_fn(lambda() { /* code that should throw anything */ });
assert_no_throw(lambda() { /* code that should not throw */ });
```

### Forced failure

```pike
assert_fail("This should not be reached");
```

All assertions accept an optional `msg` parameter before the last argument for custom failure messages.

## Parameterized tests

Define `test_data` as a mapping from base method name to an array of row data. Each row is a mapping passed as an argument:

```pike
constant test_data = ([
  "test_add": ({
    ([ "a": 1, "b": 1, "expected": 2 ]),
    ([ "a": -1, "b": 1, "expected": 0 ]),
    ([ "a": 0, "b": 0, "expected": 0 ]),
  }),
]);

void test_add(mapping row) {
  assert_equal(row->expected, row->a + row->b);
}
```

The runner expands these into `test_add[0]`, `test_add[1]`, `test_add[2]`. Each row runs and reports independently. Tag filtering and skip_tests work on the base method name (`test_add`).

## Inline tag annotations

Add tags directly in method names using double-underscore suffixes:

```pike
void test_sort__algo__fast() {
  // Automatically tagged with "algo" and "fast"
  assert_true(1);
}
```

The base method name is `test_sort` (everything before the first `__` after the `test_` prefix). Inline tags merge with any explicit `test_tags` entries for the same base name.

## Tagging and filtering

Explicit tags via constant:

```pike
constant test_tags = ([
  "test_addition": ({"math", "core"}),
  "test_slow_db": ({"slow", "database"}),
]);
```

## Skipping tests

```pike
// Skip individual tests
constant skip_tests = (< "test_broken", "test_not_implemented" >);

// Skip entire class
constant skip_all = true;
```

## Lifecycle hooks

```pike
class TestCase {
  void setup_class() { }    // Once before all tests in class
  void teardown_class() { } // Once after all tests in class
  void setup() { }          // Before each test method
  void teardown() { }       // After each test method (even on failure)
}
```

Override any combination. No need to call parent methods -- they are no-ops.

## File naming and discovery

- Test files must have `.pike` extension
- The runner recursively scans directories for `.pike` files
- Any class with methods matching `test_*` is discovered automatically
- Inheriting `PUnit.TestCase` is only required for lifecycle hooks; the runner uses duck-typing
