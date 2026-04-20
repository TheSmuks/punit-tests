//! JUnitReporter — Produces JUnit XML output for CI/CD integration.
//!
//! Consumed by Jenkins, GitLab, GitHub Actions (dorny/test-reporter),
//! Azure DevOps, CircleCI, and most CI systems.
//!
//! @seealso Reporter

inherit .Reporter;

protected string output_file;
protected array suite_data = ({});

//! Create a JUnitReporter that writes to a file.
//!
//! @param file
//!   Output file path for the XML report.
//!
void create(string file) {
  output_file = file;
}

//! Called when a test suite begins.
//!
//! @param suite_name
//!   Name of the suite.
//! @param num_tests
//!   Number of tests in this suite.
//!
void suite_started(string suite_name, int num_tests) {
  // Track current suite
  suite_data += ({ ([
    "name": suite_name,
    "num_tests": num_tests,
    "test_results": ({ }),
    "start_time": gethrtime() / 1000.0,
  ]) });
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
  if (sizeof(suite_data) == 0) return;
  mapping current = suite_data[-1];
  current->test_results += ({ ([
    "name": test_name, "status": "pass",
    "time": elapsed_ms / 1000.0,
  ]) });
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
  if (sizeof(suite_data) == 0) return;
  mapping current = suite_data[-1];
  current->test_results += ({ ([
    "name": test_name, "status": "fail",
    "time": elapsed_ms / 1000.0,
    "message": message, "location": location,
    "type": "AssertionError",
  ]) });
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
  if (sizeof(suite_data) == 0) return;
  mapping current = suite_data[-1];
  current->test_results += ({ ([
    "name": test_name, "status": "error",
    "time": elapsed_ms / 1000.0,
    "message": message, "location": location,
    "type": "Error",
  ]) });
}

//! Called when a test is skipped.
//!
//! @param test_name
//!   Name of the test.
//! @param reason
//!   Optional skip reason.
//!
void test_skipped(string test_name, void|string reason) {
  if (sizeof(suite_data) == 0) return;
  mapping current = suite_data[-1];
  current->test_results += ({ ([
    "name": test_name, "status": "skip",
    "time": 0.0,
    "message": reason || "",
  ]) });
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
  if (sizeof(suite_data) == 0) return;
  mapping current = suite_data[-1];
  current->passed = passed;
  current->failed = failed;
  current->errors = errors;
  current->skipped = skipped;
  current->elapsed_s = elapsed_ms / 1000.0;
}

//! Called after all suites have finished.
//!
//! @param all_results
//!   Array of suite result mappings.
//!
void run_finished(array all_results) {
  String.Buffer buf = String.Buffer();
  buf->add("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");

  // Calculate totals
  int total_tests = 0, total_failures = 0, total_errors = 0;
  float total_time = 0.0;

  foreach (suite_data; ; mapping s) {
    total_tests += sizeof(s->test_results);
    foreach (s->test_results; ; mapping tr) {
      if (tr->status == "fail") total_failures++;
      else if (tr->status == "error") total_errors++;
    }
    total_time += s->elapsed_s || 0.0;
  }

  buf->add(sprintf(
    "<testsuites name=\"PUnit\" tests=\"%d\" failures=\"%d\" "
    "errors=\"%d\" time=\"%.3f\">\n",
    total_tests, total_failures, total_errors, total_time));

  foreach (suite_data; ; mapping s) {
    int s_tests = sizeof(s->test_results);
    int s_failures = 0, s_errors = 0;
    float s_time = s->elapsed_s || 0.0;

    foreach (s->test_results; ; mapping tr) {
      if (tr->status == "fail") s_failures++;
      else if (tr->status == "error") s_errors++;
    }

    buf->add(sprintf(
      "  <testsuite name=\"%s\" tests=\"%d\" failures=\"%d\" "
      "errors=\"%d\" time=\"%.3f\">\n",
      _xml_escape(s->name), s_tests, s_failures, s_errors, s_time));

    foreach (s->test_results; ; mapping tr) {
      string classname = s->name;
      buf->add(sprintf(
        "    <testcase name=\"%s\" classname=\"%s\" time=\"%.3f\"",
        _xml_escape(tr->name), _xml_escape(classname), tr->time));

      if (tr->status == "pass") {
        buf->add("/>\n");
      } else if (tr->status == "fail") {
        buf->add(sprintf(">\n      <failure message=\"%s\" type=\"%s\">\n",
                         _xml_escape(tr->message || ""),
                         _xml_escape(tr->type || "AssertionError")));
        buf->add(sprintf("        %s\n",
                         _xml_escape(tr->message || "")));
        if (sizeof(tr->location || "") > 0)
          buf->add(sprintf("          at %s\n",
                           _xml_escape(tr->location)));
        buf->add("      </failure>\n    </testcase>\n");
      } else if (tr->status == "error") {
        buf->add(sprintf(">\n      <error message=\"%s\" type=\"%s\">\n",
                         _xml_escape(tr->message || ""),
                         _xml_escape(tr->type || "Error")));
        buf->add(sprintf("        %s\n",
                         _xml_escape(tr->message || "")));
        if (sizeof(tr->location || "") > 0)
          buf->add(sprintf("          at %s\n",
                           _xml_escape(tr->location)));
        buf->add("      </error>\n    </testcase>\n");
      } else if (tr->status == "skip") {
        buf->add(">\n      <skipped/>\n    </testcase>\n");
      }
    }

    buf->add("  </testsuite>\n");
  }

  buf->add("</testsuites>\n");

  Stdio.write_file(output_file, buf->get());
}

//! Escape a string for safe inclusion in XML attribute values and text.
//!
//! @param s
//!   Raw string to escape.
//! @returns
//!   XML-safe string with entities escaped and control chars removed.
protected string _xml_escape(string s) {
  if (!s) return "";
  s = replace(s, ({"&", "<", ">", "\"", "'"}),
              ({"&amp;", "&lt;", "&gt;", "&quot;", "&apos;"}));
  // Remove control characters except tab, newline, carriage return
  string result = "";
  foreach (s; int i; int c) {
    if (c >= 0x20 || c == 0x09 || c == 0x0a || c == 0x0d)
      result += sprintf("%c", c);
  }
  return result;
}
