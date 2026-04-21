# PUnit.pmod — Framework Source

## Module structure and re-exports

`module.pmod` re-exports `Assertions` and `Version` via `inherit`. `import PUnit` exposes all assert functions, `skip()`, `PUnit.version`, and error types.

## Category sub-modules (selective imports)

Eight `.pmod` files provide selective imports via `import PUnit.<Category>`:

| File | Category | Functions |
|------|----------|----------|
| `Equal.pmod` | Equality | assert_equal, assert_not_equal, assert_same, assert_not_same |
| `Boolean.pmod` | Boolean | assert_true, assert_false |
| `Comparison.pmod` | Comparison | assert_gt, assert_lt, assert_gte, assert_lte |
| `Null.pmod` | Null | assert_null, assert_not_null, assert_undefined |
| `Membership.pmod` | Membership | assert_contains, assert_match |
| `Exception.pmod` | Exception | assert_throws, assert_throws_fn, assert_no_throw, assert_throws_message |
| `Collection.pmod` | Collection | assert_each, assert_contains_only, assert_has_size |
| `Misc.pmod` | Misc | assert_fail, assert_type, assert_approx_equal |

Each sub-module:
- `inherit .Assertions` to get all assertion functions
- Overrides `[]` and `->` to return `UNDEFINED` for non-allowed names
- Overrides `_indices()` to return only allowed names
- This means `import PUnit.Equal` brings only equality assertions into scope

`import PUnit` (full import) is unchanged — all functions remain available.


## Assertion function contract

Every assertion function signature ends with `void|string msg, void|string _loc`:

```pike
void assert_XXXX(mixed ... args, void|string msg, void|string _loc)
```

- `msg` — optional custom failure message
- `_loc` — exact source location (`__FILE__:__LINE__`), injected by macros; when absent, `_fail` falls back to backtrace walking via `find_caller_location()`
- On failure, call `_fail(_msg(msg, ...), _loc)` which throws `AssertionError`

## Macro naming convention

Each assertion needs a preprocessor macro in the corresponding granular header:

```pike
#define assert_XXXX(...) PUnit.assert_XXXX(__VA_ARGS__, UNDEFINED, __FILE__ + ":" + __LINE__)
```

- Use `PUnit.assert_XXXX` (fully qualified) to avoid recursive expansion
- `UNDEFINED` sentinel allows detecting omitted `msg`/`_loc`
- Granular headers: `equal.h`, `boolean.h`, `comparison.h`, `null.h`, `membership.h`, `exception.h`, `misc.h`, `collection.h`
- `macros.h` is the umbrella header that includes all granular headers

## Reporter interface

All reporters inherit `Reporter.pike` and implement 8 callbacks:

- `suite_started(name, num_tests)`
- `test_started(name)`
- `test_passed(name, elapsed_ms)`
- `test_failed(name, elapsed_ms, message, location)`
- `test_error(name, elapsed_ms, message, location)`
- `test_skipped(name, reason)`
- `suite_finished(passed, failed, errors, skipped, elapsed_ms)`
- `run_finished(all_results)`

Four built-in implementations: `DotReporter` (default), `VerboseReporter`, `TAPReporter`, `JUnitReporter`.

## Public API stability

These changes require a **MAJOR** version bump:
- Removing or renaming any `assert_*` function
- Changing the signature of any `assert_*` function
- Removing or renaming any Reporter callback
- Changing the `TestCase` lifecycle hook signatures
- Removing exported symbols from `module.pmod`

Backwards-compatible additions (new assertions, new optional parameters) are **MINOR**.
Bug fixes with no API change are **PATCH**.

## Internal vs public API

- `protected` members are internal — not part of the public API, may change between minor versions
- Helper functions prefixed with `_` (e.g., `_fail`, `_msg`, `_discover_test_methods`) are internal
- Constants prefixed with `_` are internal state
- The `Error.pmod` internals (`find_caller_location`, `format_location`) are used by the framework but may be called by advanced users — avoid breaking changes
