# tests/ — PUnit Test Suite

## Test file conventions

- Files must have `.pike` extension
- Hidden files (dot-prefix) like `.HangTest.pike` are also discovered
- Files are discovered recursively from the test directory
- Each file should `#include <PUnit.pmod/macros.h>` and `import PUnit`
- Inherit `PUnit.TestCase` only when lifecycle hooks are needed; the runner uses duck-typing

## Discovery rules

The runner (`TestRunner.pike`) discovers tests by:
1. Recursively scanning for `.pike` files
2. Compiling each via `compile_string(source, filename)`
3. Instantiating the compiled program
4. Finding any class with methods matching `test_*` (duck-typing)
5. Also checking inner classes for test methods

Parameterized tests expand `test_method` into `test_method[0]`, `test_method[1]`, etc.

## Parameterized test pattern

```pike
constant test_data = ([
  "test_add": ({
    ([ "a": 1, "b": 1, "expected": 2 ]),
    ([ "a": -1, "b": 1, "expected": 0 ]),
  }),
]);

void test_add(mapping row) {
  assert_equal(row->expected, row->a + row->b);
}
```

## Baseline

**165 passed, 4 skipped, exit code 0**

This is the expected baseline for a clean test run:
```bash
pike -M . run_tests.pike tests/
```

If the baseline changes (new tests added, tests removed, skip count changes), update this file AND the root `AGENTS.md` expected result line.

## Adding new test files

1. Create `tests/YourFeatureTests.pike`
2. Follow the standard structure:
   ```pike
   #include <PUnit.pmod/macros.h>
   import PUnit;
   inherit PUnit.TestCase;
   ```

For selective assertion imports, use `import PUnit.<Category>` instead of `import PUnit`:
   ```pike
   import PUnit.Equal;     // assert_equal, assert_not_equal, assert_same, assert_not_same
   import PUnit.Boolean;   // assert_true, assert_false
   ```
3. Add `test_*` methods
4. Run `pike -M . run_tests.pike tests/` to verify
5. Update baseline in this file and root `AGENTS.md` if counts changed
6. Update `CHANGELOG.md` [Unreleased] section

## Skip test conventions

Three mechanisms for skipping:

- **Compile-time skip**: `constant skip_tests = (< "method_name" >);` — multiset of method names
- **Compile-time reason**: `constant skip_reasons = ([ "method_name": "Bug #123" ]);` — mapping with reason
- **Runtime skip**: Call `skip("reason")` from within a test — throws `SkipError`
- **Skip entire class**: `constant skip_all = true;`
