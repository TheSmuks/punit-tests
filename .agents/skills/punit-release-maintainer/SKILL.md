---
name: punit-release-maintainer
description: Manage PUnit releases — version bumping, changelog formatting, tagging, and GitHub release workflow. Use when preparing a release, bumping versions, updating CHANGELOG.md, or creating release tags.
license: MIT
compatibility: Requires Pike 8.0.1116 or later
metadata:
  author: TheSmuks
  version: "1.0"
---

# PUnit Release Maintainer

## Version bumping (3-file sync)

Version is defined in three places. ALL THREE must be updated together:

1. `PUnit.pmod/Version.pmod` — `constant version = "x.y.z";`
2. `.version` — `vx.y.z` (with `v` prefix)
3. `pike.json` — `"version": "x.y.z"`

## Semver rules

| Increment | When |
|-----------|------|
| **PATCH** | Bug fixes, no new API surface, no behavioral changes. Existing tests pass unmodified. |
| **MINOR** | New assertions, new features, new optional parameters. Backwards-compatible. |
| **MAJOR** | Breaking API changes: removed functions, changed signatures, changed default behavior. |

## CHANGELOG.md formatting

Format: [Keep a Changelog](https://keepachangelog.com/). Structure:

```markdown
## [Unreleased]

### Added
- Description of new feature

### Changed
- Description of change

### Fixed
- Description of fix

## [x.y.z] - YYYY-MM-DD

### Added
- ...
```

On release: move items from `[Unreleased]` to a new version section with today's date.

## Tag and release workflow

1. Bump version in all 3 files
2. Update CHANGELOG.md — move `[Unreleased]` items to versioned section
3. Commit with message: `chore(release): Bump version to x.y.z`
4. Verify: `pike -M . run_tests.pike tests/` (must pass)
5. Push to `main`
6. Create annotated tag: `git tag -a vx.y.z -m "vx.y.z: brief summary"`
7. Push tag: `git push origin vx.y.z`
8. CI (`release.yml`) automatically creates GitHub Release via `softprops/action-gh-release@v2`

## GitHub release body format

```markdown
## What's New
- **Feature** — description

## Fixes
- **Fix** — description

## Breaking Changes
- None. (Or describe them.)

## Baseline
- **130 passed, 4 skipped, 0 failures**
```

## Pre-release checklist

From RELEASE.md:
1. Version bumped in all 3 files
2. CHANGELOG.md updated (versioned section with date)
3. All tests pass (`pike -M . run_tests.pike tests/`)
4. AGENTS.md baseline matches actual test count
5. ARCHITECTURE.md reflects any structural changes
6. SKILL.md files updated if API surface changed

## Pre-release versions

Suffixes: `-alpha.N`, `-beta.N`, `-rc.N` (e.g., `1.2.0-beta.1`). Mark GitHub release as pre-release.
