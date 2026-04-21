//! Selective import: miscellaneous assertions only.
//!
//! @pre{import PUnit.Misc;@}
//!
//! Provides: @expr{assert_fail@}, @expr{assert_type@},
//! @expr{assert_approx_equal@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_fail", "assert_type",
                       "assert_approx_equal" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

array(string) _indices() { return indices(_allowed); }
