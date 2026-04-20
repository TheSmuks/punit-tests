import PUnit;
inherit PUnit.TestCase;

protected int attempt_counter = 0;

void setup() {
  attempt_counter = 0;
}

void test_always_passes() {
  assert_true(1);
}

//! Verifies retry mechanics by counting invocations.
//! Without --retry: runs once, counter == 1 (passes).
//! With --retry=3: if retried, counter reflects retries.
void test_retry_invocation_count() {
  attempt_counter++;
  // Without retry, attempt_counter is 1. With retry on failure,
  // it would be higher. This always passes without retry.
  assert_gt(attempt_counter, 0, "Should have been called at least once");
  assert_lt(attempt_counter, 100, "Should not be called excessively");
}
