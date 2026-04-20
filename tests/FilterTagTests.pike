//! Filter and tag tests — verify tag/metadata configuration.

import PUnit;

// Test that inline tags are correctly declared
constant test_tags = ([
  "test_tagged_math": ({"math"}),
  "test_tagged_slow": ({"slow", "integration"}),
  "test_tagged_core": ({"core"}),
]);

void test_tagged_math() {
  assert_true(1);
}

void test_tagged_slow() {
  assert_true(1);
}

void test_tagged_core() {
  assert_true(1);
}

// Inline tag methods (double-underscore suffix tags)
void test_inline_tagged__unit__fast() {
  // This method has inline tags "unit" and "fast"
  assert_true(1);
}

void test_another_inline__integration() {
  assert_true(1);
}

// Test that skip_tests multiset is valid
constant skip_tests = (< "test_skipped_by_filter" >);
constant skip_reasons = ([ "test_skipped_by_filter": "filtered out" ]);

void test_skipped_by_filter() {
  assert_fail("Should not run");
}

// Test method name follows filter pattern
void test_filter_match_alpha() {
  assert_true(1);
}

void test_filter_match_beta() {
  assert_true(1);
}

// Test that assert_contains works with multisets
void test_multiset_contains() {
  multiset ms = (<"a", "b", "c">);
  assert_contains("a", ms);
}

void test_multiset_contains_missing() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_contains("z", (<"a", "b">)); });
}

// Test method filter glob would match
void test_filter_glob_starts() {
  // This would match glob "test_filter_glob*"
  assert_true(1);
}
