//! Selective import: equality assertions only.
//!
//! @pre{#include <PUnit.pmod/equal.h>@}
//!
//! Provides: assert_equal, assert_not_equal

#define assert_equal(expected, actual) PUnit.assert_equal((expected), (actual), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_not_equal(expected, actual) PUnit.assert_not_equal((expected), (actual), UNDEFINED, __FILE__ + ":" + __LINE__)
