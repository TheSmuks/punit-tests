//! TestCase — Base class for PUnit test classes.
//!
//! Users @expr{inherit PUnit.TestCase;@} to get lifecycle hooks.
//! The runner discovers any class with @expr{test_*@} methods via
//! duck-typing; this base class is only needed for lifecycle support.
//!
//! @dl
//!  @item setup_class()
//!    Called once before any test methods in this class.
//!  @item teardown_class()
//!    Called once after all test methods in this class.
//!  @item setup()
//!    Called before each test method.
//!  @item teardown()
//!    Called after each test method, even if setup or the test throws.
//! @enddl
//!
//! @defines
//!  @item test_tags
//!    Optional constant: @expr{([ "test_xxx": ({"tag1", "tag2"}) ])@}
//!  @item skip_tests
//!    Optional constant: @expr{(< "test_broken_thing" >)@}
//!  @item skip_all
//!    Optional constant: @expr{true@} to skip the entire class.
//! @enddefines

class TestCase {
  //! Called once before all test methods in this class.
  void setup_class() { }

  //! Called once after all test methods in this class.
  void teardown_class() { }

  //! Called before each test method.
  void setup() { }

  //! Called after each test method (even on failure).
  void teardown() { }
}
