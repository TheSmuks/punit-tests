//! Selective import: exception assertions only.
//!
//! @pre{#include <PUnit.pmod/exception.h>@}
//!
//! Provides: assert_throws, assert_throws_fn, assert_no_throw

#define assert_throws(error_type, fn) PUnit.assert_throws((error_type), (fn), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_throws_fn(fn) PUnit.assert_throws_fn((fn), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_no_throw(fn) PUnit.assert_no_throw((fn), UNDEFINED, __FILE__ + ":" + __LINE__)
