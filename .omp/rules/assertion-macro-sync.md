---
globs: ["PUnit.pmod/Assertions.pmod"]
alwaysApply: false
---

When adding a new assertion function to `Assertions.pmod`, you must also:

1. Add the corresponding `#define` macro in the appropriate granular header (`equal.h`, `boolean.h`, `comparison.h`, `null.h`, `membership.h`, `exception.h`, `collection.h`, or `misc.h`). Format:
   ```pike
   #define assert_XXXX(...) PUnit.assert_XXXX(__VA_ARGS__, UNDEFINED, __FILE__ + ":" + __LINE__)
   ```
   If creating a new category, add a new header file and include it in `macros.h`.
2. Update the assertion table in `README.md`.
3. Add test coverage in `tests/` — at minimum, a passing case and a failure case.
4. Update `CHANGELOG.md` [Unreleased] section with the new assertion.
5. Bump version: this is a MINOR bump (new public API surface).

Every assertion function signature must end with `void|string msg, void|string _loc`.
