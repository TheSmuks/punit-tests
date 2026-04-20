//! Selective import: collection assertions only.
//!
//! @pre{#include <PUnit.pmod/collection.h>@}
//!
//! Provides: assert_each, assert_contains_only, assert_has_size

#define assert_each(items, checker) PUnit.assert_each((items), (checker), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_contains_only(expected, actual) PUnit.assert_contains_only((expected), (actual), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_has_size(collection, expected_size) PUnit.assert_has_size((collection), (expected_size), UNDEFINED, __FILE__ + ":" + __LINE__)
