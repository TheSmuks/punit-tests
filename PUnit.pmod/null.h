//! Selective import: null/undefined assertions only.
//!
//! @pre{#include <PUnit.pmod/null.h>@}
//!
//! Provides: assert_null, assert_not_null, assert_undefined

#define assert_null(val) PUnit.assert_null((val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_not_null(val) PUnit.assert_not_null((val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_undefined(val) PUnit.assert_undefined((val), UNDEFINED, __FILE__ + ":" + __LINE__)
