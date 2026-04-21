//! Selective import: membership/pattern assertions only.
//!
//! @pre{import PUnit.Membership;@}
//!
//! Provides: @expr{assert_contains@}, @expr{assert_match@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_contains", "assert_match" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

array(string) _indices() { return indices(_allowed); }
