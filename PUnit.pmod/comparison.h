//! Selective import: comparison assertions only.
//!
//! @pre{#include <PUnit.pmod/comparison.h>@}
//!
//! Provides: assert_gt, assert_lt, assert_gte, assert_lte

#define assert_gt(a, b) PUnit.assert_gt((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_lt(a, b) PUnit.assert_lt((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_gte(a, b) PUnit.assert_gte((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_lte(a, b) PUnit.assert_lte((a), (b), UNDEFINED, __FILE__ + ":" + __LINE__)
