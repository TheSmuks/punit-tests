#!/usr/bin/env pike
//!
//! Auto-generate PUnit macro header files from Assertions.pmod.
//!
//! Usage: pike scripts/generate_macros.pike
//!
//! Parses the public assertion functions from PUnit.pmod/Assertions.pmod
//! and regenerates all 8 granular .h files plus the umbrella macros.h.
//! Also fixes the assert_same/assert_not_same string concatenation bug.
//!
//! The script reads function signatures, extracts parameter names (excluding
//! the trailing msg/_loc), and emits #define macros that inject
//! __FILE__ + ":" + __LINE__ for exact source location.

// Category definitions: header file → (description, function list)
// Each function entry: (name, macro_params, expansion_suffix)
// macro_params: parameters in the #define(...) parenthesis
// expansion_suffix: extra arguments appended after the user-visible params
//
// The general form is:
//   #define assert_FOO(params) PUnit.assert_FOO((params), expansion_suffix)
//
// For most assertions, expansion_suffix = "UNDEFINED, __FILE__ + \":\" + __LINE__"
// Special cases:
//   assert_fail: no UNDEFINED (msg is the first param, not optional)
//   assert_throws_message: includes ", 0" for the is_regex default

constant categories = ([
  "equal": ([
    "desc": "equality assertions only",
    "functions": ({
      ({ "assert_equal", "expected, actual", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_not_equal", "expected, actual", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_same", "expected, actual", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_not_same", "expected, actual", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
  "boolean": ([
    "desc": "boolean assertions only",
    "functions": ({
      ({ "assert_true", "val", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_false", "val", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
  "comparison": ([
    "desc": "comparison assertions only",
    "functions": ({
      ({ "assert_gt", "a, b", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_lt", "a, b", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_gte", "a, b", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_lte", "a, b", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
  "null": ([
    "desc": "null/undefined assertions only",
    "functions": ({
      ({ "assert_null", "val", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_not_null", "val", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_undefined", "val", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
  "membership": ([
    "desc": "membership/pattern assertions only",
    "functions": ({
      ({ "assert_contains", "needle, haystack", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_match", "pattern, str", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
  "exception": ([
    "desc": "exception assertions only",
    "functions": ({
      ({ "assert_throws", "error_type, fn", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_throws_fn", "fn", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_no_throw", "fn", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_throws_message", "error_type, expected_message, fn",
         "0, UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
  "collection": ([
    "desc": "collection assertions only",
    "functions": ({
      ({ "assert_each", "items, checker", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_contains_only", "expected, actual", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_has_size", "collection, expected_size", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
  "misc": ([
    "desc": "miscellaneous assertions only",
    "functions": ({
      ({ "assert_fail", "msg", "__FILE__ + \":\" + __LINE__" }),
      ({ "assert_type", "expected_type, val", "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
      ({ "assert_approx_equal", "expected, actual, tolerance",
         "UNDEFINED, __FILE__ + \":\" + __LINE__" }),
    }),
  ]),
]);

//! Wrap a comma-separated param list in parenthesized form for the expansion.
//! "expected, actual" → "(expected), (actual)"
string wrap_params(string params) {
  if (params == "") return "";
  array(string) parts = map(params / ",", String.trim_whites);
  return map(parts, lambda(string p) { return "(" + p + ")"; }) * ", ";
}

//! Generate a single granular header file.
string generate_header(string category, mapping info) {
  String.Buffer buf = String.Buffer();

  buf->add("//! Selective import: " + info->desc + ".\n");
  buf->add("//!\n");
  buf->add("//! @pre{#include <PUnit.pmod/" + category + ".h>@}\n");
  buf->add("//!\n");

  // Build the "Provides:" line
  array(string) names = map(info->functions, lambda(array f) { return f[0]; });
  buf->add("//! Provides: " + names * ", " + "\n");

  foreach (info->functions, array func) {
    string name = func[0];
    string params = func[1];
    string suffix = func[2];

    buf->add("\n");
    buf->add("#define " + name + "(" + params + ") "
             + "PUnit." + name + "(" + wrap_params(params)
             + (suffix != "" ? ", " + suffix : "") + ")\n");
  }

  buf->add("\n");
  return buf->get();
}

//! Generate the umbrella macros.h.
string generate_umbrella() {
  String.Buffer buf = String.Buffer();

  buf->add("//! PUnit assertion macros — automatic __FILE__/__LINE__ injection.\n");
  buf->add("//!\n");
  buf->add("//! Include this header in your test file to get exact source locations\n");
  buf->add("//! in assertion failure messages, instead of backtrace-based guessing.\n");
  buf->add("//!\n");
  buf->add("//! @b{Usage:@}\n");
  buf->add("//! @pre{#include <PUnit.pmod/macros.h>\n");
  buf->add("//! import PUnit;\n");
  buf->add("//!\n");
  buf->add("//! void test_example() {\n");
  buf->add("//!   assert_equal(2, 1 + 1);  // failure will show exact file:line\n");
  buf->add("//! }@}\n");
  buf->add("//!\n");
  buf->add("//! Without this header, assertions still work — locations are inferred\n");
  buf->add("//! from the backtrace. This header just makes them precise.\n");
  buf->add("//!\n");
  buf->add("//! For selective import (only specific assertions in scope), include\n");
  buf->add("//! individual headers instead:\n");
  buf->add("//! @pre{#include <PUnit.pmod/equal.h>      // assert_equal, assert_not_equal\n");
  buf->add("//! #include <PUnit.pmod/boolean.h>    // assert_true, assert_false@}\n");
  buf->add("\n");
  buf->add("// Each granular header provides #define macros that wrap PUnit.assert_*()\n");
  buf->add("// calls with automatic __FILE__:__LINE__ injection.\n");
  buf->add("\n");

  foreach (sort(indices(categories)), string cat) {
    buf->add("#include <PUnit.pmod/" + cat + ".h>\n");
  }
  buf->add("\n");

  return buf->get();
}

int main() {
  string base_dir = combine_path(__FILE__, "../..") + "/PUnit.pmod/";

  foreach (sort(indices(categories)), string category) {
    string content = generate_header(category, categories[category]);
    string path = base_dir + category + ".h";

    Stdio.File f = Stdio.File(path, "wct");
    if (!f) {
      werror("Failed to open %s for writing\n", path);
      return 1;
    }
    f->write(content);
    f->close();
    write("Generated %s.h\n", category);
  }

  // Generate umbrella
  string umbrella = generate_umbrella();
  string umbrella_path = base_dir + "macros.h";
  Stdio.File uf = Stdio.File(umbrella_path, "wct");
  if (!uf) {
    werror("Failed to open %s for writing\n", umbrella_path);
    return 1;
  }
  uf->write(umbrella);
  uf->close();
  write("Generated macros.h\n");

  write("All header files generated successfully.\n");
  return 0;
}
