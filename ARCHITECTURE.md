# PUnit Architecture

Adapted from [architecture.md](https://architecture.md/).

| Field | Value |
|-------|-------|
| Name | PUnit |
| Repository | github.com/TheSmuks/punit-tests |
| Version | 1.1.0 |
| Date | 2026-04-20 |

## Project Structure

```
PUnit.pmod/
  module.pmod            Re-exports Assertions + Version so `import PUnit` works
  Assertions.pmod        28 assertion functions with optional _loc parameter
  Version.pmod           `constant version = "1.1.0"`
  macros.h               Umbrella header including all granular headers
  equal.h                assert_equal, assert_not_equal, assert_same, assert_not_same
  boolean.h              assert_true, assert_false
  comparison.h           assert_gt, assert_lt, assert_gte, assert_lte
  null.h                 assert_null, assert_not_null, assert_undefined
  membership.h           assert_contains, assert_match
  exception.h            assert_throws, assert_throws_fn, assert_no_throw, assert_throws_message
  collection.h           assert_each, assert_contains_only, assert_has_size
  misc.h                 assert_fail, assert_type, assert_approx_equal
  Error.pmod             AssertionError, SkipError, find_caller_location, format_location
  TestCase.pike          Base class with lifecycle hooks (setup/teardown/setup_class/teardown_class)
  TestSuite.pike         Test discovery, parameterization, tag filtering, validation
  TestRunner.pike        CLI harness, file scanning, compilation, suite orchestration
  TestResult.pike        Per-test result container (pass/fail/error/skip)
  Reporter.pike          Base reporter interface (8 callbacks)
  DotReporter.pike       Dot-matrix console output (default)
  VerboseReporter.pike   Per-test status with details
  TAPReporter.pike       TAP v13 output
  JUnitReporter.pike     JUnit XML output
  Colors.pmod            ANSI color helpers
run_tests.pike              CLI entry point — parses flags, delegates to TestRunner
tests/
  ExampleTests.pike      Core assertion tests (41 test methods, 3 skipped)
  LifecycleTests.pike    setup/teardown lifecycle tests
  TimeoutTests.pike      Per-test timeout tests
  Calculator.pike        Parameterized test example
  .HangTest.pike         Timeout edge case (dot-prefixed, hidden)
  .BadSyntax.pike        Compilation error handling (dot-prefixed, hidden)
  Core/                  Nested test discovery examples
    RepositoryTests.pike
    ContractTests/
      RepositoryContract.pike
  Clients/
    ClientA/RepositoryTests.pike
    ClientB/RepositoryTests.pike
  Fixtures/
    DatabaseFixture.pike
pike.json                   Package manifest (name, version, description)
.version                    Version file (v1.1.0)
AGENTS.md                   Agent context file
.github/workflows/ci.yml    GitHub Actions CI (7-step matrix)
```

## System Diagram

```
CLI (run_tests.pike)
  │ parses flags, builds options mapping
  ▼
TestRunner
  │ scans directories, compiles .pike files via compile_string()
  │ discovers classes with test_* methods (duck-typing)
  │ builds TestSuite per file
  ▼
TestSuite
  │ discovers test methods (indices-based)
  │ expands parameterized tests (test_data → test_method[0..N])
  │ applies tag/method filtering
  │ validates class config (test_tags, skip_tests, test_data keys)
  │ runs setup_class → [setup → test → teardown]* → teardown_class
  ▼
TestCase (base class)        Reporter (callbacks)
  lifecycle hooks               suite_started / test_started
  skip_tests / skip_all         test_passed / test_failed
  test_tags / test_data         test_error / test_skipped
  skip_reasons / skip()         suite_finished / run_finished
  ▼
TestResult                    Error.pmod
  status: pass/fail/error/skip  AssertionError (assertion failures)
  elapsed_ms, message, location  SkipError (skip() calls)
  skip_reason                   find_caller_location() for backtrace
```

## Core Components

### Entry Point (`run_tests.pike`)

CLI argument parser and orchestrator. Parses command-line flags and delegates to TestRunner.

Supported flags: `-v`, `--tap`, `--junit`, `--tag`, `--filter`, `--strict`, `--timeout`, `--randomize`, `--seed`, `--list`, `--no-color`.

### Runner + Suite

- **TestRunner** handles file discovery and compilation. It scans directories for `.pike` files, reads and compiles each via `compile_string(source, filename)`, discovers objects with `test_*` methods (including inner classes), and builds a TestSuite per file.
- **TestSuite** handles per-class test discovery, filtering (by tags and method name patterns), parameterized test expansion, class config validation, and orchestrates the setup/test/teardown lifecycle.

### Assertions

28 functions in `Assertions.pmod`, organized by category:

| Category | Header | Functions |
|----------|--------|-----------|
| Equality | `equal.h` | `assert_equal`, `assert_not_equal`, `assert_same`, `assert_not_same` |
| Boolean | `boolean.h` | `assert_true`, `assert_false` |
| Comparison | `comparison.h` | `assert_gt`, `assert_lt`, `assert_gte`, `assert_lte` |
| Null | `null.h` | `assert_null`, `assert_not_null`, `assert_undefined` |
| Membership | `membership.h` | `assert_contains`, `assert_match` |
| Exception | `exception.h` | `assert_throws`, `assert_throws_fn`, `assert_no_throw`, `assert_throws_message` |
| Collection | `collection.h` | `assert_each`, `assert_contains_only`, `assert_has_size` |
| Misc | `misc.h` | `assert_fail`, `assert_type`, `assert_approx_equal` |

Each function accepts an optional `void|string msg` and `void|string _loc`. Granular headers (`.h` files) inject `__FILE__:__LINE__` via preprocessor macros, providing exact source locations on failure without requiring manual location arguments.

### Test Lifecycle

`TestCase` provides 4 lifecycle hooks:

- `setup()` / `teardown()` — per-test
- `setup_class()` / `teardown_class()` — per-class

`TestResult` records per-test outcome: status (`pass`/`fail`/`error`/`skip`), elapsed time in milliseconds, message, location, and skip reason.

The `skip()` function throws `SkipError` to mark a test as skipped at runtime.

### Error Types

Defined in `Error.pmod`:

- **AssertionError** — thrown on assertion failure. Carries `is_assertion_error = 1` for type-safe catch blocks.
- **SkipError** — thrown by `skip()`. Carries `is_skip_error = 1`.
- **`find_caller_location()`** — walks the Pike backtrace, skipping PUnit-internal frames, to locate the user's test code.
- **`format_location()`** — formats a file:line pair into a human-readable string.

### Reporters

Four implementations inheriting from the `Reporter` base class, which defines 8 callbacks:

| Reporter | Output |
|----------|--------|
| `DotReporter` | Single character per test (`.FES`) + summary. Default. |
| `VerboseReporter` | Per-test status line with name and details. |
| `TAPReporter` | TAP v13 compatible output. |
| `JUnitReporter` | JUnit XML file written to disk. |

Callbacks: `suite_started`, `test_started`, `test_passed`, `test_failed`, `test_error`, `test_skipped`, `suite_finished`, `run_finished`.

### Utilities

- **Colors.pmod** — 10 ANSI color helper functions with global enable/disable toggle.
- **Version.pmod** — exports `constant version = "1.1.0"`.
- **module.pmod** — re-exports `Assertions` and `Version` via inherit so `import PUnit` works.

## Data Flow

Full test run lifecycle:

1. CLI parses arguments into an options mapping.
2. `TestRunner.run()` scans directories for `.pike` files.
3. Each file is read and compiled via `compile_string(source, filename)`.
4. Compiled programs are instantiated; objects with `test_*` methods are discovered.
5. Inner classes are also checked for test methods.
6. A `TestSuite` is built per file with filtered classes.
7. `TestSuite` discovers methods, expands parameterized tests, applies tag/method filters.
8. Per class: `setup_class()` → per method: `[setup() → test_method() → teardown()]` → `teardown_class()`.
9. `AssertionError` / `SkipError` caught → `TestResult` created.
10. Results accumulated → Reporter callbacks fire at each stage.
11. `run_finished()` produces the final summary.
12. Exit code: 0 if all pass, 1 if any failure or error.

## Extension Points

### New Assertions

1. Add a function in `Assertions.pmod`. The last two parameters must be `void|string msg, void|string _loc`.
2. Add a macro in the appropriate granular `.h` file.
3. If a new category header is needed, add it and update `macros.h` (the umbrella header) to include it.

### New Reporters

Inherit `Reporter.pike` and implement any subset of the 8 callbacks. Pass the reporter instance to `TestRunner` via the options mapping.

### Lifecycle Hooks

Inherit `TestCase` and override any combination of `setup`, `teardown`, `setup_class`, `teardown_class`.

### Test Annotations

- `test_tags` — constant mapping method names to tag arrays.
- Inline tags — double-underscore suffixes in method names (e.g., `test_sort__fast__algo`).
- `skip_tests` — multiset of method names to skip.
- `skip_all` — constant `true` to skip an entire class.
- `skip_reasons` — mapping from method name to reason string.
- `skip()` — runtime function that throws `SkipError`.

### Parameterized Tests

Define a `test_data` constant: a mapping from method name to an array of row mappings. Each row mapping expands the method into a separate test case with a `[0..N]` suffix.

## Testing & CI

### GitHub Actions

CI runs on `ubuntu-latest` with a 7-step matrix: dot reporter, verbose, TAP, JUnit, strict mode, list mode, and upload artifact.

### Local Commands

```bash
# Default run
pike -M . run_tests.pike tests/

# Verbose output
pike -M . run_tests.pike tests/ -v

# TAP output
pike -M . run_tests.pike tests/ --tap

# JUnit XML
pike -M . run_tests.pike tests/ --junit=results.xml

# Strict validation
pike -M . run_tests.pike tests/ --strict

# List tests
pike -M . run_tests.pike tests/ --list=verbose

# Timeout + randomized order
pike -M . run_tests.pike tests/ --timeout=30 --randomize --seed=42
```

### Expected Baseline

41 passed, 3 skipped, exit code 0.

### Commit Conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/) 1.0.0:

```
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`, `perf`, `style`, `revert`

Scopes: `assert`, `runner`, `suite`, `reporter`, `lifecycle`, `error`

## Glossary

- **Test method** — Any method whose name starts with `test_`.
- **Duck-typing discovery** — The runner finds any class with `test_*` methods; no inheritance from `TestCase` is required.
- **Parameterized test** — A `test_data` constant that expands one method into N tests.
- **Inline tags** — Double-underscore suffixes in method names (e.g., `test_sort__fast__algo`).
- **skip_tests** — Multiset of method names to skip.
- **skip_all** — Constant set to `true` to skip an entire class.
- **skip_reasons** — Mapping from method name to reason string.
- **skip()** — Runtime function that throws `SkipError`.
- **Strict validation** — Treats `test_tags`/`skip_tests`/`test_data` key mismatches as errors rather than warnings.
- **Granular headers** — Individual `.h` files for selective assertion imports.
- **_loc parameter** — Exact source location (`__FILE__:__LINE__`) injected by preprocessor macros.
