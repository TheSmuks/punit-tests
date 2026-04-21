---
globs: ["PUnit.pmod/**/*.pmod", "PUnit.pmod/**/*.pike", "PUnit.pmod/**/*.h"]
alwaysApply: false
---

Any change to PUnit.pmod source files must update:

1. **CHANGELOG.md** — Add entry to `[Unreleased]` section (Added/Changed/Fixed as appropriate)
2. **ARCHITECTURE.md** — If the change is structural (new files, renamed files, new components, changed data flow, new extension points)
3. **AGENTS.md** — If test count changes, update the baseline (line 22: expected result)
4. **tests/AGENTS.md** — If test count changes, update the baseline section
5. **SKILL.md files** — If public API surface changes (new assertions, changed signatures), update `.agents/skills/punit-framework-dev/SKILL.md` and `.agents/skills/punit-write-test/SKILL.md`

Doc-only changes (comment rewrites, typo fixes in `//!` blocks) do NOT require this full sweep.
