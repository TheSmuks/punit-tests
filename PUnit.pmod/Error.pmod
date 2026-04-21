//! AssertionError — thrown when an assertion fails.
//!
//! Carries a structured message with optional source location info
//! for reporter formatting. Inherits @expr{Error.Generic@}.
//!
//! @member string assertion_message
//!   Human-readable failure description.
//! @member string location
//!   Source location string (e.g. @tt{"MyTests.pike:42"@}), or empty.
//!
//! @seealso TestResult

//! SkipError — thrown by @expr{skip()@} to abort the current test.
//!
//! The test runner catches this and marks the test as skipped
//! with the provided reason string.
//!
//! @member string skip_reason
//!   The reason the test was skipped.
//!
//! @seealso skip
class SkipError {
  inherit Error.Generic;

  constant is_skip_error = 1;

  string skip_reason;

  //! @param reason
  //!   Skip reason string.
  void create(string reason) {
    skip_reason = reason;
    ::create(reason);
  }

  string _sprintf(int|void fmt) {
    if (fmt == 'O')
      return "SkipError: " + skip_reason;
    return sprintf("SkipError(%O)", skip_reason);
  }
}

class AssertionError {
  inherit Error.Generic;

  constant is_assertion_error = 1;

  string assertion_message;
  string location;

  //! @param msg
  //!   Failure message.
  //! @param loc
  //!   Optional source location string.
  //!
  void create(string msg, void|string loc) {
    assertion_message = msg;
    location = loc || "";
    ::create(msg);
  }

  //! Format the error for display.
  //!
  //! @param fmt
  //!   Format specifier; @expr{'O'@} for human-readable, others for debug.
  //! @returns
  //!   Formatted string representation.
  //!
  string _sprintf(int|void fmt) {
    if (fmt == 'O') {
      string s = "AssertionError: " + assertion_message;
      if (sizeof(location) > 0)
        s += "\n  at " + location;
      return s;
    }
    return sprintf("AssertionError(%O, %O)", assertion_message, location);
  }
}

//! Extract a formatted location string from a Pike backtrace frame.
//!
//! @param frame
//!   A backtrace frame object or array.
//!
//! @returns
//!   A string like @tt{"MyTests.pike:42"@}, or @expr{""@} if unavailable.
string format_location(mixed frame) {
  if (!frame) return "";
  // Pike 8.0 backtrace frames are objects with filename/lineno methods
  if (objectp(frame)) {
    if (functionp(frame->filename))
      return format_location(({ frame->filename(), frame->lineno() }));
    return "";
  }
  if (arrayp(frame) && sizeof(frame) >= 2) {
    string file = frame[0];
    int line = frame[1];
    if (!stringp(file)) return "";
    return basename(file) + ":" + line;
  }
  return "";
}

//! Find the first non-framework frame in a backtrace.
//!
//! Walks the backtrace from the top, skipping frames that originate
//! from within PUnit itself, and returns the formatted location of
//! the first caller frame (typically the test file).
//!
//! @param bt
//!   A backtrace array of frame objects or arrays.
//!
//! @returns
//!   A formatted location string like @tt{"MyTests.pike:42"@}.
string find_caller_location(array bt) {
  if (!bt || !arrayp(bt)) return "";
  foreach (bt; ; mixed frame) {
    string file = _frame_file(frame);
    if (!stringp(file) || sizeof(file) == 0) continue;
    // Skip frames from within PUnit framework
    if (has_prefix(file, "PUnit.pmod/") || has_value(file, "/PUnit.pmod/")) continue;
    // Skip master.pike frames (compilation/runner infrastructure)
    if (has_suffix(file, "master.pike")) continue;
    // Skip eval frames (shown as "-")
    if (file == "-") continue;
    return format_location(frame);
  }
  return "";
}

//! Get the filename from a backtrace frame (object or array).
//! @param frame
//!   A backtrace frame (object or array).
//! @returns
//!   The filename string, or empty string on failure.
//!
protected string _frame_file(mixed frame) {
  if (objectp(frame) && functionp(frame->filename))
    return frame->filename();
  if (arrayp(frame) && sizeof(frame) >= 1 && stringp(frame[0]))
    return frame[0];
  return "";
}
