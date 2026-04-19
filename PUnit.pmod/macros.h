//! PUnit assertion macros — automatic __FILE__/__LINE__ injection.
//!
//! Include this header in your test file to get exact source locations
//! in assertion failure messages, instead of backtrace-based guessing.
//!
//! @b{Usage:@}
//! @pre{#include <PUnit.pmod/macros.h>
//! import PUnit;
//!
//! void test_example() {
//!   assert_equal(2, 1 + 1);  // failure will show exact file:line
//! }@}
//!
//! Without this header, assertions still work — locations are inferred
//! from the backtrace. This header just makes them precise.
//!
//! For selective import (only specific assertions in scope), include
//! individual headers instead:
//! @pre{#include <PUnit.pmod/equal.h>      // assert_equal, assert_not_equal
//! #include <PUnit.pmod/boolean.h>    // assert_true, assert_false@}

// Each granular header provides #define macros that wrap PUnit.assert_*()
// calls with automatic __FILE__:__LINE__ injection.

#include <PUnit.pmod/equal.h>
#include <PUnit.pmod/boolean.h>
#include <PUnit.pmod/comparison.h>
#include <PUnit.pmod/null.h>
#include <PUnit.pmod/membership.h>
#include <PUnit.pmod/exception.h>
#include <PUnit.pmod/misc.h>
