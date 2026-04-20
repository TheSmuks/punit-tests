//! TestResult — Records the outcome of a single test method.
//!
//! Each test produces one TestResult with a status (pass/fail/error/skip),
//! optional timing, and failure details.
//!
//! @member string test_name
//!   Name of the test method.
//! @member string class_name
//!   Name of the test class.
//! @member string status
//!   One of STATUS_PASS, STATUS_FAIL, STATUS_ERROR, STATUS_SKIP.
//! @member float elapsed_ms
//!   Test execution time in milliseconds.
//! @member string message
//!   Failure or error message (empty for passes/skips).
//! @member string location
//!   Source location of the failure (e.g. @tt{"MyTests.pike:42"}).
//! @member string skip_reason
//!   Reason for skipping (empty if not skipped).

//! Status constants.
//! @expr{STATUS_PASS@} — test passed.
//! @expr{STATUS_FAIL@} — assertion failure.
//! @expr{STATUS_ERROR@} — unexpected exception.
//! @expr{STATUS_SKIP@} — test was skipped.
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

//! Create a new TestResult.
//!
//! @param test_name_val
//!   Name of the test method.
//! @param class_name_val
//!   Name of the test class.
void create(string test_name_val, string class_name_val) {
  test_name = test_name_val;
  class_name = class_name_val;
  status = STATUS_PASS;
  elapsed_ms = 0.0;
  message = "";
  location = "";
  skip_reason = "";
}

//! Mark this test as passed.
//!
//! @param ms
//!   Elapsed time in milliseconds.
void set_passed(float ms) {
  status = STATUS_PASS;
  elapsed_ms = ms;
}

//! Mark this test as failed (assertion error).
//!
//! @param ms
//!   Elapsed time in milliseconds.
//! @param msg
//!   Failure message.
//! @param loc
//!   Source location string.
void set_failed(float ms, string msg, string loc) {
  status = STATUS_FAIL;
  elapsed_ms = ms;
  message = msg;
  location = loc;
}

//! Mark this test as errored (unexpected exception).
//!
//! @param ms
//!   Elapsed time in milliseconds.
//! @param msg
//!   Error message.
//! @param loc
//!   Source location string.
void set_error(float ms, string msg, string loc) {
  status = STATUS_ERROR;
  elapsed_ms = ms;
  message = msg;
  location = loc;
}

//! Mark this test as skipped.
//!
//! @param reason
//!   Optional skip reason.
void set_skipped(void|string reason) {
  status = STATUS_SKIP;
  skip_reason = reason || "";
}

//! @returns Non-zero if the test passed.
int is_pass() { return status == STATUS_PASS; }
//! @returns Non-zero if the test failed.
int is_fail() { return status == STATUS_FAIL; }
//! @returns Non-zero if the test errored.
int is_error() { return status == STATUS_ERROR; }
//! @returns Non-zero if the test was skipped.
int is_skip() { return status == STATUS_SKIP; }
