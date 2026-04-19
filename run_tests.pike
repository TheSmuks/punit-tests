//! PUnit CLI harness.
//!
//! @code
//! pike -M . run_tests.pike [options] <directories...>
//! @endcode

int main(int argc, array(string) argv) {
  // Parse CLI arguments
  mapping options = ([]);
  array(string) paths = ({});
  array(string) tags = ({});
  array(string) exclude_tags = ({});

  int i = 1;
  while (i < sizeof(argv)) {
    string arg = argv[i];

    if (arg == "-v" || arg == "--verbose") {
      options->verbose = 1;
    } else if (arg == "-s" || arg == "--stop-on-failure") {
      options->stop_on_failure = 1;
    } else if (arg == "--no-color") {
      options->no_color = 1;
    } else if (has_prefix(arg, "--junit=")) {
      options->junit = arg[8..];
    } else if (has_prefix(arg, "--tag=")) {
      tags += ({ arg[6..] });
    } else if (has_prefix(arg, "-t")) {
      // -t TAG or -tTAG
      if (sizeof(arg) > 2)
        tags += ({ arg[2..] });
      else if (i + 1 < sizeof(argv))
        tags += ({ argv[++i] });
    } else if (has_prefix(arg, "--exclude-tag=")) {
      exclude_tags += ({ arg[14..] });
    } else if (has_prefix(arg, "-e")) {
      if (sizeof(arg) > 2)
        exclude_tags += ({ arg[2..] });
      else if (i + 1 < sizeof(argv))
        exclude_tags += ({ argv[++i] });
    } else if (has_prefix(arg, "--filter=")) {
      options->filter = arg[9..];
    } else if (has_prefix(arg, "-f")) {
      if (sizeof(arg) > 2)
        options->filter = arg[2..];
      else if (i + 1 < sizeof(argv))
        options->filter = argv[++i];
    } else if (arg == "--list" || arg == "--list=names") {
      options->list_only = 1;
    } else if (arg == "--list=verbose") {
      options->list_only = 1;
      options->list_verbose = 1;
    } else if (arg == "--strict") {
      options->strict = 1;
    } else if (arg == "--tap") {
      options->tap = 1;
    } else if (arg == "--version") {
      write("PUnit " + PUnit.version + "\n");
      return 0;
    } else if (arg == "--help" || arg == "-h") {
      _usage();
      return 0;
    } else if (!has_prefix(arg, "-")) {
      paths += ({ arg });
    }
    i++;
  }

  options->tags = tags;
  options->exclude_tags = exclude_tags;

  object runner = PUnit.TestRunner(options);
  int exit_code = runner->run(paths);

  return exit_code;
}

void _usage() {
  write("Usage: pike -M . run_tests.pike [options] <directories...>\n"
        "\n"
        "Options:\n"
        "  -v, --verbose          Show each test name with status\n"
        "  -t, --tag=TAG          Run only tests with this tag (repeatable)\n"
        "  -e, --exclude-tag=TAG  Skip tests with this tag (repeatable)\n"
        "  -f, --filter=GLOB      Run only test methods matching glob\n"
        "  -s, --stop-on-failure  Stop after first failure\n"
        "  --list                 List test names without running\n"
        "  --list=verbose         List test names with tags\n"
        "  --strict               Treat validation warnings as errors\n"
        "  --no-color             Disable ANSI colors\n"
        "  --junit=FILE           Write JUnit XML report to FILE\n"
        "  --tap                  Output TAP v13 to stdout\n"
        "  --version              Show version and exit\n"
        "  -h, --help             Show this help\n"
        "\n"
        "Exit code: 0 if all pass, 1 if any failure.\n");
}