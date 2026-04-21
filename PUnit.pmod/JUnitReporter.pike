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

  // Build XML tree
  Parser.XML.Tree.SimpleRootNode root = Parser.XML.Tree.SimpleRootNode();
  root->add_child(Parser.XML.Tree.SimpleHeaderNode((["version": "1.0", "encoding": "UTF-8"])));

  Parser.XML.Tree.SimpleElementNode testsuites =
    Parser.XML.Tree.SimpleElementNode("testsuites", ([
      "name": "PUnit",
      "tests": (string)total_tests,
      "failures": (string)total_failures,
      "errors": (string)total_errors,
      "time": sprintf("%.3f", total_time),
    ]));

  foreach (suite_data; ; mapping s) {
    int s_tests = sizeof(s->test_results);
    int s_failures = 0, s_errors = 0;
    float s_time = s->elapsed_s || 0.0;

    foreach (s->test_results; ; mapping tr) {
      if (tr->status == "fail") s_failures++;
      else if (tr->status == "error") s_errors++;
    }

    Parser.XML.Tree.SimpleElementNode suite_node =
      Parser.XML.Tree.SimpleElementNode("testsuite", ([
        "name": _sanitize(s->name),
        "tests": (string)s_tests,
        "failures": (string)s_failures,
        "errors": (string)s_errors,
        "time": sprintf("%.3f", s_time),
      ]));

    foreach (s->test_results; ; mapping tr) {
      Parser.XML.Tree.SimpleElementNode tc =
        Parser.XML.Tree.SimpleElementNode("testcase", ([
          "name": _sanitize(tr->name),
          "classname": _sanitize(s->name),
          "time": sprintf("%.3f", tr->time),
        ]));

      if (tr->status == "pass") {
        // Empty testcase — self-closing
      } else if (tr->status == "fail") {
        Parser.XML.Tree.SimpleElementNode failure =
          Parser.XML.Tree.SimpleElementNode("failure", ([
            "message": _sanitize(tr->message || ""),
            "type": _sanitize(tr->type || "AssertionError"),
          ]));
        String.Buffer fbuf = String.Buffer();
        fbuf->add(_sanitize(tr->message || ""));
        if (sizeof(tr->location || "") > 0)
          fbuf->add(sprintf("\n          at %s", _sanitize(tr->location)));
        failure->add_child(Parser.XML.Tree.SimpleTextNode(fbuf->get()));
        tc->add_child(failure);
      } else if (tr->status == "error") {
        Parser.XML.Tree.SimpleElementNode error_node =
          Parser.XML.Tree.SimpleElementNode("error", ([
            "message": _sanitize(tr->message || ""),
            "type": _sanitize(tr->type || "Error"),
          ]));
        String.Buffer ebuf = String.Buffer();
        ebuf->add(_sanitize(tr->message || ""));
        if (sizeof(tr->location || "") > 0)
          ebuf->add(sprintf("\n          at %s", _sanitize(tr->location)));
        error_node->add_child(Parser.XML.Tree.SimpleTextNode(ebuf->get()));
        tc->add_child(error_node);
      } else if (tr->status == "skip") {
        tc->add_child(Parser.XML.Tree.SimpleElementNode("skipped", ([])));
      }

      suite_node->add_child(tc);
    }

    testsuites->add_child(suite_node);
  }

  root->add_child(testsuites);
  Stdio.write_file(output_file, root->render_xml());
}

//! Sanitize a string by removing control characters invalid in XML.
//!
//! @param s
//!   Raw string to sanitize.
//! @returns
//!   String with control characters removed (tab, newline, CR preserved).
//! @note
//!   Entity escaping is handled by @expr{Parser.XML.Tree@} automatically.
//!   This only strips characters that are illegal in XML 1.0.
protected string _sanitize(string s) {
  if (!s) return "";
  return (string)filter((array(int))s, lambda(int c) {
    return c >= 0x20 || c == 0x09 || c == 0x0a || c == 0x0d;
  });
}
