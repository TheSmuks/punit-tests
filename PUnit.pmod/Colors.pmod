//! ANSI color helpers for console output.
//!
//! All functions accept a string and return it wrapped in the
//! appropriate ANSI escape sequence. When colors are disabled,
//! the string is returned unchanged.

protected int _enabled = 1;

//! Enable or disable color output globally.
void set_enabled(int enabled) {
  _enabled = enabled;
}

//! Returns true if color output is currently enabled.
int is_enabled() {
  return _enabled;
}

string bold(string s) {
  if (!_enabled) return s;
  return "\e[1m" + s + "\e[0m";
}

string green(string s) {
  if (!_enabled) return s;
  return "\e[32m" + s + "\e[0m";
}

string red(string s) {
  if (!_enabled) return s;
  return "\e[31m" + s + "\e[0m";
}

string yellow(string s) {
  if (!_enabled) return s;
  return "\e[33m" + s + "\e[0m";
}

string cyan(string s) {
  if (!_enabled) return s;
  return "\e[36m" + s + "\e[0m";
}

string bold_green(string s) {
  if (!_enabled) return s;
  return "\e[1;32m" + s + "\e[0m";
}

string bold_red(string s) {
  if (!_enabled) return s;
  return "\e[1;31m" + s + "\e[0m";
}

string bold_yellow(string s) {
  if (!_enabled) return s;
  return "\e[1;33m" + s + "\e[0m";
}

string bold_cyan(string s) {
  if (!_enabled) return s;
  return "\e[1;36m" + s + "\e[0m";
}
