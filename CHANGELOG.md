# Changelog

All notable changes to PUnit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/2.0.0.html).

## [Unreleased]

## [1.3.0] - 2026-05-01

### Fixed
- Renamed `PUnit.Process` to `PUnit.Subprocess` to avoid shadowing Pike's system `Process` module — no more forwarding workaround needed (fixes #6)

## [1.2.0] - 2026-05-01

### Added
- `.editorconfig` — editor consistency for Pike, YAML, Markdown files
- `.gitattributes` — line ending normalization (LF) for Pike source files
- `.architecture.yml` — code quality thresholds documented
- `.template-version` — tracks ai-project-template v0.2.0
- `docs/decisions/` — architectural decision record template and initial ADR
- `.omp/agents/` — code-reviewer, adr-writer, changelog-updater agent definitions
- `.omp/settings.json` — project configuration
- `.github/CODEOWNERS` — default code ownership
- `.github/PULL_REQUEST_TEMPLATE.md` — structured PR template
- `.github/ISSUE_TEMPLATE/` — bug report and feature request templates
- `.github/SECURITY.md` — security reporting policy
- `.github/dependabot.yml` — weekly GitHub Actions dependency updates
- `.github/workflows/commit-lint.yml` — conventional commit enforcement
- `.github/workflows/changelog-check.yml` — changelog entry requirement on PRs
- `.github/workflows/blob-size-policy.yml` — large file rejection (> 1MB)
- Category sub-modules for selective assertion imports (`import PUnit.Equal`, `import PUnit.Boolean`, etc.)
- 9 sub-module files: `Equal.pmod`, `Boolean.pmod`, `Comparison.pmod`, `Null.pmod`, `Membership.pmod`, `Exception.pmod`, `Collection.pmod`, `Misc.pmod`, `Process.pmod`
- `scripts/generate_macros.pike` — auto-generates all granular `.h` files from `Assertions.pmod`
- `tests/SelectiveImportTests.pike` — 35 tests verifying category sub-module behavior
- `--retry=N` flag — automatically retry failed tests up to N times
- Thread cleanup on timeout — timed-out tests no longer leak threads
- Wrong-arity detection — tests with incorrect `test_data` arity are reported as errors
- `CONTRIBUTING.md` — standard contributing guide
- `.github/workflows/release.yml` — tag-triggered release workflow
- Comprehensive test suite (10 new test files):
  - `RetryEdgeCases.pike` — retry behavior edge cases
  - `TimeoutEdgeCases.pike` — timeout edge cases
  - `AssertThrowsEdgeCases.pike` — exception assertion edge cases
  - `AssertionFailureTests.pike` — 28 failure mode tests
  - `DiscoveryTests.pike` — compilation and discovery tests
  - `ErrorReportingTests.pike` — error type and format tests
  - `FilterTagTests.pike` — tag and filter tests
  - `ReporterTests.pike` — reporter output tests
  - `RetryTests.pike` — basic retry test
  - `RunProcessTests.pike` — 12 tests for run_process utility
- `PUnit.pmod/Summary.pmod` — shared summary formatting for console reporters
- `run_process()` utility function — wraps `Process.run()` to return `({exit_code, stdout, stderr})`, avoiding the `Process.Process()->status()` footgun (closes #5)
- `PUnit.pmod/Process.pmod` — selective import module exposing `run_process`

### Changed
- `TestSuite.pike` — replaced hand-rolled LCG PRNG with `Nettle.Fortuna` for deterministic shuffle (`--randomize --seed`)
- `TestSuite.pike` — tag dedup uses multiset union instead of foreach + `has_value`
- `JUnitReporter.pike` — uses `Parser.XML.Tree` instead of manual `String.Buffer` XML construction
- `run_tests.pike` — replaced hand-rolled CLI parser with `Getopt.find_all_options`
- `Error.pmod` — uses `basename()` efun instead of manual `file / "/"` split
- `TestRunner.pike` — uses `basename()` efun in `_extract_class_name`
- `Assertions.pmod` — uses `(multiset)expected` cast instead of manual loop
- `TestSuite.pike` — retry logic, thread cleanup on timeout, wrong-arity detection
- `TestRunner.pike` — `retry` option passthrough
- `run_tests.pike` — added `--retry=N` CLI flag
- `PUnit.pmod/Assertions.pmod` — section comment normalization
- `.github/workflows/docs-check.yml` — removed `continue-on-error: true`

### Fixed
- `PUnit.pmod/equal.h` — fixed `assert_same`/`assert_not_same` using C-style string concatenation instead of Pike `+` operator

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
