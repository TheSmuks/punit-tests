//! ANSI color helpers for console output.
//!
//! All functions accept a string and return it wrapped in the
//! appropriate ANSI escape sequence. When colors are disabled,
//! the string is returned unchanged.

protected int _enabled = 1;

//! Enable or disable color output globally.
//!
//! @param enabled
//!   Non-zero to enable, zero to disable.
void set_enabled(int enabled) {
  _enabled = enabled;
}

//! Returns true if color output is currently enabled.
//!
//! @returns
//!   Non-zero if colors are enabled.
int is_enabled() {
  return _enabled;
}

//! Wrap string in bold ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string bold(string s) {
  if (!_enabled) return s;
  return "\e[1m" + s + "\e[0m";
}

//! Wrap string in green ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string green(string s) {
  if (!_enabled) return s;
  return "\e[32m" + s + "\e[0m";
}

//! Wrap string in red ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string red(string s) {
  if (!_enabled) return s;
  return "\e[31m" + s + "\e[0m";
}

//! Wrap string in yellow ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string yellow(string s) {
  if (!_enabled) return s;
  return "\e[33m" + s + "\e[0m";
}

//! Wrap string in cyan ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string cyan(string s) {
  if (!_enabled) return s;
  return "\e[36m" + s + "\e[0m";
}

//! Wrap string in bold green ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string bold_green(string s) {
  if (!_enabled) return s;
  return "\e[1;32m" + s + "\e[0m";
}

//! Wrap string in bold red ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string bold_red(string s) {
  if (!_enabled) return s;
  return "\e[1;31m" + s + "\e[0m";
}

//! Wrap string in bold yellow ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string bold_yellow(string s) {
  if (!_enabled) return s;
  return "\e[1;33m" + s + "\e[0m";
}

//! Wrap string in bold cyan ANSI escape sequence.
//!
//! @param s
//!   The string to style.
//! @returns
//!   The string wrapped in ANSI escape sequences, or unchanged if disabled.
string bold_cyan(string s) {
  if (!_enabled) return s;
  return "\e[1;36m" + s + "\e[0m";
}
