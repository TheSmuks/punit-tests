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

//! Produce a structured diff for complex values (arrays, mappings).
//! Returns a string with line-by-line differences, or empty string if not applicable.
protected string _diff_values(mixed expected, mixed actual) {
  // Only diff complex types
  if (!arrayp(expected) && !mappingp(expected)) return "";
  if (arrayp(expected) && !arrayp(actual)) return "";
  if (mappingp(expected) && !mappingp(actual)) return "";

  String.Buffer buf = String.Buffer();

  if (arrayp(expected)) {
    array ea = expected;
    array aa = actual;
    int max_len = max(sizeof(ea), sizeof(aa));
    if (max_len <= 20) {
      // Show element-by-element diff for small arrays
      buf->add("\n  Diff (array, " + sizeof(ea) + " expected, " + sizeof(aa) + " actual):\n");
      for (int i = 0; i < max_len; i++) {
        if (i < sizeof(ea) && i < sizeof(aa)) {
          if (!equal(ea[i], aa[i])) {
            buf->add(sprintf("    [%d] expected: %O\n", i, ea[i]));
            buf->add(sprintf("    [%d] actual:   %O\n", i, aa[i]));
          }
        } else if (i < sizeof(ea)) {
          buf->add(sprintf("    [%d] expected: %O  (missing in actual)\n", i, ea[i]));
        } else {
          buf->add(sprintf("    [%d] actual:   %O  (extra in actual)\n", i, aa[i]));
        }
      }
    }
  } else if (mappingp(expected)) {
    mapping em = expected;
    mapping am = actual;
    array all_keys = sort(Array.uniq(indices(em) + indices(am)));
    if (sizeof(all_keys) <= 20) {
      buf->add("\n  Diff (mapping, " + sizeof(em) + " expected, " + sizeof(am) + " actual):\n");
      foreach (all_keys; ; mixed key) {
        int in_exp = !zero_type(em[key]);
        int in_act = !zero_type(am[key]);
        if (in_exp && in_act) {
          if (!equal(em[key], am[key])) {
            buf->add(sprintf("    [%O] expected: %O\n", key, em[key]));
            buf->add(sprintf("    [%O] actual:   %O\n", key, am[key]));
          }
        } else if (in_exp) {
          buf->add(sprintf("    [%O] expected: %O  (missing in actual)\n", key, em[key]));
        } else {
          buf->add(sprintf("    [%O] actual:   %O  (extra in actual)\n", key, am[key]));
        }
      }
    }
  }

  return buf->get();
}

//! Assert that @expr{expected@} and @expr{actual@} are structurally equal
//! using Pike's @expr{equal()@}. This works for arrays, mappings, multisets,
//! and objects implementing @expr{_equal()@}.
//! For arrays and mappings, the failure message includes an element-by-element diff.
void assert_equal(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (!equal(expected, actual)) {
    string diff = _diff_values(expected, actual);
    _fail(_msg(msg, "Expected %O but got %O" + diff, expected, actual), _loc);
  }
}

//! Assert that @expr{expected@} and @expr{actual@} are @b{not@} equal.
void assert_not_equal(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (equal(expected, actual))
    _fail(_msg(msg, "Expected values to differ, but both were %O", expected), _loc);
}

//! Assert that @expr{expected@} and @expr{actual@} are the same object
//! (identity check using @expr{==@}). Unlike @expr{assert_equal@}, which uses
//! structural equality, this checks that both values reference the same object.
void assert_same(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (expected != actual)
    _fail(_msg(msg, "Expected same identity but got different objects: %O vs %O", expected, actual), _loc);
}

//! Assert that @expr{expected@} and @expr{actual@} are @b{not@} the same object.
void assert_not_same(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (expected == actual)
    _fail(_msg(msg, "Expected different identity but both are the same object: %O", expected), _loc);
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
      program actual_prog = object_program(err_obj);
      // Check exact match or inheritance
      if (actual_prog != error_type &&
          !Program.inherits(actual_prog, error_type)) {
        _fail(_msg(msg, "Expected %O (or subclass) but got %O", error_type,
                   actual_prog), _loc);
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
