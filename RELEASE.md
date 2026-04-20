# Release and Tagging Rules

This project follows [Semantic Versioning](https://semver.org/). Every push to `main` that changes framework behavior, public API, or documentation ships with a version bump, git tag, and GitHub release.

## Version Scheme

Format: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)

| Increment | When |
|-----------|------|
| **PATCH** (`1.1.0` → `1.1.1`) | Bug fixes, no new API surface, no behavioral changes. Existing tests continue to pass without modification. |
| **MINOR** (`1.1.0` → `1.2.0`) | New assertions, new features, new optional parameters. Backwards-compatible — no test breakage. |
| **MAJOR** (`1.1.0` → `2.0.0`) | Breaking API changes: removed functions, changed signatures, changed default behavior. |

## When to Tag and Release

**Always** when any of the following land on `main`:

1. A new assertion function, reporter, or user-facing feature.
2. A bug fix that changes runtime behavior.
3. A breaking change to public API.
4. A version bump in `PUnit.pmod/Version.pmod`.

**Do NOT** tag for:
- Documentation-only changes to comments/`//!` blocks (no behavior change).
- Changes to `AGENTS.md`, `RELEASE.md`, or CI config.
- Test-only additions that don't change framework code.

## Checklist

For every release:

1. **Bump version** in `PUnit.pmod/Version.pmod` (`constant version = "x.y.z";`).
2. **Update CHANGELOG.md** — move relevant items from `[Unreleased]` to a new version section.
3. **Commit** with message: `Bump version to x.y.z`.
4. **Verify**: `pike -M . run_tests.pike tests/` passes.
5. **Push** to `main`.
6. **Create annotated tag**: `git tag -a vx.y.z -m "vx.y.z: brief summary"`.
7. **Push tag**: `git push origin vx.y.z`.
8. **Create GitHub Release** from the tag with a changelog sectioned by feature area.

## Changelog Format

The canonical changelog is `CHANGELOG.md` (Keep a Changelog format). The GitHub release body should mirror the relevant version section from `CHANGELOG.md`.

Use this structure in the GitHub release body:

```markdown
## What's New
- **Feature description** — brief explanation (#PR or commit)

## Fixes
- **Fix description** — what changed and why

## Breaking Changes
- None. (Or describe them.)

## Baseline
- **X passed, Y skipped, 0 failures**
```

## Pre-release Tags

Use `-alpha.N`, `-beta.N`, `-rc.N` suffixes for pre-release versions (e.g., `1.2.0-beta.1`). Mark the GitHub release as a pre-release. These do not require the full checklist — but tests must still pass.

## Documentation maintenance protocol

When any change lands on `main` that modifies:

- **Public API** (new functions, changed signatures, removed exports)
- **File structure** (new files, renamed files, removed files)
- **Test baseline** (new tests, changed skip counts)
- **Architecture** (new components, changed data flow, new extension points)

The following MUST be updated in the same commit:

1. **AGENTS.md** — project overview, architecture list, setup commands, expected test baseline
2. **SKILL.md** (`.agents/skills/*/SKILL.md`) — patterns, reference tables, verification checklist
3. **ARCHITECTURE.md** — project structure tree, component descriptions, data flow diagram

**Doc-only changes** (comment rewrites, typo fixes) do NOT require a full doc sweep.

**Version bumps** MUST verify all three docs reflect the new version.
