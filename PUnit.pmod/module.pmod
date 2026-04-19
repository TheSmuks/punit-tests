//! PUnit — JUnit-inspired test framework for Pike.
//!
//! @code
//! import PUnit;
//! inherit PUnit.TestCase;
//!
//! void test_addition() {
//!   assert_equal(2, 1 + 1);
//! }
//! @endcode

// Re-export all assertion functions so that
//   import PUnit;
//   assert_equal(2, 1+1);
// works. In Pike, inherit on a .pmod pulls in its symbols
// as module-level identifiers visible to importers.
inherit .Assertions;
inherit .Version;
