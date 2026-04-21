//! Tests for selective import sub-modules.
//!
//! Verifies that @expr{import PUnit.Equal@} (and other categories) expose only
//! the allowed assertion functions, while @expr{import PUnit@} remains unchanged.

import PUnit;
inherit PUnit.TestCase;

// ── Equal category ─────────────────────────────────────────────────────

void test_equal_import_provides_assert_equal() {
  // Verify that the Equal sub-module exposes assert_equal
  mixed fn = PUnit.Equal["assert_equal"];
  assert_not_equal(UNDEFINED, fn, "PUnit.Equal.assert_equal should exist");
}

void test_equal_import_provides_assert_not_equal() {
  mixed fn = PUnit.Equal["assert_not_equal"];
  assert_not_equal(UNDEFINED, fn,
    "PUnit.Equal.assert_not_equal should exist");
}

void test_equal_import_provides_assert_same() {
  mixed fn = PUnit.Equal["assert_same"];
  assert_not_equal(UNDEFINED, fn, "PUnit.Equal.assert_same should exist");
}

void test_equal_import_provides_assert_not_same() {
  mixed fn = PUnit.Equal["assert_not_same"];
  assert_not_equal(UNDEFINED, fn,
    "PUnit.Equal.assert_not_same should exist");
}

void test_equal_import_hides_assert_true() {
  mixed fn = PUnit.Equal["assert_true"];
  assert_equal(UNDEFINED, fn,
    "PUnit.Equal should NOT expose assert_true");
}

void test_equal_import_hides_assert_null() {
  mixed fn = PUnit.Equal["assert_null"];
  assert_equal(UNDEFINED, fn,
    "PUnit.Equal should NOT expose assert_null");
}

void test_equal_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Equal));
  assert_equal(({ "assert_equal", "assert_not_equal",
                   "assert_not_same", "assert_same" }), idx);
}

// ── Boolean category ───────────────────────────────────────────────────

void test_boolean_import_provides_assert_true() {
  mixed fn = PUnit.Boolean["assert_true"];
  assert_not_equal(UNDEFINED, fn,
    "PUnit.Boolean.assert_true should exist");
}

void test_boolean_import_provides_assert_false() {
  mixed fn = PUnit.Boolean["assert_false"];
  assert_not_equal(UNDEFINED, fn,
    "PUnit.Boolean.assert_false should exist");
}

void test_boolean_import_hides_assert_equal() {
  mixed fn = PUnit.Boolean["assert_equal"];
  assert_equal(UNDEFINED, fn,
    "PUnit.Boolean should NOT expose assert_equal");
}

void test_boolean_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Boolean));
  assert_equal(({ "assert_false", "assert_true" }), idx);
}

// ── Comparison category ────────────────────────────────────────────────

void test_comparison_import_provides_all() {
  assert_not_equal(UNDEFINED, PUnit.Comparison["assert_gt"]);
  assert_not_equal(UNDEFINED, PUnit.Comparison["assert_lt"]);
  assert_not_equal(UNDEFINED, PUnit.Comparison["assert_gte"]);
  assert_not_equal(UNDEFINED, PUnit.Comparison["assert_lte"]);
}

void test_comparison_import_hides_others() {
  assert_equal(UNDEFINED, PUnit.Comparison["assert_equal"]);
  assert_equal(UNDEFINED, PUnit.Comparison["assert_true"]);
}

void test_comparison_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Comparison));
  assert_equal(({ "assert_gt", "assert_gte", "assert_lt", "assert_lte" }), idx);
}

// ── Null category ──────────────────────────────────────────────────────

void test_null_import_provides_all() {
  assert_not_equal(UNDEFINED, PUnit.Null["assert_null"]);
  assert_not_equal(UNDEFINED, PUnit.Null["assert_not_null"]);
  assert_not_equal(UNDEFINED, PUnit.Null["assert_undefined"]);
}

void test_null_import_hides_others() {
  assert_equal(UNDEFINED, PUnit.Null["assert_equal"]);
  assert_equal(UNDEFINED, PUnit.Null["assert_true"]);
}

void test_null_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Null));
  assert_equal(({ "assert_not_null", "assert_null", "assert_undefined" }), idx);
}

// ── Membership category ────────────────────────────────────────────────

void test_membership_import_provides_all() {
  assert_not_equal(UNDEFINED, PUnit.Membership["assert_contains"]);
  assert_not_equal(UNDEFINED, PUnit.Membership["assert_match"]);
}

void test_membership_import_hides_others() {
  assert_equal(UNDEFINED, PUnit.Membership["assert_equal"]);
  assert_equal(UNDEFINED, PUnit.Membership["assert_true"]);
}

void test_membership_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Membership));
  assert_equal(({ "assert_contains", "assert_match" }), idx);
}

// ── Exception category ─────────────────────────────────────────────────

void test_exception_import_provides_all() {
  assert_not_equal(UNDEFINED, PUnit.Exception["assert_throws"]);
  assert_not_equal(UNDEFINED, PUnit.Exception["assert_throws_fn"]);
  assert_not_equal(UNDEFINED, PUnit.Exception["assert_no_throw"]);
  assert_not_equal(UNDEFINED, PUnit.Exception["assert_throws_message"]);
}

void test_exception_import_hides_others() {
  assert_equal(UNDEFINED, PUnit.Exception["assert_equal"]);
  assert_equal(UNDEFINED, PUnit.Exception["assert_true"]);
}

void test_exception_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Exception));
  assert_equal(({ "assert_no_throw", "assert_throws", "assert_throws_fn",
                   "assert_throws_message" }), idx);
}

// ── Collection category ────────────────────────────────────────────────

void test_collection_import_provides_all() {
  assert_not_equal(UNDEFINED, PUnit.Collection["assert_each"]);
  assert_not_equal(UNDEFINED, PUnit.Collection["assert_contains_only"]);
  assert_not_equal(UNDEFINED, PUnit.Collection["assert_has_size"]);
}

void test_collection_import_hides_others() {
  assert_equal(UNDEFINED, PUnit.Collection["assert_equal"]);
  assert_equal(UNDEFINED, PUnit.Collection["assert_true"]);
}

void test_collection_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Collection));
  assert_equal(({ "assert_contains_only", "assert_each",
                   "assert_has_size" }), idx);
}

// ── Misc category ──────────────────────────────────────────────────────

void test_misc_import_provides_all() {
  assert_not_equal(UNDEFINED, PUnit.Misc["assert_fail"]);
  assert_not_equal(UNDEFINED, PUnit.Misc["assert_type"]);
  assert_not_equal(UNDEFINED, PUnit.Misc["assert_approx_equal"]);
}

void test_misc_import_hides_others() {
  assert_equal(UNDEFINED, PUnit.Misc["assert_equal"]);
  assert_equal(UNDEFINED, PUnit.Misc["assert_true"]);
}

void test_misc_indices_are_correct() {
  array(string) idx = sort(indices(PUnit.Misc));
  assert_equal(({ "assert_approx_equal", "assert_fail",
                   "assert_type" }), idx);
}

// ── Functional tests: actually call through sub-modules ────────────────

void test_equal_assertion_works_via_submodule() {
  // Calling the function directly through the sub-module
  PUnit.Equal.assert_equal(42, 42);
  PUnit.Equal.assert_not_equal(1, 2);
  // If we get here, no exception was thrown — pass
  assert_true(1);
}

void test_boolean_assertion_works_via_submodule() {
  PUnit.Boolean.assert_true(1);
  PUnit.Boolean.assert_false(0);
}

void test_comparison_assertion_works_via_submodule() {
  PUnit.Comparison.assert_gt(10, 5);
  PUnit.Comparison.assert_lt(5, 10);
  PUnit.Comparison.assert_gte(10, 10);
  PUnit.Comparison.assert_lte(5, 10);
}

void test_null_assertion_works_via_submodule() {
  PUnit.Null.assert_null(0);
  PUnit.Null.assert_not_null(42);
}

// ── Full import still works ────────────────────────────────────────────

void test_full_import_unchanged() {
  // These all come from the top-level import PUnit
  assert_equal(1, 1);
  assert_true(1);
  assert_false(0);
  assert_null(0);
  assert_not_null(1);
  assert_gt(10, 5);
  assert_contains(1, ({ 1, 2, 3 }));
}

// ── Arrow operator mirrors bracket operator ────────────────────────────

void test_arrow_operator_matches_bracket() {
  assert_equal(PUnit.Equal["assert_equal"], PUnit.Equal->assert_equal,
    "-> and [] should return the same function");
  assert_equal(UNDEFINED, PUnit.Equal["assert_true"],
    "-> for hidden symbol should be UNDEFINED");
}
