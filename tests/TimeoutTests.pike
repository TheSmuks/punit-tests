//! Timeout tests — verify the --timeout feature works correctly.
//!
//! These tests must be run with --timeout=3 to verify timeout behavior.
//! Without --timeout, all tests should pass normally.

import PUnit;
inherit PUnit.TestCase;

void test_fast_completes() {
  // This test should always pass, even with a timeout
  assert_equal(2, 1 + 1);
}

void test_sleep_within_timeout() {
  // Sleep for 0.5s — should complete within any reasonable timeout
  sleep(0.5);
  assert_true(1);
}
