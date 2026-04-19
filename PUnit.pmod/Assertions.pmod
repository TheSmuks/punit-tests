//! PUnit Assertions — Module-level assertion functions.
//!
//! Users @tt{import PUnit;@} and call these directly. Each function
//! throws @ref{PUnit.Error.AssertionError@} on failure with an optional
//! caller-located source position.

import .Error;

// Helper: format the "expected X but got Y" message with optional user msg.
protected string _msg(string user_msg, string fmt, mixed ... args) {
  string detail = sprintf(fmt, @args);
  if (user_msg && sizeof(user_msg))
    return user_msg + " (" + detail + ")";
  return detail;
}

// Helper: throw an AssertionError with backtrace location.
protected void _fail(string msg, void|string _loc) {
  string loc;
  if (_loc && sizeof(_loc))
    loc = _loc;
  else {
    array bt = backtrace();
    loc = find_caller_location(bt);
  }
  throw(AssertionError(msg, loc));
}

// ── Equality ──────────────────────────────────────────────────────────

//! Assert that @expr{expected@} and @expr{actual@} are structurally equal
//! using Pike's @expr{equal()@}. This works for arrays, mappings, multisets,
//! and objects implementing @expr{_equal()@}.
void assert_equal(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (!equal(expected, actual))
    _fail(_msg(msg, "Expected %O but got %O", expected, actual), _loc);
}

//! Assert that @expr{expected@} and @expr{actual@} are @b{not@} equal.
void assert_not_equal(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (equal(expected, actual))
    _fail(_msg(msg, "Expected values to differ, but both were %O", expected), _loc);
}

// ── Boolean ───────────────────────────────────────────────────────────

//! Assert that @expr{val@} is truthy.
void assert_true(mixed val, void|string msg, void|string _loc) {
  if (!val)
    _fail(_msg(msg, "Expected truthy value but got %O", val), _loc);
}

//! Assert that @expr{val@} is falsy.
void assert_false(mixed val, void|string msg, void|string _loc) {
  if (val)
    _fail(_msg(msg, "Expected falsy value but got %O", val), _loc);
}

// ── Null / Undefined ──────────────────────────────────────────────────

//! Assert that @expr{val@} is @expr{0@} (zero-type 1, i.e. UNDEFINED/missing).
void assert_null(mixed val, void|string msg, void|string _loc) {
  if (val != 0)
    _fail(_msg(msg, "Expected null/0 but got %O", val), _loc);
}

//! Assert that @expr{val@} is not @expr{0@}.
void assert_not_null(mixed val, void|string msg, void|string _loc) {
  if (val == 0)
    _fail(_msg(msg, "Expected non-null value but got 0/UNDEFINED"), _loc);
}

//! Assert that @expr{val@} is a missing value (zero_type == 1).
//! Useful for checking that a mapping key is absent.
void assert_undefined(mixed val, void|string msg, void|string _loc) {
  if (zero_type(val) != 1)
    _fail(_msg(msg, "Expected UNDEFINED but got %O (zero_type=%d)", val, zero_type(val)), _loc);
}

// ── Comparison ────────────────────────────────────────────────────────

//! Assert @expr{a > b@}.
void assert_gt(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a > b))
    _fail(_msg(msg, "Expected %O > %O", a, b), _loc);
}

//! Assert @expr{a < b@}.
void assert_lt(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a < b))
    _fail(_msg(msg, "Expected %O < %O", a, b), _loc);
}

//! Assert @expr{a >= b@}.
void assert_gte(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a >= b))
    _fail(_msg(msg, "Expected %O >= %O", a, b), _loc);
}

//! Assert @expr{a <= b@}.
void assert_lte(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a <= b))
    _fail(_msg(msg, "Expected %O <= %O", a, b), _loc);
}

// ── Containment ───────────────────────────────────────────────────────

//! Assert that @expr{needle@} is found in @expr{haystack@}.
//! Works for strings (substring), arrays (@expr{search()@}),
//! and mappings (key lookup).
void assert_contains(mixed needle, mixed haystack, void|string msg, void|string _loc) {
  int found;
  if (stringp(haystack)) {
    found = has_value(haystack, needle);
  } else if (arrayp(haystack)) {
    found = has_value(haystack, needle);
  } else if (mappingp(haystack)) {
    found = !zero_type(haystack[needle]);
  } else if (multisetp(haystack)) {
    found = haystack[needle];
  } else {
    _fail(_msg(msg, "assert_contains: unsupported haystack type %s",
               basetype(haystack)), _loc);
    return;
  }
  if (!found)
    _fail(_msg(msg, "Expected %O to contain %O", haystack, needle), _loc);
}

// ── Exceptions ────────────────────────────────────────────────────────

//! Assert that calling @expr{fn@} throws an error.
//! If @expr{error_type@} is provided, the error must be of that program.
//! Returns the thrown error for further inspection.
//!
//! @param error_type
//!   Optional error program to match against (e.g., @expr{Error.Generic@}).
//! @param fn
//!   Function to call.
mixed assert_throws(void|program error_type, function fn, void|string msg, void|string _loc) {
  mixed err;
  int threw = 0;
  mixed result;
  if (mixed e = catch { result = fn(); }) {
    threw = 1;
    err = e;
  }
  if (!threw)
    _fail(_msg(msg, "Expected an exception but none was thrown"), _loc);
  if (error_type && err) {
    // Check if the thrown error matches the expected program.
    // Pike errors can be arrays ({error_object_or_string, backtrace})
    // or objects.
    object err_obj;
    if (arrayp(err)) {
      if (sizeof(err) > 0 && objectp(err[0]))
        err_obj = err[0];
    } else if (objectp(err)) {
      err_obj = err;
    }
    if (err_obj && programp(error_type)) {
      // Check if the error object's program is the expected one.
      // Pike objects implement _is_type or we check the program directly.
      // Simple approach: check if the object is an instance of the program.
      // We can do this by checking if the program of the object inherits
      // from or equals error_type.
      if (object_program(err_obj) != error_type) {
        // Also check if the object inherits from the expected type.
        // Pike doesn't have a simple isinstance(). We just compare programs.
        _fail(_msg(msg, "Expected %O but got %O", error_type,
                   object_program(err_obj)), _loc);
      }
    }
  }
  return err;
}

//! Overloaded: assert_throws with just a function (any error matches).
mixed assert_throws_fn(function fn, void|string msg, void|string _loc) {
  return assert_throws(UNDEFINED, fn, msg, _loc);
}

//! Assert that calling @expr{fn@} does @b{not@} throw.
//! Returns the function's return value.
mixed assert_no_throw(function fn, void|string msg, void|string _loc) {
  mixed result;
  if (mixed e = catch { result = fn(); }) {
    _fail(_msg(msg, "Expected no exception but one was thrown: %O", e), _loc);
  }
  return result;
}

// ── Explicit failure ──────────────────────────────────────────────────

//! Fail the test unconditionally with the given message.
void assert_fail(void|string msg, void|string _loc) {
  _fail(msg || "Test explicitly failed", _loc);
}

// ── Type checking ─────────────────────────────────────────────────────

//! Assert that @expr{val@} is of type @expr{expected_type@}.
//! @param expected_type
//!   A type string like @expr{"int"@}, @expr{"string"@}, @expr{"array"@},
//!   or a program.
void assert_type(mixed expected_type, mixed val, void|string msg, void|string _loc) {
  if (stringp(expected_type)) {
    string actual = sprintf("%t", val);
    if (actual != expected_type)
      _fail(_msg(msg, "Expected type %O but got %O (%O)", expected_type, actual, val), _loc);
  } else if (programp(expected_type)) {
    if (!objectp(val) || object_program(val) != expected_type)
      _fail(_msg(msg, "Expected program %O but got %O", expected_type,
                 objectp(val) ? object_program(val) : val), _loc);
  }
}

// ── String matching ───────────────────────────────────────────────────

//! Assert that @expr{str@} matches the regex @expr{pattern@}.
void assert_match(string pattern, string str, void|string msg, void|string _loc) {
  if (!Regexp(pattern)->match(str))
    _fail(_msg(msg, "Expected %O to match pattern %O", str, pattern), _loc);
}

// ── Numeric tolerance ─────────────────────────────────────────────────

//! Assert that @expr{expected@} and @expr{actual@} are within
//! @expr{tolerance@} of each other.
void assert_approx_equal(float expected, float actual, float tolerance,
                         void|string msg, void|string _loc) {
  float diff = abs(expected - actual);
  if (diff > tolerance)
    _fail(_msg(msg, "Expected %O ≈ %O (tolerance %O, diff %O)",
               expected, actual, tolerance, diff), _loc);
}
