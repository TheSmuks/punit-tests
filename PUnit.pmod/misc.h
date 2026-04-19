//! Selective import: miscellaneous assertions only.
//!
//! @pre{#include <PUnit.pmod/misc.h>@}
//!
//! Provides: assert_fail, assert_type, assert_approx_equal

#define assert_fail(msg) PUnit.assert_fail((msg), __FILE__ + ":" + __LINE__)

#define assert_type(expected_type, val) PUnit.assert_type((expected_type), (val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_approx_equal(expected, actual, tolerance) PUnit.assert_approx_equal((expected), (actual), (tolerance), UNDEFINED, __FILE__ + ":" + __LINE__)
