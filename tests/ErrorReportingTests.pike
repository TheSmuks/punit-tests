//! Error reporting tests — verify error types, location, and formatting.

import PUnit;

// Test AssertionError creation and fields
void test_assertion_error_fields() {
  object err = PUnit.Error.AssertionError("test message", "file.pike:10");
  assert_equal(err->assertion_message, "test message");
  assert_equal(err->location, "file.pike:10");
  assert_true(err->is_assertion_error);
}

void test_assertion_error_no_location() {
  object err = PUnit.Error.AssertionError("no loc");
  assert_equal(err->assertion_message, "no loc");
  assert_equal(err->location, "");
}

void test_assertion_error_sprintf() {
  object err = PUnit.Error.AssertionError("msg", "loc.pike:5");
  string s = sprintf("%O", err);
  assert_contains("AssertionError", s);
  assert_contains("msg", s);
}

// Test SkipError creation and fields
void test_skip_error_fields() {
  object err = PUnit.Error.SkipError("not implemented");
  assert_equal(err->skip_reason, "not implemented");
  assert_true(err->is_skip_error);
}

void test_skip_error_sprintf() {
  object err = PUnit.Error.SkipError("reason");
  string s = sprintf("%O", err);
  assert_contains("SkipError", s);
  assert_contains("reason", s);
}

void test_skip_error_catchable() {
  mixed err = catch { PUnit.skip("test skip"); };
  assert_not_null(err);
  assert_true(err->is_skip_error);
  assert_equal(err->skip_reason, "test skip");
}

// Test format_location
void test_format_location_array() {
  string loc = PUnit.Error.format_location(({"test.pike", 42}));
  assert_equal(loc, "test.pike:42");
}

void test_format_location_null() {
  string loc = PUnit.Error.format_location(0);
  assert_equal(loc, "");
}

void test_format_location_empty_array() {
  string loc = PUnit.Error.format_location(({}));
  assert_equal(loc, "");
}

void test_format_location_with_path() {
  string loc = PUnit.Error.format_location(({"/path/to/test.pike", 10}));
  assert_equal(loc, "test.pike:10");
}

// Test that assertions throw with useful messages
void test_assert_equal_error_message() {
  mixed err = assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_equal("expected", "actual"); });
  assert_contains("expected", err->assertion_message);
  assert_contains("actual", err->assertion_message);
}

void test_assert_true_error_message() {
  mixed err = assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_true(0, "custom msg"); });
  assert_contains("custom msg", err->assertion_message);
  assert_contains("truthy", err->assertion_message);
}

void test_assert_type_error_message() {
  mixed err = assert_throws(PUnit.Error.AssertionError,
    lambda() { assert_type("string", 42); });
  assert_contains("string", err->assertion_message);
}
