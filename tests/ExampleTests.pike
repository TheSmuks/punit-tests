//! Basic example tests demonstrating PUnit features.
//!
//! Run with: pike -M . run_tests.pike tests/ExampleTests.pike

import PUnit;
inherit PUnit.TestCase;

constant test_tags = ([
  "test_addition": ({"math", "core"}),
  "test_subtraction": ({"math", "core"}),
  "test_multiplication": ({"math"}),
  "test_division": ({"math"}),
  "test_division_by_zero": ({"math", "error"}),
  "test_assertions": ({"core"}),
  "test_string_ops": ({"core"}),
  "test_comparison": ({"core"}),
  "test_containment": ({"core"}),
  "test_approx_equal": ({"math"}),
  "test_skipped": ({"slow"}),
  "test_param_add": ({"math", "param"}),
  "test_same_identity": ({"core"}),
  "test_not_same_identity": ({"core"}),
]);

protected object calc;

void setup() {
  calc = .Calculator.Calculator();
}

void teardown() {
  calc = 0;
}

void test_addition() {
  assert_equal(5, calc->add(5));
  assert_equal(8, calc->add(3));
}

void test_subtraction() {
  calc->add(10);
  assert_equal(7, calc->subtract(3));
  assert_equal(2, calc->subtract(5));
}

void test_multiplication() {
  calc->add(6);
  assert_equal(18, calc->multiply(3));
}

void test_division() {
  calc->add(10);
  assert_equal(5, calc->divide(2));
}

void test_division_by_zero() {
  assert_throws(UNDEFINED, lambda() { calc->divide(0); });
}

void test_assertions() {
  assert_true(1);
  assert_false(0);
  assert_null(0);
  assert_not_null(42);
}

void test_string_ops() {
  string greeting = "hello world";
  assert_equal(11, sizeof(greeting));
  assert_contains("world", greeting);
  assert_match("hello.*world", greeting);
}

void test_comparison() {
  assert_gt(10, 5);
  assert_lt(5, 10);
  assert_gte(10, 10);
  assert_lte(5, 10);
}

void test_containment() {
  array a = ({1, 2, 3, 4, 5});
  assert_contains(3, a);

  mapping m = (["key": "value"]);
  assert_contains("key", m);

  string s = "hello world";
  assert_contains("world", s);
}

void test_approx_equal() {
  assert_approx_equal(0.1 + 0.2, 0.3, 0.0001);
}

// Skipped test
constant skip_tests = (< "test_skipped" >);
void test_skipped() {
  assert_fail("This should not run");
}

void test_no_throw() {
  mixed result = assert_no_throw(lambda() { return 42; });
  assert_equal(42, result);
}

void test_same_identity() {
  array a = ({1, 2, 3});
  assert_same(a, a);  // Same object

  // Different objects with same content should NOT be same
  array b = ({1, 2, 3});
  assert_not_same(a, b);
  assert_equal(a, b);  // But structurally equal
}

void test_not_same_identity() {
  // Use arrays for a clear identity test (strings may be interned)
  array a1 = ({1});
  array a2 = ({1});
  assert_not_same(a1, a2);
}

void test_type_checks() {
  assert_type("int", 42);
  assert_type("string", "hello");
  assert_type("array", ({1, 2, 3}));
}

// ── Parameterized tests ───────────────────────────────────────────────

// test_data maps method names to arrays of row data. Each row is passed
// as a mapping argument to the test method. The runner expands these into
// individual test entries: test_param_add[0], test_param_add[1], etc.
constant test_data = ([
  "test_param_add": ({
    ([ "a": 1, "b": 1, "expected": 2 ]),
    ([ "a": 2, "b": 3, "expected": 5 ]),
    ([ "a": -1, "b": 1, "expected": 0 ]),
  }),
]);

void test_param_add(mapping p) {
  assert_equal(p->expected, p->a + p->b);
}

// ── Inline tag annotations ────────────────────────────────────────────

// Method names with __tag suffixes are auto-tagged. The base method name
// is everything before the first __. Tags from __suffixes are merged with
// explicit test_tags entries.
void test_inline_tagged__core__fast() {
  // Auto-tagged as {"core", "fast"}
  assert_true(1);
}
