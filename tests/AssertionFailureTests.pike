//! Assertion failure tests — verify error behavior when assertions fail.

import PUnit;
program GenericError = _static_modules.Builtin.GenericError;


// Verify that assert_equal throws AssertionError on mismatch
void test_assert_equal_failure() {
  mixed err = assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_equal(1, 2); });
  assert_true(arrayp(err) || objectp(err));
}

void test_assert_equal_array_diff() {
  mixed err = assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_equal(({1, 2, 3}), ({1, 4, 3})); });
  assert_true(arrayp(err) || objectp(err));
}

void test_assert_equal_mapping_diff() {
  mixed err = assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_equal((["a": 1]), (["a": 2])); });
  assert_true(arrayp(err) || objectp(err));
}

void test_assert_not_equal_failure() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_not_equal(5, 5); });
}

void test_assert_same_failure() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_same(({1}), ({1})); });
}

void test_assert_not_same_failure() {
  array a = ({1});
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_not_same(a, a); });
}

void test_assert_true_falsy_zero() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_true(0); });
}


void test_assert_false_truthy_one() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_false(1); });
}

void test_assert_false_truthy_string() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_false("hello"); });
}

void test_assert_null_nonzero() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_null(42); });
}

void test_assert_not_null_zero() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_not_null(0); });
}

void test_assert_undefined_defined_zero() {
  // 0 is defined (zero_type != 1), so assert_undefined should fail
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_undefined(0); });
}

void test_assert_gt_equal() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_gt(5, 5); });
}

void test_assert_gte_less() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_gte(4, 5); });
}

void test_assert_lt_equal() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_lt(5, 5); });
}

void test_assert_lte_greater() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_lte(6, 5); });
}

void test_assert_contains_string_missing() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_contains("xyz", "hello world"); });
}

void test_assert_contains_array_missing() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_contains(99, ({1, 2, 3})); });
}

void test_assert_contains_mapping_key_missing() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_contains("z", (["a": 1])); });
}

void test_assert_contains_unsupported_type() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_contains(1, 42); });
}

void test_assert_match_failure() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_match("^xyz", "hello"); });
}

void test_assert_approx_equal_beyond_tolerance() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_approx_equal(1.0, 2.0, 0.5); });
}

void test_assert_type_wrong_string() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_type("string", 42); });
}

void test_assert_type_wrong_program() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_type(PUnit.Error.AssertionError, 42); });
}

void test_assert_each_partial_failure() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_each(({2, 4, 5, 8}), lambda(int x) { return x % 2 == 0; }); });
}

void test_assert_contains_only_extra_elements() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_contains_only(({1, 2}), ({1, 2, 3})); });
}

void test_assert_has_size_mismatch() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_has_size(({1, 2, 3}), 5); });
}

void test_assert_has_size_unsupported_type() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_has_size(42, 1); });
}

void test_assert_fail_throws() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_fail("custom message"); });
}

void test_assert_throws_no_exception() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_throws(UNDEFINED, lambda() { 1 + 1; }); });
}

void test_assert_throws_wrong_type() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() {
      assert_throws(PUnit.Error.SkipError,
        lambda() { throw(({ GenericError("not a skip"), backtrace() })); });
    });
}

void test_assert_throws_message_wrong_message() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() {
      assert_throws_message(UNDEFINED, "nope",
        lambda() { throw(({ GenericError("actual error"), backtrace() })); });
    });
}

void test_assert_no_throw_when_thrown() {
  assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_no_throw(lambda() { throw(({ GenericError("boom"), backtrace() })); }); });
}
