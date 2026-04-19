//! Reporter — Base class defining the reporter interface.
//!
//! All reporters inherit this and override the callbacks they care about.
//! The runner calls these methods during test execution.

class Reporter {
  //! Called when a test suite begins.
  //! @param suite_name
  //!   Name of the suite (typically the file or class name).
  //! @param num_tests
  //!   Number of tests that will run in this suite.
  void suite_started(string suite_name, int num_tests) { }

  //! Called when an individual test begins.
  void test_started(string test_name) { }

  //! Called when a test passes.
  void test_passed(string test_name, float elapsed_ms) { }

  //! Called when a test fails (assertion error).
  void test_failed(string test_name, float elapsed_ms,
                   string message, string location) { }

  //! Called when a test errors (unexpected exception).
  void test_error(string test_name, float elapsed_ms,
                  string message, string location) { }

  //! Called when a test is skipped.
  void test_skipped(string test_name, void|string reason) { }

  //! Called when a test suite finishes.
  //! @param passed
  //!   Number of passing tests.
  //! @param failed
  //!   Number of failing tests.
  //! @param errors
  //!   Number of errored tests.
  //! @param skipped
  //!   Number of skipped tests.
  //! @param elapsed_ms
  //!   Total elapsed time for this suite in milliseconds.
  void suite_finished(int passed, int failed, int errors,
                      int skipped, float elapsed_ms) { }

  //! Called after all suites have finished.
  //! @param all_results
  //!   Array of suite result mappings, each containing:
  //!   @mapping
  //!     @member string "suite_name"
  //!     @member int "passed"
  //!     @member int "failed"
  //!     @member int "errors"
  //!     @member int "skipped"
  //!     @member float "elapsed_ms"
  //!     @member array "test_results"
  //!   @endmapping
  void run_finished(array all_results) { }
}
