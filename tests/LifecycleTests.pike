import PUnit;
inherit PUnit.TestCase;

int class_counter = 0;
int setup_class_calls = 0;

void setup_class() {
  class_counter = 10;
  setup_class_calls++;
}

void teardown_class() {
  class_counter = 0;
}

void test_counter_after_setup_class() {
  // setup_class should have set counter to 10
  assert_equal(10, class_counter);
}

void test_counter_still_10() {
  // Proves setup_class only ran once, not before each test
  assert_equal(10, class_counter);
  assert_equal(1, setup_class_calls);
}

void test_third_method_also_sees_class_state() {
  // All test methods see the same class-level state
  assert_equal(10, class_counter);
  assert_equal(1, setup_class_calls);
}
