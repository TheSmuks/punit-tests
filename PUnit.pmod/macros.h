//! PUnit assertion macros — automatic __FILE__/__LINE__ injection.
//!
//! Include this header in your test file to get exact source locations
//! in assertion failure messages, instead of backtrace-based guessing.
//!
//! @b{Usage:@}
//! @pre{#include "PUnit.pmod/macros.h"
//! import PUnit;
//!
//! void test_example() {
//!   assert_equal(2, 1 + 1);  // failure will show exact file:line
//! }@}
//!
//! Without this header, assertions still work — locations are inferred
//! from the backtrace. This header just makes them precise.

// Each macro wraps the underlying PUnit function, passing UNDEFINED
// for the optional msg parameter and injecting __FILE__:__LINE__ as _loc.

#define assert_equal(expected, actual) PUnit.assert_equal((expected), (actual), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_not_equal(expected, actual) PUnit.assert_not_equal((expected), (actual), UNDEFINED, __FILE__ + ":" + __LINE__)

#define assert_true(val) PUnit.assert_true((val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_false(val) PUnit.assert_false((val), UNDEFINED, __FILE__ + ":" + __LINE__)

#define assert_null(val) PUnit.assert_null((val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_not_null(val) PUnit.assert_not_null((val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_undefined(val) PUnit.assert_undefined((val), UNDEFINED, __FILE__ + ":" + __LINE__)

#define assert_gt(a, b) PUnit.assert_gt((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_lt(a, b) PUnit.assert_lt((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_gte(a, b) PUnit.assert_gte((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_lte(a, b) PUnit.assert_lte((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)

#define assert_contains(needle, haystack) PUnit.assert_contains((needle), (haystack), UNDEFINED, __FILE__ + ":" + __LINE__)

#define assert_throws(error_type, fn) PUnit.assert_throws((error_type), (fn), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_throws_fn(fn) PUnit.assert_throws_fn((fn), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_no_throw(fn) PUnit.assert_no_throw((fn), UNDEFINED, __FILE__ + ":" + __LINE__)

#define assert_fail(msg) PUnit.assert_fail((msg), __FILE__ + ":" + __LINE__)

#define assert_type(expected_type, val) PUnit.assert_type((expected_type), (val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_match(pattern, str) PUnit.assert_match((pattern), (str), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_approx_equal(expected, actual, tolerance) PUnit.assert_approx_equal((expected), (actual), (tolerance), UNDEFINED, __FILE__ + ":" + __LINE__)
