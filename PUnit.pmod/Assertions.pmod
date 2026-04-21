//! PUnit Assertions — Module-level assertion functions.
//!
//! Users @tt{import PUnit;@} and call these directly. Each function
//! throws @ref{PUnit.Error.AssertionError@} on failure with an optional
//! caller-located source position.

import .Error;

//! Helper: format the "expected X but got Y" message with optional user msg.
//!
//! @param user_msg
//!   Optional user message prefix.
//! @param fmt
//!   sprintf format string for the detail message.
//! @returns
//!   Formatted message string combining user message and detail.
protected string _msg(string user_msg, string fmt, mixed ... args) {
  string detail = sprintf(fmt, @args);
  if (user_msg && sizeof(user_msg))
    return user_msg + " (" + detail + ")";
  return detail;
}

//! Helper: throw an AssertionError with backtrace location.
//!
//! @param msg
//!   Error message.
//! @param _loc
//!   Optional source location string (@expr{"file:line"}@).
//! @throws AssertionError
//!   Always throws on call.
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

// ── Equality assertions ──────────────────────────────────────────────

//! Produce a structured diff for complex values (arrays, mappings).
//! Returns a string with line-by-line differences, or empty string if not applicable.
//!
//! @param expected
//!   Expected value to diff against.
//! @param actual
//!   Actual value to compare.
//! @returns
//!   Diff string for arrays and mappings, or empty string for other types.
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
//!
//! @param expected
//!   Expected value.
//! @param actual
//!   Actual value to compare.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If values are not structurally equal.
//! @seealso assert_not_equal, assert_same
void assert_equal(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (!equal(expected, actual)) {
    string diff = _diff_values(expected, actual);
    _fail(_msg(msg, "Expected %O but got %O" + diff, expected, actual), _loc);
  }
}

//! Assert that @expr{expected@} and @expr{actual@} are @b{not@} equal.
//!
//! @param expected
//!   Value that should differ from actual.
//! @param actual
//!   Actual value to compare.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If values are structurally equal.
//! @seealso assert_equal
void assert_not_equal(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (equal(expected, actual))
    _fail(_msg(msg, "Expected values to differ, but both were %O", expected), _loc);
}

//! Assert that @expr{expected@} and @expr{actual@} are the same object
//! (identity check using @expr{==@}). Unlike @expr{assert_equal@}, which uses
//! structural equality, this checks that both values reference the same object.
//!
//! @param expected
//!   Expected object identity.
//! @param actual
//!   Actual value to compare.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If values are not the same object.
//! @seealso assert_equal, assert_not_same
void assert_same(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (expected != actual)
    _fail(_msg(msg, "Expected same identity but got different objects: %O vs %O", expected, actual), _loc);
}

//! Assert that @expr{expected@} and @expr{actual@} are @b{not@} the same object.
//!
//! @param expected
//!   Value that should not be the same object.
//! @param actual
//!   Actual value to compare.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If values are the same object.
//! @seealso assert_same
void assert_not_same(mixed expected, mixed actual, void|string msg, void|string _loc) {
  if (expected == actual)
    _fail(_msg(msg, "Expected different identity but both are the same object: %O", expected), _loc);
}
// ── Boolean assertions ──────────────────────────────────────────────

//! Assert that @expr{val@} is truthy.
//!
//! @param val
//!   Value to check.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If value is falsy.
//! @seealso assert_false
void assert_true(mixed val, void|string msg, void|string _loc) {
  if (!val)
    _fail(_msg(msg, "Expected truthy value but got %O", val), _loc);
}

//! Assert that @expr{val@} is falsy.
//!
//! @param val
//!   Value to check.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If value is truthy.
//! @seealso assert_true
void assert_false(mixed val, void|string msg, void|string _loc) {
  if (val)
    _fail(_msg(msg, "Expected falsy value but got %O", val), _loc);
}

// ── Null assertions ─────────────────────────────────────────────────

//! Assert that @expr{val@} is @expr{0@} (zero-type 1, i.e. UNDEFINED/missing).
//!
//! @param val
//!   Value to check.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If value is not @expr{0@}.
//! @seealso assert_not_null
void assert_null(mixed val, void|string msg, void|string _loc) {
  if (val != 0)
    _fail(_msg(msg, "Expected null/0 but got %O", val), _loc);
}

//! Assert that @expr{val@} is not @expr{0@}.
//!
//! @param val
//!   Value to check.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If value is @expr{0@}.
//! @seealso assert_null
void assert_not_null(mixed val, void|string msg, void|string _loc) {
  if (val == 0)
    _fail(_msg(msg, "Expected non-null value but got 0/UNDEFINED"), _loc);
}

//! Assert that @expr{val@} is a missing value (zero_type == 1).
//! Useful for checking that a mapping key is absent.
//!
//! @param val
//!   Value to check.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If value is not undefined.
//! @note
//!   Checks @expr{zero_type(val)==1@}, which is different from @expr{==0@}.
//! @seealso assert_null
void assert_undefined(mixed val, void|string msg, void|string _loc) {
  if (zero_type(val) != 1)
    _fail(_msg(msg, "Expected UNDEFINED but got %O (zero_type=%d)", val, zero_type(val)), _loc);
}

// ── Comparison assertions ───────────────────────────────────────────

//! Assert @expr{a > b@}.
//!
//! @param a
//!   Left-hand value.
//! @param b
//!   Right-hand value.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If @expr{a@} is not greater than @expr{b@}.
//! @seealso assert_gte, assert_lt
void assert_gt(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a > b))
    _fail(_msg(msg, "Expected %O > %O", a, b), _loc);
}

//! Assert @expr{a < b@}.
//!
//! @param a
//!   Left-hand value.
//! @param b
//!   Right-hand value.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If @expr{a@} is not less than @expr{b@}.
//! @seealso assert_lte, assert_gt
void assert_lt(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a < b))
    _fail(_msg(msg, "Expected %O < %O", a, b), _loc);
}

//! Assert @expr{a >= b@}.
//!
//! @param a
//!   Left-hand value.
//! @param b
//!   Right-hand value.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If @expr{a@} is less than @expr{b@}.
//! @seealso assert_gt, assert_lte
void assert_gte(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a >= b))
    _fail(_msg(msg, "Expected %O >= %O", a, b), _loc);
}

//! Assert @expr{a <= b@}.
//!
//! @param a
//!   Left-hand value.
//! @param b
//!   Right-hand value.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If @expr{a@} is greater than @expr{b@}.
//! @seealso assert_lt, assert_gte
void assert_lte(mixed a, mixed b, void|string msg, void|string _loc) {
  if (!(a <= b))
    _fail(_msg(msg, "Expected %O <= %O", a, b), _loc);
}

// ── Membership assertions ──────────────────────────────────────────

//! Assert that @expr{needle@} is found in @expr{haystack@}.
//! Works for strings (substring), arrays (@expr{search()@}),
//! and mappings (key lookup).
//!
//! @param needle
//!   Value to search for.
//! @param haystack
//!   Container to search in (string, array, mapping, or multiset).
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If needle is not found in haystack, or haystack type is unsupported.
//! @seealso assert_match
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

// ── Exception assertions ────────────────────────────────────────────

//! Assert that calling @expr{fn@} throws an error.
//! If @expr{error_type@} is provided, the error must be of that program.
//! Returns the thrown error for further inspection.
//!
//! @param error_type
//!   Optional error program to match against (e.g., @expr{Error.Generic@}).
//! @param fn
//!   Function to call.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @returns
//!   The thrown error object/array for further inspection.
//! @throws AssertionError
//!   If @expr{fn@} does not throw, or throws wrong type.
//! @seealso assert_throws_fn, assert_no_throw
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
//!
//! @param fn
//!   Function to call.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @returns
//!   The thrown error.
//! @throws AssertionError
//!   If @expr{fn@} does not throw.
//! @seealso assert_throws
mixed assert_throws_fn(function fn, void|string msg, void|string _loc) {
  return assert_throws(UNDEFINED, fn, msg, _loc);
}

//! Assert that calling @expr{fn@} does @b{not@} throw.
//! Returns the function's return value.
//!
//! @param fn
//!   Function expected not to throw.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @returns
//!   The return value of @expr{fn()@}.
//! @throws AssertionError
//!   If @expr{fn@} throws.
//! @seealso assert_throws
mixed assert_no_throw(function fn, void|string msg, void|string _loc) {
  mixed result;
  if (mixed e = catch { result = fn(); }) {
    _fail(_msg(msg, "Expected no exception but one was thrown: %O", e), _loc);
  }
  return result;
}

//! Extract a human-readable message string from a Pike error.
//!
//! @param err
//!   A Pike error (string, array, or object).
//! @returns
//!   The error message string.
string _extract_error_message(mixed err) {
  if (stringp(err)) return err;
  if (arrayp(err) && sizeof(err) > 0) {
    if (stringp(err[0])) return err[0];
    if (objectp(err[0])) {
      if (err[0]->assertion_message)
        return err[0]->assertion_message;
      if (functionp(err[0]->message))
        return err[0]->message() || sprintf("%O", err[0]);
      return sprintf("%O", err[0]);
    }
  }
  if (objectp(err)) {
    if (err->assertion_message)
      return err->assertion_message;
    if (functionp(err->message))
      return err->message() || sprintf("%O", err);
    return sprintf("%O", err);
  }
  return sprintf("%O", err);
}

//! Assert that calling @expr{fn@} throws an error of the expected type
//! AND that the error message contains @expr{expected_message@}.
//!
//! The message check supports both substring matching (default) and
//! regex matching (when @expr{is_regex@} is non-zero).
//!
//! @param error_type
//!   Error program to match against (e.g., @expr{Error.Generic@}),
//!   or @expr{UNDEFINED@} to match any error.
//! @param expected_message
//!   String to search for in the error message (substring or regex).
//! @param fn
//!   Function to call.
//! @param is_regex
//!   If non-zero, treat @expr{expected_message@} as a regex pattern.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"@}); auto-filled by macros.h.
//! @returns
//!   The thrown error object/array for further inspection.
//! @throws AssertionError
//!   If @expr{fn@} does not throw, throws wrong type, or message doesn't match.
//! @seealso assert_throws, assert_no_throw
mixed assert_throws_message(void|program error_type, string expected_message,
                            function fn, void|int is_regex,
                            void|string msg, void|string _loc) {
  // First, delegate type checking to assert_throws
  mixed err = assert_throws(error_type, fn, msg, _loc);

  // Extract the error message string
  string actual_message = _extract_error_message(err);

  // Check message match
  int matches;
  if (is_regex) {
    matches = Regexp(expected_message)->match(actual_message);
  } else {
    matches = has_value(actual_message, expected_message);
  }

  if (!matches) {
    string match_type = is_regex ? "match regex" : "contain";
    _fail(_msg(msg,
      "Expected error message to %s %O but got %O",
      match_type, expected_message, actual_message), _loc);
  }

  return err;
}

// ── Collection assertions ──────────────────────────────────────────

//! Assert that @expr{checker@} returns true for every element in @expr{items@}.
//!
//! On failure, reports which elements (by index) failed the check,
//! with their values.
//!
//! @param items
//!   Array of elements to check.
//! @param checker
//!   Function that takes one element and returns non-zero if it passes.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If any element fails the checker.
void assert_each(array items, function checker,
                 void|string msg, void|string _loc) {
  array(int) failed_indices = ({});
  array failed_values = ({});
  foreach (items; int i; mixed item) {
    if (!checker(item)) {
      failed_indices += ({ i });
      failed_values += ({ item });
    }
  }
  if (sizeof(failed_indices) > 0) {
    String.Buffer buf = String.Buffer();
    buf->add(sprintf("assert_each: %d of %d elements failed",
                     sizeof(failed_indices), sizeof(items)));
    if (sizeof(failed_indices) <= 10) {
      for (int j = 0; j < sizeof(failed_indices); j++) {
        buf->add(sprintf("\n  [%d] %O", failed_indices[j], failed_values[j]));
      }
    }
    _fail(_msg(msg, buf->get()), _loc);
  }
}

//! Assert that @expr{actual@} contains only elements from @expr{expected@}.
//!
//! Both arrays are treated as sets — duplicates and order are ignored.
//! Fails if @expr{actual@} has any element not in @expr{expected@}.
//!
//! @param expected
//!   Array of allowed values.
//! @param actual
//!   Array to check.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If actual contains elements not in expected.
void assert_contains_only(array expected, array actual,
                          void|string msg, void|string _loc) {
  multiset allowed = (multiset)expected;
  array extra = ({});
  foreach (actual; ; mixed v) {
    if (!allowed[v]) extra += ({ v });
  }
  if (sizeof(extra) > 0) {
    _fail(_msg(msg,
      "Expected only elements from %O but found extra: %O",
      expected, extra), _loc);
  }
}

//! Assert that @expr{collection@} has the expected number of elements.
//!
//! Works with arrays, mappings, multisets, and strings.
//!
//! @param collection
//!   The collection to check (array, mapping, multiset, or string).
//! @param expected_size
//!   Expected number of elements/characters.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If the collection size does not match.
void assert_has_size(mixed collection, int expected_size,
                     void|string msg, void|string _loc) {
  int actual_size;
  if (arrayp(collection) || stringp(collection)) {
    actual_size = sizeof(collection);
  } else if (mappingp(collection)) {
    actual_size = sizeof(collection);
  } else if (multisetp(collection)) {
    actual_size = sizeof(collection);
  } else {
    _fail(_msg(msg, "assert_has_size: unsupported type %s",
               basetype(collection)), _loc);
    return;
  }
  if (actual_size != expected_size) {
    string type_str = basetype(collection);
    _fail(_msg(msg,
      "Expected %s of size %d but got %d",
      type_str, expected_size, actual_size), _loc);
  }
}

// ── Miscellaneous assertions ────────────────────────────────────────

//! Fail the test unconditionally with the given message.
//!
//! @param msg
//!   Failure message. Defaults to @expr{"Test explicitly failed"}@.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   Always throws.
void assert_fail(void|string msg, void|string _loc) {
  _fail(msg || "Test explicitly failed", _loc);
}


//! Skip the current test with a reason string.
//!
//! Call from within a test method or @expr{setup()@} to immediately
//! mark the test as skipped. The test runner catches the thrown
//! @ref{PUnit.Error.SkipError@} and reports the reason.
//!
//! Typical use: skip tests that depend on an optional module or
//! runtime condition.
//!
//! @param reason
//!   Human-readable skip reason (e.g. @expr{"SQLite module not available"}@).
//! @throws SkipError
//!   Always throws.
//!
//! @code
//! void test_sqlite() {
//!   if (!master()->resolv("Sql.SQLite3"))
//!     skip("SQLite3 module not available");
//!   // ... actual test ...
//! }
//! @endcode
void skip(string reason) {
  throw(SkipError(reason));
}

// ── Type checking assertions ───────────────────────────────────────

//! Assert that @expr{val@} is of type @expr{expected_type@}.
//!
//! @param expected_type
//!   A type string like @expr{"int"@}, @expr{"string"@}, @expr{"array"@},
//!   or a program.
//! @param val
//!   Value to check the type of.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If value does not match the expected type.
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

// ── String matching assertions ─────────────────────────────────────

//! Assert that @expr{str@} matches the regex @expr{pattern@}.
//!
//! @param pattern
//!   Regular expression pattern.
//! @param str
//!   String to test against the pattern.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If string does not match the pattern.
//! @note
//!   Uses Pike's @expr{Regexp@} class for matching.
//! @seealso assert_contains
void assert_match(string pattern, string str, void|string msg, void|string _loc) {
  if (!Regexp(pattern)->match(str))
    _fail(_msg(msg, "Expected %O to match pattern %O", str, pattern), _loc);
}

// ── Numeric tolerance assertions ───────────────────────────────────

//! Assert that @expr{expected@} and @expr{actual@} are within
//! @expr{tolerance@} of each other.
//!
//! @param expected
//!   Expected float value.
//! @param actual
//!   Actual float value to compare.
//! @param tolerance
//!   Maximum allowed absolute difference.
//! @param msg
//!   Optional user message prepended to failure detail.
//! @param _loc
//!   Optional source location (@expr{"file:line"}@); auto-filled by macros.h.
//! @throws AssertionError
//!   If the absolute difference exceeds tolerance.
//! @seealso assert_equal
void assert_approx_equal(float expected, float actual, float tolerance,
                         void|string msg, void|string _loc) {
  float diff = abs(expected - actual);
  if (diff > tolerance)
    _fail(_msg(msg, "Expected %O ≈ %O (tolerance %O, diff %O)",
               expected, actual, tolerance, diff), _loc);
}
