//! Reporter tests — verify reporter interface and basic behavior.

import PUnit;

string _tmp() { return "/tmp/punit_" + random(999999999) + ".xml"; }

void test_dot_reporter_creation() {
  object r = PUnit.DotReporter();
  assert_not_null(r);
  assert_true(functionp(r->suite_started));
  assert_true(functionp(r->test_passed));
  assert_true(functionp(r->test_failed));
  assert_true(functionp(r->test_error));
  assert_true(functionp(r->test_skipped));
  assert_true(functionp(r->suite_finished));
  assert_true(functionp(r->run_finished));
}

void test_verbose_reporter_creation() {
  object r = PUnit.VerboseReporter();
  assert_not_null(r);
  assert_true(functionp(r->suite_started));
  assert_true(functionp(r->test_passed));
  assert_true(functionp(r->test_failed));
}

void test_tap_reporter_creation() {
  object r = PUnit.TAPReporter();
  assert_not_null(r);
  assert_true(functionp(r->suite_started));
  assert_true(functionp(r->test_passed));
  assert_true(functionp(r->test_failed));
}

void test_junit_reporter_creation() {
  string tmp = _tmp();
  object r = PUnit.JUnitReporter(tmp);
  assert_not_null(r);
  assert_true(functionp(r->suite_started));
  assert_true(functionp(r->test_passed));
  rm(tmp);
}

void test_junit_reporter_xml_output() {
  string tmp = _tmp();
  object r = PUnit.JUnitReporter(tmp);
  r->suite_started("TestSuite", 2);
  r->test_passed("test_one", 10.0);
  r->test_failed("test_two", 5.0, "Expected 1", "file.pike:10");
  r->suite_finished(1, 1, 0, 0, 15.0);
  r->run_finished(({
    (["passed": 1, "failed": 1, "errors": 0, "skipped": 0,
      "elapsed_ms": 15.0, "test_results": ({}), "suite_name": "TestSuite"]),
  }));
  string xml = Stdio.read_file(tmp);
  assert_not_null(xml);
  assert_contains("<?xml", xml);
  assert_contains("testsuites", xml);
  assert_contains("test_one", xml);
  assert_contains("test_two", xml);
  assert_contains("failure", xml);
  rm(tmp);
}

void test_junit_reporter_escape() {
  // Test XML escaping of special characters
  string tmp = _tmp();
  object r = PUnit.JUnitReporter(tmp);
  r->suite_started("Suite<>&", 1);
  r->test_failed("test", 1.0, "msg with \"quotes\" and 'apos'", "");
  r->suite_finished(0, 1, 0, 0, 1.0);
  r->run_finished(({
    (["passed": 0, "failed": 1, "errors": 0, "skipped": 0,
      "elapsed_ms": 1.0, "test_results": ({}), "suite_name": "Suite"]),
  }));
  string xml = Stdio.read_file(tmp);
  assert_contains("&lt;", xml);
  assert_contains("&gt;", xml);
  assert_contains("&amp;", xml);
  rm(tmp);
}

void test_reporter_inheritance() {
  // All reporters should inherit PUnit.Reporter
  object dot = PUnit.DotReporter();
  object verbose = PUnit.VerboseReporter();
  object tap = PUnit.TAPReporter();
  assert_true(Program.inherits(object_program(dot), PUnit.Reporter));
  assert_true(Program.inherits(object_program(verbose), PUnit.Reporter));
  assert_true(Program.inherits(object_program(tap), PUnit.Reporter));
}
