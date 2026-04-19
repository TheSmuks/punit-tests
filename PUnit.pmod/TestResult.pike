//! TestResult — Records the outcome of a single test method.
//!
//! Each test produces one TestResult with a status (pass/fail/error/skip),
//! optional timing, and failure details.

constant STATUS_PASS = "pass";
constant STATUS_FAIL = "fail";
constant STATUS_ERROR = "error";
constant STATUS_SKIP = "skip";

string test_name;
string class_name;
string status;
float elapsed_ms;
string message;
string location;
string skip_reason;

void create(string test_name_val, string class_name_val) {
  test_name = test_name_val;
  class_name = class_name_val;
  status = STATUS_PASS;
  elapsed_ms = 0.0;
  message = "";
  location = "";
  skip_reason = "";
}

void set_passed(float ms) {
  status = STATUS_PASS;
  elapsed_ms = ms;
}

void set_failed(float ms, string msg, string loc) {
  status = STATUS_FAIL;
  elapsed_ms = ms;
  message = msg;
  location = loc;
}

void set_error(float ms, string msg, string loc) {
  status = STATUS_ERROR;
  elapsed_ms = ms;
  message = msg;
  location = loc;
}

void set_skipped(void|string reason) {
  status = STATUS_SKIP;
  skip_reason = reason || "";
}

int is_pass() { return status == STATUS_PASS; }
int is_fail() { return status == STATUS_FAIL; }
int is_error() { return status == STATUS_ERROR; }
int is_skip() { return status == STATUS_SKIP; }
