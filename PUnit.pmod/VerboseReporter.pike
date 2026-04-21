//! VerboseReporter — Console reporter showing each test name with status.
//!
//! One line per test: status icon + test name + timing.
//!
//! @seealso Reporter

inherit .Reporter;

import .Colors;

//! Called when a test suite begins.
//!
//! @param suite_name
//!   Name of the suite.
//! @param num_tests
//!   Number of tests in this suite.
//!
void suite_started(string suite_name, int num_tests) {
  write(bold_cyan(sprintf("[ %s ] (%d tests)\n", suite_name, num_tests)));
}

//! Called when an individual test begins.
//!
//! @param test_name
//!   Name of the test.
//!
void test_started(string test_name) {
  // Nothing — we report at completion
}

//! Called when a test passes.
//!
//! @param test_name
//!   Name of the test.
//! @param elapsed_ms
//!   Execution time in milliseconds.
//!
void test_passed(string test_name, float elapsed_ms) {
  write(sprintf("  %s %s (%.1fms)\n",
                green("✓"), test_name, elapsed_ms));
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
  write(sprintf("  %s %s (%.1fms)\n",
                red("✗"), test_name, elapsed_ms));
  write(sprintf("     %s\n", message));
  if (sizeof(location) > 0)
    write(sprintf("       at %s\n", location));
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
  write(sprintf("  %s %s (%.1fms)\n",
                red("⚡"), test_name, elapsed_ms));
  write(sprintf("     %s\n", message));
  if (sizeof(location) > 0)
    write(sprintf("       at %s\n", location));
}

//! Called when a test is skipped.
//!
//! @param test_name
//!   Name of the test.
//! @param reason
//!   Optional skip reason.
//!
void test_skipped(string test_name, void|string reason) {
  string line = sprintf("  %s %s", yellow("⊘"), test_name);
  if (reason && sizeof(reason) > 0)
    line += sprintf(" (%s)", reason);
  write(line + "\n");
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
  write("\n");
}

//! Called after all suites have finished.
//!
//! @param all_results
//!   Array of suite result mappings.
//!
void run_finished(array all_results) {
  string summary = .Summary.format_summary(all_results);
  int has_issues = 0;
  foreach (all_results; ; mapping result) {
    if (result->failed > 0 || result->errors > 0) { has_issues = 1; break; }
  }
  if (has_issues)
    write(bold_red(summary + "\n"));
  else
    write(bold_green(summary + "\n"));
}
