//! TAPReporter — Test Anything Protocol v13 output.
//!
//! Machine-readable text format widely supported by CI systems.
//! Output goes to stdout.
//!
//! @seealso Reporter

inherit .Reporter;

protected int test_counter = 0;
protected int planned_tests = 0;
protected int header_written = 0;

//! Called when a test suite begins.
//!
//! @param suite_name
//!   Name of the suite.
//! @param num_tests
//!   Number of tests in this suite.
//!
//! @note Accumulates @expr{planned_tests@} across all suites.
//!
void suite_started(string suite_name, int num_tests) {
  if (!header_written) {
    write("TAP version 13\n");
    header_written = 1;
  }
  planned_tests += num_tests;
}

//! Called when an individual test begins.
//!
//! @param test_name
//!   Name of the test.
//!
void test_started(string test_name) { }

//! Called when a test passes.
//!
//! @param test_name
//!   Name of the test.
//! @param elapsed_ms
//!   Execution time in milliseconds.
//!
void test_passed(string test_name, float elapsed_ms) {
  test_counter++;
  write(sprintf("ok %d - %s\n", test_counter, test_name));
}

//! Called when a test fails (assertion error).
//!
//! @param test_name
//!   Name of the test.
//! @param elapsed_ms
//!   Execution time in milliseconds.
//! @param message
//!   Failure message.
//! @param location
//!   File and line where the failure occurred.
//!
void test_failed(string test_name, float elapsed_ms,
                 string message, string location) {
  test_counter++;
  write(sprintf("not ok %d - %s\n", test_counter, test_name));
  write("  ---\n");
  write(sprintf("  message: %q\n", message));
  write("  severity: fail\n");
  if (sizeof(location) > 0)
    write(sprintf("  location: %q\n", location));
  write("  ...\n");
}

//! Called when a test errors (unexpected exception).
//!
//! @param test_name
//!   Name of the test.
//! @param elapsed_ms
//!   Execution time in milliseconds.
//! @param message
//!   Error message.
//! @param location
//!   File and line where the error occurred.
//!
void test_error(string test_name, float elapsed_ms,
                string message, string location) {
  test_counter++;
  write(sprintf("not ok %d - %s\n", test_counter, test_name));
  write("  ---\n");
  write(sprintf("  message: %q\n", message));
  write("  severity: error\n");
  if (sizeof(location) > 0)
    write(sprintf("  location: %q\n", location));
  write("  ...\n");
}

//! Called when a test is skipped.
//!
//! @param test_name
//!   Name of the test.
//! @param reason
//!   Optional skip reason.
//!
void test_skipped(string test_name, void|string reason) {
  test_counter++;
  write(sprintf("ok %d - %s # SKIP", test_counter, test_name));
  if (reason && sizeof(reason) > 0)
    write(" " + reason);
  write("\n");
}

//! Called when a test suite finishes.
//!
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
//!
void suite_finished(int passed, int failed, int errors,
                    int skipped, float elapsed_ms) {
  // Per-suite nothing extra
}

//! Called after all suites have finished.
//!
//! @param all_results
//!   Array of suite result mappings.
//!
//! @note Emits the TAP plan line @expr{1..N@}.
//!
void run_finished(array all_results) {
  write(sprintf("1..%d\n", planned_tests));
}
