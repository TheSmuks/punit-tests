//! TestSuite — Groups test classes for a given file/directory.
//!
//! Manages test discovery within compiled programs, applies tag and method
//! filtering, and executes tests with lifecycle callbacks.

//! Result of running a complete suite.
class Results {
  string suite_name;
  int passed;
  int failed;
  int errors;
  int skipped;
  float elapsed_ms;
  array test_results = ({});
}

//! Information about a discovered test class.
protected string _suite_name;
protected array _classes = ({});
protected object _reporter;
protected array(string) _include_tags = ({});
protected array(string) _exclude_tags = ({});
protected string _method_filter;
protected int _stop_on_failure;
protected int _strict;
protected int _timeout = 0;
protected int _randomize = 0;
protected int _seed = 0;
protected int _prng_state = 0;
protected array(string) _validation_warnings = ({});
void create(string name, object rep,
          void|array(string) inc_tags,
          void|array(string) exc_tags,
          void|string meth_filter,
          void|int stop,
          void|int strict,
          void|int timeout,
          void|int randomize,
          void|int seed) {
  _suite_name = name;
  _reporter = rep;
  _include_tags = inc_tags || ({});
  _exclude_tags = exc_tags || ({});
  _method_filter = meth_filter;
  _stop_on_failure = stop;
  _strict = strict || 0;
  _timeout = timeout || 0;
  _randomize = randomize || 0;
  _seed = seed || 0;
  _prng_state = _seed;
}

//! Add a compiled class to the suite.
//! Discovers test_ methods from the class and its ancestors.
//! Skips classes with skip_all = 1.
void add_class(object test_instance, string class_name) {
  // Check if entire class should be skipped
  int skip_all = 0;
  if (mixed e = catch {
    mixed v = test_instance->skip_all;
    if (v) skip_all = 1;
  }) { }

  if (skip_all) return;

  // Validate class configuration
  array(string) warnings = _validate_class(test_instance, class_name);
  foreach (warnings; ; string w) {
    if (_strict) {
      werror("ERROR: %s\n", w);
    } else {
      werror("WARNING: %s\n", w);
    }
  }
  _validation_warnings += warnings;

  // Discover test methods by inspecting the object's program
  array(string) methods = _discover_test_methods(test_instance);

  if (sizeof(methods) == 0) return;

  // Extract test_data mapping for parameterized tests
  mapping test_data = _get_test_data(test_instance);

  _classes += ({ ([
    "class_name": class_name,
    "instance": test_instance,
    "test_methods": methods,
    "test_data": test_data,
  ]) });
}

//! Validate a test class for common configuration errors.
//! Returns an array of warning strings (empty if no issues).
//! Checks: test_tags/skip_tests/test_data keys that don't match any test method.
protected array(string) _validate_class(object test_instance, string class_name) {
  array(string) warnings = ({});

  // Get the raw method names (without [N] expansion)
  array(string) raw_methods = ({});
  array(string) all_indices;
  if (mixed e = catch { all_indices = indices(test_instance); }) return ({});
  foreach (all_indices; ; string name) {
    if (has_prefix(name, "test_")) {
      mixed val;
      if (mixed err = catch { val = test_instance[name]; }) continue;
      if (functionp(val)) raw_methods += ({ name });
    }
  }
  // Build set of base names (without __tags) for matching
  multiset(string) base_names = (<>);
  foreach (raw_methods; ; string m) base_names[_strip_inline_tags(m)] = 1;
  multiset(string) full_names = (<>);
  foreach (raw_methods; ; string m) full_names[m] = 1;

  // Check test_tags keys
  mapping tags;
  mixed tags_err = catch { mixed v = test_instance->test_tags; if (mappingp(v)) tags = v; };
  if (!tags_err && tags) {
    foreach (indices(tags); ; string key) {
      if (!base_names[key] && !full_names[key])
        warnings += ({ sprintf("test_tags key \"%s\" in %s does not match any test method", key, class_name) });
    }
  }

  // Check skip_tests keys
  multiset skips;
  mixed skips_err = catch { mixed v = test_instance->skip_tests; if (multisetp(v)) skips = v; };
  if (!skips_err && skips) {
    foreach (indices(skips); ; string key) {
      if (!base_names[key] && !full_names[key])
        warnings += ({ sprintf("skip_tests entry \"%s\" in %s does not match any test method", key, class_name) });
    }
  }

  // Check test_data keys
  mapping tdata;
  mixed tdata_err = catch { mixed v = test_instance->test_data; if (mappingp(v)) tdata = v; };
  if (!tdata_err && tdata) {
    foreach (indices(tdata); ; string key) {
      if (!base_names[key] && !full_names[key])
        warnings += ({ sprintf("test_data key \"%s\" in %s does not match any test method", key, class_name) });
    }
  }
  return warnings;
}


//! List all test methods in this suite without running them.
//! Returns an array of mappings with name and tags for each test.
//! Includes parameterized expansions.
array(mapping) list_tests() {
  array(mapping) result = ({});
  foreach (_classes; ; mapping cls) {
    string class_name = cls->class_name;
    object instance = cls->instance;
    mapping explicit_tags = _get_tags(instance);

    foreach (cls->test_methods; ; string method) {
      string base = _base_method(method);
      // Build merged tag list: explicit + inline
      array(string) tags = explicit_tags[base] || explicit_tags[method] || ({});
      foreach (_inline_tags(method); ; string t) {
        if (!has_value(tags, t))
          tags += ({ t });
      }
      result += ({ ([
        "name": class_name + "::" + method,
        "method": method,
        "class_name": class_name,
        "tags": tags,
      ]) });
    }
  }
  return result;
}

//! Check if strict validation produced any errors.
int has_validation_errors() {
  return _strict && sizeof(_validation_warnings) > 0;
}
//! Execute all tests in this suite and return results.
Results run() {
  Results results = Results();
  results->suite_name = _suite_name;

  // Count total tests for the reporter (runnable + skipped)
  int total_tests = 0;
  foreach (_classes; ; mapping cls) {
    foreach (cls->test_methods; ; string method) {
      total_tests++;
    }
  }

  _reporter->suite_started(_suite_name, total_tests);

  float suite_start = gethrtime() / 1000.0;

  foreach (_classes; ; mapping cls) {
    _run_class(cls, results);
    if (_stop_on_failure && (results->failed > 0 || results->errors > 0))
      break;
  }

  float suite_end = gethrtime() / 1000.0;
  results->elapsed_ms = suite_end - suite_start;

  _reporter->suite_finished(results->passed, results->failed,
                            results->errors, results->skipped,
                            results->elapsed_ms);

  return results;
}

//! Discover test_* methods from an object, including inherited ones.
//! Expands parameterized methods into synthetic entries: test_method[0], etc.
protected array(string) _discover_test_methods(object obj) {
  array(string) result = ({});
  // indices() returns all symbols including inherited ones
  array(string) all_indices;
  if (mixed e = catch { all_indices = indices(obj); }) return ({});

  // Collect raw test methods
  array(string) raw_methods = ({});
  foreach (all_indices; ; string name) {
    if (has_prefix(name, "test_")) {
      // Verify it's a function
      mixed val;
      if (mixed err = catch { val = obj[name]; }) continue;
      if (functionp(val)) {
        raw_methods += ({ name });
      }
    }
  }

  // Get test_data for parameterized expansion
  mapping test_data = _get_test_data(obj);

  foreach (raw_methods; ; string name) {
    // Use base name (without __tags) for test_data lookup
    string base = _strip_inline_tags(name);
    if (test_data && !undefinedp(test_data[base]) && arrayp(test_data[base])) {
      array rows = test_data[base];
      for (int i = 0; i < sizeof(rows); i++) {
        result += ({ name + "[" + i + "]" });
      }
    } else {
      result += ({ name });
    }
  }

  // Sort for deterministic order
  result = sort(result);

  // Shuffle if randomized ordering requested
  if (_randomize) {
    // Fisher-Yates shuffle using deterministic PRNG
    for (int i = sizeof(result) - 1; i > 0; i--) {
      _prng_state = (_prng_state * 1103515245 + 12345) & 0x7fffffff;
      int j = _prng_state % (i + 1);
      mixed tmp = result[i];
      result[i] = result[j];
      result[j] = tmp;
    }
  }

  return result;
}

//! Check if a test method should run based on tags, filters, and skips.
//! For parameterized methods (name matches pattern[N]), uses the base name
//! for tag/skip/filter checks. Merges inline tags from __suffixes.
protected int _should_run(object instance, string method_name) {
  string base = _base_method(method_name);
  array(string) inline_tags = _inline_tags(method_name);

  // Check skip_tests multiset
  int is_skipped = 0;
  if (mixed e = catch {
    mixed v = instance->skip_tests;
    if (multisetp(v) && (v[base] || v[method_name]))
      is_skipped = 1;
  }) { }
  if (is_skipped) return 0;

  // Check method filter glob
  if (_method_filter && sizeof(_method_filter) > 0) {
    if (!glob(_method_filter, method_name) && !glob(_method_filter, base))
      return 0;
  }

  // Get merged tags for this method: inline + explicit
  mapping explicit_tags = _get_tags(instance);
  array(string) test_tags = explicit_tags[base] || explicit_tags[method_name] || ({});
  // Merge inline tags (avoid duplicates)
  foreach (inline_tags; ; string t) {
    if (!has_value(test_tags, t))
      test_tags += ({ t });
  }

  // Check include tags: if tags are specified, test must have at least one
  if (sizeof(_include_tags) > 0) {
    int found = 0;
    foreach (_include_tags; ; string tag) {
      if (has_value(test_tags, tag)) {
        found = 1;
        break;
      }
    }
    if (!found) return 0;
  }

  // Check exclude tags: test must not have any excluded tag
  if (sizeof(_exclude_tags) > 0) {
    foreach (_exclude_tags; ; string tag) {
      if (has_value(test_tags, tag))
        return 0;
    }
  }

  return 1;
}

//! Get the test_tags mapping from an instance (or empty mapping).
protected mapping _get_tags(object instance) {
  if (mixed e = catch {
    mixed v = instance->test_tags;
    if (mappingp(v)) return v;
  }) { }
  return ([]);
}

//! Run all tests in a single test class.
protected void _run_class(mapping cls, Results results) {
  object instance = cls->instance;
  string class_name = cls->class_name;
  array(string) methods = cls->test_methods;

  // Call setup_class() if it exists
  if (functionp(instance->setup_class))
    instance->setup_class();

  foreach (methods; ; string method) {
    .TestResult tr = .TestResult(method, class_name);

    if (!_should_run(instance, method)) {
      tr->set_skipped("skipped");
      results->skipped++;
      results->test_results += ({ tr });
      _reporter->test_skipped(class_name + "::" + method, "skipped");
      continue;
    }

    float start = gethrtime() / 1000.0;
    int setup_ok = 1;
    string setup_error = "";

    // Setup
    if (mixed e = catch {
      if (functionp(instance->setup))
        instance->setup();
    }) {
      setup_ok = 0;
      setup_error = _format_error(e);
    }

    if (setup_ok) {
      // Run the test, with optional timeout
      mixed test_error;
      int timed_out = 0;

      if (_timeout > 0) {
        // Thread-based timeout: run test in a thread, poll for completion
        Thread.Mutex done_mtx = Thread.Mutex();
        int test_done = 0;

        Thread.Thread test_thread = Thread.Thread(lambda() {
          mixed err = catch { _invoke_test(instance, method, cls->test_data); };
          Thread.MutexKey key = done_mtx->lock();
          test_error = err;
          test_done = 1;
          destruct(key);
        });

        float deadline = gethrtime() / 1000.0 + (float)_timeout * 1000.0;
        while (1) {
          Thread.MutexKey key = done_mtx->lock();
          if (test_done) { destruct(key); break; }
          destruct(key);
          if (gethrtime() / 1000.0 >= deadline) {
            timed_out = 1;
            break;
          }
          sleep(0.02);
        }
      } else {
        // No timeout — run synchronously
        test_error = catch { _invoke_test(instance, method, cls->test_data); };
      }

      float elapsed = (gethrtime() / 1000.0) - start;

      if (timed_out) {
        // Timed out — report as error
        string msg = sprintf("Test timed out after %ds", _timeout);
        tr->set_error(elapsed, msg, "");
        results->errors++;
        results->test_results += ({ tr });
        _reporter->test_error(class_name + "::" + method, elapsed, msg, "");
      } else if (test_error) {
        // Test threw — determine if it's an assertion failure or error
        string msg = _format_error(test_error);
        string loc = _extract_location(test_error);

        if (_is_assertion_error(test_error)) {
          tr->set_failed(elapsed, msg, loc);
          results->failed++;
          results->test_results += ({ tr });
          _reporter->test_failed(class_name + "::" + method,
                                 elapsed, msg, loc);
        } else {
          tr->set_error(elapsed, msg, loc);
          results->errors++;
          results->test_results += ({ tr });
          _reporter->test_error(class_name + "::" + method,
                                elapsed, msg, loc);
        }
      } else {
        tr->set_passed(elapsed);
        results->passed++;
        results->test_results += ({ tr });
        _reporter->test_passed(class_name + "::" + method, elapsed);
      }
    } else {
      // Setup failed
      float elapsed = (gethrtime() / 1000.0) - start;
      tr->set_error(elapsed, "setup() failed: " + setup_error, "");
      results->errors++;
      results->test_results += ({ tr });
      _reporter->test_error(class_name + "::" + method,
                            elapsed, "setup() failed: " + setup_error, "");
    }

    // Teardown — always runs
    if (mixed te = catch {
      if (functionp(instance->teardown))
        instance->teardown();
    }) {
      // If teardown throws and test was passing, mark as error
      if (tr->is_pass()) {
        string teardown_msg = "teardown() threw: " + _format_error(te);
        tr->set_error(tr->elapsed_ms, teardown_msg,
                      _extract_location(te));
        results->passed--;
        results->errors++;
        results->test_results[-1] = tr;
      }
    }
  }

  // Call teardown_class() if it exists
  if (functionp(instance->teardown_class))
    instance->teardown_class();
}


//! Get the test_data mapping from an instance (or empty mapping).
protected mapping _get_test_data(object instance) {
  if (mixed e = catch {
    mixed v = instance->test_data;
    if (mappingp(v)) return v;
  }) { }
  return ([]);
}

//! Extract the base method name from a (possibly parameterized/inline-tagged) name.
//! Strips [N] parameterized index and __tag inline tag suffixes.
//! "test_foo__math[2]" -> "test_foo", "test_foo[2]" -> "test_foo",
//! "test_foo__math" -> "test_foo", "test_foo" -> "test_foo".
protected string _base_method(string method_name) {
  // First strip [N] suffix
  int bracket = search(method_name, "[");
  if (bracket > 0) method_name = method_name[..bracket - 1];
  // Then strip __tag suffixes
  return _strip_inline_tags(method_name);
}

//! Extract the row index from a parameterized method name, or -1.
protected int _param_index(string method_name) {
  int start = search(method_name, "[");
  if (start < 0) return -1;
  int end = search(method_name, "]", start);
  if (end < 0) return -1;
  string idx_str = method_name[start + 1..end - 1];
  return (int)idx_str;
}

//! Strip inline tag suffixes from a method name.
//! "test_add__math__fast" -> "test_add", "test_add" -> "test_add".
protected string _strip_inline_tags(string method_name) {
  // Look for __ after the initial test_ prefix
  int pos = search(method_name[5..], "__");
  if (pos < 0) return method_name;
  return method_name[..5 + pos - 1];
}

//! Extract inline tags from a method name.
//! "test_add__math__fast" -> ({"math", "fast"}), "test_add" -> ({}).
protected array(string) _inline_tags(string method_name) {
  int pos = search(method_name[5..], "__");
  if (pos < 0) return ({});
  string suffix = method_name[5 + pos + 2..];
  // Filter out empty segments from consecutive __
  return filter(suffix / "__", lambda(string s) { return sizeof(s) > 0; });
}

//! Invoke a test method, handling parameterized dispatch.
//! For parameterized methods (name contains [N]), extracts the actual
//! method name (with __tags preserved) and row data.
protected void _invoke_test(object instance, string method, void|mapping test_data) {
  int idx = _param_index(method);
  if (idx < 0) {
    // Regular method — call directly
    instance[method]();
    return;
  }
  // Strip [N] to get the actual method name (preserving __tags)
  int bracket = search(method, "[");
  string actual_method = method[..bracket - 1];
  // Use base name (without __tags) for test_data lookup
  string base = _base_method(method);
  if (!test_data || undefinedp(test_data[base])) {
    // No data for this method — call without args
    instance[actual_method]();
    return;
  }
  array rows = test_data[base];
  if (idx >= sizeof(rows)) {
    error("Parameterized test index out of range: %O (have %d rows)\n",
          method, sizeof(rows));
  }
  instance[actual_method](rows[idx]);
}

//! Format a Pike error for display.
//! Pike errors can be: string, array({message, backtrace}), or error objects.
protected string _format_error(mixed err) {
  if (stringp(err)) return err;

  if (objectp(err) && err->assertion_message) {
    // Our AssertionError
    return err->assertion_message;
  }

  if (objectp(err) && functionp(err->describe)) {
    return err->describe();
  }

  if (objectp(err) && functionp(err->_sprintf)) {
    return sprintf("%O", err);
  }

  if (objectp(err)) {
    if (functionp(err->message))
      return err->message() || sprintf("%O", err);
    return sprintf("%O", err);
  }

  if (arrayp(err)) {
    // Pike error array: ({ message_string, backtrace })
    // or ({ error_object, backtrace })
    if (sizeof(err) > 0) {
      if (stringp(err[0])) return err[0];
      if (objectp(err[0])) {
        if (err[0]->assertion_message)
          return err[0]->assertion_message;
        return sprintf("%O", err[0]);
      }
    }
    return sprintf("%O", err);
  }

  return sprintf("%O", err);
}

//! Extract source location from an error.
//! Walks the backtrace looking for the test file frame.
//! Collects ALL non-framework frames and returns the last one,
//! which is typically the deepest call site (the test method).
protected string _extract_location(mixed err) {
  // Try to get location from our AssertionError object
  if (objectp(err) && !undefinedp(err->location) &&
      stringp(err->location) && sizeof(err->location) > 0) {
    return err->location;
  }

  // Walk the backtrace from catch error arrays
  if (arrayp(err) && sizeof(err) >= 2 && arrayp(err[1])) {
    array bt = err[1];
    // Collect all non-framework frames
    array(string) candidates = ({});
    foreach (bt; ; mixed frame) {
      string file;
      int|void line;
      if (catch { file = frame[0]; line = frame[1]; }) continue;
      if (!stringp(file) || sizeof(file) == 0) continue;
      if (has_suffix(file, "master.pike")) continue;
      if (file == "-") continue;
      if (has_prefix(file, "PUnit.pmod/") ||
          has_value(file, "/PUnit.pmod/")) continue;
      if (has_suffix(file, "TestSuite.pike")) continue;
      candidates += ({ file + ":" + line });
    }
    // Last candidate is the deepest non-framework call — the test method
    if (sizeof(candidates) > 0)
      return candidates[-1];
  }

  return "";
}

//! Check if an error is an AssertionError from our framework.
protected int _is_assertion_error(mixed err) {
  if (objectp(err))
    return !undefinedp(err->is_assertion_error) && err->is_assertion_error;
  if (arrayp(err) && sizeof(err) > 0 && objectp(err[0]))
    return !undefinedp(err[0]->is_assertion_error) && err[0]->is_assertion_error;
  return 0;
}
