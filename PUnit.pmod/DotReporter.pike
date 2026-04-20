//! DotReporter — Default console reporter.
//!
//! Prints one character per test: @expr{.@} (pass), @expr{F@} (fail),
//! @expr{E@} (error), @expr{S@} (skip). After all suites, prints
//! a summary with failure/error details.

inherit .Reporter;

import .Colors;

protected array failures = ({});
protected array errors = ({});
protected int fail_count = 0;
protected int error_count = 0;
protected int skip_count = 0;
protected int pass_count = 0;

protected void _maybe_print_progress() {
  int completed = pass_count + fail_count + error_count + skip_count;
  if (completed > 0 && completed % 50 == 0 && total_tests > 0) {
    write(sprintf(" [%d/%d] ", completed, total_tests));
  }
}
protected int total_tests = 0;

void suite_started(string suite_name, int num_tests) {
  total_tests += num_tests;
}

void test_started(string test_name) {
  // Nothing for dot reporter
}

void test_passed(string test_name, float elapsed_ms) {
  pass_count++;
  write(green("."));
  _maybe_print_progress();
}

void test_failed(string test_name, float elapsed_ms,
                 string message, string location) {
  fail_count++;
  failures += ({ (["test_name": test_name, "message": message,
                   "location": location, "type": "fail"]) });
  write(red("F"));
  _maybe_print_progress();
}

void test_error(string test_name, float elapsed_ms,
                string message, string location) {
  error_count++;
  errors += ({ (["test_name": test_name, "message": message,
                 "location": location, "type": "error"]) });
  write(red("E"));
  _maybe_print_progress();
}

void test_skipped(string test_name, void|string reason) {
  skip_count++;
  write(yellow("S"));
  _maybe_print_progress();
}

void suite_finished(int passed, int failed, int errors,
                    int skipped, float elapsed_ms) {
  // Per-suite nothing extra; we summarize at run_finished
}

void run_finished(array all_results) {
  write("\n\n");

  int total_passed = 0, total_failed = 0, total_errors = 0,
      total_skipped = 0;
  float total_ms = 0.0;

  foreach (all_results; ; mapping result) {
    total_passed += result->passed;
    total_failed += result->failed;
    total_errors += result->errors;
    total_skipped += result->skipped;
    total_ms += result->elapsed_ms;
  }

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
  string summary = sprintf("Results: %d passed", total_passed);
  if (total_failed > 0)
    summary += sprintf(", %d failed", total_failed);
  if (total_errors > 0)
    summary += sprintf(", %d errors", total_errors);
  if (total_skipped > 0)
    summary += sprintf(", %d skipped", total_skipped);
  summary += sprintf(" (%.1fms)", total_ms);

  if (total_failed > 0 || total_errors > 0)
    write(bold_red(summary + "\n"));
  else
    write(bold_green(summary + "\n"));
}
