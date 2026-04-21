---
name: punit-ci-debug
description: Debug PUnit CI failures — triage workflow errors, reproduce failures locally, and fix common CI issues. Use when a GitHub Actions workflow is failing and needs diagnosis.
license: MIT
compatibility: Requires Pike 8.0.1116 or later
metadata:
  author: TheSmuks
  version: "1.0"
---

# PUnit CI Debug

## CI workflow structure

### ci.yml — Main test matrix (7 steps)
1. Install Pike (`pike8.0` via apt on `ubuntu-latest`)
2. Run tests (dot reporter) — `pike -M . run_tests.pike tests/`
3. Run tests (verbose reporter) — `pike -M . run_tests.pike -v tests/`
4. Run tests (TAP reporter) — `pike -M . run_tests.pike --tap tests/`
5. Run tests (JUnit XML) — `pike -M . run_tests.pike --junit=junit-report.xml tests/`
6. Run with --strict — `pike -M . run_tests.pike --strict tests/`
7. List tests — `pike -M . run_tests.pike --list=verbose tests/`
8. Upload JUnit report artifact

Triggered by: push to `main`, PRs to `main`, weekly schedule (Monday 06:00 UTC), manual dispatch.

### docs-check.yml — Documentation sync validation
Verifies that source changes are reflected in documentation.

### release.yml — Tag-triggered release
Triggered by pushing a `v*` tag. Creates GitHub Release via `softprops/action-gh-release@v2`.

## Common failure patterns

### Pike version mismatch
- Symptom: Compilation errors about missing Pike features
- Cause: CI installs `pike8.0` from apt, which may not be 8.0.1116+
- Fix: Check the installed Pike version in CI logs. If too old, the apt package needs updating or a manual Pike build step.

### Test count changes (baseline shift)
- Symptom: Tests pass locally but CI shows different counts
- Cause: New tests added without updating baseline docs
- Fix: Run `pike -M . run_tests.pike tests/` locally and verify the count matches `AGENTS.md` baseline (130 passed, 4 skipped)
- Update: Root `AGENTS.md` line 22 and `tests/AGENTS.md` baseline section

### Strict mode failures
- Symptom: `--strict` step fails while dot reporter passes
- Cause: `test_tags`, `skip_tests`, or `test_data` keys reference non-existent test methods
- Fix: Check the validation warnings in the verbose output, fix the key mismatches

### Doc sync failures
- Symptom: docs-check.yml fails
- Cause: Source file changed without updating CHANGELOG.md, ARCHITECTURE.md, or AGENTS.md
- Fix: Add entry to CHANGELOG.md [Unreleased] section; update ARCHITECTURE.md if structural; update AGENTS.md if test count changed

### Reporter output format issues
- Symptom: TAP or JUnit output malformed
- Cause: Bug in Reporter subclass
- Fix: Run `pike -M . run_tests.pike --tap tests/` locally and inspect the output

## Reproducing CI failures locally

```bash
# Replicate the exact CI steps
pike -M . run_tests.pike tests/              # dot
pike -M . run_tests.pike -v tests/           # verbose
pike -M . run_tests.pike --tap tests/        # TAP
pike -M . run_tests.pike --junit=/tmp/test.xml tests/  # JUnit
pike -M . run_tests.pike --strict tests/     # strict
pike -M . run_tests.pike --list=verbose tests/  # list
```

All must pass with: 130 passed, 4 skipped, exit code 0.

## Reading CI logs

1. Go to the failed workflow run in GitHub Actions
2. Expand each step to see its output
3. The failing step's output shows Pike stderr and the test summary
4. For compilation errors, look at the `Run tests (dot reporter)` step — it's the first to compile
5. For test failures, the summary line shows the count: `X passed, Y failed, Z errors, W skipped`
