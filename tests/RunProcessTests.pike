//! run_process tests — verify the subprocess helper utility.
//!
//! Tests the run_process() function that wraps Process.run() to avoid
//! the Process.Process()->status() footgun (returns process state
//! constant, not exit code).

import PUnit;

// ── Basic exit code capture ────────────────────────────────────────

void test_exit_code_zero() {
  array result = run_process(({"pike", "-e", "exit(0)"}));
  assert_equal(0, result[0]);
}

void test_exit_code_nonzero() {
  array result = run_process(({"pike", "-e", "exit(2)"}));
  assert_equal(2, result[0]);
}

void test_exit_code_one() {
  array result = run_process(({"pike", "-e", "exit(1)"}));
  assert_equal(1, result[0]);
}

// ── Stdout/stderr capture ──────────────────────────────────────────

void test_stdout_capture() {
  array result = run_process(({"pike", "-e", "write(\"hello world\\n\");"}));
  assert_equal(0, result[0]);
  assert_contains("hello world", result[1]);
}

void test_stderr_capture() {
  array result = run_process(({"pike", "-e",
    "Stdio.stderr.write(\"error output\\n\");"}));
  assert_equal(0, result[0]);
  assert_contains("error output", result[2]);
}

void test_empty_output() {
  array result = run_process(({"pike", "-e", "exit(0);"}));
  assert_equal(0, result[0]);
  assert_equal("", result[1]);
  assert_equal("", result[2]);
}

// ── Return value structure ─────────────────────────────────────────

void test_return_is_three_element_array() {
  array result = run_process(({"pike", "-e", "exit(0)"}));
  assert_equal(3, sizeof(result));
  assert_type("int", result[0]);
  assert_type("string", result[1]);
  assert_type("string", result[2]);
}

// ── Error process exit code ────────────────────────────────────────

void test_runtime_error_exit_code() {
  array result = run_process(({"pike", "-e",
    "error(\"something broke\\n\");"}));
  // Pike exits with non-zero code on unhandled error
  assert_true(result[0] != 0, "Expected non-zero exit code for runtime error");
}

// ── With options ───────────────────────────────────────────────────

void test_with_cwd_option() {
  array result = run_process(({"pike", "-e",
    "write(getcwd());"}), (["cwd": "/tmp"]));
  assert_equal(0, result[0]);
  assert_contains("/tmp", result[1]);
}

void test_with_stdin_option() {
  array result = run_process(({"pike", "-e",
    "write(Stdio.stdin.read());"}),
    (["stdin": "piped input data"]));
  assert_equal(0, result[0]);
  assert_contains("piped input data", result[1]);
}

// ── Selective import ───────────────────────────────────────────────

void test_selective_import() {
  // Verify that import PUnit.Subprocess exposes run_process
  // We're already using `import PUnit` here, so we test
  // that the function exists at the PUnit.Subprocess path
  assert_true(functionp(PUnit.Subprocess.run_process));
}

void test_selective_import_does_not_expose_assertions() {
  // PUnit.Subprocess should NOT expose assert_equal etc.
  array available = indices(PUnit.Subprocess);
  assert_true(!has_value(available, "assert_equal"));
  assert_true(!has_value(available, "assert_true"));
}

