//! TAPReporter — Test Anything Protocol v13 output.
//!
//! Machine-readable text format widely supported by CI systems.
//! Output goes to stdout.

inherit .Reporter;

protected int test_counter = 0;
protected int planned_tests = 0;
protected int header_written = 0;

void suite_started(string suite_name, int num_tests) {
  if (!header_written) {
    write("TAP version 13\n");
    header_written = 1;
  }
  planned_tests += num_tests;
}

void test_started(string test_name) { }

void test_passed(string test_name, float elapsed_ms) {
  test_counter++;
  write(sprintf("ok %d - %s\n", test_counter, test_name));
}

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

void test_skipped(string test_name, void|string reason) {
  test_counter++;
  write(sprintf("ok %d - %s # SKIP", test_counter, test_name));
  if (reason && sizeof(reason) > 0)
    write(" " + reason);
  write("\n");
}

void suite_finished(int passed, int failed, int errors,
                    int skipped, float elapsed_ms) {
  // Per-suite nothing extra
}

void run_finished(array all_results) {
  write(sprintf("1..%d\n", planned_tests));
}
