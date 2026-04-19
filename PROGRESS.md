# PMP Implementation Progress Tracker

## Plan source: local://PMP_PACKAGE_MANAGER_DESIGN.md

## Phase 1: PUnit repo changes (TheSmuks/punit-tests)

### task-1: Create PUnit.pmod/Version.pmod
- [x] Create file with `constant version = "1.0.0";`

### task-2: Create granular .h headers (6 files)
- [x] PUnit.pmod/equal.h — assert_equal, assert_not_equal
- [x] PUnit.pmod/boolean.h — assert_true, assert_false
- [x] PUnit.pmod/comparison.h — assert_gt, assert_lt, assert_gte, assert_lte
- [x] PUnit.pmod/null.h — assert_null, assert_not_null, assert_undefined
- [x] PUnit.pmod/membership.h — assert_contains, assert_match
- [x] PUnit.pmod/exception.h — assert_throws, assert_throws_fn, assert_no_throw
- [x] PUnit.pmod/misc.h — assert_fail, assert_type, assert_approx_equal

### task-3: Update macros.h to include granular headers
- [x] Replace inline macros with #include of the 7 granular headers

### task-4: Create .version file
- [x] Write "v1.0.0" to .version

### task-5: Create pike.json
- [x] Self-referencing manifest

### task-6: Add --version flag to run_tests.pike
- [x] Parse --version, output version, exit 0

### task-7: Verify existing tests pass
- [x] Run `pike -M . run_tests.pike tests/` — 28 passed, 1 skipped
- [x] `pike -M . run_tests.pike --version` → "PUnit 1.0.0"
- [x] `PUnit.version` → "1.0.0"

## Phase 2: Create pmp repo (TheSmuks/pmp)

### task-8: Create GitHub repo
- [x] TheSmuks/pmp created, pushed to main branch

### task-9: Create bin/pike wrapper
- [x] POSIX shell script that injects PIKE_MODULE_PATH and execs real pike
- [x] Walks up directories to find pike.json
- [x] Handles .h files via PIKE_INCLUDE_PATH

### task-10: Create bin/pmp CLI
- [x] install, update, list, clean, init, run, version subcommands
- [x] GitHub tag-based version resolution

### task-11: Create test suite
- [x] tests/test_install.sh — 6 tests passing

### task-12: Push all files to GitHub
- [x] Pushed to https://github.com/TheSmuks/pmp

## Recovery instructions for compact
1. Read this file to see what's done — everything is done
2. All deliverables from the plan are complete
3. PUnit tests pass: 28 passed, 1 skipped
4. pmp tests pass: 6 passed, 0 failed
