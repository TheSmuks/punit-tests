//! VerboseReporter — Console reporter showing each test name with status.
//!
//! One line per test: status icon + test name + timing.

inherit .Reporter;

import .Colors;

void suite_started(string suite_name, int num_tests) {
  write(bold_cyan(sprintf("[ %s ] (%d tests)\n", suite_name, num_tests)));
}

void test_started(string test_name) {
  // Nothing — we report at completion
}

void test_passed(string test_name, float elapsed_ms) {
  write(sprintf("  %s %s (%.1fms)\n",
                green("✓"), test_name, elapsed_ms));
}

void test_failed(string test_name, float elapsed_ms,
                 string message, string location) {
  write(sprintf("  %s %s (%.1fms)\n",
                red("✗"), test_name, elapsed_ms));
  write(sprintf("     %s\n", message));
  if (sizeof(location) > 0)
    write(sprintf("       at %s\n", location));
}

void test_error(string test_name, float elapsed_ms,
                string message, string location) {
  write(sprintf("  %s %s (%.1fms)\n",
                red("⚡"), test_name, elapsed_ms));
  write(sprintf("     %s\n", message));
  if (sizeof(location) > 0)
    write(sprintf("       at %s\n", location));
}

void test_skipped(string test_name, void|string reason) {
  string line = sprintf("  %s %s", yellow("⊘"), test_name);
  if (reason && sizeof(reason) > 0)
    line += sprintf(" (%s)", reason);
  write(line + "\n");
}

void suite_finished(int passed, int failed, int errors,
                    int skipped, float elapsed_ms) {
  write("\n");
}

void run_finished(array all_results) {
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
