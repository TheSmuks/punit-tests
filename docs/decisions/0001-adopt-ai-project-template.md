# ADR 0001: Adopt ai-project-template Standard

## Status

Accepted

## Date

2026-04-21

## Context

PUnit has grown to 28 assertion functions, 8 reporter formats, multiple CI workflows, and a comprehensive test suite. The project lacked several infrastructure standards that are common in well-maintained open-source projects:

- No editor configuration standardization (`.editorconfig`)
- No line-ending normalization (`.gitattributes`)
- No code quality thresholds documented
- No structured issue/PR templates
- No code ownership file
- No security policy
- No commit message enforcement in CI
- No changelog enforcement on PRs
- No large file rejection policy
- No architectural decision records

The ai-project-template provides a proven set of configuration files and CI workflows that fill these gaps with minimal adaptation for Pike projects.

## Decision

Adopt the ai-project-template v0.2.0 standard, adding 20 new files across four categories:

1. **Foundation files** -- `.editorconfig`, `.gitattributes`, `.architecture.yml`, `.template-version`, ADR template and initial record
2. **Agent configuration** -- OMP agent definitions for code review, ADR writing, and changelog updates
3. **GitHub community files** -- CODEOWNERS, PR template, issue templates, SECURITY.md, dependabot.yml
4. **Quality gate workflows** -- commit-lint, changelog-check, blob-size-policy CI checks

The existing `docs-check.yml` workflow is retained alongside the new `changelog-check.yml` because they serve complementary purposes: docs-check warns about stale documentation, while changelog-check blocks PRs without changelog entries.

All templates are adapted for Pike conventions: 2-space indentation, `//!` doc comments, `({})` array syntax, and `pike -M . run_tests.pike tests/` as the test command.

## Consequences

### Positive

- Consistent editor behavior across all contributors
- Enforced conventional commits in CI
- Required changelog entries on every PR
- Structured issue and PR templates reduce back-and-forth
- Code ownership is explicit
- Security reporting path is documented
- Architectural decisions are recorded for future reference
- Large binary files are automatically rejected

### Negative

- Slightly stricter CI requirements on PRs (commit message format, changelog entry)
- More files to maintain in `.github/` and `.omp/`
- Contributors must follow conventional commit format

### Risks

- Template version drift if ai-project-template evolves independently
  - Mitigated by `.template-version` tracking and ADR documentation
- False positives from changelog-check on trivial PRs (e.g., typo fixes)
  - Mitigated by using `skip-changelog` label support in the action
