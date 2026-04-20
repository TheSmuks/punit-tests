# Changelog

All notable changes to PUnit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `--retry=N` flag — automatically retry failed tests up to N times
- Thread cleanup on timeout — timed-out tests no longer leak threads
- Wrong-arity detection — tests with incorrect `test_data` arity are reported as errors
- `CONTRIBUTING.md` — standard contributing guide
- `.github/workflows/release.yml` — tag-triggered release workflow
- Comprehensive test suite (9 new test files):
  - `RetryEdgeCases.pike` — retry behavior edge cases
  - `TimeoutEdgeCases.pike` — timeout edge cases
  - `AssertThrowsEdgeCases.pike` — exception assertion edge cases
  - `AssertionFailureTests.pike` — 28 failure mode tests
  - `DiscoveryTests.pike` — compilation and discovery tests
  - `ErrorReportingTests.pike` — error type and format tests
  - `FilterTagTests.pike` — tag and filter tests
  - `ReporterTests.pike` — reporter output tests
  - `RetryTests.pike` — basic retry test

### Changed
- `TestSuite.pike` — retry logic, thread cleanup on timeout, wrong-arity detection
- `TestRunner.pike` — `retry` option passthrough
- `run_tests.pike` — added `--retry=N` CLI flag
- `PUnit.pmod/Assertions.pmod` — section comment normalization
- `.github/workflows/docs-check.yml` — removed `continue-on-error: true`

## [1.1.0] - 2026-04-20

### Added
- `ARCHITECTURE.md` — full architecture document with diagrams, data flow, and extension points
- `RELEASE.md` — release and tagging rules with version scheme and pre-release protocol
- Granular assertion headers (`equal.h`, `boolean.h`, `comparison.h`, `null.h`, `membership.h`, `exception.h`, `misc.h`, `collection.h`) for selective imports
- Collection assertions: `assert_each`, `assert_contains_only`, `assert_has_size`
- `assert_throws_message` — assert that a thrown error matches an expected message
- `skip()` function and `SkipError` class for runtime test skipping
- `skip_reasons` constant for annotating skipped tests with reasons
- Per-test timeout support (`--timeout` flag)
- Randomized test ordering (`--randomize`, `--seed` flags)
- Documentation sync protocol across AGENTS.md, SKILL.md, and ARCHITECTURE.md
- CI doc-sync workflow (`.github/workflows/docs-check.yml`)
- `CHANGELOG.md` for tracking notable changes
- Conventional commit conventions documented in AGENTS.md and ARCHITECTURE.md

### Changed
- `Assertions.pmod` expanded from 20 to 28 assertion functions
- `Error.pmod` now exports both `AssertionError` and `SkipError`
- `TestSuite.pike` handles timeout, randomized ordering, and skip reasons
- `.version` updated to v1.1.0
