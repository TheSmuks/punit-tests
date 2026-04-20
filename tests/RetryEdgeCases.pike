//! Retry edge case tests — verify retry behavior.
//!
//! Run with --retry=2 to test retry behavior:
//!   pike -M . run_tests.pike --retry=2 tests/RetryEdgeCases.pike
//! Without --retry, all tests pass normally.

import PUnit;
inherit PUnit.TestCase;

protected int attempt_counter = 0;

void setup() {
  attempt_counter = 0;
}

void test_always_passes() {
  assert_true(1);
}

void test_passes_on_first_try() {
  attempt_counter++;
  assert_equal(1, attempt_counter);
}

void test_reliable_assertion() {
  // This test is deterministic — always passes
  assert_gt(10, 5);
  assert_lt(5, 10);
}

void test_state_isolation() {
  // Verify setup() resets state between tests
  assert_equal(attempt_counter, 0);
  attempt_counter++;
  assert_equal(attempt_counter, 1);
}

void test_parameterized_retry(array|mapping row) {
  // Parameterized test that should work with retry
  assert_true(sizeof(row) > 0 || mappingp(row) || arrayp(row));
}

// Simple parameterized data for the retry test
constant test_data = ([
  "test_parameterized_retry": ({
    ([ "value": 1 ]),
    ([ "value": 2 ]),
    ([ "value": 3 ]),
  }),
]);
