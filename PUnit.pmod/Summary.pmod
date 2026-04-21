//! Summary — Shared summary formatting for console reporters.
//!
//! Provides @expr{format_summary@} for DotReporter and VerboseReporter.

//! Format a summary string from an array of suite result mappings.
//!
//! Counts passed/failed/errors/skipped across all suites and formats
//! the standard summary line used by console reporters.
//!
//! @param all_results
//!   Array of suite result mappings, each containing:
//!   @mapping
//!     @member int "passed"
//!     @member int "failed"
//!     @member int "errors"
//!     @member int "skipped"
//!     @member float "elapsed_ms"
//!   @endmapping
//! @returns
//!   Formatted summary string.
//! @seealso DotReporter, VerboseReporter
string format_summary(array all_results) {
  int total_passed = 0, total_failed = 0, total_errors = 0,
      total_skipped = 0;
  float total_ms = 0.0;

  foreach (all_results; ; mapping result) {
    total_passed += result->passed;
    total_failed += result->failed;
    total_errors += result->errors;
    total_skipped += result->skipped;
    total_ms += result->elapsed_ms;
  }

  string summary = sprintf("Results: %d passed", total_passed);
  if (total_failed > 0)
    summary += sprintf(", %d failed", total_failed);
  if (total_errors > 0)
    summary += sprintf(", %d errors", total_errors);
  if (total_skipped > 0)
    summary += sprintf(", %d skipped", total_skipped);
  summary += sprintf(" (%.1fms)", total_ms);

  return summary;
}
