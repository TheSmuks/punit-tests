//! Selective import: membership/pattern assertions only.
//!
//! @pre{#include <PUnit.pmod/membership.h>@}
//!
//! Provides: assert_contains, assert_match

#define assert_contains(needle, haystack) PUnit.assert_contains((needle), (haystack), UNDEFINED, __FILE__ + ":" + __LINE__)
#define assert_match(pattern, str) PUnit.assert_match((pattern), (str), UNDEFINED, __FILE__ + ":" + __LINE__)
