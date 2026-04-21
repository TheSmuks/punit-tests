//! DotReporter — Default console reporter.
//!
//! Prints one character per test: @expr{.@} (pass), @expr{F@} (fail),
//! @expr{E@} (error), @expr{S@} (skip). After all suites, prints
//! a summary with failure/error details.
//!
//! @seealso Reporter

inherit .Reporter;

import .Colors;

protected array failures = ({});
protected array errors = ({});
protected int fail_count = 0;
protected int error_count = 0;
protected int skip_count = 0;
protected int pass_count = 0;

//! Print a progress marker every 50 completed tests.
//!
//! @note Prints progress marker every 50 tests.
//!
protected void _maybe_print_progress() {
  int completed = pass_count + fail_count + error_count + skip_count;
  if (completed > 0 && completed % 50 == 0 && total_tests > 0) {
    write(sprintf(" [%d/%d] ", completed, total_tests));
  }
}
protected int total_tests = 0;

//! Called when a test suite begins.
//!
//! @param suite_name
//!   Name of the suite.
//! @param num_tests
//!   Number of tests in this suite.
//!
//! @note Accumulates @expr{total_tests@} across all suites for progress reporting.
//!
void suite_started(string suite_name, int num_tests) {
  total_tests += num_tests;
}

//! Called when an individual test begins.
//!
//! @note No-op — dot reporter reports at completion.
//!
void test_started(string test_name) {
  // Nothing for dot reporter
}

//! Called when a test passes.
//!
//! @param test_name
//!   Name of the test.
//! @param elapsed_ms
//!   Execution time in milliseconds.
//!
void test_passed(string test_name, float elapsed_ms) {
  pass_count++;
  write(green("."));
  _maybe_print_progress();
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
  fail_count++;
  failures += ({ (["test_name": test_name, "message": message,
                   "location": location, "type": "fail"]) });
  write(red("F"));
  _maybe_print_progress();
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
  error_count++;
  errors += ({ (["test_name": test_name, "message": message,
                 "location": location, "type": "error"]) });
  write(red("E"));
  _maybe_print_progress();
}

//! Called when a test is skipped.
//!
//! @param test_name
//!   Name of the test.
//! @param reason
//!   Optional skip reason.
//!
void test_skipped(string test_name, void|string reason) {
  skip_count++;
  write(yellow("S"));
  _maybe_print_progress();
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
//! @note Per-suite results are accumulated; final summary printed in run_finished.
//!
void suite_finished(int passed, int failed, int errors,
                    int skipped, float elapsed_ms) {
  // Per-suite nothing extra; we summarize at run_finished
}

//! Called after all suites have finished.
//!
//! @param all_results
//!   Array of suite result mappings.
//!
void run_finished(array all_results) {
  write("\n\n");

  // Collect all failures and errors from results
  array all_failures = ({});
  array all_errors = ({});
  foreach (all_results; ; mapping result) {
    if (result->test_results) {
      foreach (result->test_results; ; object tr) {
        if (tr->is_fail())
          all_failures += ({ tr });
        else if (tr->is_error())
          all_errors += ({ tr });
      }
    }
  }

  int issue_num = 0;

  if (sizeof(all_failures) > 0) {
    write(bold_red("Failures:\n"));
    foreach (all_failures; ; object tr) {
      issue_num++;
      write(sprintf("  %d) %s::%s\n", issue_num,
                    tr->class_name, tr->test_name));
      write(sprintf("     %s\n", tr->message));
      if (sizeof(tr->location) > 0)
        write(sprintf("       at %s\n", tr->location));
    }
    write("\n");
  }

  if (sizeof(all_errors) > 0) {
    write(bold_red("Errors:\n"));
    foreach (all_errors; ; object tr) {
      issue_num++;
      write(sprintf("  %d) %s::%s\n", issue_num,
                    tr->class_name, tr->test_name));
      write(sprintf("     %s\n", tr->message));
      if (sizeof(tr->location) > 0)
        write(sprintf("       at %s\n", tr->location));
    }
    write("\n");
  }

  // Summary line
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
