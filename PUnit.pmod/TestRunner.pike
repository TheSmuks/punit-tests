//! TestRunner — Discovers, orchestrates suites, and manages the CLI.
//!
//! Scans directories for .pike files, compiles them, discovers test classes,
//! builds TestSuite instances, runs them, and reports results.

protected object reporter;
protected array(string) include_tags = ({});
protected array(string) exclude_tags = ({});
protected string method_filter;
protected int stop_on_failure;
protected int verbose;
protected int list_only;
protected int list_verbose;
protected int compilation_errors = 0;
protected int strict;
protected int retry = 0;
protected int timeout = 0;
protected int randomize = 0;
protected int seed = 0;

//! Create a new TestRunner with the given options.
//!
//! @param options
//!   Mapping of configuration options:
//!   @mapping
//!     @member array "tags"
//!       Include tags — run only tests with at least one matching tag.
//!     @member array "exclude_tags"
//!       Exclude tags — skip tests with any matching tag.
//!     @member string "filter"
//!       Glob pattern for method name filtering.
//!     @member int "stop_on_failure"
//!       Stop after first failure.
//!     @member int "verbose"
//!       Use VerboseReporter.
//!     @member int "list_only"
//!       List test names without running.
//!     @member int "list_verbose"
//!       Include tags in listing.
//!     @member int "strict"
//!       Treat validation warnings as errors.
//!     @member int "timeout"
//!       Per-test timeout in seconds.
//!     @member int "randomize"
//!       Randomize test execution order.
//!     @member int "seed"
//!       PRNG seed for reproducible random ordering.
//!     @member string "junit"
//!     @member int "retry"
//!       Retry failed tests up to N times.
//!       File path for JUnit XML output.
//!     @member int "tap"
//!       Use TAP reporter.
//!     @member int "no_color"
//!       Disable ANSI colors.
//!   @endmapping
void create(void|mapping options) {
  if (!options) options = ([]);

  // Ensure the framework directory is in the module and include paths
  // so test files can "import PUnit" and #include "PUnit.pmod/macros.h"
  // when compiled via compile_string.
  string cwd = getcwd();
  master()->add_module_path(cwd);
  master()->add_include_path(cwd);

  include_tags = options->tags || ({});
  exclude_tags = options->exclude_tags || ({});
  method_filter = options->filter;
  stop_on_failure = options->stop_on_failure || 0;
  verbose = options->verbose || 0;
  list_only = options->list_only || 0;
  list_verbose = options->list_verbose || 0;
  strict = options->strict || 0;
  timeout = options->timeout || 0;
  randomize = options->randomize || 0;
  retry = options->retry || 0;
  seed = options->seed || 0;

  // Set up reporter
  if (options->junit) {
    reporter = .JUnitReporter(options->junit);
  } else if (options->tap) {
    reporter = .TAPReporter();
  } else if (verbose) {
    reporter = .VerboseReporter();
  } else {
    reporter = .DotReporter();
  }

  // Handle color
  if (options->no_color) {
    .Colors.set_enabled(0);
  }
}

//! Run tests in the given directories/files.
//! @param paths
//!   Array of file or directory paths to scan.
//! @returns
//!   0 if all tests pass, 1 if any failures/errors.
int run(array(string) paths) {
  if (!paths || sizeof(paths) == 0)
    paths = ({"."});

  // Collect all .pike files
  array(string) files = ({});
  foreach (paths; ; string path) {
    files += _collect_files(path);
  }

  if (sizeof(files) == 0) {
    write("No test files found.\n");
    return 0;
  }

  // Compile and discover test classes
  array suite_specs = ({});

  foreach (files; ; string file) {
    array classes = _discover_in_file(file);
    if (sizeof(classes) > 0) {
      suite_specs += ({ (["file": file, "classes": classes]) });
    }
  }

  if (sizeof(suite_specs) == 0) {
    write("No test classes found.\n");
    return 0;
  }

  // Build suites
  array suites = ({});

  // Initialize random seed once before building suites
  if (randomize) {
    if (!seed) seed = (int)(time() * gethrtime()) & 0x7fffffff;
    werror("Random seed: %d\n", seed);
  }

  foreach (suite_specs; ; mapping spec) {
    string file = spec->file;
    array classes = spec->classes;

    .TestSuite suite = .TestSuite(
      _suite_name(file), reporter,
      include_tags, exclude_tags, method_filter, stop_on_failure, strict,
      timeout, randomize, seed, retry
    );

    foreach (classes; ; mapping class_info) {
      suite->add_class(class_info->instance, class_info->name);
    }
    suites += ({ suite });
  }

  // List-only mode: print test names and exit
  if (list_only) {
    foreach (suites; ; .TestSuite suite) {
      array(mapping) tests = suite->list_tests();
      foreach (tests; ; mapping t) {
        if (list_verbose && sizeof(t->tags) > 0)
          write("%s [%s]\n", t->name, t->tags * ", ");
        else
          write("%s\n", t->name);
      }
    }
    return 0;
  }

  // Run each suite
  array all_results = ({});
  int has_failures = 0;

  foreach (suites; ; .TestSuite suite) {
    if (suite->has_validation_errors())
      has_failures = 1;
    .TestSuite.Results res = suite->run();
    all_results += ({ res });

    if (res->failed > 0 || res->errors > 0)
      has_failures = 1;

    if (stop_on_failure && has_failures)
      break;
  }

  if (compilation_errors > 0)
    has_failures = 1;

  reporter->run_finished(_to_result_maps(all_results));

  return has_failures ? 1 : 0;
}

//! Collect .pike files from a path (file or directory).
//!
//! @param path
//!   File or directory path to scan.
//! @returns
//!   Array of .pike file paths.
protected array(string) _collect_files(string path) {
  if (Stdio.is_file(path)) {
    if (has_suffix(path, ".pike"))
      return ({ path });
    return ({});
  }

  // Directory: recursive scan
  return sort(_scan_dir(path));
}

//! Recursively scan a directory for .pike files.
//!
//! @param dir
//!   Directory path to scan.
//! @returns
//!   Array of .pike file paths found.
protected array(string) _scan_dir(string dir) {
  array(string) entries;
  if (mixed e = catch { entries = get_dir(dir); }) {
    return ({});
  }

  array(string) result = ({});
  foreach (sort(entries); ; string entry) {
    // Skip hidden files/dirs
    if (has_prefix(entry, ".")) continue;

    string full_path = combine_path(dir, entry);

    if (Stdio.is_dir(full_path)) {
      result += _scan_dir(full_path);
    } else if (has_suffix(entry, ".pike")) {
      result += ({ full_path });
    }
  }
  return result;
}

//! Compile a .pike file and discover test classes.
//!
//! @param file
//!   Path to the .pike file to compile and scan.
//! @returns
//!   Array of mappings: ([ "name": class_name, "instance": obj ])
protected array _discover_in_file(string file) {
  string source;
  if (mixed e = catch {
    source = Stdio.read_file(file);
  }) {
    return ({});
  }

  if (!source || sizeof(source) == 0)
    return ({});

  // Compile the file
  program pgm;
  if (mixed e = catch {
    pgm = compile_string(source, file);
  }) {
    // Compilation error — report but don't crash
    werror("Compilation error in %s: %s\n", file, _format_compile_error(e));
    compilation_errors++;
    return ({});
  }

  if (!pgm) return ({});

  // Instantiate and find classes with test methods
  array result = ({});

  // The compiled file itself might be a class with test methods
  object instance;
  if (mixed e = catch { instance = pgm(); }) {
    // Instantiation failed (e.g., abstract class or missing create args)
    // This is expected for contract test files — skip silently
    return ({});
  }

  if (_has_test_methods(instance)) {
    string class_name = _extract_class_name(file);
    result += ({ (["name": class_name, "instance": instance]) });
  }

  // Check for inner classes defined in the file
  // (Pike files can define multiple classes)
  if (mixed err = catch {
    array(string) symbols = indices(instance);
    foreach (symbols; ; string sym) {
      mixed val = instance[sym];
      if (programp(val)) {
        object inner;
        if (mixed ie = catch { inner = val(); }) continue;
        if (_has_test_methods(inner)) {
          result += ({ (["name": sym, "instance": inner]) });
        }
      }
    }
  }) { }

  return result;
}

//! Check if an object has any test_* methods.
//!
//! @param obj
//!   Object to inspect.
//! @returns
//!   Non-zero if the object has any test_* methods.
protected int _has_test_methods(object obj) {
  array(string) indices_list;
  if (mixed e = catch { indices_list = indices(obj); }) return 0;

  foreach (indices_list; ; string name) {
    if (has_prefix(name, "test_")) {
      mixed val;
      if (mixed e = catch { val = obj[name]; }) continue;
      if (functionp(val)) return 1;
    }
  }
  return 0;
}

//! Extract a display name from a file path.
//!
//! @param file
//!   File path to extract name from.
//! @returns
//!   Display name derived from the file's basename.
protected string _extract_class_name(string file) {
  array parts = file / "/";
  string basename = sizeof(parts) > 0 ? parts[-1] : file;
  // Remove .pike extension
  if (has_suffix(basename, ".pike"))
    basename = basename[..<5];
  return basename;
}

//! Generate a suite name from a file path.
//!
//! @param file
//!   File path to generate name from.
//! @returns
//!   Suite name derived from the file path.
protected string _suite_name(string file) {
  return _extract_class_name(file);
}

//! Format a compilation error.
//!
//! @param err
//!   Error value from a @expr{catch@} block.
//! @returns
//!   Human-readable error string.
protected string _format_compile_error(mixed err) {
  if (arrayp(err)) {
    if (sizeof(err) > 0 && stringp(err[0]))
      return err[0];
    return sprintf("%O", err);
  }
  return sprintf("%O", err);
}

//! Convert Results objects to the mapping format expected by run_finished.
//!
//! @param all_results
//!   Array of TestSuite.Results objects.
//! @returns
//!   Array of result mappings with suite_name, passed, failed, errors,
//!   skipped, elapsed_ms, and test_results.
protected array _to_result_maps(array all_results) {
  array result = ({});
  foreach (all_results; ; object r) {
    result += ({ ([
      "suite_name": r->suite_name,
      "passed": r->passed,
      "failed": r->failed,
      "errors": r->errors,
      "skipped": r->skipped,
      "elapsed_ms": r->elapsed_ms,
      "test_results": r->test_results,
    ]) });
  }
  return result;
}
