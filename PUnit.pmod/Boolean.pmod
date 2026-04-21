//! Selective import: boolean assertions only.
//!
//! @pre{import PUnit.Boolean;@}
//!
//! Provides: @expr{assert_true@}, @expr{assert_false@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_true", "assert_false" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

array(string) _indices() { return indices(_allowed); }
