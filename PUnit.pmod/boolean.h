//! Selective import: boolean assertions only.
//!
//! @pre{#include <PUnit.pmod/boolean.h>@}
//!
//! Provides: assert_true, assert_false

#define assert_true(val) PUnit.assert_true((val), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_false(val) PUnit.assert_false((val), UNDEFINED, __FILE__ + ":" + __LINE__)
