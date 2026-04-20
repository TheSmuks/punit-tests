//! Hanging test — used to verify timeout kills hanging tests.
//! Do NOT run this without --timeout!
import PUnit;

void test_hangs_forever() {
  while (1) {
    sleep(0.1);
  }
  assert_true(1);
}
