//! Selective import: process helpers only.
//!
//! @pre{import PUnit.Process;@}
//!
//! Provides: @expr{run_process@}
//!
//! This module also re-exports Pike's system @expr{Process@} module so that
//! code calling @expr{Process.run()@} or other system Process functions
//! continues to work after @expr{import PUnit@}.
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

// Re-export Pike's system Process functions so that Process.run() etc.
// are still accessible when import PUnit shadows the system module.
constant _real = Process;

// Forward system Process functions via `[]` while also providing our own.
// Check _allowed first (for run_process), then forward to the real Process module.
mixed `[] (string what) {
  if (_allowed[what]) return _get_value(what);
  return _real[what];
}

// Support both -> and [] access patterns
function `->(string what) { return `[](what); }

constant _allowed = (< "run_process" >);

// Internal method to get values from Assertions for allowed keys.
// Named differently to avoid collision with `[]`.
private mixed _get_value(string what) {
  return ::`[](what);
}

// Return only the allowed keys for selective import behavior.
array(string) _indices() { return indices(_allowed); }
